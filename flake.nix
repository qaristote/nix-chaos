{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = {
    self,
    nixpkgs,
  }: {
    packages.x86_64-linux.default = self.nixosConfigurations.exampleIso.config.system.build.isoImage;
    nixosConfigurations.chaos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({
          config,
          pkgs,
          modulesPath,
          ...
        }: {
          imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];

          environment.systemPackages = with pkgs; [vim];

          nix.settings.experimental-features = ["nix-command" "flakes"];
          programs.git = {
            enable = true;
            config.user = {
              name = "Root user of ${config.networking.hostName}";
              email = "root@${config.networking.hostName}";
            };
          };

          networking.hostName = "chaos";
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4wGbl3++lqCjLUhoRyABBrVEeNhIXYO4371srkRoyq qaristote@latitude-7490"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvPsKWQXX/QsFQjJU0CjG4LllvUVZme45d9JeS/yhLt qaristote@precision-3571"
          ];

          time.time = "Europe/Paris";
          i18n = {
            defaultLocal = "fr_FR.utf8";
            extraLocaleSettings.LANG = "en_US.utf8";
          };
          console = {
            "font" = "Lat2-Terminus32";
            keyMap = "fr";
          };
        })
      ];
    };
  };
}
