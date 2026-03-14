{
  description = "vainim - personal Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # Expose the config directory for symlinking
      # Usage:
      #   inputs.vainim = { url = "github:wowvain-dev/vainim"; flake = true; };
      #   xdg.configFile."nvim".source = inputs.vainim.packages.${system}.config;
      packages = forAllSystems (system: {
        config = self;
        default = self;
      });

      # Home Manager module for turnkey integration
      homeManagerModules.default = { pkgs, lib, ... }: {
        xdg.configFile."nvim" = {
          source = self;
          recursive = true;
        };

        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          extraPackages = with pkgs; [
            # Treesitter compilation
            gcc
            tree-sitter

            # LSP servers (what mason would install on non-NixOS)
            lua-language-server
            basedpyright
            nodePackages.typescript-language-server
            vscode-langservers-extracted  # html, css, json, eslint
            yaml-language-server
            bash-language-server
            clang-tools                   # clangd
            rust-analyzer
            marksman                      # markdown

            # Formatters
            stylua
            prettierd
            shfmt
            taplo

            # Linters
            ruff
            luajitPackages.luacheck
            shellcheck
            markdownlint-cli
            yamllint

            # DAP adapters
            python3Packages.debugpy
            vscode-extensions.vadimcn.vscode-lldb  # codelldb
          ];
        };
      };
    };
}
