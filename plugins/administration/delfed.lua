local delfed = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function delfed:init()
    delfed.commands = oneteam.commands(self.info.username):command('delfed').table
    delfed.help = '/delfed <fed UUID> - Allows the Fed creator to delete a Fed, specified by its UUID.'
end

function delfed:on_new_message(message)
    if message.chat.type == 'private' then
        return false
    end
    local feds = redis:smembers('chat:' .. message.chat.id .. ':feds')
    if #feds == 0 then
        return false
    end
    for _, fed in pairs(feds) do
        if not redis:hexists('fed:' .. fed, 'creator') then
            redis:srem('chat:' .. message.chat.id .. ':feds', fed)
            oneteam.send_message(message.chat.id, 'The Fed this chat is part of has been deleted! To start a new one, use `/newfed <name>`.', true)
        end
    end
    return
end

function delfed:on_message(message, configuration, language)
    local input = oneteam.input(message.text)
    if message.chat.type ~= 'supergroup' and not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return false
    elseif not input then
        return oneteam.send_reply(message, 'You must specify the UUID of the Fed you\'d like to delete, in the format `/delfed <fed UUID>`!', true)
    elseif not input:match('^%w+%-%w+%-%w+%-%w+%-%w+$') then
        return oneteam.send_reply(message, 'That\'s not a valid UUID!')
    end
    local creator = redis:hget('fed:' .. input, 'creator')
    if not creator then
        return oneteam.send_reply(message, 'I couldn\'t find that Fed, perhaps it has already been deleted?')
    elseif creator ~= message.from.id then
        return oneteam.send_reply(message, 'You must be the creator of the Fed in order to delete it!')
    end
    local title = redis:hget('fed:' .. input, 'title')
    redis:del('fedadmins:' .. input)
    redis:del('fedmembers:' .. input)
    redis:del('fed:' .. input)
    redis:srem('feds:' .. message.from.id, input)
    if message.chat.type ~= 'private' then
        local current = redis:sismember('chat:' .. message.chat.id .. ':feds', input)
        if current then
            redis:srem('chat:' .. message.chat.id .. ':feds', input)
        end
    end
    local output = 'Successfully deleted the Fed "<b>%s</b>" <code>%s</code>!'
    output = string.format(output, oneteam.escape_html(title), input)
    return oneteam.send_reply(message, output)
end

return delfed