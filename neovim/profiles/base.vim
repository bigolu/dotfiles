" vim:foldmethod=marker

" Miscellaneous {{{
set nrformats-=octal
set ttimeout ttimeoutlen=100
set updatetime=500
set noswapfile
set fileformats=unix,dos,mac
set paragraphs= sections=

augroup ExtendIskeyword
  autocmd!
  " Extend iskeyword for filetypes that can reference CSS classes
  autocmd FileType
        \ css,scss,javascriptreact,typescriptreact,javascript,typescript,sass,postcss
        \ setlocal iskeyword+=-,?,!
  autocmd FileType vim setlocal iskeyword+=:,#
  autocmd FileType tmux setlocal iskeyword+=-
augroup END

inoremap jk <Esc>

function! VisualPaste()
  let keys = ''

  " Delete the selected text and put it in the blackhole register.
  " This way, we don't overwrite the contents of the clipboard
  let keys .= '"_d'

  " Paste the contents of the clipboard
  let last_visualmode = visualmode()
  " visual or visual-block mode
  if last_visualmode ==# 'v' || last_visualmode ==# ''
    let selection_end_column = getcharpos("'>")[2]
    let line_column_count = strdisplaywidth(getline("'>"))
    let is_selection_end_at_end_of_line = selection_end_column == line_column_count
    if is_selection_end_at_end_of_line
      let keys .= 'p'
    else
      let keys .= 'P'
    endif
  " visual-line mode
  else
    let keys .= 'P'

    " Reindent the pasted text. This will also move the cursor to the end of the pasted text
    let keys .= '=`]'
  endif

  return keys
endfunction
xnoremap <silent> p <Esc>:execute 'normal gv<C-r><C-r>=VisualPaste()<CR>'<CR>

" - reindent the pasted text
" - move to the end of the pasted text
nnoremap <silent> p p=`]

" select the text that was just pasted
noremap gV `[v`]

" Prevents inserting two spaces after punctuation on a join (J)
set nojoinspaces
" Delete comment character when joining commented lines
set formatoptions+=j

set matchpairs+=<:>
" move ten lines at a time by holding ctrl and a directional key
noremap <C-j> 10j
noremap <C-k> 10k

" Copy up to the end of line, not including the newline character
nnoremap Y yg_

" Using the paragraph motions won't add to the jump stack
nnoremap } <Cmd>keepjumps normal! }<CR>
nnoremap { <Cmd>keepjumps normal! {<CR>

" 'n' always searches forwards, 'N' always searches backwards
nnoremap <expr> n  'Nn'[v:searchforward]
xnoremap <expr> n  'Nn'[v:searchforward]
onoremap <expr> n  'Nn'[v:searchforward]
nnoremap <expr> N  'nN'[v:searchforward]
xnoremap <expr> N  'nN'[v:searchforward]
onoremap <expr> N  'nN'[v:searchforward]

" Enter a newline above or below the current line.
nnoremap <Enter> o<ESC>
" TODO: This won't work until tmux can differentiate between enter and shift+enter.
" tmux issue: https://github.com/tmux/tmux/issues/2705#issuecomment-841133549
nnoremap <S-Enter> O<ESC>

" Disable language providers. Feels like a lot of trouble to install neovim bindings for all these languages
" so I'll just avoid plugins that require them. By disabling the providers, I won't get a warning about
" missing bindings when I run ':checkhealth'.
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
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

" Searching {{{
" searching is only case sensitive when the query contains an uppercase letter
set ignorecase smartcase

" Use ripgrep as the grep program, if it's available. Otherwise use the internal
" grep implementation since it's cross-platform
let &grepprg = executable('rg') ? 'rg --vimgrep --smart-case --follow' : 'internal'

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
" }}}

" Plugins {{{
" Motions for levels of indentation
Plug 'jeetsukumaran/vim-indentwise'

" replacement for matchit since matchit wasn't working for me
Plug 'andymass/vim-matchup'
" Don't display offscreen matches in my statusline or a popup window
let g:matchup_matchparen_offscreen = {}

" Additional text objects and motions
Plug 'wellle/targets.vim'

Plug 'bkad/CamelCaseMotion'
let g:camelcasemotion_key = ','

" Makes it easier to manipulate brace/bracket/quote pairs by providing commands to do common
" operations like change pair, remove pair, etc.
Plug 'tpope/vim-surround'

" For swapping two pieces of text
Plug 'tommcdo/vim-exchange'

" Commands/mappings for working with variants of words:
" - A command for performing substitutions. More features than vim's builtin :substitution
" - A command for creating abbreviations. More features than vim's builtin :iabbrev
" - Mappings for case switching e.g. mixed-case, title-case, etc.
Plug 'tpope/vim-abolish'

Plug 'tpope/vim-commentary'

" Text object for text at the same level of indentation
Plug 'michaeljsmith/vim-indent-object'
" Make 'ai' and 'ii' behave like 'aI' and 'iI' respectively
function! ChangeVimIndentObjectMappings()
  omap ai aI
  vmap ai aI

  omap ii iI
  vmap ii iI
endfunction
augroup VimIndentObject
  autocmd!
  autocmd VimEnter * call ChangeVimIndentObjectMappings()
augroup END

" " Override operators that delete text, like 'c' and 'd', such that they only delete text, not cut it
" Plug 'svermeulen/vim-cutlass'
" " Make 'x' behave like 'd'. This way I still have a way to cut text
" nnoremap x d
" xnoremap x d
" nnoremap xx dd
" nnoremap X D
" }}}