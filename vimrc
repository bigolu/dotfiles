" Section: Settings
" -------------------------------------
" env variables
let $VIMHOME = $HOME . '/.vim/'

" misc.
set confirm
set encoding=utf8
scriptencoding utf-8
syntax enable
set mouse=a
set backspace=indent,eol,start
set linebreak
set cursorline
set pastetoggle=<F2>
set laststatus=2
set number relativenumber
set incsearch
set termguicolors
set hidden
set autoindent
set smartindent
set complete=.,w,b,u
set smarttab
set nrformats-=octal
set ttimeout
set ttimeoutlen=100
set display=lastline
set clipboard=unnamed
set nocompatible
set wildmenu
set wildmode=list,longest:longest
set nojoinspaces " Prevents inserting two spaces after punctuation on a join (J)
set shiftround " Round indent to multiple of shiftwidth (applies to < and >)
set autoread " Re-read file if it is changed by an external program
set nolazyredraw
set foldmethod=syntax
set dictionary+=/usr/share/dict/words
set foldlevel=20
set scrolloff=10
set wrap
set updatetime=800
set cmdheight=3
set sessionoptions-=blank sessionoptions-=options sessionoptions+=tabpages
let &grepprg = executable('rg') ? 'rg --vimgrep --smart-case --follow' : 'internal'

" turn off bell sounds
set belloff+=all

" show the completion [menu] even if there is only [one] suggestion
" by default, [no] suggestion is [select]ed
" Use [popup] instead of [preview] window
set completeopt+=menuone,noselect,popup completeopt-=preview

set shortmess+=Icm " don't display messages related to completion

set formatoptions+=j " Delete comment character when joining commented lines

" set swapfile directory
let &directory = $VIMHOME . 'swapfile_dir/'
call mkdir(&directory, "p")

" persist undo history to disk
let &undodir = $VIMHOME . 'undo_dir/'
call mkdir(&undodir, "p")
set undofile

" set backup directory
let &backupdir = $VIMHOME . 'backup_dir/'
call mkdir(&backupdir, "p")
set backup

" tab setup
set expandtab
let s:tab_width = 2
let &tabstop = s:tab_width
let &shiftwidth = s:tab_width
let &softtabstop = s:tab_width

set ignorecase smartcase " searching is only case sensitive when the query contains an uppercase letter

set splitright splitbelow " open new horizontal and vertical panes to the right and bottom respectively

let &ttymouse = has('mouse_sgr') ? 'sgr' : 'xterm2' " enable mouse mode while in tmux

" Section: Mappings
" NOTE: "<C-U>" is added to a lot of mappings to clear the visual selection
" that is being added automatically. Without it, trying to run a command
" through :Cheatsheet won't work.
" see: https://stackoverflow.com/questions/13830874/why-do-some-vim-mappings-include-c-u-after-a-colon
" -------------------------------------
" Map the output of these key combinations to their actual names
" to make mappings that use these key combinations easier to understand
" WARNING: When doing this you should turn off any plugin that
" automatically adds closing braces since it might accidentally
" add a closing brace to an escape sequence
nmap l <M-l>
nmap h <M-h>
nmap j <M-j>
nmap k <M-k>
vmap l <M-l>
vmap h <M-h>
vmap j <M-j>
vmap k <M-k>
nmap [1;2D <S-Left>
nmap [1;2C <S-Right>
nmap [1;2B <S-Down>
nmap [1;2A <S-Up>
nmap [1;5D <C-Left>
nmap [1;5C <C-Right>
nmap [1;5B <C-Down>
nmap [1;5A <C-Up>
nmap <C-@> <C-Space>
vmap <C-@> <C-Space>
imap <C-@> <C-Space>

let g:mapleader = "\<Space>"
inoremap jk <Esc>
nnoremap <silent> <Leader>\ :nohl<CR>
nnoremap <silent> <Leader>w :wa<CR>
nnoremap <Leader>r :source $MYVIMRC<CR>
nnoremap <Leader>x :wqa<CR>
nnoremap <silent> <Leader>i :IndentLinesToggle<CR>
nnoremap <silent> <Leader>t :vimgrep /TODO/j **/*<CR>

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>

" LSP
nnoremap <Leader>lis :<C-U>LspInstallServer<CR>
nnoremap <Leader>ls :<C-U>LspStatus<CR>
nnoremap <Leader>lh :<C-U>LspHover<CR>
nnoremap <Leader>ld :<C-U>LspDefinition<CR>
nnoremap <Leader>lrn :<C-U>LspRename<CR>
nnoremap <Leader>lrf :<C-U>LspReferences<CR>
nnoremap <Leader>lca :<C-U>LspCodeActionSync<CR>
nnoremap <Leader>lo :<C-U>LspCodeActionSync source.organizeImports<CR>

" buffer navigation
noremap <silent> <C-Left> :bp<CR>
noremap <silent> <C-Right> :bn<CR>

" tab navigation
nnoremap <silent> <S-Left> :tabprevious<CR>
nnoremap <silent> <S-Right> :tabnext<CR>

" wrap a function call in another function call.
let @w='hf)%bvf)S)i'

" remove all trailing whitespace
nnoremap <Leader>cc :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" move ten lines at a time by holding ctrl and a directional key
nnoremap <C-h> 10h
nnoremap <C-j> 10j
nnoremap <C-k> 10k
nnoremap <C-l> 10l
vnoremap <C-j> 10j
vnoremap <C-h> 10h
vnoremap <C-k> 10k
vnoremap <C-l> 10l

" toggle folds
let $unrol=1
function UnrolMe()
  if $unrol==0
    :exe "normal zR"
    let $unrol=1
  else
    :exe "normal zM"
    let $unrol=0
  endif
endfunction
nnoremap <silent> <Leader>z :call UnrolMe()<CR>

nnoremap " :vsplit<CR>
nnoremap % :split<CR>

function! CloseBufferAndPossiblyWindow()
  " If the current buffer is a help or preview page or there is only one window and one buffer
  " left, then close the window and buffer.
  " Otherwise close the buffer and preserve the window
  if &l:filetype ==? "help"
        \ || (len(getbufinfo({'buflisted':1})) == 1 && winnr('$') == 1)
        \ || getwinvar('.', '&previewwindow') == 1
    execute "silent Sayonara"
  elseif &l:filetype ==? "qf"
    " Close preview window when the qf window is closed (quickr-preview.vim)
    execute "silent Sayonara"
    exe "pclose"
  else
    execute "silent Sayonara!"
  endif
endfunction

nnoremap <silent> <leader>q :call CloseBufferAndPossiblyWindow()<CR>
" close window
nnoremap <silent> <leader>Q :q<CR>

function! CleanNoNameEmptyBuffers()
  let buffers = filter(
        \ range(1, bufnr('$')),
        \ 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])'
        \ )
  if !empty(buffers)
    exe 'bd '.join(buffers, ' ')
  endif
endfunction
autocmd BufEnter * call CleanNoNameEmptyBuffers()

" Combine enter key (<CR>) mappings from my plugins
imap <expr> <CR>
  \ pumvisible() ?
    \ asyncomplete#close_popup() :
    \ delimitMate#WithinEmptyPair() ?
      \ "\<C-R>=delimitMate#ExpandReturn()\<CR>" :
      \ "\<CR>\<Plug>DiscretionaryEnd"

" Keybind cheatsheet
let s:command_list = [
      \ "Show references [<Leader>lrf]", "Rename symbol [<Leader>lrn]",
      \ "Next buffer [<S-l>]", "Previous buffer [<S-h>]",
      \ "Next tab [<S-Up>]", "Previous tab [<S-Down>]",
      \ "Remove trailing whitespace [<F5>]", "Shift line(s) up [<C-Up>]",
      \ "Shift line(s) down [<C-Down>]", "Toggle folds [<Leader>z]",
      \ "Vertical split [|]", "Horizontal split [_]",
      \ "Close buffer [<Leader>q]", "Close window [<Leader>Q]",
      \ ]
function! CheatsheetSink(command)
  " Extract the keybinding which is always between brackets at the end
  let l:keybind = a:command[ match(a:command, '\[.*\]$') + 1 : -2 ]
  " Replace '<leader>' with mapleader
  let l:keybind = substitute(l:keybind, '<leader>', '\<Space>', 'g')
  " If the command starts with space, put a 1 before it (:h normal)
  " TODO: handle multiple spaces
  if l:keybind =~? '^<space>'
    let l:keybind = 1 . l:keybind
  endif
  " Escape angle bracket sequences, like <C-h>, by prepending a '\'
  let l:keybind = substitute(l:keybind, '<[a-z,0-9,-]*>', '\="\\" . submatch(0)', 'g')
  " Escape sequences will only be parsed by vim if the string is in
  " double quotes so this line will make it a double quoted string,
  " see: https://vi.stackexchange.com/questions/10916/execute-normal-command-doesnt-work
  let l:keybind = eval('"' . l:keybind . '"')

  exe "normal " . l:keybind
endfunction

" Section: Plugins
" -------------------------------------
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
call plug#begin('~/.vim/plugged')

" Colorschemes
""""""""""""""""""""""""""""""""""""
" light and dark
Plug 'lifepillar/vim-solarized8' | Plug 'arcticicestudio/nord-vim'

" Text Manipulation
""""""""""""""""""""""""""""""""""""
" Automatically add closing keywords (e.g. function/endfunction in vimscript)
Plug 'tpope/vim-endwise'
  let g:endwise_no_mappings = 1
" Automatically close html tags
Plug 'alvan/vim-closetag'
" Automatically insert closing braces/quotes
Plug 'Raimondi/delimitMate'
  " Given the following line (where | represents the cursor):
  "   function foo(bar) {|}
  " Pressing enter will result in :
  " function foo(bar) {
  "   |
  " }
  let g:delimitMate_expand_cr = 0
" Makes it easier to manipulate brace/bracket/quote pairs by providing commands to do common
" operations like change pair, remove pair, etc.
Plug 'tpope/vim-surround'
" For swapping two pieces of text
Plug 'tommcdo/vim-exchange'

" Colors
""""""""""""""""""""""""""""""""""""
" Detects color strings (e.g. hex, rgba) and changes the background of the characters
" in that string to match the color. For example, in the following sample line of CSS:
"   p {color: red}
" The background color of the string "red" would be the color red.
Plug 'ap/vim-css-color'
" Opens the OS color picker and inserts the chosen color into the buffer.
Plug 'KabbAmine/vCoolor.vim'

" Buffer/tab/window management
""""""""""""""""""""""""""""""""""""
" Commands for closing buffers while keeping/destroying the window it was displayed in.
Plug 'mhinz/vim-sayonara'
" Easy movement between vim windows and tmux panes.
Plug 'christoomey/vim-tmux-navigator'
  let g:tmux_navigator_no_mappings = 1
  nnoremap <M-h> :TmuxNavigateLeft<cr>
  nnoremap <M-l> :TmuxNavigateRight<cr>
  nnoremap <M-j> :TmuxNavigateDown<cr>
  nnoremap <M-k> :TmuxNavigateUp<cr>

" Version control
""""""""""""""""""""""""""""""""""""
" Add icons to the gutter to signify version control changes (e.g. new lines, modified lines, etc.)
Plug 'mhinz/vim-signify'

" Misc.
""""""""""""""""""""""""""""""""""""
" Status line and tab line
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail'
" File explorer
Plug 'preservim/nerdtree', {'on': ['NERDTreeTabsToggle']}
  let g:NERDTreeMouseMode=2
  let g:NERDTreeWinPos="right"
  let g:NERDTreeShowHidden=1
  Plug 'jistr/vim-nerdtree-tabs', {'on': 'NERDTreeTabsToggle'}
    let g:nerdtree_tabs_autofind = 1
    nnoremap <silent> <Leader>n :NERDTreeTabsToggle<CR>
" A tool for profiling vim's startup time. Useful for finding slow plugins.
Plug 'tweekmonster/startuptime.vim'
" Visualizes indentation in the buffer. Useful for fixing incorrectly indented lines.
Plug 'Yggdroot/indentLine'
  let g:indentLine_char = '▏'
  let g:indentLine_setColors = 0
  let g:indentLine_enabled = 0

" Fuzzy finder
""""""""""""""""""""""""""""""""""""
if executable('fzf')
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    let &runtimepath .= ',' . exepath('fzf')
    " Customize fzf colors to match color scheme
    " - fzf#wrap translates this to a set of `--color` options
    let g:fzf_colors =
    \ { 'fg': ['fg', 'Normal'], 'bg': ['bg', 'Normal'], 'hl': ['fg', 'Comment'],
      \ 'fg+': ['fg', 'CursorLine', 'CursorColumn', 'Normal'], 'bg+': ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+': ['fg', 'Statement'], 'info': ['fg', 'PreProc'], 'border': ['fg', 'Ignore'],
      \ 'prompt': ['fg', 'Conditional'], 'pointer': ['fg', 'Exception'], 'marker': ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'], 'header': ['fg', 'Comment'] }
    Plug 'junegunn/fzf.vim'
  " Cheatsheet
  command! -bang -nargs=* Cheatsheet call
        \ fzf#run(fzf#wrap({
        \ 'source': s:command_list,
        \ 'sink': function('CheatsheetSink')}))
  nnoremap <Leader><Leader> :Cheatsheet<CR>
  " Buffer
  nnoremap <Leader>b :Buffers<CR>
  " Marks
  nnoremap <Leader>m :Marks<CR>
  if executable('rg')
    let s:fzfFindLineCommand = 'rg '.$FZF_RG_OPTIONS
    let s:fzfFindFileCommand = 'rg '.$FZF_RG_OPTIONS.' --files'
    " recursive grep
    function! FindLineResultHandler(result)
      let l:resultTokens = split(a:result, ':')
      let l:filename = l:resultTokens[0]
      let l:lineNumber = l:resultTokens[1]
      execute 'silent edit '.l:filename
      execute l:lineNumber
    endfunction
    command! -bang -nargs=* FindLine call
          \ fzf#vim#grep(
          \ s:fzfFindLineCommand.' '.shellescape(<q-args>).' | tr -d "\017"',
          \ 1,
          \ fzf#vim#with_preview({'sink': function('FindLineResultHandler'), 'options': '--delimiter : --nth 4..'}),
          \ <bang>0)
    nnoremap <Leader>g :FindLine<CR>
    " recursive file search
    command! -bang -nargs=* FindFile call
          \ fzf#run(fzf#wrap({
          \ 'source': s:fzfFindFileCommand.' | tr -d "\017"',
          \ 'sink': 'edit'}))
    nnoremap <Leader>f :FindFile<CR>
  else
    nnoremap <Leader>f :Files<CR>
    nnoremap <Leader>g :Lines<CR>
  endif
else
  Plug 'ctrlpvim/ctrlp.vim'
    let g:ctrlp_prompt_mappings = {
          \ 'PrtSelectMove("j")':   ['<c-j>', '<down>', '<tab>'],
          \ 'PrtSelectMove("k")':   ['<c-k>', '<up>', '<s-tab>'],
          \ 'ToggleFocus()': [], 'PrtExpandDir()': [],
          \ }
    nnoremap <Leader>f :CtrlP<CR>
    nnoremap <Leader>b :CtrlPBuffer<CR>
    function! RegisterCheatsheet()
      let g:CheatsheetInit = {-> s:command_list}
      function! CheatsheetAccept(mode, str)
        call ctrlp#exit()
        call CheatsheetSink(a:str)
      endfunction
      call add(g:ctrlp_ext_vars, {
            \ 'init': 'g:CheatsheetInit()',
            \ 'accept': 'CheatsheetAccept',
            \ 'lname': 'cheatsheet',
            \ 'sname': 'csheet',
            \ 'type': 'line',
            \ 'sort': 0,
            \ })
      let s:cheatsheet_id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
      command! CtrlPCheatsheet call ctrlp#init(s:cheatsheet_id)
      nnoremap <Leader><Leader> :CtrlPCheatsheet<CR>
    endfunction
    " Have to do this after ctrlp loads since we need reference to g:ctrlp_ext_vars
    autocmd VimEnter * call RegisterCheatsheet()
  command! -nargs=+ -complete=file Grep
    \ execute 'silent grep! "<args>"' | redraw! | copen
  nnoremap <Leader>g :Grep 
  Plug 'ronakg/quickr-preview.vim'
  let g:quickr_preview_on_cursor = 1
  let g:quickr_preview_exit_on_enter = 1
  let g:quickr_preview_size = '0'
  let g:quickr_preview_keymaps = 0
  let g:quickr_preview_position = 'below'
  if executable('rg')
    let g:ctrlp_user_command = 'rg ' . $FZF_RG_OPTIONS . ' --files --vimgrep'
    let g:ctrlp_use_caching = 0
  else
    let g:ctrlp_clear_cache_on_exit = 0
  endif
endif

" IDE features (e.g. autocomplete, smart refactoring, goto definition, etc.)
""""""""""""""""""""""""""""""""""""
Plug 'prabirshrestha/asyncomplete.vim'
  let g:asyncomplete_auto_completeopt = 0
  let g:asyncomplete_auto_popup = 0
  let g:asyncomplete_min_chars = 3
  let g:asyncomplete_matchfuzzy = 0
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction
  inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ asyncomplete#force_refresh()
" Language Server Protocol client that provides IDE like features
" e.g. autocomplete, autoimport, smart renaming, go to definition, etc.
Plug 'prabirshrestha/vim-lsp'
  " for debugging
  let g:lsp_log_file = $VIMHOME . 'vim-lsp-log'
  let g:lsp_fold_enabled = 0
  let g:lsp_document_code_action_signs_enabled = 0
  let g:lsp_document_highlight_enabled = 1
  Plug 'prabirshrestha/asyncomplete-lsp.vim'
  " An easy way to install/manage language servers for vim-lsp.
  Plug 'mattn/vim-lsp-settings'
    " where the language servers are stored
    let g:lsp_settings_servers_dir = $VIMHOME . "vim-lsp-servers"
    call mkdir(g:lsp_settings_servers_dir, "p")
  " A bridge between vim-lsp and ale. This works by
  " sending diagnostics (e.g. errors, warning) from vim-lsp to ale.
  " This way, vim-lsp will only provide LSP features
  " and ALE will only provide realtime diagnostics.
  " Now if something goes wrong its easier to determine which plugin
  " has the issue. Plus it allows ALE and vim-lsp to focus on their
  " strengths: linting and LSP respectively.
  Plug 'rhysd/vim-lsp-ale'
    " Only report diagnostics with a level of 'warning' or above
    " i.e. warning,error
    let g:lsp_ale_diagnostics_severity = "warning"
Plug 'prabirshrestha/async.vim'
  " autocomplete from other tmux panes
  Plug 'wellle/tmux-complete.vim'
    let g:tmuxcomplete#trigger = ''
Plug 'prabirshrestha/asyncomplete-buffer.vim'
  let g:asyncomplete_buffer_clear_cache = 0
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'allowlist': ['*'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ }))
Plug 'prabirshrestha/asyncomplete-file.vim'
autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    \ 'name': 'file',
    \ 'allowlist': ['*'],
    \ 'priority': 10,
    \ 'completor': function('asyncomplete#sources#file#completor')
    \ }))
" TODO this doesn't insert correctly, at least in python, need to fix
" Plug 'yami-beta/asyncomplete-omni.vim'
" autocmd User asyncomplete_setup
"     \ call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
"     \ 'name': 'omni',
"     \ 'allowlist': ['*'],
"     \ 'completor': function('asyncomplete#sources#omni#completor'),
"     \ 'config': {
"     \   'show_source_kind': 1,
"     \ },
"     \ }))
Plug 'jsit/asyncomplete-user.vim'
autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#user#get_source_options({
    \ 'name': 'user',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#user#completor')
    \  }))
Plug 'Shougo/neco-vim'
  Plug 'prabirshrestha/asyncomplete-necovim.vim'
  autocmd User asyncomplete_setup
      \ call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
      \ 'name': 'necovim',
      \ 'allowlist': ['vim'],
      \ 'completor': function('asyncomplete#sources#necovim#completor'),
      \ }))
Plug 'Shougo/neco-syntax'
  Plug 'prabirshrestha/asyncomplete-necosyntax.vim'
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#necosyntax#get_source_options({
    \ 'name': 'necosyntax',
    \ 'allowlist': ['vim'],
    \ 'completor': function('asyncomplete#sources#necosyntax#completor'),
    \ }))
" Expands Emmet abbreviations to write HTML more quickly
Plug 'mattn/emmet-vim'
  let g:user_emmet_expandabbr_key = '<C-e>'
  Plug 'prabirshrestha/asyncomplete-emmet.vim'
  autocmd User asyncomplete_setup
      \ call asyncomplete#register_source(asyncomplete#sources#emmet#get_source_options({
      \ 'name': 'emmet',
      \ 'whitelist': ['html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact'],
      \ 'completor': function('asyncomplete#sources#emmet#completor'),
      \ }))
" Snippets
Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
  Plug 'rafamadriz/friendly-snippets'
" Asynchronous linting
Plug 'dense-analysis/ale'
  " If a linter is not found don't continue to check on subsequent linting operations.
  let g:ale_cache_executable_check_failures = 1
  " Don't show popup when the mouse if over a symbol, vim-lsp
  " should be responsible for that.
  let g:ale_set_balloons = 0
  " Don't show variable information in the status line,
  " vim-lsp should be responsible for that.
  let g:ale_hover_cursor = 0
  " Only display diagnostics with a warning level or above
  " i.e. warning,error
  let g:ale_lsp_show_message_severity = "warning"
  let g:ale_lint_on_enter = 0 " Don't lint when a buffer opens
  let g:ale_lint_on_text_changed = "always"
  let g:ale_lint_delay = 1000
  let g:ale_lint_on_insert_leave = 0
  let g:ale_lint_on_filetype_changed = 0
  let g:ale_lint_on_save = 0
  let g:ale_fix_on_save = 1
  let g:ale_fixers = {
        \ 'javascript': ['prettier'],
        \ 'javascriptreact': ['prettier'],
        \ 'typescript': ['prettier'],
        \ 'typescriptreact': ['prettier'],
        \ 'json': ['prettier'],
        \ 'html': ['prettier'],
        \ 'css': ['prettier']
        \ }
  let g:ale_linters = {
        \ 'vim': [],
        \ 'javascript': ['eslint'],
        \ 'javascriptreact': ['eslint'],
        \ 'typescript': ['eslint'],
        \ 'typescriptreact': ['eslint']
        \ }
" Debugger
Plug 'puremourning/vimspector'
  let g:vimspector_enable_mappings = 'HUMAN'
" Applies editorconfig settings to vim
Plug 'editorconfig/editorconfig-vim'
call plug#end()

" Section: Autocommands
" -------------------------------------
augroup RestoreSettings
  autocmd!
  " Restore session after vim starts. The 'nested' keyword tells vim to fire events
  " normally while this autocmd is executing. By default, no events are fired
  " during the execution of an autocmd to prevent infinite loops.
  autocmd VimEnter * nested
        \ if argc() == 0 |
          \ let s:session_name =  substitute($PWD, "/", ".", "g") . ".vim" |
          \ let s:session_full_path = $VIMHOME . 'sessions/' . s:session_name |
          \ let s:session_cmd = filereadable(s:session_full_path) ? "source " : "mksession! " |
          \ silent! execute s:session_cmd . s:session_full_path |
        \ endif
  " restore last cursor position after opening a file
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line ("'\"") <= line("$") |
          \ exe "normal! g'\"" |
        \ endif
  " save session before vim exits
  autocmd VimLeavePre *
        \ if !empty(v:this_session) |
          \ exe 'mksession! ' . fnameescape(v:this_session) |
        \ endif
augroup END

augroup Styles
  autocmd!
  " Increase brightness of comments in nord
  autocmd ColorScheme nord highlight Comment guifg=#6d7a96
  " Make CursorLine look like an underline
  autocmd ColorScheme * execute "hi clear CursorLine"
  autocmd ColorScheme * execute "hi CursorLine gui=underline cterm=underline"
  " MatchParen
  autocmd Colorscheme * execute "hi MatchParen ctermbg=blue guibg=lightblue"
  " Only highlight the current line on the active window
  au WinLeave * set nocursorline
  au WinEnter * set cursorline
  " Transparent SignColumn
  autocmd Colorscheme solarized8,nord execute "hi clear SignColumn"
  autocmd Colorscheme solarized8 execute "hi DiffAdd ctermbg=NONE guibg=NONE"
  autocmd Colorscheme solarized8 execute "hi DiffChange ctermbg=NONE guibg=NONE"
  autocmd Colorscheme solarized8 execute "hi DiffDelete ctermbg=NONE guibg=NONE"
  autocmd Colorscheme solarized8 execute "hi SignifyLineChange ctermbg=NONE guibg=NONE"
  autocmd Colorscheme solarized8 execute "hi SignifyLineDelete ctermbg=NONE guibg=NONE"
  autocmd Colorscheme solarized8 execute "hi ALEErrorSign ctermbg=NONE guibg=NONE"
  autocmd Colorscheme solarized8 execute "hi ALEWarningSign ctermbg=NONE guibg=NONE"
  " Transparent number column
  autocmd Colorscheme solarized8 execute "hi clear CursorLineNR"
  autocmd Colorscheme solarized8 execute "hi clear LineNR"
  " Transparent vertical split (line that divides NERDTree and editor)
  autocmd Colorscheme solarized8 execute "highlight VertSplit ctermbg=NONE guibg=NONE"
  " Transparent background
  autocmd ColorScheme * hi Normal guibg=NONE ctermbg=NONE
augroup END

augroup Miscellaneous
  autocmd!
  " for some reason there is an ftplugin that is bundled with vim that
  " sets the textwidth to 78 if it is currently 0. This sets it back to 0
  autocmd VimEnter * :set tw=0
  " Set a default omnifunc
  autocmd Filetype *
        \	if index(asyncomplete#get_source_names(), 'necosyntax', 0, 1) < 0 && &omnifunc == "" |
          \ setlocal omnifunc=syntaxcomplete#Complete |
        \	endif
  " Set fold method for vim
  autocmd Filetype vim execute "setlocal foldmethod=indent"
  " Extend iskeyword for filetypes that can reference CSS classes
  autocmd FileType
    \ css,scss,javascriptreact,typescriptreact,javascript,typescript,sass,postcss
    \ setlocal iskeyword+=-,?,!
  autocmd FileType vim setlocal iskeyword+=:,#
  " Open help/preview/quickfix windows across the bottom of the editor
  autocmd FileType *
        \ if &filetype ==? "qf" || getwinvar('.', '&previewwindow') == 1 |
          \ wincmd J |
        \ endif
  autocmd FileType help
        \ if &columns > 150 |
          \ wincmd L |
        \ else |
          \ wincmd J |
        \ endif
  " Use vim help pages for keywordprg in vim files
  autocmd FileType vim setlocal keywordprg=:help
  " If there's a language server running, assign keywordprg to its hover feature.
  " Unless it's bash or vim in which case they'll use man pages and vim help pages respectively.
  function! HighlightWordUnderCursor()
          augroup HighlightWordUnderCursor
            autocmd!
            autocmd CursorMoved * exe printf('match DiffText /\V\<%s\>/', escape(expand('<cword>'), '/\'))
          augroup END
  endfunction
  " TODO the fallback highlighter logic seems out of place. also this won't
  " work if lsp isn't running since the autcmd won't fire
  autocmd User lsp_server_init
        \ if execute("LspStatus") =~? 'running' |
          \ if &filetype !=? "vim" && &filetype !=? "sh" |
            \ setlocal keywordprg=:LspHover |
          \ endif |
        \ else |
          \ call HighlightWordUnderCursor() |
        \ endif
augroup END

" After a quickfix command is run, open the quickfix window , if there are results
augroup myvimrc
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l*    lwindow
augroup END

" Section: Aesthetics
" -------------------------------------
set listchars=tab:¬-,space:· " chars to represent tabs and spaces when 'setlist' is enabled
set signcolumn=yes " always show the sign column
set fillchars=vert:│ " For a nice continuous line

" Block cursor in normal mode, thin line in insert mode, and underline in replace mode.
" Might not work in all terminals.
" See: https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[3 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)
" When vim exits, reset terminal cursor to blinking bar
autocmd VimLeave * silent exe "!echo -ne '\033[5 q'" 

" Colorscheme
""""""""""""""""""""""""""""""""""""
function! SetColorscheme(background)
    let &background = a:background
    let l:vim_colorscheme = a:background ==? "light" ? "solarized8" : "nord"
    exe "color " . l:vim_colorscheme
endfunction
function! SyncColorschemeWithOs(...)
  let l:is_os_in_dark_mode = system("defaults read -g AppleInterfaceStyle 2>/dev/null | tr -d '\n'") ==? 'dark'
  let l:new_vim_background = l:is_os_in_dark_mode ? "dark" : "light"
  let l:vim_background_changed_or_is_not_set = &background !=? l:new_vim_background || !exists('g:colors_name')
  if l:vim_background_changed_or_is_not_set
    call SetColorscheme(l:new_vim_background)
  endif
endfunction
if !has('macunix')
  call SyncColorschemeWithOs()
  " Check periodically to see if darkmode is toggled on the OS and update the vim theme accordingly.
  call timer_start(5000, function('SyncColorschemeWithOs'), {"repeat": -1})
else
  call SetColorscheme('dark')
endif
