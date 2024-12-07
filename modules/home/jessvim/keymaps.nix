{
  lib,
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
