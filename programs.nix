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
}
