PREFIX ?= /usr/local
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
install: bin/client_dynamic
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 bin/client_dynamic $(DESTDIR)$(PREFIX)/bin/client
	install -d $(DESTDIR)$(PREFIX)/share/man/man3
	install -m 644 man/man3/*.3 $(DESTDIR)$(PREFIX)/share/man/man3/

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/client
	rm -f $(DESTDIR)$(PREFIX)/share/man/man3/mystrlen.3
	rm -f $(DESTDIR)$(PREFIX)/share/man/man3/mystrcpy.3
	rm -f $(DESTDIR)$(PREFIX)/share/man/man3/mystrncpy.3
	rm -f $(DESTDIR)$(PREFIX)/share/man/man3/mystrcat.3
	rm -f $(DESTDIR)$(PREFIX)/share/man/man3/wordCount.3
	rm -f $(DESTDIR)$(PREFIX)/share/man/man3/mygrep.3
