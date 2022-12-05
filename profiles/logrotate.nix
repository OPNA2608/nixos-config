{ lib
, ...
}:

let
	rotateConfig = {
		create = "0664 root root";
		rotate = 3;
		frequency = "monthly";
	};
	mkRotateConfigs = logfiles: builtins.listToAttrs (
		lib.lists.forEach logfiles (logfile:
			lib.attrsets.nameValuePair "/var/log/${logfile}" rotateConfig
		)
	) // {
		header = {
			compress = true;
		};
	};
in
{
	services.logrotate = {
		enable = true;
		settings = mkRotateConfigs [ "auth.log" "boot.log" "daemon.log" "syslog" "user.log" ];
	};
}
