```unison
unique type Foo = Bar Nat
```

```ucm

  I found and typechecked these definitions in scratch.u. If you
  do an `add` or `update`, here's how your codebase would
  change:
  
    ⍟ These new definitions are ok to `add`:
    
      unique type Foo

```
```ucm
.> add

  ⍟ I've added these definitions:
  
    unique type Foo

```
```unison
unique type Foo = Bar Nat Nat
```

```ucm

  I found and typechecked these definitions in scratch.u. If you
  do an `add` or `update`, here's how your codebase would
  change:
  
    ⍟ These names already exist. You can `update` them to your
      new definition:
    
      unique type Foo

```
```ucm
.> update

  Okay, I'm searching the branch for code that needs to be
  updated...

  Done.

.> view Foo

  unique type Foo = Bar Nat Nat

.> find.verbose

  1. -- #8fk6k0j208th1ia4vnjtoc5fomd6le540prec255svg71bcfga9dofrvoq1d7v6010d6b6em4q51p8st5c5juhrev72cnnel8ko3o1g
     unique type Foo
     
  2. -- #8fk6k0j208th1ia4vnjtoc5fomd6le540prec255svg71bcfga9dofrvoq1d7v6010d6b6em4q51p8st5c5juhrev72cnnel8ko3o1g#0
     Foo.Bar : Nat -> Nat -> Foo
     
  

```
