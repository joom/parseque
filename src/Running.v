Require Import Category.
Require Import Indexed.
Require Import Sized.
Require Import Success.
Require Import Combinators.
Require Import String.
Require Import StringAsList.
Require Import Ascii.

Require Import Coq.Arith.Le.

Inductive Singleton (A : Type) : A -> Type :=
  MkSingleton : forall a, Singleton A a.

Arguments Singleton {_}.
Arguments MkSingleton {_}.

Class Tokenizer (A : Type) : Type :=
  MkTokenizer { _tokenize : list ascii -> list A }.

Definition tokenize {A : Type} `{Tokenizer A} : list ascii -> list A := _tokenize.

Arguments MkTokenizer {_}.

Definition fromText {A : Type} `{Tokenizer A} (s : string) : list A :=
  tokenize (fromString s).

Instance tokAscii : Tokenizer ascii := MkTokenizer (fun x => x).

Section Check.

Context
  {Tok : Type} `{Tokenizer Tok}
  {M : Type -> Type} `{RawMonadRun M}
  {A : Type}.

Definition check : string -> [ Parser (SizedList Tok) Tok M A ] -> Type := fun s p =>
  let tokens := (fromText s : list Tok) in
  let n      := List.length tokens in
  let input  := mkSizedList tokens in
  let result := runParser (p n) (le_refl n) input in
  let valid  := fun s => match Success.size s with | O => Some (Success.value s) | _ => None end in
  match mapM valid (runMonad result) with
    | Some (cons hd _) => @Singleton A hd
    | _                => False
  end.

End Check.