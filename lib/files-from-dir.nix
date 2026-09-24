{ lib }:
target: directory:
let
  collect =
    relative:
    lib.concatMapAttrs (
      name: type:
      let
        path = directory + "/${relative}${name}";
        targetPath = lib.concatStringsSep "/" (
          lib.filter (part: part != "") [
            target
            "${relative}${name}"
          ]
        );
      in
      if type == "directory" then
        collect "${relative}${name}/" (builtins.readDir path)
      else
        {
          ${targetPath}.source = path;
        }
    );
in
collect "" (builtins.readDir directory)
