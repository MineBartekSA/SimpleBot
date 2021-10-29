class SimpleBot::Command
    include SimpleBot

    @@instance : self?
    # Command name
    getter command : String
    # :nodoc:
    getter id : UInt32
    def initialize(@command)
        @id = COMMANDS.size.to_u
        @@instance = self
    end

    # Full description of the command
    def description : String
        "No Description provided"
    end
    # If command takes arguments, argument string in order to present them
    def arguments : String?
        nil
    end
    # Command Permissions
    def permissions : Permission
        Permission.new public: true
    end
    # Command flags
    def flags : Flag
        Flag::None
    end
    # On Bot Ready
    def ready
    end
    # On Message starting with bot prefix and command name
    def execute(message : Discord::Message, args : Array(String))
        raise Exception.new "#{self.class.name} does not implement execution!"
    end
    # On Reaction Add
    def on_reaction(payload : Discord::Gateway::MessageReactionPayload) : Bool
        false
    end
    # On Next Message sent
    def on_next_message(message : Discord::Message, data : String)
    end

    # Wait for next message from provided user
    def next_message(channel : Discord::Snowflake, user : Discord::Snowflake, data = "", timeout = nil)
        NMLM.synchronize { NML[channel.value] = NextMessageInfo.new user, @id, data }
        if !timeout.nil?
            spawn do
                sleep timeout.not_nil!
                NMLM.synchronize { NML.delete channel.value if NML.has_key? channel.value }
            end
        end
    end

    macro inherited
        Log = ::Log.for self
        name = self.name.split("::")[-1]
        COMMANDS << self.new "#{name[0].downcase}#{name[1..]}"
        COMMANDS.delete COMMANDS[-1] if COMMANDS[-1].flags & Flag::Debug == Flag::Debug && {{ flag?(:release) ? true.id : false.id }}
        def self.instance : self
            @@instance.not_nil!.as self
        end
    end

    @[Flags]
    enum Flag
        NSFW
        NoDM
        Debug
    end
end
