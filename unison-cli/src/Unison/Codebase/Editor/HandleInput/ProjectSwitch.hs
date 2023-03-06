-- | @project.switch@ input handler
module Unison.Codebase.Editor.HandleInput.ProjectSwitch
  ( projectSwitch,
  )
where

import Control.Lens (over, view, (^.))
import qualified Data.Text as Text
import Data.These (These (..))
import qualified Data.UUID.V4 as UUID
import U.Codebase.Sqlite.DbId
import qualified U.Codebase.Sqlite.Queries as Queries
import Unison.Cli.Monad (Cli)
import qualified Unison.Cli.Monad as Cli
import qualified Unison.Cli.MonadUtils as Cli (getBranch0At, stepAt)
import Unison.Cli.ProjectUtils (getCurrentProjectBranch, loggeth, projectBranchPath)
import qualified Unison.Codebase.Path as Path
import Unison.Prelude
import Unison.Project (ProjectAndBranch (..), ProjectBranchName, ProjectName)
import qualified Unison.Sqlite as Sqlite
import Witch (unsafeFrom)

-- | Switch to (or create) a project or project branch.
projectSwitch :: These ProjectName ProjectBranchName -> Cli ()
projectSwitch = \case
  These projectName branchName -> switchToProjectAndBranch (ProjectAndBranch projectName branchName)
  This projectName -> switchToProjectAndBranch (ProjectAndBranch projectName (unsafeFrom @Text "main"))
  That branchName -> do
    projectAndBranch <-
      getCurrentProjectBranch & onNothingM do
        loggeth ["Not currently on a branch"]
        Cli.returnEarlyWithoutOutput
    let projectId = projectAndBranch ^. #project
    project <- Cli.runTransaction (Queries.expectProject projectId)
    let projectName = unsafeFrom @Text (project ^. #name)
    switchToProjectAndBranch2
      (ProjectAndBranch (projectId, projectName) branchName)
      (Just (projectAndBranch ^. #branch))

-- Switch to a project+branch.
switchToProjectAndBranch :: ProjectAndBranch ProjectName ProjectBranchName -> Cli ()
switchToProjectAndBranch projectAndBranch = do
  project <- do
    let projectName = into @Text (projectAndBranch ^. #project)
    Cli.runTransaction (Queries.loadProjectByName projectName) & onNothingM do
      loggeth ["no such project"]
      Cli.returnEarlyWithoutOutput
  let projectId = project ^. #projectId
  maybeCurrentBranchId <- fmap (view #branch) <$> getCurrentProjectBranch
  switchToProjectAndBranch2 (over #project (projectId,) projectAndBranch) maybeCurrentBranchId

data SwitchToBranchOutcome
  = SwitchedToExistingBranch
  | SwitchedToNewBranchFrom ProjectBranchId -- id of branch we switched from

-- Switch to a project+branch.
switchToProjectAndBranch2 ::
  ProjectAndBranch (ProjectId, ProjectName) ProjectBranchName ->
  Maybe ProjectBranchId ->
  Cli ()
switchToProjectAndBranch2 (ProjectAndBranch (projectId, projectName) branchName) maybeCurrentBranchId = do
  (outcome, newBranchId) <-
    Cli.runTransaction do
      Queries.loadProjectBranchByName projectId (into @Text branchName) >>= \case
        Nothing -> do
          newBranchId <- Sqlite.unsafeIO (ProjectBranchId <$> UUID.nextRandom)
          Queries.insertProjectBranch projectId newBranchId (into @Text branchName)
          fromBranchId <-
            case maybeCurrentBranchId of
              Just currentBranchId -> pure currentBranchId
              Nothing -> do
                -- For now, we treat switching to a new branch from outside of that project as equivalent to switching
                -- to a new branch from the branch called "main" in that project. Eventually, we should probably instead
                -- use the default project branch
                Queries.loadProjectBranchByName projectId "main" >>= \case
                  Nothing ->
                    error $
                      reportBug "E469471" $
                        "No branch called 'main' in project "
                          ++ Text.unpack (into @Text projectName)
                          ++ " (id = "
                          ++ show projectId
                          ++ "). We (currently) assume the existence of such a branch."
                  Just branch -> pure (branch ^. #branchId)
          Queries.markProjectBranchChild projectId fromBranchId newBranchId
          pure (SwitchedToNewBranchFrom fromBranchId, newBranchId)
        Just branch -> pure (SwitchedToExistingBranch, branch ^. #branchId)
  let path = projectBranchPath (ProjectAndBranch projectId newBranchId)
  case outcome of
    SwitchedToExistingBranch -> loggeth ["I just switched to an existing branch"]
    SwitchedToNewBranchFrom fromBranchId -> do
      fromBranch <- Cli.getBranch0At (projectBranchPath (ProjectAndBranch projectId fromBranchId))
      Cli.stepAt "project.switch" (Path.unabsolute path, const fromBranch)
      loggeth ["I just created a new branch"]
  Cli.cd path
