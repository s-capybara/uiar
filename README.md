# Uiar

Formats given source codes of Elixir to follow coding styles below:
  * Directives are grouped and ordered as `use`, `import`, `alias` and `require`.
  * Each group of directive is separated by an empty line.
  * Directives of the same group are ordered alphabetically.
  * If a directive handles multiple modules with `{}`, they are alphabetically ordered.

Files can be passed by command line arguments:

```sh
  mix uiar mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"
```

If no arguments are passed, they are taken from `inputs` of `.formatter.exs`.
If `--check-formatted` option is given, it doesn't modify files but raises an error if not formatted yet.

## Installation

### mix.exs

```elixir
def deps do
  [
    {:uiar, github: "s-capybara/uiar", tag: "develop", runtime: false, only: [:dev]}
  ]
end
```

