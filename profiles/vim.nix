{ ...
}:

{
	programs.vim = {
		enable = true;
		defaultEditor = true;
		package = (import ../packages/vim.nix);
	};
}
