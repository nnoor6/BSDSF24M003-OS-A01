all: bin/client_static

# Static library archive
lib/libmyutils.a: obj/mystfunctions.o obj/myfilefunctions.o
	ar rcs lib/libmyutils.a obj/mystfunctions.o obj/myfilefunctions.o

# Static client links against the library
bin/client_static: obj/main.o lib/libmyutils.a
	gcc obj/main.o -Llib -lmyutils -o bin/client_static

# Compile source files
obj/main.o: source/main.c
	gcc -Wall -Iinclude -c source/main.c -o obj/main.o

obj/mystfunctions.o: source/mystfunctions.c
	gcc -Wall -Iinclude -c source/mystfunctions.c -o obj/mystfunctions.o

obj/myfilefunctions.o: source/myfilefunctions.c
	gcc -Wall -Iinclude -c source/myfilefunctions.c -o obj/myfilefunctions.o

clean:
	rm -f obj/*.o bin/client_static lib/libmyutils.a
