all:
	cc -o ml_createfile_excl ml_createfile_excl.c
	mex ml_getpid.c
	mex ml_tclread.cpp
	mv *.mex* ../matlab/mex
	mv ml_createfile_excl ../bin
