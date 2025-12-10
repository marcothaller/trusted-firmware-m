{
  description = "Development environment for ST TF-M (Trusted Firmware-M)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          # Tools needed at build time (compilers, build systems)
          nativeBuildInputs = with pkgs; [
            cmake
            curl
            gcc-arm-embedded
            git
            gnumake
            just
            llvmPackages.clang
            llvmPackages.libclang
            llvmPackages.llvm
            pkg-config
            wget
          ];

          # Libraries needed by the software
          buildInputs = with pkgs; [
            openssl

            (python3.withPackages (ps: with ps; [
              pip
              cryptography
              cbor2
              click
              jinja2
              intelhex
              pyyaml
            ]))
          ];

          # This script runs every time you enter the shell
          shellHook = ''
            export Clang_DIR="${pkgs.llvmPackages.clang-unwrapped.dev}/lib/cmake/clang"

            echo "================================================"
            echo "   ST TF-M Development Environment (Cortex-M)   "
            echo "================================================"
            echo "Compiler: $(arm-none-eabi-gcc --version | head -n 1)"

            # --- Auto-Configuration Logic ---

            # 1. Check/Create Virtual Environment
            if [ ! -d ".venv" ]; then
              echo ">> Creating new Python virtual environment in .venv..."
              python3 -m venv .venv
              source .venv/bin/activate

              # 2. Check for TF-M requirements file and install
              if [ -f "tools/requirements.txt" ]; then
                echo ">> Found tools/requirements.txt. Installing dependencies..."
                pip install -r tools/requirements.txt
              else
                 echo ">> WARNING: tools/requirements.txt not found."
                 echo "   (If you haven't cloned the repo yet, ignore this. Run 'pip install -r tools/requirements.txt' after cloning.)"
              fi
            else
              # Existing environment - just activate
              source .venv/bin/activate
            fi

            echo "================================================"
            echo "Environment Ready."
            echo "Run 'just configure' to setup."
            echo "Run 'just build' to compile."
            echo "================================================"
          '';
        };
      }
    );
}
