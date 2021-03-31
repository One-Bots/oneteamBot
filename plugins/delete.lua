local delete = {}
local oneteam = require('oneteam')

function delete:init()
    delete.commands = oneteam.commands(self.info.username):command('delete').table
    delete.help = '/delete [message ID] - Deletes the specified (or replied-to) message.'
end

function delete:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup'
    then
        return oneteam.send_reply(
            message,
            language['errors']['supergroup']
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
    or (
        message.reply
        and message.reply.message_id
    )
    if not input
    or tonumber(input) == nil
    then
        return oneteam.send_reply(
            message,
            delete.help
        )
    end
    local success = oneteam.delete_message(
        message.chat.id,
        tonumber(input)
    )
    if not success
    then
        return oneteam.send_reply(
            message,
            language['delete']['1']
        )
    end
    return oneteam.delete_message(
        message.chat.id,
        message.message_id
    )
end

return delete