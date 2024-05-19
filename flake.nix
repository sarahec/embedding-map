{
  description = "Multi-agent AI/ML with CrewAI (and ollama for local use)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
       "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      #     flake.overlays.default = nixpkgs.lib.composeManyExtensions [
      #       inputs.ml-pkgs.overlays.torch-family
      #     ];

      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
          # This sets `pkgs` to a nixpkgs with allowUnfree option set.
          _module.args.pkgs = import nixpkgs {
            inherit system;
            #            overlays = [ inputs.self.overlays.default ];
            config = {
              allowUnfree = true;
              allowBroken = false;
              cudaSupport = false;
            };
          };

          devenv.shells.default = {

            # imports = [
            #   # This is just like the imports in devenv.nix.
            #   # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            #   # ./devenv-foo.nix
            # ];

            # https://devenv.sh/reference/options/
            languages.nix.enable = true;

            languages.python = {
              enable = true;
              # package = (pkgs.python3.withPackages (ps: [
              #   ps.numpy
              #   ps.finalfusion
              #   ps.wn
              #   ps.pip
              #   ps.pytest
              #   ps.tqdm
              #   ps.spacy
              #   #ps.spacy-models.en_core_web_sm
              #   ps.spacy_lookups_data
              # ]));
              venv = {
                enable = true;
                quiet = false;
                requirements = ''
                '';
              };
            };

            packages = [
              # (pkgs.ollama.override { acceleration = "cuda"; })

              pkgs.python311Packages.numpy
              pkgs.python311Packages.finalfusion
              pkgs.python311Packages.wn
              pkgs.python311Packages.pip
              pkgs.python311Packages.pytest
              pkgs.python311Packages.tqdm
              pkgs.python311Packages.spacy
              pkgs.python311Packages.spacy-models.en_core_web_sm
              pkgs.python311Packages.spacy-lookups-data

              # Load the model here as it has package dependencies not picked up in the custom Python build
              # pkgs.python311Packages.spacy-models.en_core_web_sm
              pkgs.zlib
            ];

            dotenv.disableHint = true;


            # NIX_LD_LIBRARY_PATH = pkgs.makeLibraryPath [
            #   pkgs.stdenv.cc.cc
            #   pkgs.zlib
            # ];
            # NIX_LD = pkgs.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
            # buildInputs = [ pkgs.python311 ];

            enterShell = ''
              export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/:${pkgs.zlib}/lib:$LD_LIBRARY_PATH
          '';
          };

        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}

