local translate = {}
local oneteam = require('oneteam')
local https = require('ssl.https')
local url = require('socket.url')
local json = require('dkjson')

function translate:init()
    translate.commands = oneteam.commands(self.info.username):command('translate'):command('tl').table
    translate.help = [[/translate [locale] <text> - If a locale is given, the given text is translated into the said locale's language. If no locale is given then the given text is translated into the bot's configured language. If the command is used in reply to a message containing text, then the replied-to text is translated and the translation is returned. Alias: /tl.]]
end

function translate:on_inline_query(inline_query, configuration)
    local input = oneteam.input(inline_query.query)
    if not input then
        return
    end
    local lang
    if not oneteam.get_word(input) or oneteam.get_word(input):len() > 2 then
        lang = configuration.language
    else
        lang = oneteam.get_word(input)
    end
    local jstr, res = https.request('https://translate.yandex.net/api/v1.5/tr.json/translate?key=' .. configuration.keys.translate .. '&lang=' .. lang .. '&text=' .. url.escape(input:gsub(lang .. ' ', '')))
    if res ~= 200 then
        return
    end
    local jdat = json.decode(jstr)
    return oneteam.answer_inline_query(
        inline_query.id,
        json.encode(
            {
                {
                    ['type'] = 'article',
                    ['id'] = '1',
                    ['title'] = jdat.text[1],
                    ['description'] = 'Click to send your translation.',
                    ['input_message_content'] = {
                        ['message_text'] = jdat.text[1]
                    }
                }
            }
        )
    )
end

function translate:on_message(message, configuration, language)
    local input = oneteam.input(message.text)
    local lang = oneteam.get_user_language(message.from.id):match('^(..)')
    if message.reply then
        if input and input:match('^%a%a$') then
            lang = input
        end
        input = message.reply.text
    elseif not input then
        return oneteam.send_reply(message, translate.help)
    elseif input:match('^%a%a .-$') then
        lang, input = input:match('^(%a%a) (.-)$')
    end
    local jstr, res = https.request('https://translate.yandex.net/api/v1.5/tr.json/translate?key=' .. configuration.keys.translate .. '&lang=' .. lang .. '&text=' .. url.escape(input))
    if res ~= 200 then
        return oneteam.send_reply(message, language.errors.connection)
    elseif message.reply then
        oneteam.delete_message(message.chat.id, message.message_id)
        message.message_id = message.reply.message_id
    end
    local jdat = json.decode(jstr)
    return oneteam.send_reply(
        message,
        '<b>Translation (from ' .. jdat.lang:gsub('%-', ' to ') .. '):</b>\n' .. oneteam.escape_html(jdat.text[1]),
        'html'
    )
end

return translate