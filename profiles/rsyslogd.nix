{ config
, lib
, ...
}:

{
	services.journald.extraConfig = ''
		Storage=none
		ForwardToSyslog=yes
	'';
	services.rsyslogd = {
		enable = true;
		defaultConfig = ''
			auth,authpriv.*                    /var/log/auth.log
			local7.*                          -/var/log/boot.log
			cron.*                             /var/log/cron.log
			daemon.*                          -/var/log/daemon.log
			kern.*                             /var/log/kern.log
			user.*                            -/var/log/user.log
			*.*;auth,authpriv.*               -/var/log/syslog
		'';
	};
}
