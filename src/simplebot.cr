require "discordcr"
require "log"
require "./**"

{% for const in ["PREFIX", "OWNER", "PING_MESSAGE"] %}
    {% if !@type.has_constant? const %}
        {% if const == "PREFIX" %}
            {{ const.id }} = "!"
        {% else %}
            {{ const.id }} = ""
        {% end %}
    {% end %}
{% end %}

module SimpleBot
    Log = ::Log.for self
    VERSION = "0.1.0"

    CLIENT = Discord::Client.new "Bot #{TOKEN}"
    CACHE = Discord::Cache.new CLIENT
    CLIENT.cache = CACHE

    COMMANDS = Array(SimpleBot::Command).new

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
        next if !(payload.author.bot || true)
        if payload.content == "<@#{CLIENT.client_id}>" || payload.content == "<@!#{CLIENT.client_id}>"
            if PING_MESSAGE != ""
                CLIENT.create_message payload.channel_id, PING_MESSAGE
            end
            next
        end
        next if !(payload.content.starts_with? PREFIX)
        COMMANDS.each do |command|
            fullCommand = "#{PREFIX}#{command.command}"
            next if !payload.content.starts_with? "#{fullCommand} "
            Log.info { "Got: #{fullCommand}" }
            if !command.permissions.check payload.author, payload.member.not_nil!
                CLIENT.create_message payload.channel_id, "⛔ You don't have enough permissions to use this command!"
                next
            end
            begin
                command.execute payload, payload.content.size > fullCommand.size ? payload.content[(fullCommand.size + 1)..-1].split(" ") : Array(String).new
            rescue err
                sendError err, payload.author, payload.channel_id, "‼️ Failed to execute command `#{command.command}`! ‼️"
                Log.error(exception: err) { "An error occurred while trying to process command: '#{fullCommand}'" }
            end
            break
        end
    end

    def start    
        Signal::INT.trap { safeHalt }
        Signal::TERM.trap { safeHalt }
        
        Log.info { "Started bot with prefix '#{PREFIX}'" }
        CLIENT.run
    end

    def self.ready
    end
    def self.interupt
    end

    def self.sendError(err : Exception|String, author : Discord::User, channel : Discord::Snowflake, content : String = "")
        owner = checkIfOwner author.id
        errMsg = err.is_a?(Exception) ? err.as(Exception).inspect_with_backtrace : err.as(String)
        CLIENT.create_message channel, "#{content.size != 0 ? "\n#{content}" : "Error!"}#{owner ? "\n```\n#{errMsg.size > 1500 ? "#{errMsg[..1500]}\n..." : errMsg}\n```" : ""}"
    end

    def self.checkIfOwner(id : Discord::Snowflake) : Bool
        {% if OWNER.class_name == "ArrayLiteral" %}
            i = id.to_s
            OWNER.each do |owner|
                return true if i == owner
            end
            false
        {% else %}
            id.to_s == OWNER
        {% end %}
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
end