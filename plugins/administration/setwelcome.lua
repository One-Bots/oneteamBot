local setwelcome = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function setwelcome:init()
    setwelcome.commands = oneteam.commands(self.info.username):command('setwelcome').table
    setwelcome.help = '/setwelcome <text> - Sets the group\'s welcome message to the given, Markdown-formatted text. You can use placeholders to automatically customise the welcome message for each user. Use $user_id to insert the user\'s numerical ID, $chat_id to insert the chat\'s numerical ID, $name to insert the user\'s name, $title to insert the chat\'s title and $username to insert the user\'s username (if the user doesn\'t have an @username, their name will be used instead, so it is best to avoid using this in conjunction with $name).'
end

function setwelcome:on_message(message, configuration, language)
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
        local success = oneteam.send_force_reply(
            message,
            language['setwelcome']['1']
        )
        if success
        then
            redis:set(
                string.format(
                    'action:%s:%s',
                    message.chat.id,
                    success.result.message_id
                ),
                '/setwelcome'
            )
        end
        return
    end
    local validate = oneteam.send_message(
        configuration.log_chat,
        input,
        'markdown'
    )
    if not validate
    then
        return oneteam.send_reply(
            message,
            language['setwelcome']['2']
        )
    end
    oneteam.delete_message(
        configuration.log_chat,
        validate.result.message_id
    )
    redis:hset(
        'chat:' .. message.chat.id .. ':info',
        'welcome message',
        input
    )
    return oneteam.send_message(
        message.chat.id,
        string.format(
            language['setwelcome']['3'],
            message.chat.title
        )
    )
end

return setwelcome
