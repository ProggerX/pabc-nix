{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };
    outputs = { nixpkgs, flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
        systems = nixpkgs.lib.platforms.unix;
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
            in pkgs.writeShellScriptBin "pabc-run" ''
                ${pkgs.mono}/bin/mono ${pabcnetc}/pabcnetc.exe $1 && ${pkgs.mono}/bin/mono ''${1%.*}.exe && rm ''${1%.*}.exe ''${1%.*}.exe.mdb
            '';
        };
    };
}
