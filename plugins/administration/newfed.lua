local newfed = {}
local oneteam = require('oneteam')
local uuid = require('uuid')
local redis = require('libs.redis')

function newfed:init(configuration)
    newfed.commands = oneteam.commands(self.info.username):command('newfed').table
    newfed.help = '/newfed <fed name> - Allows a group admin to create a new Fed, and return its UUID.'
    newfed.limit = configuration.administration.feds.group_limit
end

function newfed.on_message(_, message, _, language)
    if message.chat.type ~= 'private' and not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    end
    local input = oneteam.input(message.text)
    if not input then
        local success = oneteam.send_force_reply(message, 'Please specify a name for the Fed!')
        if success then
            oneteam.set_command_action(message.chat.id, success.result.message_id, '/newfed')
        end
        return success
    elseif input:len() > 128 then
        return oneteam.send_reply(message, 'Fed names cannot be longer than 128 characters in length!')
    end
    uuid.seed()
    local fed_uuid = uuid.new()
    local feds = redis:smembers('chat:' .. message.chat.id .. ':feds')
    if message.chat.type ~= 'private' and #feds >= newfed.limit then
        return oneteam.send_reply(message, 'This group is already part of ' .. newfed.limit .. ' or more Feds. To leave one of these Feds and create a new one (starting with this chat in it), please send /leavefed <fed UUID> and then try this command again! Alternatively, to create a Fed but not have this group join it, use this command in private message!')
    elseif redis:exists('fedmembers:' .. fed_uuid) then -- EXTREMELY unlikely it would generate the same UUID but I know my luck
        fed_uuid = uuid.new()
    end
    redis:hset('fed:' .. fed_uuid, 'creator', message.from.id)
    redis:hset('fed:' .. fed_uuid, 'date_created', os.time())
    redis:hset('fed:' .. fed_uuid, 'title', input)
    redis:sadd('fedadmins:' .. fed_uuid, message.from.id)
    redis:sadd('feds:' .. message.from.id, fed_uuid)
    local output = 'Created the Fed <b>%s</b>\nTo join this Fed in a group, send <code>/joinfed %s</code> in the group.'
    if message.chat.type ~= 'private' then
        redis:sadd('chat:' .. message.chat.id .. ':feds', fed_uuid)
        redis:sadd('fedmembers:' .. fed_uuid, message.chat.id)
        output = 'Created the Fed <b>%s</b>, and added this group <code>[%s]</code> to it!\nTo join this Fed in another group, send <code>/joinfed %s</code>'
    end
    input = oneteam.escape_html(input)
    output = message.chat.type == 'private' and string.format(output, input, fed_uuid) or string.format(output, input, message.chat.id, fed_uuid)
    return oneteam.send_reply(message, output, 'html')
end

return newfed