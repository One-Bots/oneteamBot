local purge = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function purge:init()
    purge.commands = oneteam.commands(self.info.username):command('purge'):command('delmessages'):command('clear').table
    purge.help = '/purge [1-25] - Deletes the previous X messages (by message ID), where X is the number specified between 1 and 25 inclusive. Alternatively, a message can be replied to (within the past 25 messages), and those messages will be deleted. If messages have already been purged in between the replied-to message and the command, less will be deleted. Aliases: /delmessages, /clear.'
end

function purge:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(
            message,
            language['errors']['supergroup']
        )
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language['errors']['admin'])
    end
    if redis:get('purge:' .. message.chat.id) then
        return oneteam.send_reply(message, 'You can only use this command once every 2 minutes. Please wait for it to cooldown!')
    end
    redis:set('purge:' .. message.chat.id, message.from.id)
    redis:expire('purge:' .. message.chat.id, 120)
    local input = oneteam.input(message.text)
    if not input and not message.reply then
        redis:del('purge:' .. message.chat.id)
        return oneteam.send_reply(message, purge.help)
    elseif message.reply then
        local amount = message.message_id - message.reply.message_id
        if amount > 25 then
            amount = 25
        end
        if tonumber(input) ~= nil and tonumber(input) <= 25 then
            amount = tonumber(input)
        elseif tonumber(input) ~= nil then
            redis:del('purge:' .. message.chat.id)
            return oneteam.send_reply(message, 'You cannot purge more than 25 messages at a time!')
        end
        local progress = message.reply.message_id
        local deleted = 0
        for i = 1, amount do
            if deleted == amount then
                return oneteam.send_message(message.chat.id, 'Successfully deleted ' .. deleted .. ' message(s)!')
            end
            local done = oneteam.delete_message(message.chat.id, progress)
            if done then
                deleted = deleted + 1
            end
            progress = progress + 1
        end
        return oneteam.send_message(message.chat.id, 'Successfully deleted ' .. deleted .. ' message(s)!')
    elseif tonumber(input) == nil then
        redis:del('purge:' .. message.chat.id)
        return oneteam.send_reply(message, 'Please specify a numeric value, between 1 and 25 inclusive.')
    elseif tonumber(input) < 1 then
        redis:del('purge:' .. message.chat.id)
        return oneteam.send_reply(message, 'That number is too small! You must specify a number between 1 and 25 inclusive.')
    elseif tonumber(input) > 25 then
        redis:del('purge:' .. message.chat.id)
        return oneteam.send_reply(message, 'That number is too large! You must specify a number between 1 and 25 inclusive.')
    end
    local current = 0
    if not message.reply then
        current = oneteam.send_message(message.chat.id, 'Attempting to purge the previous ' .. input .. ' message(s)...')
        if not current then
            redis:del('purge:' .. message.chat.id)
            return false
        end
    else
        current = message
        current.result = current.reply
    end
    current = current.result.message_id
    if tonumber(current) - tonumber(input) <= 1 then
        redis:del('purge:' .. message.chat.id)
        return oneteam.edit_message_text(
            message.chat.id,
            current,
            'There are not ' .. input .. ' message(s) available to be deleted! Please specify a number between 1 and ' .. tonumber(current) - tonumber(input) - 1 .. ' inclusive.'
        )
    end
    local progress = tonumber(current) - 1
    local deleted = 0
    for i = 1, tonumber(input) do
        local done = oneteam.delete_message(message.chat.id, progress)
        if done then
            deleted = deleted + 1
        end
        progress = progress - 1
    end
    local success = oneteam.edit_message_text(message.chat.id, current, 'Successfully deleted ' .. deleted .. ' message(s)!')
    if not success then
        return oneteam.send_message(message.chat.id, 'Successfully deleted ' .. deleted .. ' message(s)!')
    end
    return success
end

return purge