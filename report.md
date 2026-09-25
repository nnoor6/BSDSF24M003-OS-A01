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
