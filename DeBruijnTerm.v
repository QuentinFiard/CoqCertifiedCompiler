Require Import ssreflect ssrbool eqtype ssrnat.
Require Import ListSet.

Module DeBruijnTerms.

Section Declaration.

Inductive DBT:Type :=
| Var : nat -> DBT
| Fun : DBT -> DBT
| Appl : DBT -> DBT -> DBT.

(* This lemma is required for the definition of natural integer sets *)
Lemma nat_unicity : forall x y:nat, {x = y} + {x <> y}.
Proof.
  move/(_ nat_eqType):eqVneq=> h.
  move => x y.
  move/(_ x y):h => h.
  case:h => h.
  left.
  done.
  right.
  move:h.
  move/eqP.
  done.
Qed.

(* Definition set_substract_one (s:set nat) : set nat. *)

(*
Definition 

Definition free_variables (t:DBT) : set nat.
Proof.
  (* Cas d'une variable *)
  elim:t.
  move => x.
  move/(_ nat):empty_set => s.
  move:set_add => h.
  move/(_ nat):h => h.
  apply:h.
  move:nat_unicity => h.
  done.
  done.
  done.
  
  (* Cas d'une fonction *)
  move => t free_t.
  move:set_remove => h.
  move/(_ nat):h => h.
  apply:h.
  move:nat_unicity => h.
  done.
  apply:0.
  done.

  (* Cas d'une application *)

  done.
Defined.
*)

Definition heredity_n_k (f:nat -> nat -> Prop) : Prop := forall n k:nat, f n k -> f (n+1) k.

Lemma stupid : forall x y:nat, x<y -> x<y+1.
Admitted.

Definition n_k_free (t:DBT) : { f:(nat->nat->Prop) | heredity_n_k f}.
Proof.
  elim:t.

  (* Variable *)
  move => x.
  exists (fun n:nat => (fun k:nat => ((x<k)\/(x<n)))).
  rewrite/heredity_n_k.
  move => n k h.
  case:h => h.
  by left.
  right.
  move/(_ x n):stupid => h1.
  apply:h1.
  done.

  (* Fonction *)
  move => t ih.
  case:ih => f p.
  exists (fun n => (fun k => (f n (k+1)))).
  move:p.
  rewrite/heredity_n_k.
  move => ih n k h.
  move/(_ n (k+1)):ih => ih.
  apply:ih.
  done.

  (* Application *)
  move => t iht u ihu.
  case:iht => ft pt.
  case:ihu => fu pu.

  exists (fun n => (fun k => ((ft n k)/\(fu n k)))).

  move:pt pu.
  rewrite/heredity_n_k.
  move => iht ihu n k h.
  move/(_ n k): iht => iht.
  move/(_ n k): ihu => ihu.
  split.
  apply:iht.
  by case:h => h.
  apply:ihu.
  by case:h => h.
Defined.

Definition n_free (t:DBT) : { f:nat -> Prop | forall n:nat, forall t:DBT, f n -> f (n+1) }.
Proof.
  move:n_k_free => h.
  case:h.
  done.
  move => n_k_free.
  rewrite/heredity_n_k.
  move => p.
  exists (fun n => (n_k_free n 0)).

  move => n.
  move/(_ n 0):p => p.
  done.
Defined.

Fixpoint closed (t:DBT) : Prop.
Proof.
  move:n_free => h.
  case:h.
  done.
  move => n p.
  apply:n 0.
Defined.

Definition t1:DBT := Var 0.
Definition t2:DBT := Fun (Var 0).
Definition t3:DBT := Fun (Var 1).

Compute closed t1.
Compute closed t2.
Compute closed t3.

Definition is_function (f:DBT) : Prop :=
  match f with
    | Fun t => true
    | _ => false
  end.

Theorem is_function_eq : forall f, is_function f <-> exists x, f = Fun x.
Proof.
  split.
  case:f.
  rewrite/is_function.
  done.
  move => d p.
  exists d.
  done.
  rewrite/is_function.
  done.

  move => p.
  elim:p.
  move => x h.
  rewrite h.
  rewrite/is_function.
  done.
Qed.

Definition function_arg (f:DBT) : DBT :=
  match f with
    | Fun t => t
    | _ => f
  end.

Definition replace : DBT -> nat -> DBT -> DBT.
Proof.
  move => t.
  
  elim:t.

  (* Variable *)
  move => x n u.
  move/(_ n x):nat_unicity => h.
  case:h => h.
  apply:u.
  apply:(Var x).

  (* Function Fun t1*)
  move => t1 ih n u.
  apply:(Fun(ih (n+1) u)).
  

  (* Application Appl t1 t2*)
  move => t1 ih1 t2 ih2 n u.
  apply:(Appl (ih1 n u) (ih2 n u)).
Defined.

Lemma leq_or_geq: forall x y:nat, {x<y}+{x>=y}.
Proof.
  move => x y.
  move/(_ x y):leqP.
  unfold leq_xor_gtn.


  move/(_ x y):nat_unicity => h1.
  case:h1 => h1.
  right.
  rewrite h1.
  done.

  move/(_ y x):leq_total.
  move/orP.
  move => h2.
  case:h2 => h2.
  right.
  done.

  left.
  move/(_ x y):ltn_neqAle => h3.
  rewrite h3.
  rewrite/andb.
  have h4:x!=y.
  move:h1.
  move/eqP.
  done.

  rewrite h4.
  done.
Qed.

(* add_n_to_free_k t n k  adds a constant value n to all free variables >= k in t *)
Definition add_n_to_free_k : DBT -> nat -> nat -> DBT.
Proof.
  move => t.
  elim:t.

  (* Variable *)
  move => x n k.
  move/(_ x k):leq_or_geq => h1.
  case:h1 => h1.

  

  have h:(x<k)\/(x>=k).
  move/(_ x k):leq_total => h1.
  move/(_ k x):nat_unicity => h2.
  case:h2 => h2.
  right.
  move/(_ k x):eq_leq => h3.
  apply:h3.
  done.
  left.
Defined.

(* add_n_to_free adds a constant value n to all the free variables of the argument DBT *)
Definition add_n_to_free : DBT -> nat -> DBT.
Proof.
  move => t.
  
Defined.

(* La définition suivante ne tient pas compte des variables libres de u, il faut encore la modifier *)

Definition substitution : {f:DBT | is_function f} -> DBT -> DBT.
Proof.
  (* f=Fun t, calcul de (Fun t) u *)
  move => f.
  move => u.
  case:f => f.
  move => p.
  move/(_ f):function_arg => t.

  move/(_ t 0 u):replace => h.
  apply:h.
Defined.


End DeBruijnTerms.