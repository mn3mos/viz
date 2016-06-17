(*
http://camlunity.ru/swap/ocaml/ocaml-opengl-howto.en.php.html
http://www.linux-nantes.org/~fmonnier/OCaml/GL/vertex_array.html
*)

open GL
open Glut

type color = float * float * float
type vertex3d = float * float * float
type mesh = vertex3d list
type shape = Triangle of vertex3d * vertex3d * vertex3d * color
           | Mesh of mesh;;

let draw_shape = function
  | Triangle (v1, v2, v3, (r, g, b)) ->
    let draw_vertex = function (x,y,z) -> glVertex3 x y z in
    glColor3 r g b;
    glBegin GL_TRIANGLES;
    draw_vertex v1;
    draw_vertex v2;
    draw_vertex v3;
    glEnd ();
  | Mesh vertices -> print_endline "Unsupported Mesh shape"
;;



(* The scene graph *)
let sceneGraph : shape list ref =
  ref [
    Triangle ((0., 0., 0.),  (1., 0., 0.), (0., 1., 0.), (1., 0., 0.));
    Triangle ((0., 0., 0.),  (-1., 0., 0.), (0., 1., 0.), (0., 1., 0.));
    (* Mesh ([(0., 0., 0.)]) *)
  ]

let draw_graph() =
  (*glutWireCube ~size:1.0*)
  List.iter draw_shape !sceneGraph
;;


(* mouse coordinates *)
let xold = ref 0
let yold = ref 0

let b_down = ref false

let angley = ref 0
let anglex = ref 0

(* active mouse motion *)
let motion ~x ~y =
  if !b_down then  (* if the left button is down *)
  begin
 (* change the rotation angles according to the last position
    of the mouse and the new one *)
    anglex := !anglex + (!xold - x);
    angley := !angley + (!yold - y);
    glutPostRedisplay();
  end;
  xold := x;  (* save mouse position *)
  yold := y;
;;

(* mouse button event *)
let mouse ~button ~state ~x ~y =
  match button, state with
  (* if we press the left button *)
  | GLUT_LEFT_BUTTON, GLUT_DOWN ->
      b_down := true;
      xold := x;  (* save mouse position *)
      yold := y;
      (* if we release the left button *)
  | GLUT_LEFT_BUTTON, GLUT_UP ->
    b_down := false;
  | _ -> ()
;;

let keyboard ~key ~x ~y =
  match key with
  | '\027' (* escape key *)
  | 'q' -> exit 0
  | _ -> ()
;;

let display() =
  glClear [GL_COLOR_BUFFER_BIT];
  glLoadIdentity();
  glRotate ~angle:(float(- !angley)) ~x:1.0 ~y:0.0 ~z:0.0;
  glRotate ~angle:(float(- !anglex)) ~x:0.0 ~y:1.0 ~z:0.0;
  glColor3 ~r:0. ~g:1.0 ~b:0.;
  draw_graph();
  glFlush();
  glutSwapBuffers();
;;


let mainLoop () =
  ignore(glutInit Sys.argv);
  glutInitDisplayMode [GLUT_DOUBLE];
  ignore(glutCreateWindow ~title:(Sys.argv.(0) ^ " renderer") );
  glutDisplayFunc ~display;
  glutKeyboardFunc ~keyboard;
  glutMouseFunc ~mouse;
  glutMotionFunc ~motion;
  glutMainLoop ();
;;
