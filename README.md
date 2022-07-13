# Crystal tree-sitter

Crystal bindings for [tree-sitter](https://github.com/tree-sitter/tree-sitter) API.

I made this shard to be used by [Tijolo](https://github.com/hugopl/tijolo), so any missing API is because I didn't need it yet.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tree_sitter:
       github: hugopl/crystal-tree-sitter
   ```

2. Run `shards install`

## Usage

The API is *very* similar to the C API, just with objects instead of a functions.

```crystal
require "tree_sitter"

# To load parsers you call the macro `require_tree_sitter_languages`, the parameters can be the parser name or directory,
# if the parameter isn't a valid path the parser will look for one at `./parsers/tree-sitter-#{name}`.
#
# By default the language name  is the name param titleized, but if you want e.g. have JSON language class be called
# `JSONLanguage` instead of `JsonLanguage` you load it as `json:JSON`.
#
# The example above load 4 parsers:
#
# - json at ./parsers/tree-sitter-json with JSON name
# - ruby at ./parsers/tree-sitter-ruby with Ruby name
# - a custom parser at ./my-parser with MyParser name
require_tree_sitter_languages("json:JSON", "ruby", "c", "./my-parser/:MyParser")

parser = TreeSitter::Parser.new
parser.language = TreeSitter::JSONLanguage.new
tree = parser.parse_string(nil, "[1, null]")
root_node = tree.root_node

TreeSitter::Highlighter.new(language).highlight(root_node) do |rule, node|
  pp! rule
  pp! node
end
```

The code used in the [Using Parsers](https://tree-sitter.github.io/tree-sitter/using-parsers) tree-sitter tutorial
was ported as a spec test at [spec/tree_sitter_spec.cr](spec/tree_sitter_spec.cr), the API documentation is being
ported as well, not yet on github-pages, but run `crystal doc` and have fun.

## Adding parsers

Currently the `require_tree_sitter_language` macro receives the language name a directory path where the parsers were cloned.

This still subject to change in next releases.

## Contributing

1. Fork it (<https://github.com/hugopl/crystal-tree-sitter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Hugo Parente Lima](https://github.com/hugopl) - creator and maintainer
