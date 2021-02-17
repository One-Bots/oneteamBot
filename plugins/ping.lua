local ping = {}
local oneteam = require('oneteam')

function ping:init()
    ping.commands = oneteam.commands(self.info.username):command('ping'):command('pong').table
    ping.help = '/ping - PONG!'
end

function ping.on_message(_, message)
    if message.text:match('^[/!#]pong') then
        return oneteam.send_reply(message, 'You really have to go the extra mile, don\'t you?')
    end
    return oneteam.send_sticker(message.chat.id, 'CAADBAAD1QIAAlAYNw2Pr-ymr7r8TgI')
end

return ping
