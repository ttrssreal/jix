{
  lib,
  ...
}:
{
  programs.nixvim.opts = {
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
