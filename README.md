# Autoprinter
A proof-of-concept to auto-install printer functions in the OCaml toplevel

Install with `opam pin add autoprinter https://github.com/let-def/autoprinter.git`.

Then `#require autoprinter` in the ocaml toplevel or in utop-full to setup a hook that will automatically install printers.
This is done for any function that has a `[@toplevel_printer]` or `[@ocaml.toplevel_printer]` attribute.

For instance, entering the definition:

```
module X = struct
  type t = ...
  let print [@toplevel_printer] = ...
end
```

will also install `X.print` without having to manually execute `#install_printer X.print;;`.

This is similar to what utop (https://github.com/ocaml-community/utop/pull/269) and auto-printer (https://github.com/rgrinberg/auto-printer) do, but the version in this repository also works on function instantiations.

# Caveats
Because of toplevel design and particularly the expunge feature (see https://github.com/dbuenzli/rresult/issues/5, https://github.com/ocaml/ocaml/issues/6704, current state: https://github.com/ocaml/ocaml/issues/7589), the loading is a bit complicated.
With ocaml toplevel, it will **work as expected** after printing a scarry message:

```
# #require "autoprinter";;
...
Exception:
Invalid_argument
 "The ocamltoplevel.cma library from compiler-libs cannot be loaded inside the OCaml toplevel".
...
```

It won't work with utop:
```
# #require "autoprinter";;
Error: Reference to undefined global `Ident'
```
You should instead use the `utop-full` binary.

**TODO:** (though I am unlikely to do it :P)
- fix the logic in utop
- consider upstreaming the logic to the toplevel
