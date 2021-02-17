local unfilter = {}
local oneteam = require('oneteam')
local json = require('dkjson')
local redis = require('libs.redis')

function unfilter:init()
    unfilter.commands = oneteam.commands(self.info.username):command('unfilter').table
    unfilter.help = '/unfilter <words> - Remove words from this chat\'s word filter.'
end

function unfilter:on_message(message, configuration, language)
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
            unfilter.help
        )
    end
    local words = {}
    for word in input:gmatch('%w+')
    do
        table.insert(
            words,
            word
        )
    end
    local total = redis:smembers('word_filter:' .. message.chat.id)
    local removed = {}
    for n, word in pairs(words)
    do
        if redis:sismember(
            'word_filter:' .. message.chat.id,
            word
        )
        then
            local success = redis:srem(
                'word_filter:' .. message.chat.id,
                word
            )
            if success == 1
            then
                table.insert(
                    removed,
                    word
                )
            end
        end
    end
    local new_total = #total - #removed
    return oneteam.send_message(
        message.chat.id,
        tostring(#removed) .. ' word(s) have been removed from this chat\'s word filter. There is now a total of ' .. tostring(new_total) .. ' word(s) filtered in this chat. Use /filter <words> to add words to this filter.'
    )
end

return unfilter