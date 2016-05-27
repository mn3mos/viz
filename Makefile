APP_NAME=viz

#GL_PATH := +glMLite
GL_PATH := $(shell ocamlfind query glmlite)
CMA_LIBS := str.cma bigarray.cma -I $(GL_PATH) GL.cma Glu.cma Glut.cma vertArray.cma VBO.cma
CMXA_LIBS := str.cmxa bigarray.cmxa -I $(GL_PATH) GL.cmxa Glu.cmxa Glut.cmxa vertArray.cmxa VBO.cmxa

FILES=renderer.ml main.ml

TARGETS_CMO=$(subst .ml,.cmo,$(FILES))
TARGETS_CMX=$(subst .ml,.cmx,$(FILES))

all: $(APP_NAME).native

%.cmo %.cmi: %.ml
	ocamlc -c -I $(GL_PATH) $<

%.cmx %.cmi: %.ml
	ocamlopt -c -I $(GL_PATH) $<

main.cmo: renderer.cmi
main.cmx: renderer.cmi

$(APP_NAME).byte: $(TARGETS_CMO)
	ocamlc -o $@ $(CMA_LIBS) $(TARGETS_CMO)

$(APP_NAME).native: $(TARGETS_CMX)
	echo $(TARGETS_CMX)
	ocamlopt -o $@ $(CMXA_LIBS) $(TARGETS_CMX)

exec: $(APP_NAME).byte
	ocamlrun -I $(GL_PATH) ./$<

run: $(APP_NAME).native
	./$<

clean:
	rm -f *.o *.cm[iox]
