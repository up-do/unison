''
program-options
  ghc-options:
    -Wall
    -Werror
    -Wno-missing-pattern-synonym-signatures
    -Wno-name-shadowing
    -fhide-source-paths
    -fprint-expanded-synonyms
    -fwrite-ide-info
    -haddock

package haskeline
  flags: -terminfo
''
