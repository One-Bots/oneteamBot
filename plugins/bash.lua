local bash = {}
local oneteam = require('oneteam')

function bash:init()
    bash.commands = oneteam.commands(self.info.username):command('bash').table
end

function bash.on_message(_, message, _, language)
    if not oneteam.is_global_admin(message.from.id) then
        return false
    end
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, language['bash']['1'])
    end
    local res = io.popen(input)
    local output = res:read('*all')
    res:close()
    output = output:len() == 0 and language['bash']['2'] or string.format('<pre>%s</pre>', oneteam.escape_html(output))
    return oneteam.send_message(message.chat.id, output, 'html')
end

return bash