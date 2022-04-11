TOKEN = "<Your bot token>"

require "../src/simplebot"
require "log"
Log.setup :info

module YourBot
  extend SimpleBot

  def SimpleBot.ready
    Log.info { "Bot ready to serve" }
  end

  # This bot have no commands, but will respond when someone will send "test"
  def SimpleBot.on_message(payload)
    if payload.content == "test"
        CLIENT.create_message payload.channel_id, "You sent test"
        return true # Tell SimpleBot that you already handled this message
    end
  end

  def SimpleBot.interupt
    Log.info { "Bot shutting down" }
  end
  
  start
end
