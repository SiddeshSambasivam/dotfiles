-- Editor settings. No plugins referenced here.

-- files
vim.opt.undofile = true -- undo history survives closing the file
vim.opt.swapfile = false
vim.opt.backup = false

-- display
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes' -- always reserved, so text does not jump
vim.opt.cursorline = true
vim.opt.scrolloff = 8 -- keep 8 lines visible above and below the cursor
vim.opt.termguicolors = true
vim.opt.wrap = false

-- indent
vim.opt.expandtab = true -- spaces, not tabs
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true -- a capital letter makes the search case-sensitive
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.clipboard = 'unnamedplus' -- y and p use the macOS clipboard
vim.opt.mouse = 'a'
vim.opt.updatetime = 250
