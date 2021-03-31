local addrule = {}
local oneteam = require('oneteam')

function addrule:init()
    addrule.commands = oneteam.commands(self.info.username):command('addrule').table
    addrule.help = '/addrule <text> - Allows you to add another group rule!'
end

function addrule.on_message(_, message, _, language)
    if message.chat.type == 'private' then return false end
    if not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    end
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, language['addrule']['1'])
    end
    local rules = oneteam.get_value(message.chat.id, 'rules')
    if not rules then
        return oneteam.send_reply(message, language['addrule']['2'])
    end
    local new_rules = rules .. '\n' .. input
    local success = oneteam.send_message(message.chat.id, new_rules, 'markdown')
    if not success and utf8.len(new_rules) > 4096 then
        return oneteam.send_reply(message, language['addrule']['3'])
    elseif not success then
        return oneteam.send_reply(message, language['addrule']['4'])
    end
    oneteam.set_value(message.chat.id, 'rules', new_rules)
    return oneteam.edit_message_text(message.chat.id, success.result.message_id, language['addrule']['5'])
end

return addrule