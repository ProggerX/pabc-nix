{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };
    outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
        systems = ["x86_64-linux" "aarch64-linux"];
        perSystem = { pkgs, ... }: {
            packages.default =
            let pabcnetc-zip = ./PABCNETC.zip;
            pabcnetc = pkgs.stdenv.mkDerivation {
                pname = "pabcnetc";
				version = "1.0.0";
                src = pabcnetc-zip;
                phases = [ "installPhase" ];
                installPhase = ''
                    mkdir $out
                    cd $out
                    ${pkgs.p7zip}/bin/7z x -y $src
                '';
            };
            in pkgs.writeShellApplication {
				name = "pabc-run";
				runtimeInputs = with pkgs; [ mono wine64 ];
				text = ''
                ${pkgs.mono}/bin/mono ${pabcnetc}/pabcnetc.exe "$1" &&
				"$2" "''${1%.*}".exe;
				rm "''${1%.*}".exe "''${1%.*}".exe.mdb
            	'';
			};
        };
    };
}
