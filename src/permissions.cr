struct SimpleBot::Permission
    include SimpleBot
    property public, ownerOnly, allowedRoles, allowedUsers, disallowedRoles, disallowdUsers

    def initialize(
        @public : Bool = false,
        @ownerOnly : Bool = false,
        @allowedRoles : Array(Discord::Snowflake)? = nil,
        @allowedUsers : Array(Discord::Snowflake)? = nil,
        @disallowdUsers : Array(Discord::Snowflake)? = nil,
        @disallowedRoles : Array(Discord::Snowflake)? = nil
    )
    end

    def check(user : Discord::User, partial_member : Discord::PartialGuildMember)
        self.check(Discord::GuildMember.new user, partial_member)
    end

    def check(member : Discord::GuildMember) : Bool
        owner = SimpleBot.checkIfOwner member.user.id
        return owner if @ownerOnly
        return true if owner
        return false if @disallowdUsers.not_nil!.includes? member.user.id if !@disallowdUsers.nil?
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
        return true if @allowedUsers.not_nil!.includes? member.user.id if !@allowedUsers.nil?
        false
    end
end
