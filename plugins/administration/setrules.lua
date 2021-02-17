local setrules = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function setrules:init()
    setrules.commands = oneteam.commands(self.info.username):command('setrules').table
    setrules.help = '/setrules <text> - Sets the group\'s rules to the give text. Markdown formatting is supported.'
end

function setrules:on_message(message, configuration, language)
    if not oneteam.is_group_admin(
        message.chat.id,
        message.from.id
    )
    then
        return oneteam.send_reply(
            message,
            language['errors']['admin']
        )
    end
    local input = oneteam.input(message.text)
    if not input
    then
        return oneteam.send_reply(
            message,
            setrules.help
        )
    end
    redis:hset(
        'chat:' .. message.chat.id .. ':info',
        'rules',
        input
    )
    local success = oneteam.send_message(
        message,
        input,
        'markdown'
    )
    if not success
    then
        return oneteam.send_reply(
            message,
            language['setrules']['1']
        )
    end
    return oneteam.edit_message_text(
        message.chat.id,
        success.result.message_id,
        language['setrules']['2']
    )
end

return setrules