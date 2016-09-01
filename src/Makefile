.NOPARALLEL:

LIBS=
PKGS=
OCAMLCFLAGS="-g -warn-error A"
OCAMLBUILD=ocamlbuild -j 0 -cflags $(OCAMLCFLAGS) -lflags $(OCAMLCFLAGS) 
MLFILES=$(wildcard *.ml) 
MLIFILES=$(wildcard *.mli) 
ALL_EXE=test.byte

.PHONY: executables default 


default: $(ALL_EXE) 
tests: $(ALL_TESTS) 

%.inferred.mli: $(MLFILES)
	$(OCAMLBUILD) $*.inferred.mli -use-ocamlfind  $(PKGS) 
	mv _build/$*.inferred.mli .

%.byte: $(MLFILES) $(MLIFILES)
	rm -f -- $*
	$(OCAMLBUILD) $*.byte  -use-ocamlfind  $(PKGS)
	ln -s $*.byte $*

%.native: $(MLFILES) $(MLIFILES)
	rm -f -- $*
	$(OCAMLBUILD) $*.native -use-ocamlfind $(PKGS)
	ln -s $*.native $*

clean: 
	rm -rf _build *.byte *.native $(ALL_EXE) $(ALL_TESTS)

