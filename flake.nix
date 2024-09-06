{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };
    outputs = { nixpkgs, flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
        systems = nixpkgs.lib.platforms.unix;
        perSystem = { pkgs, ... }: {
            packages.default =
            let pabcnetc-zip = pkgs.fetchurl {
                url = "https://pascalabc.net/downloads/PABCNETC.zip";
                hash = "sha256-G4oWOnSbFysdbTAwimLlgbp3DTfV1RhL44959YqmJV0=";
            };
            pabcnetc = pkgs.stdenv.mkDerivation {
                name = "pabcnetc";
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
