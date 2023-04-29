# A list of available rules and their signatures can be found here: https://buck2.build/docs/api/rules/
load("//rules.bzl", "project_rule")

http_archive(
    name="treesitter-src",
    urls=[
        "https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.20.8.tar.gz"
    ],
    sha256="6181ede0b7470bfca37e293e7d5dc1d16469b9485d13f13a605baec4a8b1f791",
    strip_prefix="tree-sitter-0.20.8",
)


# project_rule(name = "my_projection", src = ":treesitter-src", project = "lib/src/lib.c")
# project_rule(name="treesitter_lib_c", src=":treesitter-src", file="lib/src/lib.c")

cxx_library(
    name = "treesitter-lib",
    # TODO: Point the C compiller at the downloared source
    srcs = [":treesitter-src/lib/src/lib.c"]
)

# genrule(
#     name="lol", out="lol.txt", cmd="cp $(location :treesitter-src)/lib/src/lib.c $OUT"
# )
