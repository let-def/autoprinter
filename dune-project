(lang dune 3.0)

(name autoprinter)

(generate_opam_files true)

(source (github let-def/autoprinter))

(authors "Frédéric Bour")

(maintainers "Frédéric Bour")

(license MIT)

(package
 (name autoprinter)
 (synopsis "A proof-of-concept to auto-install printing functions in the OCaml toplevel")
 (depends ocaml dune))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
