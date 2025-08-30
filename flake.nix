{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  outputs =
    {
      self,
      nixpkgs,
    }:
    {
      packages.x86_64-linux.default = self.nixosConfigurations.chaos.config.system.build.isoImage;
      nixosConfigurations.chaos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            {
              config,
              pkgs,
              modulesPath,
              ...
            }:
            {
              imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

              boot.kernelParams = [ "console=ttyS0,115200n8" ];
              boot.loader.grub.extraConfig = ''
                serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
                terminal_input serial
                terminal_output serial
              '';

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              programs.git = {
                enable = true;
                config.user = {
                  name = "Root user of ${config.networking.hostName}";
                  email = "root@${config.networking.hostName}";
                };
              };

              networking = {
                hostName = "chaos";
                wireless = {
                  enable = true;
                  networks.Quentinternational.pskRaw = "ext:psk_hotspot";
                  secretsFile = "/run/secrets/wireless.conf";
                };
              };
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4wGbl3++lqCjLUhoRyABBrVEeNhIXYO4371srkRoyq qaristote@latitude-7490"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvPsKWQXX/QsFQjJU0CjG4LllvUVZme45d9JeS/yhLt qaristote@precision-3571"
              ];

              time.timeZone = "Europe/Paris";
              i18n = {
                defaultLocale = "fr_FR.UTF-8";
                extraLocaleSettings.LANG = "en_US.UTF-8";
              };
              console = {
                "font" = "Lat2-Terminus32";
                keyMap = "fr";
              };

              environment.systemPackages = with pkgs; [
                vim
                (pkgs.writeShellApplication "mount-system" { } ''
                  cryptsetup open /dev/disk/by-uuid/47e77d74-1aad-4d99-9aa7-568d8524b305 crypt
                  mount /dev/disk/by-uuid/9e447187-fae1-466a-b37d-4de1fe240c6f /mnt
                  mount /dev/disk/by-uuid/b99733fc-3734-41d3-8fe5-2682714f319e /mnt/boot
                  swapon /mnt/swap
                '')
              ];
            }
          )
        ];
      };
    };
}
