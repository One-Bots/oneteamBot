local echo = {}
local oneteam = require('oneteam')

function echo:init()
    echo.commands = oneteam.commands(self.info.username):command('echo'):command('say').table
    echo.help = '/echo <text> - Repeats the given string of text. Append -del to the end of your text to delete your command message. Alias: /say.'
end

function echo.on_message(_, message)
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, echo.help)
    elseif input:match(' %-d$') then
        input = input:match('^(.-) %-d$')
        oneteam.delete_message(message.chat.id, message.message_id)
    end
    return oneteam.send_message(message.chat.id, input)
end

return echo