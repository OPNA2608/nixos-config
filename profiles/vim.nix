{ ...
}:

{
	programs.vim = {
		defaultEditor = true;
		package = (import ../packages/vim.nix);
	};
}
