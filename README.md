# Fora Mora

Automated forum interaction tools. This application models forums, their users, and the contents with classes. There are subclasses to abstract common interfaces for various forum platforms. Much of the code is procedural.

The application is in very early stages and no support is offered or implied.

It has been developed and tested on OS X; Linux and Unix variants should just work. Windows is not currently supported.

## Setup

Dependencies: Ruby (see `.ruby-version` for version), Rubygems, curl, and libraries supporting the gems

Once Rubygems is installed, install application dependencies with these commands:

```
gem install bundler
bundle
```

Use the example forae YAML to build your own fora definitions.

```
mv config/forae.example.yaml config/forae.yaml
```

## Run it!

After installing dependencies, perform this command to start the application:

`ruby fora_mora.rb`

## Development, Maintenance

TDD support:

`bundle exec guard`

NOTE: since the code is procedural, RuboCop style defaults have been loosened to account for the habits of complex assignments and long methods.

## Testing

Run the suite with this command:

`bundle exec rake spec`

Perform code coverage analysis with this command:

`bundle exec rake coverage`
