{
  lib,
  variantDir,
}:
let
  filesFromDir = import ../lib/files-from-dir.nix { inherit lib; };
  variantPath = name: variantDir + "/${name}";
  variantFiles =
    target: name:
    lib.optionalAttrs (builtins.pathExists (variantPath name)) (filesFromDir target (variantPath name));
in
{
  home.file =
    (filesFromDir ".doom.d" ../doom)
    // {
      ".config/nvim/lua/plugins/mdeval.lua".text = ''
        return {
          {
            'jubnzv/mdeval.nvim',
            config = true,
            ft = { 'markdown' },
          }
        }
      '';
      ".config/nvim/lua/codelink.lua".source = ../nvim/lua/codelink.lua;
      ".config/nvim/lua/plugins/azdo-link.lua".source = ../nvim/azdo-link.lua;
      ".config/nvim/lua/plugins/autoreload.lua".source = ../nvim/autoreload.lua;
    }
    // (variantFiles ".doom.d" "doom")
    // (variantFiles ".config/nvim" "nvim")
    // (variantFiles "" "home");
}
