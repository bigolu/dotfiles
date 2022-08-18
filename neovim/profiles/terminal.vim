" vim:foldmethod=marker

" Exit if vim is not running in a terminal. I detect this by checking if the input
" to vim is coming from a terminal (also referred to as a tty).
if !has('ttyin')
  finish
endif

" Miscellaneous {{{
set confirm
set mouse=a
set display+=lastline
let &clipboard = 'unnamedplus'
set scrolloff=10
set jumpoptions=stack

" persist undo history to disk
set undofile

augroup Miscellaneous
  autocmd!
  autocmd BufEnter *
        \ if &ft ==# 'help' && (&columns * 10) / &lines > 31 | wincmd L | endif
  autocmd FileType sh setlocal keywordprg=man
  autocmd CursorHold * execute printf('silent! 2match WordUnderCursor /\V\<%s\>/', escape(expand('<cword>'), '/\'))
  " After a quickfix command is run, open the quickfix window , if there are results
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l*    lwindow
  " Put focus back in quickfix window after opening an entry
  autocmd FileType qf nnoremap <buffer> <CR> <CR><C-W>p
  " highlight trailing whitespace
  autocmd ColorScheme * highlight! link ExtraWhitespace Warning | execute 'match ExtraWhitespace /\s\+$/'
  autocmd OptionSet readonly if v:option_new | setlocal colorcolumn= | endif
  autocmd FileType qf,help setlocal colorcolumn=
augroup END

nnoremap <silent> <Leader>w <Cmd>wa<CR>
nnoremap <Leader>x <Cmd>wqa<CR>

" TODO: When tmux is able to differentiate between tab and ctrl+i this mapping should be updated.
" tmux issue: https://github.com/tmux/tmux/issues/2705#issuecomment-841133549
"
" move forward in the jumplist
nnoremap <C-p> <C-i>

" suspend vim and start a new shell
nnoremap <C-z> <Cmd>suspend<CR>
inoremap <C-z> <Cmd>suspend<CR>
xnoremap <C-z> <Cmd>suspend<CR>

" Decide which actions to take when the enter key is pressed.
function! GetEnterKeyActions()
  let autopairs_keys = v:lua.MPairs.autopairs_cr()
  " If only the enter key is returned, that means we aren't inside a pair.
  let isCursorInEmptyPair = v:lua.vim.inspect(autopairs_keys) !=# '"\r"'
  if isCursorInEmptyPair
    return autopairs_keys
  endif

  " The existence check ensures that the plugin vim-endwise was loaded
  if exists('g:loaded_endwise')
    return "\<CR>\<Plug>DiscretionaryEnd"
  endif

  return "\<CR>"
endfunction
inoremap <expr> <CR> GetEnterKeyActions()

set colorcolumn=120

set shell=sh

nnoremap <BS> <C-^>
" }}}

" Autoreload {{{
" neovim config files
let config_files = ['init.vim']
for profile in g:profiles
  let last_filename_segment = profile->split('/', 0)[-1]
  call add(config_files, last_filename_segment)
endfor

let config_file_pattern = config_files->join(',')
execute printf(
      \ 'autocmd! bufwritepost %s ++nested source $MYVIMRC | execute "colorscheme " . trim(execute("colorscheme"))',
      \ config_file_pattern
      \ )
" }}}

" Option overrides {{{
function! OverrideVimsDefaultFiletypePlugins()
  " Vim's default filetype plugins get run after filetype detection is
  " performed (i.e. ':filetype plugin on'). So in order to override
  " settings from vim's filetype plugins, the FileType autocommands
  " need to be registered after filetype detection.
  " Since this function gets called on the VimEnter event, we're
  " certain that filetype detection has already
  " happened because filetype detection gets triggered when the
  " plugin manager, vim-plug, finishes loading plugins.
  augroup OverrideFiletypePlugins
    autocmd!
    " Use vim help pages for keywordprg in vim files
    autocmd FileType vim setlocal keywordprg=:tab\ help
    autocmd FileType * setlocal textwidth=0
    autocmd FileType * setlocal wrapmargin=0
    autocmd FileType * setlocal formatoptions-=t formatoptions-=l
  augroup END
endfunction

augroup Overrides
  autocmd!
  autocmd VimEnter * call OverrideVimsDefaultFiletypePlugins()
augroup END
" }}}

" Utilities {{{
" Sets options to the specified new values and returns their old values.
" Useful for when you want to change an option and then restore its old value later on.
function! SetOptions(new_option_values)
  let old_option_values = {}

  for item in items(a:new_option_values)
    let option_name = item[0]
    let new_option_value = item[1]

    " store old value
    execute 'let old_option_value = ' . option_name
    let old_option_values[option_name] = old_option_value

    " set new value
    if type(new_option_value) == type("")
      " quote string values
      execute printf('let %s = "%s"', option_name, new_option_value)
    else
      execute printf('let %s = %s', option_name, new_option_value)
    endif
  endfor

  return old_option_values
endfunction
" }}}

" Windows {{{
" open new horizontal and vertical panes to the right and bottom respectively
set splitright splitbelow
nnoremap <Leader><Bar> <Cmd>vsplit<CR>
nnoremap <Leader>- <Cmd>split<CR>

" close a window, quit if last window
" also when closing a tab, go to the previously opened tab
nnoremap <silent> <expr> <leader>q  winnr('$') == 1 ? ':let g:last_tab = tabpagenr("#") <Bar> execute "q" <Bar> silent! execute "tabnext " . g:last_tab<CR>' : ':close<CR>'

" TODO: When tmux is able to differentiate between enter and ctrl+m this mapping should be updated.
" tmux issue: https://github.com/tmux/tmux/issues/2705#issuecomment-841133549
"
" maximize a window by opening it in a new tab
lua << EOF
local function toggle_maximize()
  if vim.w.is_maximized then
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Leader>', true, false, true) .. 'q')
    return
  end

  if vim.fn.winnr('$') == 1 then
    return
  end

  vim.cmd([[
    tab split
  ]])
  vim.w.is_maximized = true
end
vim.keymap.set('n', '<Leader>m', toggle_maximize)
EOF

augroup Window
  autocmd!

  " Automatically resize all splits to make them equal when the vim window is
  " resized or a new window is created/closed
  autocmd VimResized,WinNew,WinClosed,TabEnter * wincmd =
augroup END
" }}}

lua << EOF
-- Tab pages {{{
vim.keymap.set('n', '<Leader>t', function() vim.cmd('$tabnew') end, {silent = true})
vim.keymap.set('n', '<C-h>', vim.cmd.tabprevious, {silent = true})
vim.keymap.set('n', '<C-l>', vim.cmd.tabnext, {silent = true})

-- Switch tabs with <Leader><tab number>
for window_index=1,9 do
  vim.keymap.set('n', '<Leader>' .. window_index, function() vim.cmd('silent! tabnext ' .. tostring(window_index)) end)
end
-- }}}
EOF

" Indentation {{{
set expandtab
set autoindent smartindent
set smarttab
set shiftround " Round indent to multiple of shiftwidth (applies to < and >)
let s:tab_width = 2
let &tabstop = s:tab_width
let &shiftwidth = s:tab_width
let &softtabstop = s:tab_width
" }}}

" Folds {{{
set fillchars+=foldsep:\ ,foldclose:›,foldopen:⌄,fold:\ 
" Setting this so that the fold column gets displayed
set foldenable
set foldlevelstart=99
" Set max number of nested folds when 'foldmethod' is 'syntax' or 'indent'
set foldnestmax=1
" Minimum number of lines a fold must have to be able to be closed
set foldminlines=1
" Fold visually selected lines. 'foldmethod' must be set to 'manual' for this work.
vnoremap <Tab> zf
" Toggle opening and closing all folds
nnoremap <silent> <expr> <S-Tab> &foldlevel ? 'zM' : 'zR'
" auto-resize the fold column
set foldcolumn=auto:9
" Jump to the top and bottom of the current fold, without adding to the jump list
nnoremap [<Tab> [z
nnoremap ]<Tab> ]z
xnoremap [<Tab> [z
xnoremap ]<Tab> ]z
nnoremap <silent> <Tab> za
augroup Fold
  autocmd!
  autocmd FileType * setlocal foldmethod=indent
augroup END

set foldtext=FoldText()
function! FoldText()
  let window_width = winwidth(0)
  let gutter_width = getwininfo(win_getid())[0].textoff
  let line_width = window_width - gutter_width

  let fold_line_count = (v:foldend - v:foldstart) + 1
  let fold_description = printf('(%s)', fold_line_count)
  let fold_description_length = strdisplaywidth(fold_description)

  let separator_text = '⋯ '
  let separator_text_length = 2

  let line_text = getline(v:foldstart)
  " truncate if there isn't space for the fold description and separator text
  let max_line_text_length = line_width - (fold_description_length + separator_text_length)
  if strdisplaywidth(line_text) > max_line_text_length
    let line_text = line_text[: max_line_text_length - 1]
  endif
  let line_text_length = strdisplaywidth(line_text)

  return line_text . separator_text . fold_description
endfunction
" }}}

" Autocomplete {{{
set complete=.,w,b,u
" - show the completion menu even if there is only one suggestion
" - when autocomplete gets triggered, no suggestion is selected
set completeopt=menu,menuone,noselect
lua << EOF
  vim.o.pumheight = vim.o.scrolloff > 5 and vim.o.scrolloff - 2 or 5
EOF
" }}}

" Command line {{{
" on first wildchar press (<Tab>), show all matches and complete the longest common substring among them.
" on subsequent wildchar presses, cycle through matches
set wildmode=longest:full,full
set wildoptions=pum
set cmdheight=1
cnoreabbrev <expr> h getcmdtype() == ":" && getcmdline() == 'h' ? 'tab help' : 'h'
" }}}

" Search {{{
set nohlsearch
" show match position in command window, don't show 'Search hit BOTTOM/TOP'
set shortmess-=S shortmess+=s
" toggle search highlighting
nnoremap <silent> \ <Cmd>set hlsearch!<CR>
" }}}

" Sessions {{{
set sessionoptions-=blank sessionoptions-=options sessionoptions+=tabpages sessionoptions+=folds
let s:session_dir = g:data_path . '/sessions'
call mkdir(s:session_dir, "p")

function! RestoreOrCreateSession()
  " We omit the first element in the list since that will always be the path to the vim executable
  if v:argv[1:]->empty()
    let session_name =  substitute($PWD, '/', '%', 'g') . '%vim'
    let session_full_path = s:session_dir . '/' . session_name
    let session_cmd = filereadable(session_full_path) ? "source " : "mksession! "
    execute session_cmd . fnameescape(session_full_path)
    let s:session_active = 1
  endif
endfunction

function! SaveSession()
  if exists("s:session_active") && !empty(v:this_session)
    execute 'mksession! ' . fnameescape(v:this_session)
  endif
endfunction

augroup SaveAndRestoreSettings
  autocmd!
  " Restore session after vim starts. The 'nested' keyword tells vim to fire events
  " normally while this autocmd is executing. By default, no events are fired
  " during the execution of an autocmd to prevent infinite loops.
  autocmd VimEnter * ++nested call RestoreOrCreateSession()
  " save session before vim exits
  autocmd VimLeavePre * call SaveSession()
augroup END
" }}}

" Aesthetics {{{

" Miscellaneous {{{
set linebreak
set number relativenumber
set cursorline cursorlineopt=number,screenline
set showtabline=1
set wrap
set listchars=tab:¬-,space:· " chars to represent tabs and spaces when 'setlist' is enabled
set signcolumn=yes:2
set fillchars+=eob:\ 
" }}}

" Statusline {{{
set laststatus=3

function! GetDiagnosticCountForSeverity(severity)
  return v:lua.vim.diagnostic.get(0, {'severity': a:severity})->len()
endfunction
function! MyStatusLine()
  let item_separator = '%#StatusLineSeparator# ∙ '

  let line = '%#StatusLine#Ln %l'
  let column = '%#StatusLine#Col %c'
  let position = line . ', ' . column

  if getbufvar(bufnr('%'), "&mod")
    let modified_indicator = '*'
  else
    let modified_indicator = ''
  endif
  let file_info = '%#StatusLine#%y %f' . modified_indicator . '%w%q'

  if &fileformat !=# 'unix'
    let fileformat = printf('%%#StatusLineStandoutText#[%s]', &fileformat)
  endif

  if &readonly
    let readonly = '%#StatusLineStandoutText#[RO]'
  endif

  let diagnostic_count = {
        \ 'warning': GetDiagnosticCountForSeverity('warn'),
        \ 'error': GetDiagnosticCountForSeverity('error'),
        \ 'info': GetDiagnosticCountForSeverity('info'),
        \ 'hint': GetDiagnosticCountForSeverity('hint')
        \ }
  let diagnostic_list = []
  let error_count = diagnostic_count.error
  if (error_count > 0)
    let error = '%#StatusLineErrorText#' . 'ⓧ '. error_count
    call add(diagnostic_list, error)
  endif
  let warning_count = diagnostic_count.warning
  if (warning_count > 0)
    let warning = '%#StatusLineWarningText#' . 'ⓦ ' . warning_count
    call add(diagnostic_list, warning)
  endif
  let info_count = diagnostic_count.info
  if (info_count > 0)
    let info = '%#StatusLineInfoText#' . 'ⓘ ' . info_count
    call add(diagnostic_list, info)
  endif
  let hint_count = diagnostic_count.hint
  if (hint_count > 0)
    let hint = '%#StatusLineHintText#' . 'ⓗ ' . hint_count
    call add(diagnostic_list, hint)
  endif
  if !empty(diagnostic_list)
    let diagnostics = diagnostic_list->join(' ')
  endif

  let left_side_items = [file_info]
  if exists('fileformat')
    call add(left_side_items, fileformat)
  endif
  if exists('readonly')
    call add(left_side_items, readonly)
  endif
  let left_side = left_side_items->join(' ')

  let right_side_items = [position]
  if exists('diagnostics')
    call add(right_side_items, diagnostics)
  endif
  let right_side = right_side_items->join(item_separator)

  let statusline_separator = '%#StatusLine#%='
  let padding = '%#StatusLine# '

  return padding . left_side . statusline_separator . right_side . padding
endfunction
set statusline=%{%MyStatusLine()%}
" }}}

" Tabline {{{
function! Tabline()
  let tab_count = tabpagenr('$')
  let tabline = ''
  let left_divider_char = '▎'
  let right_divider_char = '🮇'

  for i in range(tab_count)
    let tab = i + 1
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]

    let bufname = bufname(bufnr)
    if bufname != ''
      let bufname = fnamemodify(bufname, ':t')
    else
      let bufname = '[No Name]'
    endif
    let bufname = tab . ' ' . bufname


    let tabline .= '%' . tab . 'T'
    let highlight = (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let separator_highlight = (tab == tabpagenr() ? '%#TabLineSeparator#' : '%#TabLineSeparatorNC#')
    let tabline .= separator_highlight . left_divider_char . '  ' . highlight . bufname . '  '
    if i < tab_count - 1
      let tabline .= ' %#StatusLineSeparator#' . highlight
    endif
  endfor
  let last_tab_number = tab_count
  let last_separator_highlight = (last_tab_number == tabpagenr() ? '%#TabLineLastSeparator#' : '%#TabLineLastSeparatorNC#')
  let tabline .= last_separator_highlight . right_divider_char . '%#TabLineFill#'
  let tabline = '%=' . tabline . '%='

  return tabline
endfunction
set tabline=%!Tabline()
" }}}

" Cursor {{{
function! SetCursor()
  " Block cursor in normal mode, thin line in insert mode, and underline in replace mode
  set guicursor=n-v:block-blinkon0,o:block-blinkwait0-blinkon200-blinkoff200,i-c:ver25-blinkwait0-blinkon200-blinkoff200,r:hor20-blinkwait0-blinkon200-blinkoff200
endfunction
call SetCursor()

function! ResetCursor()
  " reset terminal cursor to blinking bar
  set guicursor=a:ver25-blinkwait0-blinkon200-blinkoff200
endfunction

augroup Cursor
  autocmd!
  autocmd VimLeave * call ResetCursor()
  autocmd VimSuspend * call ResetCursor()
  autocmd VimResume * call SetCursor()
augroup END
lua << EOF
-- }}}

-- }}}

-- Diagnostics {{{
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    -- Make it high enough to have priority over vim-signify
    priority = 11,
  },
  update_in_insert = true,
  -- With this enabled, sign priorities will become: hint=11, info=12, warn=13, error=14
  severity_sort = true,
  float = {
    source = "if_many",
  },
})

local bullet = '•'
local signs = { Error = bullet, Warn = bullet, Hint = bullet, Info = bullet }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl})
end
-- }}}

-- Plugins {{{

-- Miscellaneous {{{
-- Add icons to the gutter to represent version control changes (e.g. new lines, modified lines, etc.)
Plug(
  'mhinz/vim-signify',
  {
    config = function()
      vim.keymap.set('n', '<Leader>vk', '<Cmd>SignifyHunkDiff<CR>')
    end,
  }
)
vim.g.signify_sign_add = '│'
vim.g.signify_sign_change = '│'
vim.g.signify_sign_show_count = 0

Plug(
  'windwp/nvim-autopairs',
  {
    config = function()
      require("nvim-autopairs").setup({
        -- Before        Input         After
        -- ------------------------------------
        -- {|}           <CR>          {
        --                                 |
        --                             }
        -- ------------------------------------
        -- Disabling this mapping since I will add it through nvim-cmp.
        map_cr = false,
      })
    end
  }
)

-- Seamless movement between vim windows and tmux panes.
Plug(
  'christoomey/vim-tmux-navigator',
  {
    config = function()
      vim.keymap.set('n', '<M-h>', '<Cmd>TmuxNavigateLeft<CR>', {silent = true})
      vim.keymap.set('n', '<M-l>', '<Cmd>TmuxNavigateRight<CR>', {silent = true})
      vim.keymap.set('n', '<M-j>', '<Cmd>TmuxNavigateDown<CR>', {silent = true})
      vim.keymap.set('n', '<M-k>', '<Cmd>TmuxNavigateUp<CR>', {silent = true})
    end
  }
)
vim.g.tmux_navigator_no_mappings = 1

Plug('inkarkat/vim-CursorLineCurrentWindow')

Plug(
  'ethanholz/nvim-lastplace',
  {
    config = function()
      require('nvim-lastplace').setup({})
    end,
  }
)

Plug(
  'dstein64/vim-startuptime',
  {
    config = function()
      vim.cmd([[
        cnoreabbrev <expr> StartupTime getcmdtype() == ":" && getcmdline() == 'StartupTime' ? 'tab StartupTime' : 'StartupTime'
      ]])
    end,
  }
)
vim.g.startuptime_tries = 100

-- Opens the OS color picker and inserts the chosen color into the buffer.
Plug('KabbAmine/vCoolor.vim')
vim.g.vcoolor_disable_mappings = 1

-- To get the vim help pages for vim-plug itself, you need to add it as a plugin
Plug('junegunn/vim-plug')

-- TODO: Using this so that substitutions made by vim-abolish get highlighted as I type them.
-- Won't be necessary if vim-abolish adds support for neovim's `inccommand`.
-- issue for `inccommand` support: https://github.com/tpope/vim-abolish/issues/107
Plug('markonm/traces.vim')
vim.g.traces_abolish_integration = 1

-- Automatically add closing keywords (e.g. function/endfunction in vimscript)
Plug(
  'RRethy/nvim-treesitter-endwise',
  {
    config = function()
      -- this way endwise triggers on 'o'
      vim.keymap.set('n', 'o', 'A<CR>', {remap = true})
    end
  }
)

-- Use the ANSI OSC52 sequence to copy text to the system clipboard
Plug(
  'ojroques/nvim-osc52',
  {
    config = function()
      require('osc52').setup({ silent = true, })

      vim.cmd([[
        augroup Osc52
          autocmd!
          autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' && (!empty($SSH_CLIENT) || !empty($SSH_TTY)) | lua require('osc52').copy_register('+') | endif
        augroup END
      ]])
    end,
  }
)

Plug(
  'lukas-reineke/virt-column.nvim',
  {
    config = function()
      require("virt-column").setup({ char = "│" })
      vim.cmd([[
        execute 'VirtColumnRefresh!'
        augroup VirtColumn
          autocmd!
          autocmd WinEnter,VimResized * VirtColumnRefresh!
        augroup END
      ]])
    end,
  }
)

-- lua library specfically for use in neovim
Plug('nvim-lua/plenary.nvim')

Plug(
  'iamcco/markdown-preview.nvim',
  {
    ['do'] = function()
      vim.fn['mkdp#util#install']()
    end,
  }
)

Plug(
  'nvim-telescope/telescope.nvim',
  {
    branch = '0.1.x',
    config = function()
      telescope = require('telescope')
      actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<Tab>"] = actions.move_selection_next,
              ["<S-Tab>"] = actions.move_selection_previous,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-n>"] = actions.cycle_history_next,
            },
          },
        },
      })

      vim.cmd([[
        augroup TelescopeNvim
          autocmd!
          autocmd FileType TelescopePrompt setlocal nocursorline
        augroup END
      ]])

      vim.keymap.set('n', '<Leader>h', '<Cmd>Telescope command_history<CR>')
      vim.keymap.set('n', '<Leader>b', '<Cmd>Telescope buffers<CR>')
      vim.keymap.set('n', '<Leader>/', '<Cmd>Telescope commands<CR>')
      vim.keymap.set('n', '<Leader>k', '<Cmd>Telescope help_tags<CR>')
      vim.keymap.set('n', '<Leader>g', '<Cmd>Telescope live_grep<CR>')
      vim.keymap.set('n', '<Leader>f', '<Cmd>Telescope find_files<CR>')
      vim.cmd([[
        command! HighlightTest Telescope highlights
      ]])
    end,
  }
)

Plug(
  'stevearc/dressing.nvim',
  {
    config = function()
      require('dressing').setup({
        select = {
          telescope = {
            layout_config = {
              width = 0.6,
              height = 0.6,
            },
            layout_strategy = 'center',
            sorting_strategy = 'ascending',
          },
        },
      })
    end,
  }
)

-- Use folds provided by a language server
Plug('pierreglaser/folding-nvim')

Plug(
  'folke/which-key.nvim',
  {
    config = function()
      require('which-key').setup({
        popup_mappings = {
          scroll_down = '<c-j>',
          scroll_up = '<c-k>',
        },
        -- hide mapping boilerplate
        hidden = {"<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ ", "<Plug>", "<plug>"}, 
        layout = {
          height = {
            max = math.floor(vim.o.lines * .30),
          },
        },
      })
    end,
  }
)

Plug('gpanders/editorconfig.nvim')

Plug('tpope/vim-repeat')

Plug(
  'nvim-treesitter/nvim-treesitter',
  {
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = false,
        },
        indent = {
          enable = false,
        },
        matchup = {
          enable = true,
          disable_virtual_text = true,
          include_match_words = true,
        },
        endwise = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
      })

      _G.MaybeSetTreeSitterFoldmethod = function()
        is_foldmethod_overridable = foldmethod ~= 'manual'
          and foldmethod ~= 'marker'
          and foldmethod ~= 'diff'
        if require('nvim-treesitter.parsers').has_parser() and is_foldmethod_overridable then
          vim.o.foldmethod = 'expr'
          vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
        end
      end
      vim.cmd([[
        augroup NvimTreeSitter
          autocmd!
          autocmd FileType * lua MaybeSetTreeSitterFoldmethod()
          autocmd VimEnter * lua InstallMissingParsers()
        augroup END
      ]])

      -- Install missing parsers
      -- TODO: treesitter commands don't seem to be available until 'VimEnter' so I'll call this function then.
      _G.InstallMissingParsers = function()
        local install_info = vim.fn.execute('TSInstallInfo')
        local uninstalled_parsers_count = vim.fn.count(install_info, 'not installed')
        if uninstalled_parsers_count > 0 then
          local install_prompt = string.format(
            '%s Tree-sitter parsers are not installed, would you like to install them now?',
            uninstalled_parsers_count
          )
          if uninstalled_parsers_count > 20 then
            install_prompt = install_prompt .. ' (Warning: It might take a while.)'
          end

          local should_install = vim.fn.confirm(install_prompt, "yes\nno") == 1
          if should_install then
            vim.cmd('TSInstall all')
          else
            vim.cmd([[
              echomsg 'No problem, you can always do it later by running `:TSInstall all`.'
            ]])
          end
        end
      end
    end,
    ['do'] = vim.cmd.TSUpdateSync,
  }
)

Plug(
  'terrortylor/nvim-comment',
  {
    config = function()
      require('nvim_comment').setup({
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      })
    end,
  }
)

Plug('tpope/vim-sleuth')

Plug(
  'blankname/vim-fish',
  {
    config = function()
      vim.cmd([[
        augroup VimFish
          autocmd!
          autocmd FileType fish setlocal foldmethod=expr
        augroup END
      ]])
    end,
  }
)

Plug('windwp/nvim-ts-autotag')

Plug('JoosepAlviste/nvim-ts-context-commentstring')

-- This plugin does two things:
-- 1. fix 'CursorHold' and 'CursorHoldI' autocmd events
-- bug: https://github.com/neovim/neovim/issues/12587
-- 2. decouple 'updatetime' from 'CursorHold' and 'CursorHoldI'
Plug('antoinemadec/FixCursorHold.nvim')
vim.g.cursorhold_updatetime = 500

Plug(
  'kosayoda/nvim-lightbulb',
  {
    config = function()
      require('nvim-lightbulb').setup({
        autocmd = {enabled = true},
        -- Giving it a higher priority than diagnostics and vcs changes
        sign = {priority = 15},
      })
    end,
  }
)
-- }}}
EOF

" Prose {{{
Plug 'junegunn/goyo.vim'
  let g:goyo_width = '90%'

  function! s:goyo_enter()
    if executable('tmux') && strlen($TMUX)
      silent !tmux set status off
    endif
    let g:goyo_old_option_values = SetOptions({
          \ '&showmode': 0,
          \ '&showcmd': 0,
          \ '&cmdheight': 0,
          \ '&winbar': '',
            \})
    function! GoyoSetHighlights()
      highlight clear WordUnderCursor
      highlight CursorLine cterm=NONE
      highlight clear MatchParen
      highlight FoldColumn ctermbg=NONE ctermfg=15
    endfunction
    call GoyoSetHighlights()
    " In case the colorscheme gets set after I set highlights this will set them again
    autocmd Colorscheme <buffer> call GoyoSetHighlights()
    silent! DelimitMateSwitch
    setlocal scrolloff=0
    setlocal conceallevel=2
    setlocal concealcursor=nvic
    syn match listItem "^\s*[-*]\s\+" contains=listBullet
    syn match listBullet "[-*]" contained conceal cchar=•
    syn match headerUnderline "[-=][-=][-=][-=][-=][-=]*" contains=headerUnderlineDash
    syn match headerUnderlineDash "[-=]" contained conceal cchar=―
    syn match emDash "\s\+--\s\+" contains=emDashSingleDash
    syn match emDashSingleDash "-" contained conceal cchar=―
    nnoremap <buffer> <silent> p p
    vnoremap <buffer> <silent> p p
    setlocal breakindent
    let &breakindentopt = 'shift:' . &tabstop
    function! GetBulletAction()
      let line = getline('.')

      " Insert a newline before the bullet
      if line =~# '^\s*[-*]\s\+$'
        return "\<Esc>\<S-o>\<Esc>j\<S-a>"
      endif

      " Create a bullet on the next line
      if line =~# '^\s*[-*]\s\+.*'
        let bullet_character = line->stridx('-') != -1 ? "-" : "*"
        return "\<CR>" . bullet_character . "\<Space>"
      endif

      return "\<CR>"
    endfunction
    inoremap <buffer> <expr> <CR> GetBulletAction()
    setlocal foldlevel=0
    setlocal foldmethod=marker
    inoremap <buffer> <Tab> <C-t>
    inoremap <buffer> <S-Tab> <C-d>
  endfunction

  function! s:goyo_leave()
    if executable('tmux') && strlen($TMUX)
      silent !tmux set status on
    endif
    call SetOptions(g:goyo_old_option_values)
    silent! DelimitMateSwitch
    silent! SignifyEnableAll
  endfunction

  augroup Goyo
    autocmd!

    autocmd User GoyoEnter ++nested call <SID>goyo_enter()
    autocmd User GoyoLeave ++nested call <SID>goyo_leave()

    " If I'm about to exit vim without turning off goyo, then turn it off now.
    " 'nested' is used so that the 'GoyoLeave' event fires
    autocmd VimLeavePre * ++nested if exists('#goyo') | Goyo | endif

    " On window resize, if goyo is active, resize the window
    autocmd VimResized * if exists('#goyo') | exe "normal \<c-w>=" | endif

    " Auto activate for files ending in '.txt'
    autocmd VimEnter * if @% =~# '.txt$' | execute 'Goyo' | endif
  augroup END
" }}}

" File explorer {{{
Plug 'preservim/nerdtree', {'on': []}
  let g:NERDTreeMouseMode = 2
  let g:NERDTreeShowHidden = 1
  let g:NERDTreeStatusline = -1
  let g:NERDTreeMinimalUI=1
  let g:NERDTreeAutoDeleteBuffer=0
  let g:NERDTreeHijackNetrw=1
  function! NerdTreeToggle()
    " Lazyload NERDTree
    if !exists('s:loaded_nerdtree')
      call plug#load('nerdtree')
      let s:loaded_nerdtree = 1
    endif

    " NERDTree is open so close it.
    if g:NERDTree.IsOpen()
      silent execute 'NERDTreeToggle'
      return
    endif

    " If NERDTree can't find the current file, it prints an error and doesn't open NERDTree.
    " In which case, I'll call 'NERDTree' which opens NERDTree to the current directory.
    silent execute 'NERDTreeFind'
    if !g:NERDTree.IsOpen()
      silent execute 'NERDTree'
    endif
  endfunction
  nnoremap <silent> <M-e> <Cmd>call NerdTreeToggle()<CR>
  function! CloseIfOnlyNerdtreeLeft()
    if !exists('b:NERDTree')
      return
    endif
    if tabpagewinnr(tabpagenr(), '$') != 1
      return
    endif

    if tabpagenr('$') > 1
      tabclose
    else
      execute 'q'
    endif
  endfunction
  augroup NerdTree
    autocmd!
    " open/close directories with 'h' and 'l'
    autocmd FileType nerdtree nmap <buffer> l o
    autocmd FileType nerdtree nmap <buffer> h o
    autocmd FileType nerdtree setlocal winbar=%#NerdTreeWinBar#%=Press\ ?\ for\ help%=
    autocmd BufEnter * call CloseIfOnlyNerdtreeLeft()
  augroup END
" }}}

" Autocomplete {{{
Plug 'hrsh7th/nvim-cmp'
  function! SetupNvimCmp()
    lua << EOF
    local cmp = require("cmp")
    local luasnip = require('luasnip')

    -- sources
    local buffer = {
      name = 'buffer',
      option = {
        keyword_length = 2,
        get_bufnrs = function()
          local buf = vim.api.nvim_get_current_buf()
          local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
          if byte_size > 1024 * 1024 then -- 1 Megabyte max
            return {}
          end

          return { buf }
        end,
      },
    }
    local nvim_lsp = { name = 'nvim_lsp' }
    local omni = { name = 'omni' }
    local path = {
      name = 'path',
      option = {
        get_cwd = function(params)
          return vim.fn.getcwd()
        end,
      },
    }
    local tmux = {
      name = 'tmux',
      option = { all_panes = true },
    }
    local cmdline = { name = 'cmdline' }
    local cmdline_history = { name = 'cmdline_history' }
    local dictionary = {
      name = 'dictionary',
      keyword_length = 2,
    }
    local lsp_signature = { name = 'nvim_lsp_signature_help' }
    local luasnip_source = {
      name = 'luasnip',
      option = {use_show_condition = false},
    }

    -- views
    local wildmenu = {
      entries = {
        name = 'wildmenu',
        separator = '|',
      },
    }

    -- helpers
    local is_cursor_preceded_by_nonblank_character = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        documentation = {
          winhighlight = 'NormalFloat:CmpNormal,FloatBorder:CmpBorder',
          border = 'rounded',
        },
        completion = {
          winhighlight = 'NormalFloat:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpCursorLine',
          border = 'rounded',
        },
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-a>'] = cmp.mapping.complete(),
        ['<CR>'] = function(fallback)
          -- TODO: Don't block <CR> if signature help is active
          -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/13
          if not cmp.visible()
              or not cmp.get_selected_entry()
              or cmp.get_selected_entry().source.name == 'nvim_lsp_signature_help'
              then
            fallback()
          else
            cmp.confirm({
              -- Replace word if completing in the middle of a word
              behavior = cmp.ConfirmBehavior.Replace,
              -- Don't select first item on CR if nothing was selected
              select = false,
            })
          end
        end,
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif is_cursor_preceded_by_nonblank_character() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<C-k>'] = cmp.mapping.scroll_docs(-4),
        ['<C-j>'] = cmp.mapping.scroll_docs(4),
        ["<C-h>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
        ["<C-l>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(1) then
            luasnip.jump(1)
          end
        end, { 'i', 's' }),
      }),
      sources = cmp.config.sources(
        {
          luasnip_source,
          nvim_lsp,
          buffer,
          omni,
          path,
          tmux,
          dictionary,
          lsp_signature,
        }
      )
    })

    cmp.setup.cmdline(
      '/',
      {
        view = wildmenu,
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          buffer,
          cmdline_history,
        }
      }
    )
    cmp.setup.cmdline(
      ':',
      {
        view = wildmenu,
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          {
            path,
            cmdline,
            buffer,
            cmdline_history,
          }
        )
      }
    )
    cmp.setup.cmdline(
      '?',
      {
        view = wildmenu,
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          {
            buffer,
            cmdline_history,
          }
        )
      }
    )
EOF
  endfunction
  autocmd VimEnter * call SetupNvimCmp()

Plug 'hrsh7th/cmp-omni'

Plug 'hrsh7th/cmp-cmdline'

Plug 'dmitmel/cmp-cmdline-history'

Plug 'andersevenrud/cmp-tmux'

Plug 'hrsh7th/cmp-buffer'

Plug 'hrsh7th/cmp-nvim-lsp'

Plug 'hrsh7th/cmp-path'

Plug 'uga-rosa/cmp-dictionary'
  function! SetupCmpDictionary()
    lua << EOF
    require("cmp_dictionary").setup({
      dic = {
        ['*'] = { '/usr/share/dict/words' },
      },
    })
EOF

    call timer_start(0, { -> execute('CmpDictionaryUpdate')})
  endfunction
  autocmd VimEnter * call SetupCmpDictionary()

Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

Plug 'L3MON4D3/LuaSnip'
  function! SetupLuaSnip()
    lua << EOF
    local types = require("luasnip.util.types")
    require('luasnip').config.set_config({
      history = true,
      delete_check_events = "TextChanged",
      ext_opts = {
        [types.insertNode] = {
          passive = {
            virt_text = {{'⮜', 'LuaSnipNode'}},
            hl_group = "LuaSnipNode",
          },
        },
      },
    })
    require('luasnip.loaders.from_vscode').lazy_load()
EOF
  endfunction
  autocmd VimEnter * call SetupLuaSnip()

Plug 'saadparwaiz1/cmp_luasnip'

Plug 'rafamadriz/friendly-snippets'
" }}}

" Tool Manager {{{
Plug 'williamboman/mason.nvim'
  function! SetupMason()
    lua << EOF
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "●",
          package_pending = "⧖",
          package_uninstalled = "○"
        },
        keymaps = {
          toggle_package_expand = "<Tab>",
        },
      },
      log_level = vim.log.levels.DEBUG,
    })

    vim.cmd([[
      augroup MasonNvim
        autocmd!
        autocmd FileType mason.nvim highlight clear WordUnderCursor
      augroup END
    ]])
EOF
  endfunction
  autocmd VimEnter * call SetupMason()

Plug 'williamboman/mason-lspconfig.nvim'
  function! SetupMasonLspConfig()
    lua << EOF
    require("mason-lspconfig").setup()

    local lspconfig = require('lspconfig')

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    local on_attach = function(client, buffer_number)
      capabilities = client.server_capabilities
      buffer_keymap = vim.api.nvim_buf_set_keymap
      keymap_opts = { noremap = true, silent = true }

      foldmethod = vim.o.foldmethod
      isFoldmethodOverridable = foldmethod ~= 'manual'
        and foldmethod ~= 'marker'
        and foldmethod ~= 'diff'
        and foldmethod ~= 'expr'
      if capabilities.foldingRangeProvider and isFoldmethodOverridable then
        require('folding').on_attach()
      end

      filetype = vim.o.filetype
      isKeywordprgOverridable = filetype ~= 'vim' and filetype ~= 'sh'
      if capabilities.hoverProvider and isKeywordprgOverridable then
        buffer_keymap(buffer_number, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", keymap_opts)
      end
    end

    local default_server_config = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    require("mason-lspconfig").setup_handlers({
      -- Default handler to be called for each installed server that doesn't have a dedicated handler.
      function (server_name)
        lspconfig[server_name].setup(default_server_config)
      end,

      ["jsonls"] = function()
        lspconfig.jsonls.setup(
          vim.tbl_deep_extend(
            'force',
            default_server_config,
            {
              settings = {
                json = {
                  schemas = require('schemastore').json.schemas(),
                  validate = { enable = true },
                },
              },
            }
          )
        )
      end,
 
      ["sumneko_lua"] = function()
        lspconfig.sumneko_lua.setup(
          vim.tbl_deep_extend(
            'force',
            default_server_config,
            {
              settings = {
                Lua = {
                  runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                  },
                  diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = {'vim'},
                  },
                  workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                  },
                  telemetry = {
                    -- Do not send telemetry data containing a randomized but unique identifier
                    enable = false,
                  },
                },
              },
            }
          )
        )
      end,
    })
EOF
  endfunction
  autocmd VimEnter * call SetupMasonLspConfig()

Plug 'neovim/nvim-lspconfig'
  function! SetupNvimLspconfig()
    LspStart
    autocmd WinEnter * LspStart
  endfunction
  autocmd VimEnter * call SetupNvimLspconfig()

Plug 'b0o/schemastore.nvim'
" }}}

" CLI -> LSP {{{
" A language server that acts as a bridge between neovim's language server client and commandline tools that don't
" support the language server protocol. It does this by transforming the output of a commandline tool into the
" format specified by the language server protocol.
Plug 'jose-elias-alvarez/null-ls.nvim'
  function! SetupNullLs()
    lua << EOF
    local null_ls = require('null-ls')
    local builtins = null_ls.builtins
    null_ls.setup({
      sources = {
        builtins.diagnostics.shellcheck.with({
          filetypes = { 'sh', 'bash' }
        }),
        builtins.diagnostics.fish,
        builtins.diagnostics.markdownlint,
      }
    })
EOF
  endfunction
  autocmd VimEnter * call SetupNullLs()
" }}}

" Colorscheme {{{
Plug 'arcticicestudio/nord-vim'
  let g:nord_bold = 1
  let g:nord_italic = 1
  let g:nord_italic_comments = 1
  let g:nord_underline = 1
  function! SetNordOverrides()
    highlight MatchParen ctermfg=blue cterm=underline ctermbg=NONE
    " Transparent vertical split
    highlight VertSplit ctermbg=NONE ctermfg=8
    " statusline colors
    highlight StatusLine ctermbg=8 ctermfg=NONE
    highlight StatusLineSeparator ctermfg=8 ctermbg=NONE cterm=reverse,bold
    highlight StatusLineErrorText ctermfg=1 ctermbg=8
    highlight StatusLineWarningText ctermfg=3 ctermbg=8
    highlight StatusLineInfoText ctermfg=4 ctermbg=8
    highlight StatusLineHintText ctermfg=5 ctermbg=8
    highlight StatusLineStandoutText ctermfg=3 ctermbg=8
    " autocomplete popupmenu
    highlight PmenuSel ctermfg=14 ctermbg=NONE cterm=reverse
    highlight Pmenu ctermfg=NONE ctermbg=24
    highlight PmenuThumb ctermfg=NONE ctermbg=15
    highlight PmenuSbar ctermbg=8
    highlight CursorLine ctermfg=NONE ctermbg=NONE cterm=underline
    " transparent background
    highlight Normal ctermbg=NONE
    highlight EndOfBuffer ctermbg=NONE
    " relative line numbers
    highlight LineNr ctermfg=15
    highlight LineNrAbove ctermfg=15
    highlight! link LineNrBelow LineNrAbove
    highlight WordUnderCursor ctermbg=8
    highlight! link IncSearch Search
    highlight TabLine ctermbg=8 ctermfg=15
    highlight TabLineSel ctermbg=8 ctermfg=7 cterm=italic
    highlight TabLineFill ctermbg=8
    highlight TabLineSeparator ctermbg=8 ctermfg=8
    highlight TabLineSeparatorNC ctermbg=8 ctermfg=8
    highlight TabLineLastSeparator ctermbg=8 ctermfg=8
    highlight TabLineLastSeparatorNC ctermbg=8 ctermfg=8
    highlight Comment ctermfg=15 ctermbg=NONE
    " This variable contains a list of 16 colors that should be used as the color palette for terminals opened in vim.
    " By unsetting this, I ensure that terminals opened in vim will use the colors from the color palette of the
    " terminal in which vim is running
    if exists('g:terminal_ansi_colors') | unlet g:terminal_ansi_colors | endif
    " Have vim only use the colors from the 16 color palette of the terminal in which it runs
    set t_Co=256
    highlight Visual ctermbg=8
    " Search hit
    highlight Search ctermfg=DarkYellow ctermbg=NONE cterm=reverse
    " Parentheses
    highlight Delimiter ctermfg=NONE ctermbg=NONE
    highlight ErrorMsg ctermfg=1 ctermbg=NONE
    highlight WarningMsg ctermfg=3 ctermbg=NONE
    highlight Error ctermfg=1 ctermbg=NONE cterm=undercurl
    highlight Warning ctermfg=3 ctermbg=NONE cterm=undercurl
    highlight! link SpellBad Error
    highlight! link NvimInternalError ErrorMsg
    highlight Folded ctermfg=15 ctermbg=NONE cterm=NONE
    highlight FoldColumn ctermfg=15 ctermbg=NONE
    highlight SpecialKey ctermfg=13 ctermbg=NONE
    highlight NonText ctermfg=15 ctermbg=NONE
    highlight NerdTreeWinBar ctermfg=15 ctermbg=NONE cterm=italic
    highlight! link VirtColumn VertSplit
    highlight DiagnosticSignError ctermfg=1 ctermbg=NONE
    highlight DiagnosticSignWarn ctermfg=3 ctermbg=NONE
    highlight DiagnosticSignInfo ctermfg=4 ctermbg=NONE
    highlight DiagnosticSignHint ctermfg=5 ctermbg=NONE
    highlight! link DiagnosticUnderlineError Error
    highlight! link DiagnosticUnderlineWarn Warning
    highlight DiagnosticUnderlineInfo ctermfg=4 ctermbg=NONE cterm=undercurl
    highlight DiagnosticUnderlineHint ctermfg=5 ctermbg=NONE cterm=undercurl
    highlight! CmpItemAbbrMatch ctermbg=NONE ctermfg=14
    highlight! link CmpItemAbbrMatchFuzzy CmpItemAbbrMatch
    highlight! CmpItemKind ctermbg=NONE ctermfg=15
    highlight! link CmpItemMenu CmpItemKind
    highlight CmpNormal ctermbg=NONE ctermfg=NONE
    highlight CmpBorder ctermbg=NONE ctermfg=15
    highlight! link CmpDocumentationNormal CmpNormal
    highlight! link CmpDocumentationBorder CmpBorder
    highlight CmpCursorLine ctermfg=14 ctermbg=NONE cterm=reverse
    highlight! TelescopeBorder ctermbg=16 ctermfg=16
    highlight! TelescopePromptTitle ctermbg=24 ctermfg=5 cterm=reverse,bold,nocombine
    highlight! TelescopeMatching ctermbg=NONE ctermfg=6
    highlight! TelescopeSelectionCaret ctermbg=8 ctermfg=8
    highlight! TelescopeNormal ctermbg=16
    highlight! TelescopePromptNormal ctermbg=24
    highlight! TelescopePromptBorder ctermbg=24 ctermfg=24
    highlight! TelescopePromptPrefix ctermbg=24 ctermfg=5
    highlight MasonHeader ctermbg=NONE ctermfg=4 cterm=reverse,bold
    highlight MasonHighlight ctermbg=NONE ctermfg=6
    highlight MasonHighlightBlockBold ctermbg=NONE ctermfg=6 cterm=reverse,bold
    highlight MasonMuted ctermbg=NONE ctermfg=NONE
    highlight MasonMutedBlock ctermbg=NONE ctermfg=15 cterm=reverse
    highlight MasonError ctermbg=NONE ctermfg=1
    highlight WhichKeyFloat ctermbg=24
    highlight NormalFloat ctermbg=32
    highlight LuaSnipNode ctermfg=11
  endfunction
  augroup NordVim
    autocmd!
    autocmd ColorScheme nord call SetNordOverrides()
    " The highlight I use for the word under the cursor and text selected in visual mode is the same.
    " This will disable the highlighting for the word under the cursor while I'm in visual mode.
    function! DisableWordUnderCursorHighlight()
      if mode(1) =~# '\v^(v|)'
        highlight WordUnderCursor ctermbg=NONE
        " When I leave visual mode, enable WordUnderCursor highlighting
        autocmd ModeChanged * ++once if mode(1) !~# '\v^(v|)' | highlight WordUnderCursor ctermbg=8 | endif
      endif
    endfunction
    autocmd ModeChanged * call DisableWordUnderCursorHighlight()
    " use nested so my colorscheme changes are loaded
    autocmd User PlugEndPost ++nested lua pcall(function() vim.cmd.colorscheme('nord') end)
  augroup END
" }}}

" Plugin Management {{{
" Helpers
let g:snapshot_file = g:data_path . '/vim-plug-snapshot.vim'
function! CreateSnapshotSync()
  execute printf('PlugSnapshot! %s', g:snapshot_file)

  " Edit the snapshot file so that it updates plugins synchronously
  execute "silent! !sed --in-place --follow-symlinks 's/PlugUpdate\\!/PlugUpdate\\! --sync/g' " . g:snapshot_file
endfunction
command! PlugSnapshotSync call CreateSnapshotSync()
function! UpdateAndSnapshotSync()
  PlugUpdate --sync
  call CreateSnapshotSync()
endfunction
command! PlugUpdateAndSnapshot call UpdateAndSnapshotSync()
function! PlugRestore()
  if !filereadable(g:snapshot_file)
    echoerr printf("Restore failed. Unable to read the snapshot file '%s'", g:snapshot_file)
    return
  endif
  execute printf('source %s', g:snapshot_file)
endfunction
command! PlugRestore call PlugRestore()

" Install any plugins that have been registered, but aren't installed
function! InstallMissingPlugins()
  let plugs = get(g:, 'plugs', {})
  let missing_plugins = filter(deepcopy(plugs), {plugin_name, plugin_info -> !isdirectory(plugin_info.dir)})
  if empty(missing_plugins)
    return
  endif

  let install_prompt = "The following plugins are not installed:\n" . join(keys(missing_plugins), ", ") . "\nWould you like to install them?"
  let should_install = confirm(install_prompt, "yes\nno") == 1
  if should_install
    if filereadable(g:snapshot_file)
      " Sourcing the snapshot will set plugins to the commit specified in the snapshot
      " and install any missing ones.
      execute printf('source %s', g:snapshot_file)

      " Any plugins that don't have a commit specified must not be in the snapshot.
      " In which case, we'll make a new snapshot.
      let plugins_without_commit = filter(deepcopy(plugs), {plugin_name, plugin_info -> !has_key(plugin_info, 'commit')})
      if !empty(plugins_without_commit)
        call CreateSnapshotSync()
      endif
    else
      PlugInstall --sync
    endif
  endif
endfunction

augroup PostPluginLoadOperations
  autocmd!
  autocmd User PlugEndPost call InstallMissingPlugins()
augroup END
" }}}

" }}}
