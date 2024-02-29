{
  home-manager.enable = true;

  zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting = { enable = true; };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "vi-mode" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile ./zshrc;
  };

  fzf = { enable = true; };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
