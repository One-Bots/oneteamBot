local about = {}
local oneteam = require('oneteam')

function about:init()
    about.commands = oneteam.commands(self.info.username):command('about').table
    about.help = '/about - View information about the bot.'
end

function about:on_message(message)
    local developer = oneteam.get_formatted_user(4416003, 'BadWolf', 'html')
    local output = 'Created by %s. Powered by <code>One v%s</code> and %s. Latest stable source code available <a href="https://github.com/One-Bots/oneteamBot">on GitHub</a>.'
    return oneteam.send_message(message.chat.id, string.format(output, developer, self.version, utf8.char(10084)), 'html')
end

return about
