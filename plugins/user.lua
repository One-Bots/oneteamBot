--[[
    Copyright 2017 Diego Barreiro <diego@makeroid.io>
    This code is licensed under the MIT. See LICENSE for details.
]]

local user = {}

local oneteam = require('oneteam')
local redis = dofile('libs/redis.lua')

function user:init()
    user.commands = oneteam.commands(
        self.info.username
    ):command('user')
     :command('u')
     :command('warns')
     :command('bans')
     :command('kicks')
     :command('unbans')
     :command('warnings')
     :command('status').table
    user.help = '/user [user] - Displays information about the given user. Alias: /u'
end

function user:on_message(message, configuration)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(
            message,
            configuration.errors.supergroup
        )
    end
    local input = message.reply and tostring(message.reply.from.id) or oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(
            message,
            user.help
        )
    end
    if tonumber(input) == nil and not input:match('^%@') then
        input = '@' .. input
    end
    local success = oneteam.get_user(input)
    if not success then
        user = oneteam.get_chat(input)
    else
        user = oneteam.get_chat(success.result.id)
    end
    if not user then
        return oneteam.send_reply(
            message,
            configuration.errors.unknown
        )
    elseif user.result.id == self.info.id then
        return
    end
    user = user.result
    local status = oneteam.get_chat_member(
        message.chat.id,
        user.id
    )
    if not status then
        return oneteam.send_reply(
            message,
            'I cannot display information about that user because I have never seen them in this chat.'
        )
    end
    local bans = redis:hget(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'bans'
    ) or 0
    local kicks = redis:hget(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'kicks'
    ) or 0
    local warnings = redis:hget(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'warnings'
    ) or 0
    local unbans = redis:hget(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'unbans'
    ) or 0
    local messages = redis:get('messages:' .. user.id .. ':' .. message.chat.id)
    or 0
    return oneteam.send_message(
        message.chat.id,
        string.format(
            '<pre>%s%s [%s%s]\n\nStatus: %s\nBans: %s\nKicks: %s\nWarnings: %s\nUnbans: %s\nMessages sent: %s</pre>',
            oneteam.escape_html(user.first_name),
            user.last_name and ' ' .. oneteam.escape_html(user.last_name) or '',
            user.username and '@' or '',
            user.username or user.id,
            status.result.status:gsub('^%l', string.upper),
            bans,
            kicks,
            warnings,
            unbans,
            messages
        ),
        'html',
        true,
        false,
        nil,
        oneteam.inline_keyboard():row(
            oneteam.row():callback_data_button(
                'Reset Warnings',
                string.format(
                    'warn:reset:%s:%s',
                    message.chat.id,
                    user.id
                )
            ):callback_data_button(
                'Remove 1 Warning',
                string.format(
                    'warn:remove:%s:%s',
                    message.chat.id,
                    user.id
                )
            )
        )
    )
end

return user
