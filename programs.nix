{
  home-manager.enable = true;

  zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = { enable = true; };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "vi-mode" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile ./zshrc;
    shellAliases = {
      code = "code 2>/dev/null";
    };
  };

  fzf = { enable = true; };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
