# SimpleBot

Crystal Shard for quickly writing Discord Bots.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     simplebot:
       github: MineBartekSA/simplebot
   ```

2. Run `shards install`

## Usage

```crystal
TOKEN = "<Your bot token>"
require "simplebot"
Log.setup :info

module YourBot
  extend SimpleBot
  
  class Test < SimpleBot::Command
    def execute(message : Discord::Message, args : Array(String))
      CLIENT.create_message message.channel_id, "Hello!"
    end
  end
  
  start
end
```

Classes inhereting the `SimpleBot::Command` class, must be placed before the invocation of the start method.

## Contributing

1. Fork it (<https://github.com/MineBartekSA/simplebot/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Bartłomiej Skoczeń](https://github.com/MineBartekSA) - creator and maintainer
