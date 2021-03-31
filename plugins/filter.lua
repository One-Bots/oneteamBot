local filter = {}
local oneteam = require('oneteam')
local json = require('dkjson')
local redis = require('libs.redis')

function filter:init()
    filter.commands = oneteam.commands(self.info.username):command('filter').table
    filter.help = '/filter <words> - Add to the list of words that users will be kicked upon for saying. This feature requires the bot to have administrative permissions. The kick will only be a soft-ban (meaning the targeted user is able to return to the chat immediately), unless the "Ban Not Kick" setting is enabled in the /administration menu.'
end

function filter:on_message(message, configuration, language)
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
    or not input:match('%w+')
    then
        return oneteam.send_reply(
            message,
            filter.help
        )
    end
    local new_total = 0
    local words = {}
    for word in input:gmatch('%w+')
    do
        table.insert(
            words,
            word
        )
    end
    local total = redis:smembers('word_filter:' .. message.chat.id)
    if #total + #words >= 200
    then
        local remaining = 200 - #total
        return oneteam.send_reply(
            message,
            'You may only have 200 words filtered at a time. There are currently ' .. tostring(#total) .. ' word(s) filtered in this chat, so you may only add up to ' .. tostring(remaining) .. ' more.'
        )
    end
    local new = {}
    for n, word in pairs(words)
    do
        if not redis:sismember(
            'word_filter:' .. message.chat.id,
            word
        )
        then
            local success = redis:sadd(
                'word_filter:' .. message.chat.id,
                word
            )
            if success
            then
                table.insert(
                    new,
                    word
                )
            end
        end
    end
    return oneteam.send_message(
        message.chat.id,
        tostring(#new) .. ' word(s) have been added to this chat\'s word filter. Use /unfilter <words> to remove words from this filter.'
    )
end

return filter