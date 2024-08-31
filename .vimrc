set nocompatible
"set termguicolors

set background=light
syntax on
filetype plugin indent on

let loaded_matchparen = 1

set t_Co=256
set nu
set shortmess-=S
set nowrap
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set nosm
set showcmd
set smartindent
set autoindent
set cursorline
"set lazyredraw
set equalalways
set incsearch
set hlsearch
set ignorecase
set smartcase
set noswapfile
set title
set ttyfast
set history=10000
set autoread
set showcmd
set timeoutlen=300
set updatetime=150

" stop 'exceed redraw limit' in vim
set re=0

" stop "Thanks for Flying VIM" on MacOS
set title
set titleold=
set ruler

call plug#begin()
Plug 'arzg/vim-colors-xcode'
Plug 'mattn/emmet-vim'
Plug 'mattn/vim-goimports'
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()
colorscheme xcodelighthc
hi Search ctermbg=LightGreen

"NOTE: This is an example func that does redirection to stdout
func! s:DumpToStdout()
    redi! > /dev/stdout
    for line in getline(1, '$')
        echo line
    endfor
    redi END
endfunc

"!F=`find /usr/lib/go | fzf` && cat $F | vim -R -c 'set syntax=go' -
func! s:GoSrc()
endfunc

" TODO: make VGrep understand <','>
" quickfix: vimgrep /pattern/gj ./*.go | cw | resize 6
func! s:VGrep(pattern, dir)
    execute "vimgrep /" . a:pattern . "/gj" . a:dir . "| cw | resize 6"
endfunc

command! -nargs=* Vg :call s:VGrep(<f-args>)

":tabnew | set syntax=go | read !go doc -src -u -all filepath.join
func! s:GoDoc(lookup)
    silent exec ":tabnew|view" a:lookup "| set syntax=go | read !go doc -src -u -all" a:lookup
endfunc

command! -nargs=1 Gdc call s:GoDoc(<q-args>)

func! s:GoDocShort(lookup)
    silent exec ":tabnew|view" a:lookup "| set syntax=go | read !go doc -short" a:lookup
endfunc

"command! -nargs=1 Gdsh call s:GoDocShort(<q-args>)

func! s:GoDocSignatureDescription(lookup)
    silent exec ":tabnew|view" a:lookup "| set syntax=go | read !go doc " a:lookup
endfunc

"command! -nargs=1 Gdsc call s:GoDocSignatureDescription(<q-args>)
command! Gdsh
    \ let fullword = expand('<cWORD>') |
    \ let parts = split(matchstr(fullword, '\v\w+\.\w+'), '\.') |
    \ let docarg = join(parts, '.') |
    \ let content = systemlist('go doc -short ' . docarg) |
    \ let current_line = line('.') |
    \ let insert_line = search('^$', 'bnW') |
    \ if insert_line == 0 || insert_line < search('^import', 'bnW') |
    \   let insert_line = search('^import', 'nW') |
    \   if insert_line == 0 |
    \     let insert_line = 1 |
    \   else |
    \     let insert_line = prevnonblank(insert_line - 1) |
    \   endif |
    \ endif |
    \ call append(insert_line, [''] + map(content, '"// " . v:val') + ['//']) |
    \ call cursor(insert_line + 2, 1)

"'<,'>w ! printf 'package main\n\nfunc main() {\n' && xargs -0 echo && printf '}'
func! s:Snippet() range
    let l:lines = getline(a:firstline, a:lastline)
    echo printf("package main\n\nfunc main() {\n")
    for line in l:lines
        echo line
    endfor
    echo printf("}")
endfunc

command! -range Sn '<,'> call s:Snippet()

func! s:UploadSnippetOnMacOS() range
    let l:snip = ""
    redi! => l:snip
        sil exec "'<,'>:call s:Snippet()"
    redi END
    let l:link = "https://play.golang.org"
    let l:curl = system("curl --silent -d " . "'" . join(split(l:snip, "\\'") , "") . "'" . " https://play.golang.org/share")
    exec "'<,'>:w !open " . l:link . "/p/" . l:curl
endfunc

command! -range Pg '<,'>call s:UploadSnippetOnMacOS()
"command! -range Pg silent'<,'>w !open
            "\ https://play.golang.org/p/`curl --silent -X POST
            "\  --data-binary  @- https://play.golang.org/share`

":command -nargs=1 -complete=file -bar Ref :rightbelow :split <args> | :wincmd k
":command -nargs=1 -complete=file -bar Vref :rightbelow :vsplit <args> | :wincmd l

nnoremap <Leader>k :!go test<CR>

" :copen | set ma | silent r !go run main.go
" This opens a new quickfix window and pates any errors
" we can navigate quickfix window by using gF and CTRL-O or
" alternatively CTRL-W gf to open a new tab (or even :e#)

"!grep -Hr --color
"vim http://... will wget and open a webpage!!!!!!!!!
"
"We can use this in GOLANG codebase to open up any filepath:linenr
"use head or tail or nothing if you want ot get all of the occurrence
"vim `grep --color -n -R "TODO" . | cut -d  ":" -f -2 | sed 's/:/ +/' | head -1`
"vim $(grep -n -e "func _assert" *.go | awk '{ print $1 }' | cut -d ':' -f 1,2 |sed 's/:/ +/')
"
" So we made some progress! now we just need to figure out how to parse a
" bash output into this output...
"
"vim -c ":e /opt/homebrew/Cellar/go/1.19.2/libexec/src/cmd/go/internal/modload/mvs.go|:121|
"        :tabe /opt/homebrew/Cellar/go/1.19.2/libexec/src/cmd/go/internal/get/get.go|:262"
" NOTE: we can go to a file:linenr by using Control-w-shift-F
"
" grep -n -R "context.TODO" /opt/homebrew/Cellar/go/1.19.2/libexec/src |
" cut -d  ":" -f -2 | sed 's/:/|:/ ; 2,$s/^/|/'
"
" |:set splitbelow| split
"
" full working command: this splits the output into tabe views
" vim -c "`grep -n -R "context.TODO" /opt/homebrew/Cellar/go/1.19.2/libexec/src |
" cut -d  ":" -f -2 | sed 's/:/|:/ ; 1s/^/:edit / ; 2,$s/^/|:tabe /' | xargs | sed 's/ |/| /g'`"
"
"This is how we can generate unique md5 filepaths and sort them by TODO
"occurrence! NOTE: This is a bit slow, so maybe there is a better way to do this?
"for file in `grep --color -n -R "TODO" /usr/lib/go/src/ | cut -d  ":" -f -2 | sed 's/:[0-9]\+/ /'`; 
"do echo $(md5sum < $file) $file; done > md5todo; cat md5todo | uniq -c | sort -k1n
"
"https://github.com/compiler-explorer/compiler-explorer/blob/3f36aa96cb62c1ccde60e07f4ee048b3e0f48857/docs/API.md
"!!! TODO: ADD GODBOLT.ORG support! same as for https://play.golang.org/...
"
"HOW TO delete and replace or minify characters in shell???? Use tr!
"example:
"text="package main
"func main() {
"   fmt.Println("OK")
"}"
" echo $text | tr -d " "
" output: packagemainfuncmain(){fmt.Println(OK)}

"-------- PROJECT IDEA
" callPlayground function that will start a new project in
" a DEFAULT_FOLDER="/Documents/projects/playground/"
" with a new folder name: 2021-18-11-playground-lj99812Joijasd= (TBD)
" and open up a new vim session inside that folder with main.go
" where in main.go you'll have a simple "hello, world" boilerplate code
" It's easier for testing things and running small scripts than exiting
" your current environment, jumping to another folder and so on...
"
"
" [Quick Snippets]: cat main.go | tr '\n' '$' | sed 's/\$/\<CR>/g' 
"

let s:detail_winid = 0
let s:main_winid = 0
let s:current_pkg = ''
let s:menu_items = []
let s:current_index = 0

function! ShowGoDocPopup(pkg)
    let s:current_pkg = a:pkg
    let output = system('go doc -short ' . a:pkg)
    let s:menu_items = split(output, '\n')
    let s:current_index = 0

    let options = {
        \ 'title': printf('go doc -short %s (%d/%d)', a:pkg, s:current_index + 1, len(s:menu_items)),
        \ 'padding': [1,1,1,1],
        \ 'border': [1,1,1,1],
        \ 'maxheight': 15,
        \ 'minwidth': 60,
        \ 'maxwidth': 80,
        \ 'cursorline': 1,
        \ 'wrap': 0,
        \ 'filter': 'GoDocPopupFilter',
        \ 'callback': 'GoDocPopupCallback'
    \ }

    let s:main_winid = popup_create(s:menu_items, options)

    call win_execute(s:main_winid, 'setlocal nowrap')
    call win_execute(s:main_winid, 'setlocal conceallevel=2')
    call win_execute(s:main_winid, 'setlocal concealcursor=n')
    call win_execute(s:main_winid, 'call cursor(1, 1)')
endfunction

let s:last_key = ''
function! GoDocPopupFilter(winid, key)
    let total_items = len(s:menu_items)
    if a:key == 'j'
        let s:current_index = (s:current_index + 1) % total_items
        if s:current_index == 0
            call win_execute(a:winid, 'normal! gg')
        else
            call win_execute(a:winid, 'normal! j')
        endif
    elseif a:key == 'k'
        let s:current_index = (s:current_index - 1 + total_items) % total_items
        if s:current_index == total_items - 1
            call win_execute(a:winid, 'normal! G')
        else
            call win_execute(a:winid, 'normal! k')
        endif
    elseif char2nr(a:key) == 71 "capital G
        let s:current_index = total_items - 1
        call win_execute(a:winid, 'normal! G')
    elseif a:key == 'g'
        if s:last_key == 'g'
            let s:current_index = 0
            let s:last_key = ''
            call win_execute(a:winid, 'normal! gg')
        else
            let s:last_key = 'g'
        endif
    elseif a:key == "\<CR>"
        call ShowDetail()
    elseif a:key == "\<Esc>"
        if s:detail_winid
            call popup_close(s:detail_winid)
            let s:detail_winid = 0
            return 1
        else
            call popup_close(a:winid)
            return 0
        endif
    endif

    call popup_setoptions(a:winid, {'title': printf('go doc -short %s (%d/%d)', s:current_pkg, s:current_index + 1, total_items)})

    return 1
endfunction

function! GoDocPopupCallback(id, result)
    if a:result > 0
        call ShowDetail()
    endif
endfunction

function! RemoveKeyword(str)
  let trimmed_str = substitute(a:str, '^\s\+', '', '')
  let pattern = '\v^(func|type|const|var)\s+'
  if match(trimmed_str, pattern) != -1
    return substitute(trimmed_str, pattern, '', '')
  else
    return trimmed_str
  endif
endfunction

function! ExtractTypeName(str)
  let trimmed_str = substitute(a:str, '^\s*type\s\+', '', '')
  return matchstr(trimmed_str, '^[^ {]\+')
endfunction

function! ShowDetail()
    if s:current_index >= 0 && s:current_index < len(s:menu_items)
        let selection = s:menu_items[s:current_index]

        let processed_selection = system(printf('echo "%s" | cut -d " " -f2- | cut -d"(" -f1', selection))

        let processed_selection = ExtractTypeName(RemoveKeyword(processed_selection))

        let processed_selection = substitute(processed_selection, '\n$', '', '')  " Remove trailing newline

        let cmd = printf('go doc -short %s.%s', s:current_pkg, processed_selection)
        let output = system(cmd)
        let detail_lines = split(output, '\n')

        let main_pos = popup_getpos(s:main_winid)

        if s:detail_winid && popup_getpos(s:detail_winid) != {}
            call popup_settext(s:detail_winid, detail_lines)
        else
            let detail_options = {
                \ 'title': 'Details: ' . processed_selection,
                \ 'line': main_pos.line + main_pos.height + 15,
                \ 'col': main_pos.col,
                \ 'zindex': 300,
                \ 'minwidth': 60,
                \ 'minheight': 10,
                \ 'maxwidth': 80,
                \ 'maxheight': 15,
                \ 'border': [1,1,1,1],
                \ 'padding': [1,1,1,1],
                \ 'wrap': 0,
                \ }
            let s:detail_winid = popup_create(detail_lines, detail_options)
        endif
    endif
endfunction
command! -nargs=1 GoDocFmtPopup call ShowGoDocPopup(<f-args>)

augroup gocmds
    autocmd!
    autocmd FileType go :iabbrev http_ func _N(w http.ResponseWriter, r *http.Request) {<CR>w.Write([]byte("Hello, world!"))<CR>}<ESC>kkf_<S-*>
    autocmd FileType go :iabbrev fori_ for _N := 0; _N < _N; i++ {<CR>}<ESC>kf_<S-*>
    autocmd FileType go :iabbrev forx_ for _N := range _N {<CR>}<ESC>kf_<S-*>
    autocmd FileType go :iabbrev go_ go func(){<CR>}()<ESC>k
    autocmd FileType go :iabbrev ifer_ if err != nil {<CR>}<ESC>k
    autocmd FileType go :iabbrev iferf_ if err != nil {<CR>Fatalf()<CR>}<ESC>k
    autocmd FileType go :iabbrev gomain_ package main<CR><CR>import "fmt"<CR><CR>func main() {<CR>fmt.Println("Hello, World!")<CR>}<ESC>k
augroup END
