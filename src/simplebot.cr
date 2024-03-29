require "discordcr"
require "log"
require "./**"

{% for const in ["PREFIX", "OWNER", "WEBHOOK", "PING_MESSAGE", "NSFW_MESSAGE", "PERMISSION_MESSAGE"] %}
    {% if !@type.has_constant? const %}
        {% if const == "PREFIX" %}
            {{ const.id }} = "!"
        {% elsif const == "NSFW_MESSAGE" %}
            {{ const.id }} = "⛔ This command can only be run in a NSFW channel!"
        {% elsif const == "PERMISSION_MESSAGE" %}
            {{ const.id }} = "⛔ You don't have enough permissions to use this command!"
        {% else %}
            {{ const.id }} = ""
        {% end %}
    {% end %}
{% end %}

{% unless @type.has_constant? "INTENTS" %}
    INTENTS = Discord::Client::DEFAULT_INTENTS + (1 << 15)
{% end %}

module SimpleBot
    Log = ::Log.for self
    VERSION = "0.1.0"

    CLIENT = Discord::Client.new "Bot #{TOKEN}", intents: INTENTS
    CACHE = Discord::Cache.new CLIENT
    CLIENT.cache = CACHE

    COMMANDS = Array(SimpleBot::Command).new
    # :nodoc:
    NML = Hash(UInt64, NextMessageInfo).new
    # :nodoc:
    NMLM = Mutex.new

    CLIENT.on_ready do
        COMMANDS.each do |com|
            begin
                com.ready
                Log.info { "Readied command '#{com.command}'" }
            rescue e
                Log.error(exception: e) { "Failed to ready command '#{com.command}'!" }
            end
        end
        ready
    end

    CLIENT.on_message_create do |payload|
        next if (payload.webhook_id.nil? ? (payload.author.bot || false) : !check_if_webhook(payload.webhook_id.not_nil!))
        begin
            next if self.on_message(payload) === true
        rescue err
            sendError err, payload.author, payload.channel_id, "‼️ Failed to execute OnMessage! ‼️"
            Log.error(exception: err) { "An error occurred while trying to process onMessage event" }
            next
        end
        if payload.content == "<@#{CLIENT.client_id}>" || payload.content == "<@!#{CLIENT.client_id}>"
            if PING_MESSAGE != ""
                CLIENT.create_message payload.channel_id, PING_MESSAGE
            end
            next
        end
        if !(payload.content.starts_with? PREFIX)
            NMLM.synchronize do
                if (n = NML[payload.channel_id.value]?)
                    if payload.author && payload.author.id == n.user
                        begin
                            next if COMMANDS[n.cid].on_next_message(payload, n.data) == true
                        rescue err
                            sendError err, payload.author, payload.channel_id, "‼️ Failed to execute OnNextMessage! ‼️"
                            Log.error(exception: err) { "An error occurred while trying to process onNextMessage event with: '#{n.data}'" }
                        end
                        NML.delete payload.channel_id.value
                    end
                end
            end
            next
        end
        COMMANDS.each do |command|
            fullCommand = "#{PREFIX}#{command.command}"
            content = payload.content.split " "
            next if content[0] != fullCommand
            Log.info { "Got: #{fullCommand}" } # TODO: Change to debug
            break if command.flags & Command::Flag::NoDM == Command::Flag::NoDM && CACHE.resolve_channel(payload.channel_id).type != Discord::ChannelType::GuildText
            if command.flags & Command::Flag::NSFW == Command::Flag::NSFW && (!(ch = CACHE.resolve_channel(payload.channel_id)).nsfw && ch.type == Discord::ChannelType::GuildText)
                CLIENT.create_message payload.channel_id, NSFW_MESSAGE
                break
            end
            if !command.permissions.check payload.author, payload.member
                CLIENT.create_message payload.channel_id, PERMISSION_MESSAGE
                break
            end
            begin
                command.execute payload, content.size > 1 ? content[1..] : Array(String).new
            rescue err
                sendError err, payload.author, payload.channel_id, "‼️ Failed to execute command `#{command.command}`! ‼️"
                Log.error(exception: err) { "An error occurred while trying to process command: '#{fullCommand}'" }
            end
            break
        end
    end

    CLIENT.on_message_reaction_add do |payload|
        COMMANDS.each do |command|
            begin
                break if command.on_reaction payload # TODO: Rethink
            rescue err
                sendError err, CACHE.resolve_user(payload.user_id), payload.channel_id, "‼️ Failed to execute OnReaction event for `#{command.command}`! ‼️"
                Log.error(exception: err) { "An error occurred while trying to process reaction for command: '#{command.command}'" }
                break
            end
        end
    end

    # Starts bot session
    def start    
        Signal::INT.trap { safeHalt }
        Signal::TERM.trap { safeHalt }
        
        Log.info { "Started bot with prefix '#{PREFIX}'" }
        restart = true
        while restart
            restart = false
            begin
                CLIENT.run
            rescue e : Socket::Addrinfo::Error
                Log.error(exception: e) { "Failed to lookup hostname! Retrying..." }
                restart = true
            end
        end
    end

    # Hook run on the Ready Event
    def self.ready
    end
    # Hook run on the Message Create Event
    def self.on_message(payload)
    end
    # Hook run on SIGINT or SIGTERM signal
    def self.interupt
    end

    {% for const in ["OWNER", "WEBHOOK"] %}
    # Checks if given Snowflake is in the {{ const.id }} constant
    def self.check_if_{{ const.id.downcase }}(id : Discord::Snowflake) : Bool
        {% if parse_type(const).resolve.class_name == "ArrayLiteral" %}
            i = id.to_s
            {{ const.id }}.each do |v|
                return true if i == v
            end
            false
        {% else %}
            id.to_s == {{ const.id }}
        {% end %}
    end
    {% end %}

    # :nodoc:
    def self.sendError(err : Exception|String, author : Discord::User, channel : Discord::Snowflake, content : String = "")
        owner = check_if_owner author.id
        errMsg = err.is_a?(Exception) ? err.as(Exception).inspect_with_backtrace : err.as(String)
        CLIENT.create_message channel, "#{content.size != 0 ? "\n#{content}" : "Error!"}#{owner ? "\n```\n#{errMsg.size > 1500 ? "#{errMsg[..1500]}\n..." : errMsg}\n```" : ""}"
    end

    private def safeHalt
        SimpleBot.interupt
        CLIENT.stop
        Log.info { "Halt" }
        spawn do
            sleep 5
            exit
        end
    end

    # :nodoc:
    struct NextMessageInfo
        property user, cid, data
        def initialize(@user : Discord::Snowflake, @cid : UInt32, @data = "")
        end
    end
end
