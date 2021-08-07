{ lib
, ...
}:

let
	mkRotateConfig = filename: {
		path = "/var/log/${filename}";
		user = "root";
		group = "root";
		keep = 5;
		frequency = "monthly";
	};
in
{
	services.logrotate = {
		enable = true;
		paths = {
			auth-log = mkRotateConfig "auth.log";
			boot-log = mkRotateConfig "boot.log";
			daemon-log = mkRotateConfig "daemon.log";
			syslog = mkRotateConfig "syslog";
			user-log = mkRotateConfig "user.log";
		};
		extraConfig = lib.debug.traceIf true "Check if rotated logs actually get compressed by this!" ''
			compress
		'';
	};
}
