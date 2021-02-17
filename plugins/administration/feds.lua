local feds = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function feds:init()
    feds.commands = oneteam.commands(self.info.username):command('feds').table
    feds.help = '/feds - Allows group admins to view the group\'s current Feds.'
end

function feds:on_message(message, configuration, language)
    if message.chat.type == 'private' then
        return oneteam.send_reply(message, language.errors.supergroup)
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    end
    local all = redis:smembers('chat:' .. message.chat.id .. ':feds')
    if #all == 0 then
        local output = '<b>%s</b> isn\'t part of any Feds! To join one, use <code>/joinfed &lt;fed UUID&gt;</code>!'
        output = string.format(output, oneteam.escape_html(message.chat.title))
        return oneteam.send_reply(message, output, 'html')
    end
    local output = { '<b>' .. oneteam.escape_html(message.chat.title) .. '</b> is part of the following Feds:' }
    for _, fed in pairs(all) do
        local formatted = oneteam.symbols.bullet .. ' <em>%s</em> <code>[%s]</code>'
        local title = redis:hget('fed:' .. fed, 'title')
        formatted = string.format(formatted, oneteam.escape_html(title), fed)
        table.insert(output, formatted)
    end
    output = table.concat(output, '\n')
    return oneteam.send_reply(message, output, 'html')
end

return feds