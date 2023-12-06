\(_stackage-resolver : Optional Text) ->
  ''
  user-message: "WARNING: This stack project is generated."

  flags:
    haskeline:
      terminfo: false

  allow-different-user: true

  build:
    interleaved-output: false

  ghc-options:
    # All packages
    "$locals": -Wall -Werror -Wno-name-shadowing -Wno-missing-pattern-synonym-signatures -fprint-expanded-synonyms -fwrite-ide-info #-freverse-errors

    # See https://github.com/haskell/haskell-language-server/issues/208
    "$everything": -haddock

  ''
