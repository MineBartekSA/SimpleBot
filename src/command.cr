class SimpleBot::Command
    include SimpleBot

    @@instance : self?
    getter command : String
    getter id : UInt32
    def initialize(@command)
        @id = COMMANDS.size.to_u
        @@instance = self
    end

    def description : String
        "No Description provided"
    end
    def arguments : String?
        nil
    end
    def permissions : Permission
        Permission.new public: true
    end
    def flags : Flag
        Flag::None
    end
    def ready
    end
    def execute(message : Discord::Message, args : Array(String))
        raise Exception.new "#{self.class.name} does not implement execution!"
    end
    def on_reaction(payload : Discord::Gateway::MessageReactionPayload) : Bool
        false
    end
    def on_next_message(message : Discord::Message, data : String)
    end

    def next_message(channel : Discord::Snowflake, user : Discord::Snowflake, data = "", timeout : Float = 0_f32)
        NMLM.synchronize { NML[channel.value] = NextMessageInfo.new user, @id, data }
        if timeout != 0
            spawn do
                sleep timeout
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
