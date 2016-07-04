(*
http://camlunity.ru/swap/ocaml/ocaml-opengl-howto.en.php.html
http://www.linux-nantes.org/~fmonnier/OCaml/GL/vertex_array.html
*)

open GL
open Glut

let time () = Unix.gettimeofday () *. 1000.


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
  | Mesh _ -> failwith "Unsupported Mesh shape"
;;



(* The scene graph *)
let origSceneGraph : shape list =
  [
    Triangle ((0., 0., 0.),  (1., 0., 0.), (0., 1., 0.), (1., 0., 0.));
    Triangle ((0., 0., 0.),  (-1., 0., 0.), (0., 1., 0.), (0., 1., 0.));
    (* Mesh ([(0., 0., 0.)]) *)
  ]

let sceneGraph : shape list ref =
  ref origSceneGraph

let draw_graph() =
  (*glutWireCube ~size:1.0*)
  List.iter draw_shape !sceneGraph
;;

let sg_oscillate () =
  let offset = sin (time() /. 1000.) in (* Unix.gettimeofday() *)
  let shape_oscillate = function
    | Triangle ( (x1,y1,z1), (x2,y2,z2), (x3,y3,z3), (r, g, b)) ->
      Triangle ( (x1,y1,z1), (x2 +. offset,y2,z2), (x3,y3,z3), (r, g, b +. offset))
    | Mesh _ -> failwith "Unsupported Mesh shape"
  in
  sceneGraph := List.map shape_oscillate origSceneGraph;
  glutPostRedisplay()
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
  (* Moves the camera *)
  glLoadIdentity();
  glRotate ~angle:(float(- !angley)) ~x:1.0 ~y:0.0 ~z:0.0;
  glRotate ~angle:(float(- !anglex)) ~x:0.0 ~y:1.0 ~z:0.0;
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
  glutIdleFunc ~idle:sg_oscillate;
  glutMainLoop ();
;;
