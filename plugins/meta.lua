local meta = {}
local oneteam = require('oneteam')

function meta:init()
    meta.commands = oneteam.commands(self.info.username):command('meta').table
    meta.help = '/meta - Instructs users not to ask to ask, but just to ask.'
end

function meta.on_message(_, message)
    local send_as_reply = false
    local original_message = message.message_id
    if message.reply then
        message.message_id = message.reply.message_id
        send_as_reply = true
    end
    local method = send_as_reply == true and oneteam.send_reply or oneteam.send_message
    oneteam.delete_message(message.chat.id, original_message)
    local output = [[Please don't ask meta-questions, like:

`"Any user of $x here?"`
`"Anyone used technology $y?"`
`"Hello I need help on $z"`

Just ask a *direct question* about your problem, and the probability that someone will help is pretty high.
[Read more.](http://catb.org/~esr/faqs/smart-questions.html)]]
    return method(message, output, true)
end

return meta