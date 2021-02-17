local setchattitle = {}
local oneteam = require('oneteam')

function setchattitle:init()
    setchattitle.commands = oneteam.commands(self.info.username):command('setchattitle'):command('sct').table
    setchattitle.help = '/setchattitle <title> - Sets the replied-to admin\'s title to the given text. The given text must be between 1 and 16 characters in length. Alias: /sct.'
end

function setchattitle:on_message(message, configuration, language)
    if message.chat.type == 'private' then
        return false
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return false
    elseif not message.reply then
        return oneteam.send_reply(message, 'Please use this command in reply to the admin you want to give the title to!')
    elseif not oneteam.is_group_admin(message.chat.id, message.reply.from.id) then
        return oneteam.send_reply(message, 'The replied-to user isn\'t an admin in this group!')
    end
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, setchattitle.help)
    elseif input:len() > 16 then
        return oneteam.send_reply(message, 'The title must be between 1 and 16 characters long!')
    end
    local success = oneteam.set_chat_administrator_custom_title(message.chat.id, message.reply.from.id, input)
    if not success then
        return oneteam.send_reply(
            message,
            'An error occured whilst trying to set that admin\'s title. Please ensure I have the required administrative permissions to perform this action, then try again.'
        )
    end
    return
end

return setchattitle