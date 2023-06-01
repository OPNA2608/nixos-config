{ supportEfi ? true
, device ? null
}:
{ config
, lib
, ...
}:

assert !supportEfi -> device;

let
	systemSetupEntry = ''
		menuentry 'System Setup' $menuentry_id_option 'uefi-firmware' {
			fwsetup
		}
	'';
in
{
	boot = {
		loader = {
			grub = {
				enable = true;
				# Only needed for BIOS iirc?
				device = if (!supportEfi && device != null) then device else "nodev";
				efiSupport = supportEfi;
				useOSProber = lib.mkDefault false;
				extraEntriesBeforeNixOS = supportEfi;
				extraEntries = (if supportEfi then systemSetupEntry else "");
				default = (if supportEfi then 1 else 0);
			};
			efi.canTouchEfiVariables = lib.mkDefault supportEfi;
		};
		plymouth.enable = config.services.xserver.enable;
	};
}
