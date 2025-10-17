{
  lib,
  config,
  ...
}:
{
  programs.nixvim.keymaps =
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
            "<leader>s" = config.lib.nixvim.mkRaw ''
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
