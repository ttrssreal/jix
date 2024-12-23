{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
      comment.enable = true;
      lualine.enable = true;
      web-devicons.enable = true;

      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      nvim-tree = {
        enable = true;
        autoReloadOnWrite = true;
        openOnSetup = true;
        disableNetrw = true;
        git.enable = true;
        sortBy = "case_sensitive";
      };

      telescope = {
        enable = true;
        settings.defaults.mappings.i = {
          "<C-j>".__raw = "require('telescope.actions').move_selection_next";
          "<C-k>".__raw = "require('telescope.actions').move_selection_previous";
        };
      };

      treesitter = {
        enable = true;
        nixvimInjections = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
            settings.check.command = "clippy";
          };
          clangd.enable = true;
        };
      };
    };
  };

  # for live_grep
  home.packages = [ pkgs.ripgrep ];
}
