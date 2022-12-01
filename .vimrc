set nocompatible

set background=light
syntax on
filetype plugin indent on

set t_Co=256
set termguicolors
set nu
set shortmess-=S
set nowrap
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
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

func! s:GoDocSignature(lookup)
    silent exec ":tabnew|view" a:lookup "| set syntax=go | read !go doc " a:lookup
endfunc

command! -nargs=1 Gdcs call s:GoDocSignature(<q-args>)

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

":silent'<,'>w !firefox https://play.golang.org/p/`curl --silent -X POST --data-binary  
"let l:curl = "curl --silent -X POST --data-binary @- "
" @- https://play.golang.org/share`
" https://vi.stackexchange.com/questions/5205/how-to-grep-in-ex-command-output
" https://stackoverflow.com/questions/34847981/curl-with-multiline-of-json
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

" We need this snippet for lets-go.pdf tutorials
iabbrev http@ func _N(w http.ResponseWriter, r *http.Request) {<CR>}<ESC>kw
iabbrev fori@ for i := 0; i < _N; i++ {<CR>}<ESC>kf_
iabbrev forx@ for _N := range _N {<CR>}<ESC>kf_
iabbrev go@ go func(){<CR>}()<ESC>k
iabbrev iferr@ if err != nil {<CR>}<ESC>k
iabbrev gomain_ package main<CR><CR>func main() {<CR>}<ESC>
