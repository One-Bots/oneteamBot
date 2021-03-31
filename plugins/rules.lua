local rules = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function rules:init()
    rules.commands = oneteam.commands(self.info.username):command('rules').table
    rules.help = '/rules - View the group\'s rules.'
end

function rules:on_message(message, configuration, language)
    local input = oneteam.input(message.text)
    local chat_id = message.chat.id
    if not input and message.chat.type ~= 'supergroup' then
        return false
    elseif input and input:match('^%-?%d+$') then
        chat_id = input
    end
    local output = oneteam.get_value(chat_id, 'rules') or 'There are no rules set for this chat!'
    if oneteam.get_setting(message.chat.id, 'send rules in group') or (input and message.chat.type == 'private') then
        return oneteam.send_message(message.chat.id, output, 'markdown', true, false)
    end
    local success = oneteam.send_message(message.from.id, output, 'markdown', true, false)
    output = success and 'I have sent you the rules via private chat!' or string.format('You need to speak to me in private chat before I can send you the rules! Just click [here](https://t.me/%s?start=rules_%s), press the "START" button, and try again!', self.info.username, message.chat.id)
    return oneteam.send_reply(message, output, 'markdown', true)
end

return rules