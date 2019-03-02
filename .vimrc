set encoding=utf-8
scriptencoding utf-8

packadd minpac
call minpac#init()
call minpac#add('k-takata/minpac', {'type': 'opt'})

filetype off
syntax on
syntax sync minlines=100
filetype plugin indent on

" AutoSplit calls vsplit then switches to the rightmost pane, so long as the
" b:noAutoSplit variable does not exist.
fun! AutoSplit()
	if !exists('b:noAutoSplit')
		vsplit
		wincmd w
	endif
endfun
autocmd FileType gitcommit,noexit,none,text,markdown let b:noAutoSplit=1
autocmd VimEnter * call AutoSplit()

" Mappings
let mapleader = "\<space>"

inoremap :+ :=

nnoremap <Leader>w :w<CR>
nnoremap <leader>a :cclose<CR>

nnoremap <silent> <A-Right> <c-w>l
nnoremap <silent> <A-Left> <c-w>h
nnoremap <silent> <A-Up> <c-w>k
nnoremap <silent> <A-Down> <c-w>j

map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>

" General settings
set autowrite
set backspace=indent,eol,start
set background=dark
set breakindent
set cmdheight=2
set conceallevel=0
set cursorline
set expandtab
set fileencoding=utf-8
set fileformats=unix,dos,mac
set formatoptions=tcrqwn1j
set history=9999
set hlsearch
set ignorecase
set incsearch
set infercase
set linebreak
set linespace=0
set noexpandtab
set nowrap
set number
set numberwidth=3
set pastetoggle=<F10>
set report=0
set rtp+=/usr/local/opt/fzf
set scrolljump=5
set scrolloff=5
set secure
set shiftround " tab at 3 spaces means 4 spaces, not 7
set shiftwidth=4
set showcmd
set statusline=[%{getcwd()}][%f]%=%r%y[%P][col:%c]%{gutentags#statusline()}%{fugitive#statusline()}
set tabstop=4 " real tabs are 4 chars
set tags=./.tags,tags;
set ttimeoutlen=10
set ttimeout
set ttyfast
set updatetime=100
" Include uppercase registers
" Disable hlsearch while loading viminfo
" Remember marks for last 500 files
" remember up to 10000 lines in each register
" remember up to 1MB in each register
" remember last 1000 search patterns remember last 1000 commands
set viminfo=!,h,'500,<10000,s1000,/1000,:1000

" Clipboard
set backup
set backupdir=~/.vim/backup/
set directory=~/.vim/temp/
set undodir=~/.vim/undo/
set undofile " persistent undo
set undolevels=1000 " persistent undo
set undoreload=10000 " to undo forced reload with :e

" Mice!
set mouse=a " use mouse
set nomousehide " don't hide the mouse
if has("mouse_sgr")
	set ttymouse=sgr
else
	set ttymouse=xterm2
endif

" ruler!
if exists("+colorcolumn")
	set textwidth=80
	set colorcolumn=+1
else
	au BufWinEnter * let w:m2=matchadd("ErrorMsg", "\%>80v.\+", -1)
endif

if executable("ag")
	set grepprg=ag\ --nogroup\ --nocolor\ --ignore-case\ --column
	set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" cd to dir
autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif

" autopairs
let g:AutoPairsFlyMode = 0

" vim-go
let g:go_asmfmt_autosave = 1
let g:go_auto_sameids = 1
let g:go_auto_type_info = 0
let g:go_def_mode = "guru"
let g:go_doc_url = "http://localhost:9292"
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_highlight_generate_tags = 1
let g:go_template_file = "minimal.go"
let g:go_template_use_pkg = 1
let g:go_textobj_include_function_doc = 1
let g:go_updatetime = 200

au FileType go nmap <leader>u <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>i <Plug>(go-info)
au FileType go nmap <leader>g <Plug>(go-generate)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>v <Plug>(go-vet)
au FileType go nmap <leader>d <Plug>(go-def)
au FileType go nmap <leader>c <Plug>(go-def-stack-clear)
au FileType go nmap <leader>s <Plug>(go-def-stack)
au FileType go nmap <leader>r <Plug>(go-rename)
au FileType go nmap <leader>l <Plug>(go-lint)
au FileType go nmap <Leader>i <Plug>(go-info)

" AutoFormatSpecificFiles runs :Autoformat if the variable b:noAutoFormat does
" not exist.
fun! AutoFormatSpecificFiles()
	if !exists('b:noAutoFormat')
		:Autoformat
	endif
endfun

autocmd BufWrite * call AutoFormatSpecificFiles()
autocmd FileType markdown let b:noAutoFormat=1

let g:autoformat_verbosemode = 0

" Disable fallback when vim autoformat doesn't detect a filetype
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

let g:formatdef_fmt_gql = '"prettier --no-color --stdin --use-tabs
			\ --tab-width ' . &shiftwidth . ' --parse graphql"'
let g:formatters_graphql = ['fmt_gql']

" Gutentags
let g:gutentags_ctags_exclude = [
	\ "*.min.js", "*.min.css", "build",
	\ "vendor", ".git", "node_modules",
	\ "*.vim/pack/*"]
let g:gutentags_cache_dir = $HOME . '/.vim/tags'

" polyglot
let g:polyglot_disabled = ['go', 'graphql', 'gql']

" colors
let g:nofrils_strbackgrounds=1
let g:nofrils_heavycomments=0
let g:nofrils_heavylinenumbers=0
colo nofrils-dark

function! CopyMatches(reg)
	let hits = []
	%s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/ge
	let reg = empty(a:reg) ? '+' : a:reg
	execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)
