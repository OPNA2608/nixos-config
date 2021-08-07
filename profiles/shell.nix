{ lib
, pkgs
, ...
}:

{
	environment = {
		shellAliases = {
				vi = "vim";
				ll = "ls -ahl --color=auto";
				df = "df -h";
				htop = "htop -d0.1";
			};
		variables = {
			fish_prompt_pwd_dir_length = "0";
		};
	};
	programs.fish = {
		enable = true;
		promptInit = ''
			function fish_prompt
				switch (whoami)
					case root
						set_color red --bold
					case '*'
						set_color green --bold
				end

				printf \n(whoami)'@'(prompt_hostname)':'
				set_color blue --bold
				echo (prompt_pwd)

				switch (tty | sed -e 's:/dev/::' | head -c3)
					case pts
						printf '↪ '
					case '*'
						printf '> '
				end
				set_color normal
			end
		'';
		# Is this still needed?
		# shellInit = ''
		# 	set -x fish_prompt_pwd_dir_length 0
		# '';
	};
	programs.bash.promptInit = ''
		# Provide a nice prompt.

		PROMPT_PREFIX=""
		PROMPT_COLORTYPE="1"
		if [ "$TERM" == "xterm" ]; then
			PROMPT_PREFIX="\[\033]2;\h:\u:\w\007\]"
			PROMPT_COLORTYPE="0"
		fi
		PROMPT_COLOR_ROOT="$PROMPT_COLORTYPE;31m"
		PROMPT_COLOR_USER="$PROMPT_COLORTYPE;32m"
		PROMPT_COLOR_DIRS="$PROMPT_COLORTYPE;34m"
		PROMPT_COLOR=$PROMPT_COLOR_ROOT
		let $UID && PROMPT_COLOR=$PROMPT_COLOR_USER

		PS1="$PROMPT_PREFIX\n\[\033[$PROMPT_COLOR\]\u@\h:\[\033[0m\]\[\033[$PROMPT_COLOR_DIRS\]\w\\$\[\033[0m\] "
  '';
}
