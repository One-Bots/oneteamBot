local setdescription = {}
local oneteam = require('oneteam')

function setdescription:init()
    setdescription.commands = oneteam.commands(self.info.username):command('setdescription').table
    setdescription.help = '/setdescription <text> - Sets the group\'s description to the given text. The given text must be between 1 and 255 characters in length.'
end

function setdescription:on_message(message, configuration, language)
    if message.chat.type == 'private'
    then
        return oneteam.send_reply(
            message,
            'You can\'t use this command in private chat.'
        )
    elseif not oneteam.is_group_admin(
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
    or input:len() < 1
    or input:len() > 255
    then
        return oneteam.send_reply(
            message,
            setdescription.help
        )
    end
    local success = oneteam.set_chat_description(
        message.chat.id,
        input
    )
    if not success
    then
        return oneteam.send_reply(
            message,
            'An error occured whilst trying to set the chat\'s description. Please ensure I have the required administrative permissions to perform this action, then try again.'
        )
    end
    return
end

return setdescription