local allowbot = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function allowbot:init()
    allowbot.commands = oneteam.commands(self.info.username):command('allowbot'):command('allowbots'):command('wb').table
    allowbot.help = '/allowbot <bots> - Allowlists the given bots in the current chat. Requires administrative privileges. Aliases: /allowbots, /wb.'
    allowbot.example_bots = { 'gif', 'imdb', 'wiki', 'music', 'youtube', 'bold', 'sticker', 'vote', 'like', 'gamee', 'coub', 'pic', 'vid', 'bing' }
end

function allowbot:on_new_message(message, configuration, language)
    if message.chat.type ~= 'supergroup' then
        return false
    elseif oneteam.get_setting(message.chat.id, 'prevent inline bots') and message.via_bot and not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.delete_message(message.chat.id, message.message_id)
    end
end

function allowbot:on_message(message, configuration, language)
    if not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    end
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, 'Please specify the @usernames of the bots you\'d like to allowlist.')
    elseif not input:match('@?[%w_]') then
        return oneteam.send_reply(message, 'Please make sure you\'re specifying valid bot usernames!')
    end
    local bots = {}
    for bot in input:gmatch('@?([%w_]+bot)') do
        table.insert(bots, bot)
    end
    for _, bot in pairs(allowbot.example_bots) do
        if input:match('@?' .. bot) then
            table.insert(bots, bot)
        end
    end
    if #bots == 0 then
        return oneteam.send_reply(message, 'Please make sure you\'re specifying valid bot usernames!')
    end
    for _, bot in pairs(bots) do
        redis:sadd('allowlisted_bots:' .. message.chat.id, bot)
    end
    local output = string.format('Successfully allowlisted the following bots in this chat: %s', table.concat(bots, ', '))
    return oneteam.send_reply(message, output)
end

return allowbot