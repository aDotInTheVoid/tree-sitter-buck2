## Basic Setup

```
buck2 init --git
```

Creates folder setup:

```
.
├── .buckconfig
├── .buckroot
├── .git
├── .gitignore
├── .gitmodules
├── BUCK
├── prelude/
└── toolchains/
```

### Submodules

Next get the tree-sitter source

```
git submodule add https://github.com/tree-sitter/tree-sitter.git
```

[^fork]: In reality, I actually ran `git submodule add -b buck2-v2
    git@github.com:aDotInTheVoid/tree-sitter.git`, in order to use my fork of
    tree sitter, but this is a post about buck, not managing forks of open source projects.

### Building the tree-sitter C library

**`tree-sitter/lib/BUCK`**
```python
cxx_library(
    name = "c",
    srcs = ["src/lib.c"],
)
```

```
tree-sitter/lib$ buck2 build :c
File changed: root//post.md
Error running analysis for `root//tree-sitter/lib:c (prelude//platforms:default#524f8da68ea2a374)`

Caused by:
    0: Error looking up configured node root//tree-sitter/lib:c (prelude//platforms:default#524f8da68ea2a374)
    1: Error looking up configured node toolchains//:cxx (prelude//platforms:default#524f8da68ea2a374) (prelude//platforms:default#524f8da68ea2a374)
    2: looking up unconfigured target node `toolchains//:cxx`
    3: Unknown target `cxx` from package `toolchains//`.
       Did you mean one of the 1 targets in toolchains//:BUCK?
Build ID: 9e3795b9-c62e-44c2-8a4b-923a00c5d22a
Jobs completed: 2. Time elapsed: 0.0s.
BUILD FAILED
```

**`toolchains/BUCK`**
```python
load("@prelude//toolchains:cxx.bzl", "system_cxx_toolchain")
load("@prelude//toolchains:python.bzl", "system_python_bootstrap_toolchain")

system_cxx_toolchain(
    name = "cxx",
    visibility = ["PUBLIC"],
)

system_python_bootstrap_toolchain(
    name = "python_bootstrap",
    visibility = ["PUBLIC"],
)
```

```
tree-sitter/lib$ buck2 build :c 
File changed: root//tree-sitter/lib/BUCK
Action failed: root//tree-sitter/lib:c (cxx_compile src/lib.c (pic))
Local command returned non-zero exit code 1
Reproduce locally: `clang -o buck-out/v2/gen/root/524f8da68ea2a374/tree-sitter/lib/__c__/__objects__/src/lib.c.pic.o -fPIC @buck-out/v2/gen/root/524f8da68ea2a374/tree-sitter/lib/__c__/.c.argsfile -c tree-sitter/lib/src/lib.c`
stdout:
stderr:
In file included from tree-sitter/lib/src/lib.c:8:
In file included from tree-sitter/lib/src/./alloc.c:1:
tree-sitter/lib/src/alloc.h:4:10: fatal error: 'tree_sitter/api.h' file not found
#include "tree_sitter/api.h"
         ^~~~~~~~~~~~~~~~~~~
1 error generated.
Build ID: ba7f5fa4-83ce-4fc3-a64c-8f5e60c467b8
Jobs completed: 8. Time elapsed: 0.2s. Cache hits: 0%. Commands: 1 (cached: 0, remote: 0, local: 1)
BUILD FAILED
Failed to build 'root//tree-sitter/lib:c (prelude//platforms:default#524f8da68ea2a374)'
```

**`tree-sitter/lib/BUCK`**
```python
cxx_library(
    name = "c",
    srcs = ["src/lib.c"],
    include_directories = ["include"], # NEW!
)
```

```
$ buck2 build :c --show-output
Build ID: d530dd98-14f9-4c82-999f-4c428ff3097a
Jobs completed: 46. Time elapsed: 1.1s. Cache hits: 0%. Commands: 2 (cached: 0, remote: 0, local: 2)
BUILD SUCCEEDED
root//tree-sitter/lib:c buck-out/v2/gen/root/524f8da68ea2a374/tree-sitter/lib/__c__/libtree-sitter_lib_c.so
```

### Using The C Library

```c
#include <stdio.h>

int main() { printf("Hello\n"); }
```

```python
cxx_binary(
    name = "use_c",
    srcs = ["use.c"],
)
```

```
$ buck2 run :use_c
Build ID: 2679e751-3ff3-44b1-bf2a-60406d55cbd8
Jobs completed: 44. Time elapsed: 0.6s. Cache hits: 0%. Commands: 2 (cached: 0, remote: 0, local: 2)
Hello
```

```c
#include <stdio.h>
#include <tree_sitter/api.h>

int main() {
  TSParser *parser = ts_parser_new();
  printf("Hello\n");
}
```

```
$ buck2 run :use_c
File changed: root//tree-sitter/lib/BUCK
Error running analysis for `root//:use_c (prelude//platforms:default#524f8da68ea2a374)`

Caused by:
    0: Error looking up configured node root//:use_c (prelude//platforms:default#524f8da68ea2a374)
    1: `root//tree-sitter/lib:c` is not visible to `root//:use_c` (run `buck2 uquery --output-attribute visibility root//tree-sitter/lib:c` to check the visibility)
Build ID: 906daaa1-4f81-49ad-920e-eb2b5badeaec
Jobs completed: 4. Time elapsed: 0.0s.
BUILD FAILED
```

```
$ buck2 run :use_c
$ buck2 run :use_c
Action failed: root//:use_c (cxx_compile use.c (pic))
Local command returned non-zero exit code 1
Reproduce locally: `clang -o buck-out/v2/gen/root/524f8da68ea2a374/__use_c__/__objects__/use.c.pic.o -fPIC @buck-out/v2/gen/root/524f8da68ea2a374/__use_c__/.c.argsfile -c use.c`
stdout:
stderr:
use.c:2:10: fatal error: 'tree_sitter/api.h' file not found
#include <tree_sitter/api.h>
         ^~~~~~~~~~~~~~~~~~~
1 error generated.
Build ID: 795650d1-a35b-4a6d-a35e-300fd9317f01
Jobs completed: 4. Time elapsed: 0.1s. Cache hits: 0%. Commands: 1 (cached: 0, remote: 0, local: 1)
BUILD FAILED
Failed to build 'root//:use_c (prelude//platforms:default#524f8da68ea2a374)'
```

Argsfile
```
-Xclang
-fdebug-compilation-dir
-Xclang
.
-fcolor-diagnostics
```

```
cxx_library(
    name = "c",
    srcs = ["src/lib.c"],
    public_include_directories = ["include"], # NEW!
    visibility = ["PUBLIC"],
)
```

```
$ buck2 run :use_c
File changed: root//use.c
Build ID: 1c0abc43-fa49-4251-a1d8-4cd8000dab56
Jobs completed: 5. Time elapsed: 0.2s. Cache hits: 0%. Commands: 1 (cached: 0, remote: 0, local: 1)
Hello
```

We can also confirm that the right directory was included

```
$ buck2 log whatran
Showing commands from: buck2 run :use_c
build   root//:use_c (prelude//platforms:default#524f8da68ea2a374) (cxx_compile use.c (pic))    local   env -- "TMPDIR=/home/alona/tmp/tree-sitter-buck2/buck-out/v2/tmp/root/524f8da68ea2a374/__use_c__/cxx_compile/_buck_407f6488d829268c" "BUCK2_DAEMON_UUID=7d137423-5807-4bc1-87f9-2f8445396d54" clang -o buck-out/v2/gen/root/524f8da68ea2a374/__use_c__/__objects__/use.c.pic.o -fPIC @buck-out/v2/gen/root/524f8da68ea2a374/__use_c__/.c.argsfile -c use.c
```

**`buck-out/v2/gen/root/524f8da68ea2a374/__use_c__/.c.argsfile`**


```
-Xclang
-fdebug-compilation-dir
-Xclang
.
-fcolor-diagnostics
-Itree-sitter/lib/include
```

## Building a parser

**`tree-sitter-balanced/grammar.js`** 

```js
module.exports = grammar({
  name: "balanced",
  rules: {
    bs: ($) => seq($.b, repeat($.b)),
    b: ($) =>
      choice(
        seq("(", optional($.bs), ")"),
        seq("{", optional($.bs), "}"),
        seq("[", optional($.bs), "]")
      ),
  },
});
```

## Thaughts & Feelings

- Buck2 is very well engineered
- Not being in java is a huge boon
- Docs Suck
- Needs a monorepo
