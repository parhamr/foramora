# Fora Mora

This code uses classes to group concerns and procedural methods to interact with websites through a browser.

## Setup

Dependencies: Ruby (see `.ruby-version` for version), Rubygems, curl, and libraries supporting the gems

Once Rubygems is installed, install application dependencies with these commands:

```bash
gem install bundler
bundle
```

Use the example foræ YAML to build your own fora definitions.

```bash
mv config/foræ.example.yaml config/foræ.yaml
```

## Run it!

`ruby fora_mora.rb`

## Development, Maintenance

TDD support:

`bundle exec guard`

## Testing

`rake spec`
