# SimpleBot

Crystal Shard for quickly writting Discord Bots.

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
TOKEN = "<Your bot token>" # Must be defined on the top level and before simple bot require
require "simplebot"
require "log"
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

Plase note, Classes inhereting the `SimpleBot::Command` class, must be placed before the `start` call.

Top level constants:
- `PREFIX` - Command prefix
- `INTENTS` - Gateway Intents to send when opening a new session
- `OWNER` - String or List of owner user ids 
- `WEBHOOK` - String or List of webhook ids allowed to interact with the bot
- `PING_MESSAGE` - Message sent on bot ping
- `NSFW_MESSAGE` - Message sent when a nswf flaged command is run in a not nsfw channel
- `PERMISSION_MESSAGE` - Message set when someone run a command that they don't have the permission to run

Constants must be defined on the top layer before `require "simplebot"`

Hook instance methods:
- `ready` - Ready Event hook
- `on_message` - Message Create Event hook. Will be run before SimpleBot command logic, but after checking if message author is not a robot or is a trusted webhook. Return true to mark message as handled.
- `interupt` - SIGINT and SIGTERM hook. Will be run before stopping Discord session

Example of hook methods usage:
```crystal
TOKEN = "<Your bot token>" # Must be defined on the top level
require "simplebot"
require "log"
Log.setup :info

module YourBot
  extend SimpleBot

  def SimpleBot.on_message(payload) # Hook into on_message processor
    return true if payload.content == "test"
  end
  
  start
end
```

## Contributing

1. Fork it (<https://github.com/MineBartekSA/simplebot/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Bartłomiej Skoczeń](https://github.com/MineBartekSA) - creator and maintainer
