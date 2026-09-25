bin/client: obj/main.o obj/mystfunctions.o obj/myfilefunctions.o
	gcc obj/main.o obj/mystfunctions.o obj/myfilefunctions.o -o bin/client

obj/main.o: source/main.c
	gcc -Wall -Iinclude -c source/main.c -o obj/main.o

obj/mystfunctions.o: source/mystfunctions.c
	gcc -Wall -Iinclude -c source/mystfunctions.c -o obj/mystfunctions.o

obj/myfilefunctions.o: source/myfilefunctions.c
	gcc -Wall -Iinclude -c source/myfilefunctions.c -o obj/myfilefunctions.o

clean:
	rm -f obj/*.o bin/client
