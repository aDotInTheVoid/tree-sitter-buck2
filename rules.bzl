# project_rule(name = "my_projection", src = ":treesitter-src", project = "lib/src/lib.rs")


def project_rule_impl(ctx: "context") -> ["provider"]:
    src = ctx.attrs.src
    file = ctx.attrs.file
    out = src.project(file)
    return [DefaultInfo(default_output=out)]


project_rule = rule(
    impl=project_rule_impl, attrs={"src": attrs.source(), "file": attrs.string()}
)
