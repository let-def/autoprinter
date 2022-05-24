open Types

let cons_path path id =
  let comp = Ident.name id in
  match path with
  | None -> Longident.Lident comp
  | Some path -> Longident.Ldot (path, comp)

let is_auto_printer_attribute (attr : Parsetree.attribute) =
  match attr.attr_name.txt with
  | "toplevel_printer" | "ocaml.toplevel_printer" -> true
  | _ -> false

let rec walk_sig ppf ?path signature =
  List.iter (walk_sig_item ppf path) signature

and walk_sig_item ppf path = function
  | Sig_module (id, _, {md_type = mty; _}, _, _) ->
    walk_mty ppf (cons_path path id) mty
  | Sig_value (id, vd, _) ->
    if List.exists is_auto_printer_attribute vd.val_attributes then
      Topdirs.dir_install_printer ppf (cons_path path id)
  | _ -> ()

and walk_mty ppf path = function
  | Mty_signature s -> walk_sig ppf ~path s
  | _ -> ()

let scan =
  let last_globals = ref (Env.get_required_globals ()) in
  let last_summary = ref Env.Env_empty in
  fun ppf env ->
    let scan_module env id =
      let path, md =
        Env.find_module_by_name (Longident.Lident (Ident.name id)) env
      in
      if path = Path.Pident id then
        walk_mty ppf (Longident.Lident (Ident.name id)) md.md_type
    in
    let rec scan_globals last = function
      | [] -> ()
      | x when x == last -> ()
      | x :: xs ->
        scan_globals last xs;
        scan_module env x
    in
    let rec scan_summary last = function
      | Env.Env_empty -> ()
      | x when x == last -> ()
      | Env.Env_module (s, id, _, _) ->
        scan_summary last s;
        scan_module env id
      | Env.Env_value (s, _, _)
      | Env.Env_type (s, _, _)
      | Env.Env_extension (s, _, _)
      | Env.Env_modtype (s, _, _)
      | Env.Env_class (s, _, _)
      | Env.Env_cltype (s, _, _)
      | Env.Env_open (s, _)
      | Env.Env_functor_arg (s, _)
      | Env.Env_constraints (s, _)
      | Env.Env_copy_types s
      | Env.Env_persistent (s, _)
      | Env.Env_value_unbound (s, _, _)
      | Env.Env_module_unbound (s, _, _) ->
        scan_summary last s
    in
    let globals = Env.get_required_globals () in
    let last_globals' = !last_globals in
    last_globals := globals;
    scan_globals last_globals' globals;
    let summary = Env.summary env in
    let last_summary' = !last_summary in
    last_summary := summary;
    scan_summary last_summary' summary

let () =
  let print_out_phrase = !Toploop.print_out_phrase in
  Toploop.print_out_phrase := (fun ppf phr ->
      scan ppf !Toploop.toplevel_env;
      print_out_phrase ppf phr
    )
