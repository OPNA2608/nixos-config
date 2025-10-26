with import <nixpkgs> {
  config.vim.python = true;
  config.vim.ftNix = false;
};

vim_configurable.customize {
  name = "vim";
  vimrcConfig = {
    customRC = builtins.readFile ./vimrc;
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
