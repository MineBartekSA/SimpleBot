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
    # Argument string for command presentation
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
    # On Message Created, and the message starts with bot prefix and command name
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
        instance = self.new "#{name[0].downcase}#{name[1..]}"
        unless {{ flag?(:release) ? true.id : false.id }} && instance.flags & Flag::Debug == Flag::Debug
            COMMANDS << instance
            Log.debug { "New command added: #{instance.command}" }
        end
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
