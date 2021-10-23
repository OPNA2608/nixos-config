{ ...
}:

{
	services.chrony.enable= true;
	services.timesyncd.enable = false;
	time.timeZone = "Europe/Berlin";
}
