local spamwatch = {}
local oneteam = require('oneteam')

function spamwatch:init()
    spamwatch.commands = oneteam.commands(self.info.username):command('spamwatch'):command('sw').table
    spamwatch.help = '/spamwatch [user] - Returns SpamWatch information for the given user, either specified or replied-to. Alias: /sw.'
end

function spamwatch:on_new_message(message)
    if message.chat.type ~= 'supergroup' then
        return false
    elseif not oneteam.get_setting(message.chat.id, 'ban spamwatch users') then
        return false
    elseif self.is_spamwatch_blocklisted then
        oneteam.ban_chat_member(message.chat.id, message.from.id)
    end
    return false
end

function spamwatch:on_message(message)
    local input = message.reply and message.reply.from.id or oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, spamwatch.help)
    end
    local user = oneteam.get_user(input)
    if not user then
        if not input:match('^%d+$') then
            return oneteam.send_reply(message, 'I couldn\'t get any information about that user. To teach me who they are, forward a message from them. This will only work if they don\'t have forward privacy enabled!')
        end
        user = { ['result'] = { ['id'] = input:match('^(%d+)$') } }
    end
    user = user.result.id
    local res, jdat = oneteam.is_spamwatch_blocklisted(user)
    if not res then
        return oneteam.send_reply(message, 'That user isn\'t in the SpamWatch database!')
    end
    local output = {
        '<b>ID:</b> ' .. jdat.id,
        '<b>Reason:</b> ' .. oneteam.escape_html(jdat.reason),
        '<b>Date banned:</b> ' .. os.date('%x', jdat.date)
    }
    output = table.concat(output, '\n')
    return oneteam.send_reply(message, output, 'html')
end

return spamwatch