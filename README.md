# Crystal tree-sitter

Crystal bindings for [tree-sitter](https://github.com/tree-sitter/tree-sitter) API.

It works by reading the tree-sitter CLI configuration file to locate where the parsers can be found, then it loads the
parsers shared objects at runtime when needed. So any parser available on tree-sitter-cli must be available on Crystal.

I made this shard to be used by [Tijolo](https://github.com/hugopl/tijolo), so any missing API is because I didn't need it
or I haven't had time to work on it yet, probably the last one.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tree_sitter:
       github: hugopl/crystal-tree-sitter
   ```

2. Run `shards install`

## Usage

API still not stable at all and subject to change. Meanwhile look at the spec tests to guess hwo to use it 😁️.

The code used in the [Using Parsers](https://tree-sitter.github.io/tree-sitter/using-parsers) tree-sitter tutorial
was ported as a spec test at [spec/tree_sitter_spec.cr](spec/tree_sitter_spec.cr), the API documentation is being
ported as well, not yet on github-pages, but run `crystal doc` and have fun.

## Contributing

1. Fork it (<https://github.com/hugopl/crystal-tree-sitter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Hugo Parente Lima](https://github.com/hugopl) - creator and maintainer
