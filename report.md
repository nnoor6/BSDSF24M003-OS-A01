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
