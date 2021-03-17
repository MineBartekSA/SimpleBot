class SimpleBot::Command
    include SimpleBot

    @@instance : self?
    getter command : String
    def initialize(@command)
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

    macro inherited
        Log = ::Log.for self
        name = self.name.split("::")[-1]
        COMMANDS << self.new "#{name[0].downcase}#{name[1..]}"
        def self.instance : self
            @@instance.not_nil!.as self
        end
    end
end
