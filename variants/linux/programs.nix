{ pkgs, ... }:
{
  programs = {
    home-manager.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "vi-mode"
        ];
        theme = "robbyrussell";
      };
      initContent = builtins.readFile ./zshrc;
      shellAliases.code = "code 2>/dev/null";
    };

    fzf.enable = true;
    tmux = {
      enable = true;
      # Reload the generated configuration in an existing tmux server after
      # applying Home Manager changes:
      # tmux source-file ~/.config/tmux/tmux.conf
      mouse = true;
      prefix = "C-Space";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    kitty = {
      enable = true;
      package = null;
      settings = {
        font_family = "Ubuntu Mono";
        font_size = 12;
        symbol_map = "U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ea60-U+ec1e,U+ed00-U+efce,U+f000-U+f2ff,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0 Symbols Nerd Font Mono";
      };
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
        /*
          (pkgs.runCommand "omnisharp-wrapped" { } ''
            mkdir -p $out/bin
            ln -s ${pkgs.omnisharp-roslyn}/bin/OmniSharp $out/bin/omnisharp
          '')
        */
      ];
      plugins = {
        telescope = ''
          return {
            "nvim-telescope/telescope.nvim",
            dependencies = {
              "nvim-telescope/telescope-live-grep-args.nvim",
            },
            -- Grep with inline ripgrep args (glob include/exclude). The search
            -- term must be QUOTED before any args are parsed, e.g.
            --   "foo" -g *.lua        (only .lua files)
            --   "foo" -g !*.test.ts   (exclude, negative glob)
            -- Press <C-k> to auto-quote the term + start typing args, or
            -- <C-g> to auto-quote + insert " --iglob ".
            keys = {
              {
                "<leader>sg",
                function()
                  local t = require("telescope")
                  pcall(t.load_extension, "live_grep_args")
                  t.extensions.live_grep_args.live_grep_args({ cwd = LazyVim.root() })
                end,
                desc = "Grep w/ args (Root Dir)",
              },
              {
                "<leader>sG",
                function()
                  local t = require("telescope")
                  pcall(t.load_extension, "live_grep_args")
                  t.extensions.live_grep_args.live_grep_args({ cwd = vim.uv.cwd() })
                end,
                desc = "Grep w/ args (cwd)",
              },
            },
            opts = function(_, opts)
              local lga_actions = require("telescope-live-grep-args.actions")
              opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
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
              })
              opts.extensions = vim.tbl_deep_extend("force", opts.extensions or {}, {
                live_grep_args = {
                  auto_quoting = true,
                  mappings = {
                    i = {
                      ["<C-k>"] = lga_actions.quote_prompt(),
                      ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                    },
                  },
                },
              })
              return opts
            end,
          }
        '';
      };
    };
  };
}
