-- configurator:
--   Avoid the broken resolver version.
-- haskeline:
--   This custom Haskeline alters ANSI rendering on Windows.  If changing the
--   haskeline dependency, please ensure color renders properly in a Windows
--   terminal.  https://github.com/judah/haskeline/pull/126
[ { loc = "https://github.com/unisonweb/configurator"
  , tag = "e47e9e9fe1f576f8c835183b9def52d73c01327a"
  , sub = [] : List Text
  }
, { loc = "https://github.com/unisonweb/haskeline"
  , tag = "9275eea7982dabbf47be2ba078ced669ae7ef3d5"
  , sub = [] : List Text
  }
]
