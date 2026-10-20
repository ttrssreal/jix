{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    {
      inputs',
      pkgs,
      config,
      system,
      ...
    }:
    {
      jix.overlays = [
        (final: prev: {
          bluetooth-connect = final.callPackage ./bluetooth-connect.nix { };

          pwndbg-unwrapped = inputs'.pwndbg.packages.pwndbg;
          pwndbg = final.callPackage ./jesspwn { };

          inherit (inputs.erosanix.lib.${system}) mkWindowsApp;
          xgpro = final.callPackage ./xgpro.nix { };

          binary-ninja = final.callPackage ./binary-ninja.nix { };

          pwninit = final.callPackage ./pwninit {
            pwninit-unwrapped = prev.pwninit;
          };

          pwntools = prev.pwntools.override {
            debugger = config.packages.pwndbg;
          };

          jess-scripts = {
            nix-conf-edit = final.callPackage ./scripts/nix-conf-edit.nix { };
            nixpkgs-print-out-paths = final.callPackage ./scripts/nixpkgs-print-out-paths.nix { };
            edit-managed-file = final.callPackage ./scripts/edit-managed-file.nix { };
          };

          resetti = final.callPackage ./resetti.nix { };

          mc-monitor = final.callPackage ./mc-monitor.nix { };

          # Use the development release (has the Akahu provider)
          firefly-iii-data-importer = prev.firefly-iii-data-importer.overrideAttrs (prevAttrs: rec {
            src = final.fetchFromGitHub {
              owner = "firefly-iii";
              repo = "data-importer";
              tag = "develop-20260901";
              hash = "sha256-i9pQBGGpIfXc+fd+t5cfcVcv4ZrWsZa/uMK065xmpvI=";
            };

            vendorHash = "sha256-7Cr9u9+BImRTh6l6srT7BldDvQCBwtQuCHEHrYn7aCQ=";

            npmDeps = final.fetchNpmDeps {
              inherit src;
              name = "${prevAttrs.pname}-npm-deps";
              hash = "sha256-UKEm+4DNbQbWpDVg65BTdyGeisC/EFyJNcbxkqiLOrs=";
            };
          });

          nvim =
            (inputs.nixvim.lib.evalNixvim {
              inherit system;

              modules = [
                {
                  clipboard = {
                    register = "unnamedplus";
                    providers.xclip.enable = true;
                  };

                  # enable = true;
                  # defaultEditor = true;
                  colorschemes.tokyonight.enable = true;

                  globals = {
                    mapleader = " ";
                    maplocalleader = "\\";
                  };

                  filetype.extension.sage = "python";

                }
                {
                  keymaps =
                    let
                      mkKeymap =
                        mode: options: mapping:
                        lib.attrsets.mapAttrsToList (key: action: {
                          inherit
                            key
                            action
                            options
                            mode
                            ;
                        }) mapping;

                      normalMaps =
                        mkKeymap "n"
                          {
                            noremap = true;
                            silent = true;
                          }
                          {
                            "<leader>f" = ":NvimTreeToggle<CR>";
                            "<leader>s".__raw = ''
                              function()
                                local api = require('nvim-tree.api')

                                local node = api.tree.get_node_under_cursor()
                                if not node then
                                  vim.notify("No node under cursor", vim.log.levels.WARN)
                                  return
                                end

                                local function live_grep(path)
                                  require('telescope.builtin').live_grep({
                                    search_dirs = { path },
                                    prompt_title = "Searching in " .. path,
                                  })
                                end

                                if node.type == "link" then
                                  live_grep(node.link_to)
                                else
                                  local path = vim.fn.fnamemodify(node.absolute_path, ":.");
                                  live_grep(path, "Searching in " .. path)
                                end
                              end
                            '';
                            "<C-h>" = "<C-w>h";
                            "<C-j>" = "<C-w>j";
                            "<C-k>" = "<C-w>k";
                            "<C-l>" = "<C-w>l";
                            "<leader>sv" = ":vsplit<CR>";
                            "<leader>sh" = ":split<CR>";
                            "<leader>m" = ":Telescope find_files<CR>";
                            "<leader>n" = ":Telescope live_grep<CR>";
                            "<leader>b" = ":Telescope buffers<CR>";
                          };

                      visualMaps = mkKeymap "v" { } {
                        "<" = "<gv";
                        ">" = ">gv";
                      };
                    in
                    lib.lists.flatten [
                      normalMaps
                      visualMaps
                    ];
                }

                {
                  opts = {
                    tabstop = 2;
                    shiftwidth = 2;
                    softtabstop = 2;
                    expandtab = true;
                    smartindent = true;
                    wrap = false;

                    incsearch = true;
                    ignorecase = true;
                    smartcase = true;
                    hlsearch = false;

                    number = true;
                    relativenumber = true;
                    termguicolors = true;
                    colorcolumn = "100";
                    signcolumn = "yes";
                    cmdheight = 1;
                    scrolloff = 10;
                    completeopt = "menuone,noinsert,noselect";

                    hidden = true;
                    errorbells = false;
                    swapfile = false;
                    backup = false;
                    undodir = {
                      __raw = ''vim.fn.expand("~/.vim/undodir")'';
                    };
                    undofile = true;
                    backspace = "indent,eol,start";
                    splitright = true;
                    splitbelow = true;
                    autochdir = false;

                    modifiable = true;
                    guicursor = lib.concatStrings [
                      "n-v-c"
                      ":block,i-ci-ve"
                      ":ver25,r-cr"
                      ":hor20,o"
                      ":hor50,a"
                      ":blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm"
                      ":block-blinkwait175-blinkoff150-blinkon175"
                    ];
                    encoding = "UTF-8";
                  };
                }

                {
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
                        mapping = {
                          __raw = ''
                            cmp.mapping.preset.insert({
                              ["<Tab>"] = cmp.mapping(function(fallback)
                                if cmp.visible() then
                                  cmp.select_next_item()
                                else
                                  fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
                                end
                              end, { "i", "s" }),
                              ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                            })
                          '';
                        };
                      };
                    };

                    nvim-tree = {
                      enable = true;
                      openOnSetup = true;
                      settings = {
                        git.enable = true;
                        sort_by = "case_sensitive";
                        auto_reload_on_write = true;
                        disable_netrw = true;
                        # updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
                        sync_root_with_cwd = false;
                      };
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

                  extraPlugins = [
                    final.vimPlugins.vim-tidal
                  ];
                }
              ];
            }).config.build.package;
        })
      ];

      packages = {
        inherit (pkgs)
          bluetooth-connect
          pwndbg
          xgpro
          binary-ninja
          pwntools
          pwninit
          resetti
          mc-monitor
          nvim
          ;

        inherit (pkgs.jess-scripts)
          nix-conf-edit
          nixpkgs-print-out-paths
          edit-managed-file
          ;
      };
    };
}
