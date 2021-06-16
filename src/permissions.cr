struct SimpleBot::Permission
    include SimpleBot
    property public, ownerOnly, allowedRoles, allowedUsers, disallowedRoles, disallowdUsers

    def initialize(
        @public : Bool = false,
        @ownerOnly : Bool = false,
        @allowedRoles : Array(Discord::Snowflake)? = nil,
        @allowedUsers : Array(Discord::Snowflake)? = nil,
        @disallowedUsers : Array(Discord::Snowflake)? = nil,
        @disallowedRoles : Array(Discord::Snowflake)? = nil
    )
    end

    def check(user : Discord::User, partial_member : Discord::GuildMember?)
        if partial_member.nil?
            owner = checkIfOwner user.id
            return owner if @ownerOnly
            return true if owner
            return false if @disallowedUsers.not_nil!.includes? user.id if !@disallowedUsers.nil?
            return true if @allowedUsers.not_nil!.includes? user.id if !@allowedUsers.nil?
            return @public
        end
        self.check(Discord::GuildMember.new user, partial_member.not_nil!)
    end

    def check(member : Discord::GuildMember) : Bool
        owner = checkIfOwner member.user.not_nil!.id
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
