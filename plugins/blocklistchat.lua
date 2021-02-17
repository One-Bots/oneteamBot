local allowlistchat = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function allowlistchat:init()
    allowlistchat.commands = oneteam.commands(self.info.username):command('allowlistchat').table
end

function allowlistchat.on_message(_, message, _, language)
    if not oneteam.is_global_admin(message.from.id) then
        return false
    end
    local input = oneteam.input(message.text)
    if not input then
        return false
    end
    input = input:match('^@(.-)$') or input
    local res = oneteam.get_chat(input)
    local output
    if not res then
        output = string.format(language['allowlistchat']['3'], input)
    elseif res.result.type == 'private' then
        output = string.format(language['allowlistchat']['2'], input)
    else
        redis.set('allowlisted_chats:' .. input, true)
        output = string.format(language['allowlistchat']['1'], input)
    end
    return oneteam.send_reply(message, output)
end

return allowlistchat