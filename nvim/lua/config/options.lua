-- Editor settings. No plugins referenced here.

-- No remote plugins are used, so skip nvim's language-provider checks. The
-- Python one probes every python3 on PATH, pyenv shims included, the first
-- time a Python file opens, and blocked that open for about 3 s.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

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
-- Blinking block in every mode; the default is a bar in insert. A
-- terminal takes only "blink or not" from this, so the numbers do not
-- matter. WezTerm sets the real rate and fade (see wezterm.lua).
vim.opt.guicursor = 'a:block-blinkon500-blinkoff500'
-- Long lines wrap on screen at the window edge instead of scrolling
-- sideways. Only the display wraps, and the file keeps its long lines.
vim.opt.wrap = true
vim.opt.linebreak = true -- break between words, not mid-word
vim.opt.breakindent = true -- a wrapped line continues at its own indent

-- Show indentation and trailing spaces as faint dots, the way VS Code renders
-- whitespace. A tab shows as an arrow. Spaces between words stay blank.
vim.opt.list = true
vim.opt.listchars = { lead = '·', trail = '·', tab = '→ ', nbsp = '␣' }

-- indent
vim.opt.expandtab = true -- spaces, not tabs
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4 -- Tab inserts 4 spaces, Backspace removes them as one
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
