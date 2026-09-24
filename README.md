# Home Manager config

## Variants

Shared settings live at the repository root. Machine-specific settings live in:

```text
variants/
├── imac/
├── linux/
├── mbp/
└── wsl/
```

Each variant supports:

- `default.nix`: imports and general Home Manager options
- `packages.nix`: the variant's complete `home.packages` list
- `files.nix`: the variant's complete `home.file` configuration
- `programs.nix`: complete Zsh, FZF, tmux, direnv, LazyVim, and other program options
- `zshrc`: the variant's complete Zsh initialization
- `nvim/`: files overlaid onto `~/.config/nvim`
- `doom/`: files overlaid onto `~/.doom.d`
- `home/`: arbitrary files overlaid directly onto the home directory

Only add files that differ from the shared configuration. For example,
`variants/wsl/nvim/lua/plugins/example.lua` becomes
`~/.config/nvim/lua/plugins/example.lua`. A variant file at the same relative
path as a shared file replaces the shared file.

Home Manager manages files for the configured user, not system-wide. For
example, `variants/wsl/home/.config/tool/config.toml` becomes
`~/.config/tool/config.toml`. Generated files can still be declared directly in
the variant's `default.nix` with `home.file.<name>.text`.

Each `files.nix` currently imports `modules/shared-home-files.nix` to retain the
shared Doom and Neovim files. Remove that import and define `home.file` directly
when a variant needs a completely different file set.

Activation hooks are also variant-local. Define them in `default.nix`, or add an
`activation.nix` module to that variant's imports:

```nix
{
  imports = [
    ./activation.nix
    ./files.nix
    ./packages.nix
  ];
}
```

Program options are fully independent between variants:

```nix
{ ... }:
{
  programs.zsh.shellAliases.work = "cd ~/work";
  programs.lazyvim.extras.lang.rust.enable = true;
}
```

Variant editor files use their normal target-relative paths:

```text
variants/mbp/
├── programs.nix
├── nvim/lua/plugins/mbp.lua
└── doom/config.el
```

The iMac, MacBook Pro, and WSL variants enable minimal LazyVim configurations.
The full language extras and Telescope customization live in
`variants/linux/programs.nix`, which is used by both `linux` and `linuxArm`.

To add a variant, add one entry to `variants` in `flake.nix` and create its
`variants/<name>/default.nix`. The `linuxArm` output intentionally reuses the
`linux` variant.

## Install

### Nix

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
`

### Standalone Home Manager

`nix-shell '<home-manager>' -A install`

(which is not necessary as you can do this `nix run home-manager/master -- switch -b backup --impure --flake .#wsl` below)

### Clone this repository

`cd ~/.config`
`git clone <project-url> home-manager`

### Doom Emacs (optional)

`git clone https://github.com/hlissner/doom-emacs ~/.emacs.d`
`~/.emacs.d/bin/doom install`

### Set Zsh as the default shell

Register Zsh as an allowed login shell with elevated permissions, then change
the current user's shell without `sudo`:

```bash
zsh_path="$(command -v zsh)"
grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells
chsh -s "$zsh_path"
```

Using `sudo chsh -s "$zsh_path"` without specifying a username can change
root's shell instead. Log out and back in after running `chsh`.

If that does not work, add this to `.bashrc`:

```bash
if [ -t 1 ] && [ -x "$HOME/.nix-profile/bin/zsh" ]; then
    exec "$HOME/.nix-profile/bin/zsh" -l
fi
```

## Apply a variant

### iMac

`home-manager switch --impure --flake .#imac`

### MacBook Pro

`home-manager switch --impure --flake .#mbp`

### Linux

`home-manager switch --impure --flake .#linux`

### ARM Linux

`nix run home-manager/master -- switch --flake .#linuxArm --impure`

### WSL

`home-manager switch --impure --flake .#wsl`

## Neovim icons

Neovim icons require Nerd Font glyphs. GNOME Terminal may not reliably render a
separate symbol fallback, while fully patched fonts can change character
spacing. The Linux variant therefore configures Kitty with Ubuntu Mono for text
and maps Nerd Font codepoints explicitly to Symbols Nerd Font Mono. Install the
Ubuntu package with `sudo apt install kitty`, then run `kitty` and start Neovim
inside it. Home Manager manages `kitty.conf` but does not install the Kitty
binary.

For WSL, install the Nerd Font on Windows and select it in the Windows Terminal
Ubuntu profile. Installing a font only inside WSL does not make it available to
the Windows terminal renderer.

## neovim: grep with ripgrep args (glob filtering)

`<leader>sg` (Root Dir) and `<leader>sG` (cwd) use
[telescope-live-grep-args](https://github.com/nvim-telescope/telescope-live-grep-args.nvim),
which lets you pass inline ripgrep args (e.g. globs) right in the prompt.

Because of auto-quoting, the **search term must be quoted before any args** are
parsed. If the prompt does not start with `"`, `'`, or `-`, the whole line is
treated as one literal search string (so `foo -g *.cs` searches for the literal
text "foo -g *.cs" and finds nothing).

```
"foo" -g *.cs            only .cs files
"foo" -g !*.test.cs      exclude a glob (negative)
"foo" --iglob **/Managers/**   path filter (case-insensitive glob)
```

Shortcuts (insert mode in the prompt):

- `<C-k>` — auto-quote the current term and move the cursor after it, so you can
  immediately type args (e.g. `-g *.cs`).
- `<C-g>` — auto-quote the term and insert ` --iglob ` so you can type a glob
  directly.

ripgrep glob cheatsheet: `-g`/`--glob` is case-sensitive, `--iglob` is
case-insensitive, prefix with `!` to exclude (`-g !*_test.go`), and use `**` to
span directories (`-g **/src/**`).

## tests

### nvim code-link plugin

Unit tests for the Neovim "code link" helper (`nvim/lua/codelink.lua`, which
generates Azure DevOps / GitHub links for the current line). They mock `vim`, so
no Neovim is required:

`nix-shell -p lua --run "lua nvim/tests/codelink_spec.lua"`

The command exits non-zero if any assertion fails.
