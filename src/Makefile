.NOPARALLEL:

LIBS=
PKGS=
OCAMLCFLAGS="-g -warn-error A"
OCAMLBUILD=ocamlbuild -j 0 -cflags $(OCAMLCFLAGS) -lflags $(OCAMLCFLAGS) 
MLFILES=$(wildcard *.ml) 
MLIFILES=$(wildcard *.mli) 
ALL_EXE=create_gamess_input.native test.byte

.PHONY: executables default 


default: $(ALL_EXE) 
tests: $(ALL_TESTS) 

%.inferred.mli: $(MLFILES)
	$(OCAMLBUILD) $*.inferred.mli -use-ocamlfind  $(PKGS) 
	mv _build/$*.inferred.mli .

%.byte: $(MLFILES) $(MLIFILES)
	rm -f -- $*
	$(OCAMLBUILD) $*.byte  -use-ocamlfind  $(PKGS)
	rm -f ../bin/$*
	ln $*.byte ../bin/$*

%.native: $(MLFILES) $(MLIFILES)
	rm -f -- $*
	$(OCAMLBUILD) $*.native -use-ocamlfind $(PKGS)
	rm -f ../bin/$*
	ln $*.native ../bin/$*

clean: 
	rm -rf _build *.byte *.native $(ALL_EXE) $(ALL_TESTS)

