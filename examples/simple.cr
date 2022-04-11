TOKEN = "<Your bot token>"
PREFIX = "y!"
OWNER = "<Your user id>" # or can also be ["<Your user id>", "<Another user id>"]
PING_MESSAGE = "Hello!"

require "../src/simplebot"
require "log"
Log.setup :info

# You can define command outside your main module
class CommandOne < SimpleBot::Command
  def execute(message : Discord::Message, args : Array(String))
    CLIENT.create_message message.channel_id, "Command one!"
  end
end

module YourBot
  extend SimpleBot

  # The command name will be the last part of the full class name
  class YourBot::CommandTwo < SimpleBot::Command
    def execute(message : Discord::Message, args : Array(String))
      CLIENT.create_message message.channel_id, "Command two!"
    end
  end

  class CommandThree < SimpleBot::Command
    def execute(message : Discord::Message, args : Array(String))
      CLIENT.create_message message.channel_id, "Command three!"
    end
  end
  
  start
end

# Will not add itself to the Command list
class CommandFour < SimpleBot::Command
  def execute(message : Discord::Message, args : Array(String))
    CLIENT.create_message message.channel_id, "Command four!"
  end
end
