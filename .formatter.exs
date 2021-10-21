locals_without_parens = [
  decimal: 1,
  decimal: 2
]

[
  inputs: ["mix.exs", "{lib,test}/**/*.{ex,exs}"],
  line_length: 80,
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]

