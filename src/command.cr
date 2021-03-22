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

    def next_message(channel : Discord::Snowflake, user : Discord::Snowflake, data = "")
        NML[channel.value] = NextMessageInfo.new user, @id, data
    end

    macro inherited
        Log = ::Log.for self
        name = self.name.split("::")[-1]
        COMMANDS << self.new "#{name[0].downcase}#{name[1..]}"
        def self.instance : self
            @@instance.not_nil!.as self
        end
    end
end
