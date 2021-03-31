local logchat = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function logchat:init()
    logchat.commands = oneteam.commands(self.info.username):command('logchat').table
    logchat.help = '/logchat [chat] - Specify the chat that you wish to log all of this chat\'s administrative actions into.'
end

function logchat:on_message(message, configuration, language)
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
    if not input
    then
        local success = oneteam.send_force_reply(
            message,
            language['logchat']['1']
        )
        if success
        then
            redis:set(
                string.format(
                    'action:%s:%s',
                    message.chat.id,
                    success.result.message_id
                ),
                '/logchat'
            )
        end
        return
    end
    local res = oneteam.send_message(
        message.chat.id,
        language['logchat']['2']
    )
    if not res
    then
        return
    elseif tonumber(input) == nil
    and not input:match('^@')
    then
        input = '@' .. input
    end
    local valid = oneteam.get_chat(input)
    or oneteam.get_user(input)
    if not valid
    or not valid.result
    then
        return oneteam.edit_message_text(
            message.chat.id,
            res.result.message_id,
            language['logchat']['3']
        )
    elseif valid.result.type == 'private'
    then
        return oneteam.edit_message_text(
            message.chat.id,
            res.result.message_id,
            language['logchat']['4']
        )
    elseif not oneteam.is_group_admin(
        valid.result.id,
        message.from.id
    )
    then
        return oneteam.edit_message_text(
            message.chat.id,
            res.result.message_id,
            language['logchat']['5']
        )
    elseif redis:hget(
        'chat:' .. message.chat.id .. ':settings',
        'log chat'
    )
    and redis:hget(
        'chat:' .. message.chat.id .. ':settings',
        'log chat'
    ) == valid.result.id
    then
        return oneteam.edit_message_text(
            message.chat.id,
            res.result.message_id,
            language['logchat']['6']
        )
    end
    oneteam.edit_message_text(
        message.chat.id,
        res.result.message_id,
        language['logchat']['7']
    )
    local permission = oneteam.send_message(valid.result.id, language['logchat']['8'])
    if not permission then
        return oneteam.edit_message_text(
            message.chat.id,
            res.result.message_id,
            'It appears I don\'t have permission to post to that chat. Please ensure it\'s still a valid chat and that I have administrative rights!'
        )
    end
    oneteam.delete_message(valid.result.id, permission.result.message_id)
    redis:hset(
        'chat:' .. message.chat.id .. ':settings',
        'log chat',
        valid.result.id
    )
    return oneteam.edit_message_text(
        message.chat.id,
        res.result.message_id,
        string.format(
            language['logchat']['9'],
            input
        )
    )
end

return logchat