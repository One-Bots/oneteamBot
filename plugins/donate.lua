local donate = {}
local oneteam = require('oneteam')

function donate:init()
    donate.commands = oneteam.commands(self.info.username):command('donate').table
    donate.help = '/donate - Make an optional, monetary contribution to the OneTeam project.'
end

function donate.on_message(_, message, _, language)
    local output = string.format(language['donate']['1'], oneteam.escape_html(message.from.first_name))
    return oneteam.send_message(message.chat.id, output, 'html')
end

return donate
