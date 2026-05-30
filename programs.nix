pkgs: {
  home-manager.enable = true;

  zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
      ];
      theme = "robbyrussell";
    };
    initContent = builtins.readFile ./zshrc;
    shellAliases = {
      code = "code 2>/dev/null";
    };
  };

  fzf = {
    enable = true;
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  lazyvim = {
    enable = true;
    extras = {
      lang.nix.enable = true;
      lang.python.enable = true;
      lang.dotnet.enable = true;
      lang.markdown.enable = true;
      editor.neo-tree.enable = true;
      editor.telescope.enable = true;
    };
    extraPackages = [
      pkgs.dotnet-sdk
      (pkgs.runCommand "omnisharp-wrapped" { } ''
        mkdir -p $out/bin
        ln -s ${pkgs.omnisharp-roslyn}/bin/OmniSharp $out/bin/omnisharp
      '')
    ];
    plugins = {
      omnisharp = ''
        return {
          "neovim/nvim-lspconfig",
          opts = {
            setup = {
              omnisharp = function(_, opts)
                require("lspconfig").omnisharp.setup(vim.tbl_deep_extend("force", opts, {
                  cmd = { "omnisharp", "--languageserver" },
                  root_dir = function(fname)
                    local util = require("lspconfig.util")
                    return util.root_pattern("*.csproj", "*.sln", "omnisharp.json")(fname)
                      or util.root_pattern(".git")(fname)
                  end,
                }))
                return true
              end,
            },
          },
        }
      '';
      telescope = ''
        return {
          "nvim-telescope/telescope.nvim",
          opts = {
            defaults = {
              path_display = { "filename_first" },
              file_ignore_patterns = {
                "node_modules/",
                ".git/",
                "bin/",
                "obj/",
                "Build/",
                "Externals/",
                "Projects/",
                "Secrets/",
                "TEST/",
                "Tools/",
                "testsrc/"
              },
              layout_config = {
                horizontal = {
                  preview_width = 0.4,
                },
              },
            },
          },
        }
      '';
    };
  };
}
