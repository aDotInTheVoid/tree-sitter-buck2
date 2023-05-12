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
