all: bin/client_static bin/client_dynamic

CFLAGS = -Wall -Iinclude -fPIC

# Static library
lib/libmyutils.a: obj/mystfunctions.o obj/myfilefunctions.o
	ar rcs lib/libmyutils.a obj/mystfunctions.o obj/myfilefunctions.o

# Dynamic library
lib/libmyutils.so: obj/mystfunctions.o obj/myfilefunctions.o
	gcc -shared -o lib/libmyutils.so obj/mystfunctions.o obj/myfilefunctions.o

# Static client
bin/client_static: obj/main.o lib/libmyutils.a
	gcc obj/main.o -Llib -lmyutils -o bin/client_static

# Dynamic client
bin/client_dynamic: obj/main.o lib/libmyutils.so
	gcc obj/main.o -Llib -lmyutils -o bin/client_dynamic

# Object files
obj/main.o: source/main.c
	gcc $(CFLAGS) -c source/main.c -o obj/main.o

obj/mystfunctions.o: source/mystfunctions.c
	gcc $(CFLAGS) -c source/mystfunctions.c -o obj/mystfunctions.o

obj/myfilefunctions.o: source/myfilefunctions.c
	gcc $(CFLAGS) -c source/myfilefunctions.c -o obj/myfilefunctions.o

clean:
	rm -f obj/*.o bin/client_static bin/client_dynamic lib/libmyutils.a lib/libmyutils.so
