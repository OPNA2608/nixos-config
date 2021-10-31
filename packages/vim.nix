with import <nixpkgs> {
  config.vim.python = true;
  config.vim.ftNix = false;
};

(vim_configurable.override {
  # Drop when
  # https://github.com/NixOS/nixpkgs/issues/107548
  python = lib.debug.traceIf (lib.strings.versionAtLeast system.nixos.release "21.11")
    "#107548 is fixed, remove this workaround!"
    pkgs.python3;
}).customize {
  name = "vim";
  vimrcConfig = {
    customRC = ''
      " Switch to Vim settings mode
      set nocompatible

      " Syntax highlighting
      if has ("syntax")
        syntax on
      endif

      " Cursor position
      set ruler

      " Disable mouse
      set mouse-=a

      " Line numbers
      set number

      " Tab -> 2 Spaces
      set tabstop=2
      set softtabstop=2
      set shiftwidth=2
      set noexpandtab

      " statusline
      set laststatus=2
    '';
    packages.vim_plugins = with pkgs.vimPlugins; {
      start = [
        ale
        editorconfig-vim
        lightline-vim
        vim-better-whitespace
        vim-indent-guides
        vim-logreview
        vim-nix
        vimsence
        YouCompleteMe
      ];
    };
  };
}
