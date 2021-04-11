--[[
    Copyright 2017 Diego Barreiro <diego@makeroid.io>
    This code is licensed under the MIT. See LICENSE for details.
]]

local purge = {}
local oneteam = require('oneteam')

function purge:init()
    purge.commands = oneteam.commands(self.info.username):command('purge').table
    purge.help = '/purge <1-25> - Deletes the previous X messages, where X is the number specified between 1 and 25 inclusive.'
end

function purge:on_message(message, configuration, language)
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
        return oneteam.send_reply(
            message,
            purge.help
        )
    elseif tonumber(input) == nil
    then
        return oneteam.send_reply(
            message,
            'Please specify a numeric value, between 1 and 25 inclusive.'
        )
    elseif tonumber(input) < 1
    then
        return oneteam.send_reply(
            message,
            'That number is too small! You must specify a number between 1 and 25 inclusive.'
        )
    elseif tonumber(input) > 25
    then
        return oneteam.send_reply(
            message,
            'That number is too large! You must specify a number between 1 and 25 inclusive.'
        )
    end
    local current = 0
    if not message.reply
    then
        current = oneteam.send_message(
            message.chat.id,
            'Attempting to purge the previous ' .. input .. ' message(s)...'
        )
        if not current
        then
            return false
        end
    else
        current = message
        current.result = current.reply
    end
    current = current.result.message_id
    if tonumber(current) - tonumber(input) <= 1
    then
        return oneteam.edit_message_text(
            message.chat.id,
            current,
            'There are not ' .. input .. ' message(s) available to be deleted! Please specify a number between 1 and ' .. tonumber(current) - tonumber(input) - 1 .. ' inclusive.'
        )
    end
    local progress = tonumber(current) - 1
    local deleted = 0
    for i = 1, tonumber(input)
    do
        local done = oneteam.delete_message(
            message.chat.id,
            progress
        )
        if done
        then
            deleted = deleted + 1
        end
        progress = progress - 1
    end
    local success = oneteam.edit_message_text(
        message.chat.id,
        current,
        'Successfully deleted ' .. deleted .. ' message(s)!'
    )
    if not success
    then
        return oneteam.send_message(
            message.chat.id,
            'Successfully deleted ' .. deleted .. ' message(s)!'
        )
    end
    return
end

return purge
