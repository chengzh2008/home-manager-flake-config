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
    };
    extraPackages = with pkgs; [
      omnisharp-roslyn
      dotnet-sdk
    ];
  };
}
