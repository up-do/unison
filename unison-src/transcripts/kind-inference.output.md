
## A type param cannot have conflicting kind constraints within a single decl

conflicting constraints on the kind of `a` in a product
```unison
unique type T a = T a (a Nat)
```

```ucm

  Kind mismatch arising from
        1 | unique type T a = T a (a Nat)
    
    a doesn't expect an argument; however, it is applied to Nat.

```
conflicting constraints on the kind of `a` in a sum
```unison
unique type T a 
  = Star a 
  | StarStar (a Nat)
```

```ucm

  Kind mismatch arising from
        3 |   | StarStar (a Nat)
    
    a doesn't expect an argument; however, it is applied to Nat.

```
## Kinds are inferred by decl component

Successfully infer `a` in `Ping a` to be of kind `* -> *` by
inspecting its component-mate `Pong`.
```unison
unique type Ping a = Ping Pong
unique type Pong = Pong (Ping Optional)
```

```ucm

  I found and typechecked these definitions in scratch.u. If you
  do an `add` or `update`, here's how your codebase would
  change:
  
    ⍟ These new definitions are ok to `add`:
    
      unique type Ping a
      unique type Pong

```
Catch the conflict on the kind of `a` in `Ping a`. `Ping` restricts
`a` to `*`, whereas `Pong` restricts `a` to `* -> *`.
```unison
unique type Ping a = Ping a Pong
unique type Pong = Pong (Ping Optional)
```

```ucm

  Kind mismatch arising from
        1 | unique type Ping a = Ping a Pong
    
    The arrow type (->) expects arguments of kind Type; however,
    it is applied to a which has kind: Type -> Type.

```
Successful example between mutually recursive type and ability
```unison
unique type Ping a = Ping (a Nat -> {Pong Nat} ())
unique ability Pong a where
  pong : Ping Optional -> ()
```

```ucm

  I found and typechecked these definitions in scratch.u. If you
  do an `add` or `update`, here's how your codebase would
  change:
  
    ⍟ These new definitions are ok to `add`:
    
      unique type Ping a
      unique ability Pong a

```
Catch conflict between mutually recursive type and ability
```unison
unique type Ping a = Ping (a -> {Pong Nat} ())
unique ability Pong a where
  pong : Ping Optional -> ()
```

```ucm

  Kind mismatch arising from
        3 |   pong : Ping Optional -> ()
    
    Ping expects an argument of kind: Type; however, it is
    applied to Optional which has kind: Type -> Type.

```
Consistent instantiation of `T`'s `a` parameter in `S`
```unison
unique type T a = T a

unique type S = S (T Nat)
```

```ucm

  I found and typechecked these definitions in scratch.u. If you
  do an `add` or `update`, here's how your codebase would
  change:
  
    ⍟ These new definitions are ok to `add`:
    
      unique type S
      unique type T a

```
Delay kind defaulting until all components are processed. Here `S`
constrains the kind of `T`'s `a` parameter, although `S` is not in
the same component as `T`.
```unison
unique type T a = T

unique type S = S (T Optional)
```

```ucm

  I found and typechecked these definitions in scratch.u. If you
  do an `add` or `update`, here's how your codebase would
  change:
  
    ⍟ These new definitions are ok to `add`:
    
      unique type S
      unique type T a

```
Catch invalid instantiation of `T`'s `a` parameter in `S`
```unison
unique type T a = T a

unique type S = S (T Optional)
```

```ucm

  Kind mismatch arising from
        3 | unique type S = S (T Optional)
    
    T expects an argument of kind: Type; however, it is applied
    to Optional which has kind: Type -> Type.

```
## Checking annotations

Catch kind error in type annotation
```unison
test : Nat Nat
test = 0
```

```ucm

  Kind mismatch arising from
        1 | test : Nat Nat
    
    Nat doesn't expect an argument; however, it is applied to
    Nat.

```
Catch kind error in annotation example 2
```unison
test : Optional -> ()
test _ = ()
```

```ucm

  Kind mismatch arising from
        1 | test : Optional -> ()
    
    The arrow type (->) expects arguments of kind Type; however,
    it is applied to Optional which has kind: Type -> Type.

```
Catch kind error in annotation example 3
```unison
unique type T a = T (a Nat)

test : T Nat -> ()
test _ = ()
```

```ucm

  Kind mismatch arising from
        3 | test : T Nat -> ()
    
    T expects an argument of kind: Type -> Type; however, it is
    applied to Nat which has kind: Type.

```
Catch kind error in scoped type variable annotation
```unison
unique type StarStar a = StarStar (a Nat)
unique type Star a = Star a

test : StarStar a -> ()
test _ = 
  buggo : Star a
  buggo = bug ""
  ()
```

```ucm

  Kind mismatch arising from
        6 |   buggo : Star a
    
    Star expects an argument of kind: Type; however, it is
    applied to a which has kind: Type -> Type.

```
## Effect/type mismatch

Effects appearing where types are expected
```unison
unique ability Foo where
  foo : ()

test : Foo -> ()
test _ = ()
```

```ucm

  Kind mismatch arising from
        4 | test : Foo -> ()
    
    The arrow type (->) expects arguments of kind Type; however,
    it is applied to Foo which has kind: Ability.

```
Types appearing where effects are expected
```unison
test : {Nat} ()
test _ = ()
```

```ucm

  Kind mismatch arising from
        1 | test : {Nat} ()
    
    An ability list must consist solely of abilities; however,
    this list contains Nat which has kind Type. Abilities are of
    kind Ability.

```
## Cyclic kinds

```unison
unique type T a = T (a a)
```

```ucm

  Cannot construct infinite kind
        1 | unique type T a = T (a a)
    
    The above application constrains the kind of a to be
    infinite, generated by the constraint k = k -> Type where k
    is the kind of a.

```
```unison
unique type T a b = T (a b) (b a)
```

```ucm

  Cannot construct infinite kind
        1 | unique type T a b = T (a b) (b a)
    
    The above application constrains the kind of b to be
    infinite, generated by the constraint
    k = (k -> Type) -> Type where k is the kind of b.

```
```unison
unique type Ping a = Ping (a Pong)
unique type Pong a = Pong (a Ping)
```

```ucm

  Cannot construct infinite kind
        1 | unique type Ping a = Ping (a Pong)
    
    The above application constrains the kind of a to be
    infinite, generated by the constraint
    k = (((k -> Type) -> Type) -> Type) -> Type where k is the
    kind of a.

```
