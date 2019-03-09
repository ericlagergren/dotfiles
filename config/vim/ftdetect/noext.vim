augroup filetypedetect
	au! BufNewFile,BufRead * if expand('%:t') !~ '\.' | setf noext | endif
augroup END
