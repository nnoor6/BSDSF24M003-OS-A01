# REPORT.md

## Part 2 — Multi-file Build

### Q1: Explain the linking rule in the Makefile: `$(TARGET): $(OBJECTS)`.
The rule `bin/client: obj/main.o obj/mystfunctions.o obj/myfilefunctions.o`
declares that the executable `bin/client` **depends on** the three object
files. The recipe `gcc obj/main.o obj/mystfunctions.o obj/myfilefunctions.o
-o bin/client` invokes the linker to combine those three .o files (each
containing compiled machine code for the corresponding .c source) into a
single executable. 

This differs from a rule that links **against a library**. When linking
against a library, the recipe would include `-L<path> -l<name>` so the
linker searches a directory for a `.a` (static) or `.so` (dynamic) archive
instead of directly listing .o files. The linker then pulls the required
functions out of the archive. In Part 2, all object code is explicitly
listed — no archive is involved.

### Q2: What is a git tag and why is it useful? Simple tag vs annotated tag?
A **git tag** is a permanent, human-readable pointer to a specific commit.
It is used to mark important points in history — most commonly release
versions (e.g., `v0.1.1`). Tags are useful because they never move (unlike
branches, which advance with every commit) and can be pushed to remote
repositories so users can download exactly that version.

- **Simple (lightweight) tag:** just a name pointing to a commit. No extra
  metadata. Created with `git tag <name>`.
- **Annotated tag:** a full Git object containing tagger name, email,
  date, and a message. Created with `git tag -a <name> -m "..."`. Preferred
  for releases because it's signed/auditable and includes context.

### Q3: Purpose of a GitHub Release? Why attach binaries?
A **GitHub Release** is a packaged snapshot of the project tied to a git
tag. It bundles source code (auto-generated zip/tar.gz) and any user-supplied
**assets** — compiled executables, libraries, docs, checksums. Releases give
users a stable, downloadable version without needing to clone and build.

Attaching the compiled binary (`bin/client`) is significant because:
1. Users can run the program without installing gcc or running make.
2. It ties the exact binary to a tagged source revision — reproducibility.
3. For proprietary or complex builds, the binary is the only practical
   distribution method.

## Part 3 — Static Library

### Q1: Compare the Makefile from Part 2 and Part 3. What are the key differences in the variables and rules that enable the creation of a static library?
Part 2's Makefile linked the object files directly:
`gcc obj/main.o obj/mystfunctions.o obj/myfilefunctions.o -o bin/client`

Part 3 introduces two new rules:
1. **Archive rule:** `lib/libmyutils.a` depends on the utility object files,
   and the recipe runs `ar rcs lib/libmyutils.a obj/mystfunctions.o obj/myfilefunctions.o`.
   The `ar` tool bundles the `.o` files into a single static library.
2. **Static link rule:** `bin/client_static` depends on `obj/main.o` and the
   archive, and the recipe uses `-Llib -lmyutils`:
   `gcc obj/main.o -Llib -lmyutils -o bin/client_static`.

The linker now searches `lib/` for a library named `myutils`
(found as `libmyutils.a`) and pulls only the required symbols from it.
No variables were strictly necessary for this — but adding an
`all:` target and using `-L`/`-l` flags are the key new concepts.

### Q2: What is the purpose of the `ar` command? Why is `ranlib` often used immediately after it?
`ar` = "archiver". It creates and manipulates static libraries (`.a` files)
by combining multiple object files into a single archive. Our command
`ar rcs lib/libmyutils.a obj/mystfunctions.o obj/myfilefunctions.o`
uses three flags:
- `r` — replace/insert files into archive
- `c` — create the archive if it doesn't exist
- `s` — write a symbol index (table of contents)

`ranlib` is a separate tool that builds the symbol index (a "table of
contents") for an archive so the linker can find symbols faster. Historically
`ar` did not build this index, so users had to run `ranlib` immediately after.
Modern `ar` with the `s` flag does it in the same step, making `ranlib`
redundant — but the convention of "ar then ranlib" persists because many
legacy Makefiles still do it explicitly.

### Q3: When you run `nm` on your client_static executable, are the symbols for functions like `mystrlen` present? What does this tell you about how static linking works?
Yes — `nm bin/client_static | grep mystrlen` returns:
`000000000000158e T mystrlen`

The `T` means the symbol is **defined** in the text (code) section of the
executable. This proves that **static linking copies** the library's code
into the final executable. At runtime the program does not need
`libmyutils.a` — all the code it uses is already inside `client_static`.
This is why static executables are self-contained but larger: the library
code is duplicated into every program that links against it.

## Part 4 — Dynamic Library

### Q1: What is Position-Independent Code (-fPIC) and why is it a fundamental requirement for creating shared libraries?
-fPIC tells the compiler to generate code that does not rely on being
loaded at a fixed memory address. Instead of using absolute addresses for
functions and variables, PIC uses relative addressing (via a global offset
table, or GOT). Shared libraries are loaded into an arbitrary location in
the process's address space at runtime — the OS chooses the address based
on what's already mapped. If the code used absolute addresses, it would
break whenever it was loaded somewhere other than the compile-time guess.
Without -fPIC, the linker refuses to build a .so on 64-bit Linux
("relocation R_X86_64_32 against ... can not be used when making a shared
object").

### Q2: Explain the difference in file size between your static and dynamic clients. Why does this difference exist?
In this project the difference is small (both clients are 17K) because our
library contains only six tiny functions. In a real project, the difference
would be large: the static client contains a copy of every function it uses
from the library, while the dynamic client contains only a reference to the
library name. The dynamic client is smaller because:
- Its own code (main.o) is the only compiled code it contains.
- libmyutils.so is loaded into memory once and shared by all processes
  that need it.
- The static client duplicates library code into every executable that
  links against it.

The .so file itself (16K) is larger than the .a (4.6K) because PIC code
carries extra relocation metadata, but the .a is duplicated into every
statically-linked program.

### Q3: What is the LD_LIBRARY_PATH environment variable? Why was it necessary to set it for your program to run, and what does this tell you about the responsibilities of the operating system's dynamic loader?
LD_LIBRARY_PATH is an environment variable that contains a colon-separated
list of directories. When a dynamically linked program starts, the OS
dynamic loader (ld-linux.so) reads this variable and searches those
directories FIRST, before falling back to the system defaults
(/lib, /usr/lib, /etc/ld.so.cache).

We had to set it because our library libmyutils.so lives in a project-local
lib/ directory that is not registered with the system. Without
LD_LIBRARY_PATH the loader had no way to find it, producing the error:
"error while loading shared libraries: libmyutils.so: cannot open shared
object file".

This tells us the dynamic loader is responsible for:
- Locating every shared library a program needs at startup.
- Mapping them into the process's address space.
- Resolving undefined symbols to their definitions in those libraries.
- Running library initialization code before transferring control to main().

We can either tell the loader where our library is at runtime
(LD_LIBRARY_PATH), or bake the search path into the binary at link time
(-Wl,-rpath), or install the library into a system location.
