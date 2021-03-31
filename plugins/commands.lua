--[[
    Based on a plugin by topkecleon.
    Copyright 2017 Diego Barreiro <diego@makeroid.io>
    This code is licensed under the MIT. See LICENSE for details.
]]

local commands = {}
local oneteam = require('oneteam')
local https = require('ssl.https')
local url = require('socket.url')
local redis = dofile('libs/redis.lua')
local configuration = require('configuration')

function commands:init(configuration)
    commands.commands = oneteam.commands(self.info.username):command('commands').table
    commands.help = '/commands - Sends the full list of avaliable commands.'
end

function commands:on_message(message, configuration, language)
    local arguments_list = oneteam.get_help()
    local output = "*List of Avaliable Commands:*\n\n"
    for k, v in pairs(arguments_list) do
        output = output .. "\n" .. v
    end
    return oneteam.send_reply(
        message,
        output,
        'markdown'
  )
end

return commands
