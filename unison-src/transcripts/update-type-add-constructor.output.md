```unison
unique type Foo
  = Bar Nat
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
unique type Foo
  = Bar Nat
  | Baz Nat Nat
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

  unique type Foo = Bar Nat | Baz Nat Nat

.> find.verbose

  1. -- #2sffq4apsq1cts53njcunj63fa8ohov4eqn77q14s77ajicajh4g28sq5s5ai33f2k6oh6o67aarnlpu7u7s4la07ag2er33epalsog
     unique type Foo
     
  2. -- #2sffq4apsq1cts53njcunj63fa8ohov4eqn77q14s77ajicajh4g28sq5s5ai33f2k6oh6o67aarnlpu7u7s4la07ag2er33epalsog#0
     Foo.Bar : Nat -> Foo
     
  3. -- #2sffq4apsq1cts53njcunj63fa8ohov4eqn77q14s77ajicajh4g28sq5s5ai33f2k6oh6o67aarnlpu7u7s4la07ag2er33epalsog#1
     Foo.Baz : Nat -> Nat -> Foo
     
  

```
