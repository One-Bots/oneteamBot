local wordfilter = {}
local oneteam = require('oneteam')
local redis = dofile('libs/redis.lua')

function wordfilter:init()
    wordfilter.commands = oneteam.commands(self.info.username):command('wordfilter').table
    wordfilter.help = '/wordfilter - View a list of words which have been added to the chat\'s word filter.'
end

function wordfilter:on_message(message, configuration, language)
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
    local words = redis:smembers('word_filter:' .. message.chat.id)
    if #words < 1
    then
        return oneteam.send_reply(
            message,
            'There are no words filtered in this chat. To add words to the filter, use /filter <word(s)>.'
        )
    end
    return oneteam.send_message(
        message.chat.id,
        'Filtered words: ' .. table.concat(words, ', ')
    )
end

return wordfilter
