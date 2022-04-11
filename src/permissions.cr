struct SimpleBot::Permission
    # Makes command Public. Disallowed will only be checked
    property public : Bool
    # Makes command available only to the owner of the bot (if user is in OWNER constant)
    property ownerOnly : Bool
    # Roles allowed to use this command
    property allowedRoles : Array(Discord::Snowflake)?
    # Users allowed to use this command
    property allowedUsers : Array(Discord::Snowflake)?
    # Roles disallowed to use this command
    property disallowedRoles : Array(Discord::Snowflake)?
    # Users disallowed to use this command
    property disallowedUsers : Array(Discord::Snowflake)?

    def initialize(@public = false, @ownerOnly = false, @allowedRoles = nil, @allowedUsers = nil, @disallowedUsers = nil, @disallowedRoles = nil)
    end

    def check(user : Discord::User, partial_member : Discord::GuildMember?)
        if partial_member.nil?
            owner = SimpleBot.check_if_owner user.id
            return owner if @ownerOnly
            return true if owner
            return false if @disallowedUsers.not_nil!.includes? user.id if !@disallowedUsers.nil?
            return true if @allowedUsers.not_nil!.includes? user.id if !@allowedUsers.nil?
            return @public
        end
        self.check(Discord::GuildMember.new user, partial_member.not_nil!)
    end

    def check(member : Discord::GuildMember) : Bool
        owner = SimpleBot.check_if_owner member.user.not_nil!.id
        return owner if @ownerOnly
        return true if owner
        return false if @disallowedUsers.not_nil!.includes? member.user.not_nil!.id if !@disallowedUsers.nil?
        dis, all = false, false
        member.roles.each do |role|
            if !@disallowedRoles.nil?
                dis = @disallowedRoles.not_nil!.includes? role
                break if dis
            end
            all = @allowedRoles.not_nil!.includes? role if !all if !@allowedRoles.nil?
        end
        return false if dis
        return true if @public || all
        return true if @allowedUsers.not_nil!.includes? member.user.not_nil!.id if !@allowedUsers.nil?
        false
    end
end
