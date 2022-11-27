with import <nixpkgs> {
  config.vim.python = true;
  config.vim.ftNix = false;
};

vim_configurable.customize {
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
      " only show lightline's mode markers
      set noshowmode
    '';
    packages.vim_plugins = with pkgs.vimPlugins; {
      start = [
        ale
        editorconfig-vim
        lightline-vim
        lightline-ale
        vim-better-whitespace
        vim-indent-guides
        vim-logreview
        vim-nix
      ];
    };
  };
}
