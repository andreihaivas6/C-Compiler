all:
	lex limbaj.l
	yacc -d limbaj.y -Wcounterexamples
	gcc lex.yy.c y.tab.c -w -o 1
	./1 test.c
clean:
	rm -f *~ client server
	
