local leavefed = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function leavefed:init()
    leavefed.commands = oneteam.commands(self.info.username):command('leavefed').table
    leavefed.help = '/leavefed <fed UUID> - Allows the group creator to leave one of the group\'s current Feds.'
end

function leavefed:on_message(message, configuration, language)
    local input = oneteam.input(message.text)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(message, language.errors.supergroup)
    elseif not oneteam.is_user_group_creator(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, 'Only the group creator can use this command!')
    end
    local feds = redis:smembers('chat:' .. message.chat.id .. ':feds')
    if #feds > 1 and not input then
        return oneteam.send_reply(message, 'You must specify the Fed you\'d like to leave, by it\'s UUID!')
    elseif #feds == 0 then
        return oneteam.send_reply(message, 'This group isn\'t part of any Feds!')
    end
    local is_member = false
    for _, fed in pairs(feds) do
        if fed == input then
            is_member = true
        end
    end
    if not is_member then
        return oneteam.send_reply(message, 'This group isn\'t part of that Fed!')
    end
    redis:srem('chat:' .. message.chat.id .. ':feds', input)
    redis:srem('fedmembers:' .. input, message.chat.id)
    local title = redis:hget('fed:' .. input, 'title')
    local output = 'Successfully left the Fed "<b>%s</b>" <code>[%s]</code>! To join a new Fed, use <code>/joinfed &lt;fed UUID&gt;</code>, or to create a new Fed, use <code>/newfed &lt;fed name&gt;</code>!'
    output = string.format(output, oneteam.escape_html(title), input)
    return oneteam.send_reply(message, output, 'html')
end

return leavefed