local lua = {}
local oneteam = require('oneteam')
local json = require('dkjson')

function lua:init()
    lua.commands = oneteam.commands(self.info.username):command('lua').table
    lua.error_message = function(error_message)
        return 'Error:\n' .. tostring(error_message)
    end
end

function lua:on_message(message, configuration, language)
    if not oneteam.is_global_admin(message.from.id) then
        return
    end
    local input = oneteam.input(message.text)
    if not input then
        local text = language['lua']['1']
        return oneteam.send_reply(message, text)
    end
    local output, success = load(
    "local oneteam = require('oneteam')\n\z
    local configuration = require('configuration')\n\z
    local api = require('telegram-bot-lua.core').configure(configuration.bot_token)\n\z
    local tools = require('telegram-bot-lua.tools')\n\z
    local https = require('ssl.https')\n\z
    local http = require('socket.http')\n\z
    local url = require('socket.url')\n\z
    local ltn12 = require('ltn12')\n\z
    local json = require('dkjson')\n\z
    local utf8 = require('lua-utf8')\n\z
    local socket = require('socket')\n\z
    local redis = require('libs.redis')\n\z
    return function (self, message, configuration)\n" .. input .. '\nend')
    if output == nil then
        output = success
    else
        success, output = xpcall(
            output(),
            lua.error_message,
            self,
            message,
            configuration
        )
    end
    if output ~= nil and type(output) == 'table' then
        output = json.encode(output, { ['indent'] = true })
    elseif output == nil then
        return false
    end
    return oneteam.send_message(
        message.chat.id,
        '<pre>' .. oneteam.escape_html(
            tostring(output)
        ) .. '</pre>',
        'html'
    )
end

return lua