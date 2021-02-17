local bugreport = {}
local oneteam = require('oneteam')

function bugreport:init(configuration)
    assert(configuration.bug_reports_chat, 'Please specify a chat ID to send all bug reports to!')
    bugreport.commands = oneteam.commands(self.info.username):command('bugreport'):command('bug'):command('br').table
    bugreport.help = '/bugreport <text> - Reports a bug to the configured developer. Aliases: /bug, /br.'
end

function bugreport:on_new_message(message, configuration)
    if oneteam.is_global_admin(message.from.id) and message.chat.id == configuration.bug_reports_chat and message.reply and message.reply.forward_from and not message.text:match('^[/!#]') and message.reply.from.id == self.info.id then
        oneteam.send_message(
            message.reply.forward_from.id,
            string.format(
                'Message from the developer regarding bug report #bug%s:\n<pre>%s</pre>',
                message.reply.forward_date .. message.reply.forward_from.id,
                oneteam.escape_html(message.text)
            ),
            'html'
        )
    end
end

function bugreport.on_message(_, message, configuration, language)
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, bugreport.help)
    end
    if message.reply then
        oneteam.forward_message(configuration.bug_reports_chat, message.chat.id, false, message.message_id)
    end
    local success = oneteam.forward_message(configuration.bug_reports_chat, message.chat.id, false, message.message_id)
    if success and message.chat.id ~= configuration.bug_reports_chat then
        return oneteam.send_reply(message, string.format(language['bugreport']['1'], 'bug' .. message.date .. message.from.id))
    end
    return oneteam.send_reply(message, language['bugreport']['2'])
end

return bugreport