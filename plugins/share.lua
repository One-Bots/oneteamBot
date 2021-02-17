local share = {}
local oneteam = require('oneteam')
local url = require('socket.url')

function share:init()
    share.commands = oneteam.commands(self.info.username):command('share').table
    share.help = '/share <url> <text> - Share the given URL through an inline button, with the specified text as the caption.'
end

function share:on_message(message, configuration, language)
    local input = oneteam.input(message.text)
    if not input
    or not input:match('^.- .-$')
    then
        return oneteam.send_reply(
            message,
            share.help
        )
    end
    return oneteam.send_message(
        message.chat.id,
        input:match('^.- (.-)$'),
        nil,
        true,
        false,
        nil,
        oneteam.inline_keyboard():row(
            oneteam.row():url_button(
                language['share']['1'] .. ' ' .. utf8.char(8618),
                'https://t.me/share/url?url=' .. url.escape(
                    input:match('^(.-) .-$')
                ) .. '&text=' .. url.escape(
                    input:match('^.- (.-)$')
                )
            )
        )
    )
end

return share