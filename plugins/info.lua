--[[
    Copyright 2020 Matthew Hesketh <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local info = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function info:init()
    info.commands = oneteam.commands(self.info.username):command('info').table
    info.help = '/info - View system information & statistics about the bot.'
end

function info:on_message(message, configuration, language)
    if not oneteam.is_global_admin(message.from.id) then return false end
    local info = redis:info()
    if not info then
        return oneteam.send_reply(message, language['errors']['generic'])
    end
    return oneteam.send_message(
        message.chat.id,
        string.format(
            language['info']['1'],
            oneteam.symbols.bullet,
            info.server.config_file,
            oneteam.symbols.bullet,
            info.server.redis_mode,
            oneteam.symbols.bullet,
            info.server.tcp_port,
            oneteam.symbols.bullet,
            info.server.redis_version,
            oneteam.symbols.bullet,
            info.server.uptime_in_days,
            oneteam.symbols.bullet,
            info.server.process_id,
            oneteam.symbols.bullet,
            oneteam.comma_value(info.stats.expired_keys),
            oneteam.symbols.bullet,
            oneteam.comma_value(oneteam.get_user_count()),
            oneteam.symbols.bullet,
            oneteam.comma_value(oneteam.get_group_count()),
            oneteam.symbols.bullet,
            io.popen('uname -a'):read('*all')
        ),
        'markdown'
    )
end

return info