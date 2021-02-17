local jsondump = {}
local oneteam = require('oneteam')
local json = require('serpent')

function jsondump:init()
    jsondump.commands = oneteam.commands(self.info.username)
    :command('jsondump')
    :command('json').table
    jsondump.help = '/jsondump - Returns the raw JSON of your message. Alias: /json.'
    json = require('dkjson')
    jsondump.serialise = function(input)
        return json.encode(
            input,
            {
                indent = true
            }
        )
    end
end

function jsondump:on_message(message)
    local output = jsondump.serialise(message)
    if output:len() > 4096
    then
        return
    end
    return oneteam.send_message(
        message.chat.id,
        '<pre>' .. oneteam.escape_html(
            tostring(output)
        ) .. '</pre>',
        'html'
    )
end

return jsondump