#!/usr/bin/env ocaml

(* UTop directives to load libraries *)
#directory "/Users/mnemos/.opam/system/lib/glmlite" (* +glMLite should work but doesn't *)
#load "GL.cma"
#load "Glut.cma"

#use "renderer.ml"

(*
   #use directive include the file without creating a module
   so the mainLoop is directly available
   Module scoping is only available when using #load directive
*)
let () =
  mainLoop ();;
