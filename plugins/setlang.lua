local setlang = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')
local json = require('dkjson')

function setlang:init()
    setlang.commands = oneteam.commands(self.info.username):command('setlang').table
    setlang.help = '/setlang - Allows you to select your language.'
end

setlang.languages = {
    ['es_es'] = 'Spanish 🇪🇸',
    ['en_us'] = 'English 🇺🇸'
}

setlang.languages_short = {
    ['es_es'] = '🇪🇸',
    ['en_us'] = '🇺🇸'
}

function setlang.get_keyboard(user_id)
    local keyboard = {
        ['inline_keyboard'] = {
            {}
        }
    }
    local total = 0
    for _, v in pairs(setlang.languages_short)
    do
        total = total + 1
    end
    local count = 0
    local rows = math.floor(total / 2)
    if rows ~= total
    then
        rows = rows + 1
    end
    local row = 1
    for k, v in pairs(setlang.languages_short)
    do
        count = count + 1
        if count == rows * row
        then
            row = row + 1
            table.insert(
                keyboard.inline_keyboard,
                {}
            )
        end
        table.insert(
            keyboard.inline_keyboard[row],
            {
                ['text'] = v,
                ['callback_data'] = 'setlang:' .. user_id .. ':' .. k
            }
        )
    end
    return keyboard
end

function setlang.set_lang(user_id, locale, lang, language)
    redis:hset(
        'chat:' .. user_id .. ':settings',
        'language',
        locale
    )
    return string.format(
        language['setlang']['1'],
        lang
    )
end

function setlang.get_lang(user_id, language)
    local lang = redis:hget(
        'chat:' .. user_id .. ':settings',
        'language'
    )
    or 'en_gb'
    for k, v in pairs(setlang.languages)
    do
        if k == lang
        then
            lang = v
            break
        end
    end
    return string.format(
        language['setlang']['2'],
        lang
    )
end

function setlang:on_callback_query(callback_query, message, configuration, language)
    if not message
    or (
        message
        and message.date <= 1493668000
    )
    then
        return -- We don't want to process requests from messages before the language
        -- functionality was re-implemented, it could cause issues!
    end
    local user_id, new_language = callback_query.data:match('^(.-)%:(.-)$')
    if not user_id
    or not new_language
    or tostring(callback_query.from.id) ~= user_id
    then
        return
    end
    return oneteam.edit_message_text(
        message.chat.id,
        message.message_id,
        setlang.set_lang(
            user_id,
            new_language,
            setlang.languages[new_language],
            language
        ),
        nil,
        true,
        setlang.get_keyboard(user_id)
    )
end

function setlang:on_message(message, configuration, language)
    return oneteam.send_message(
        message.chat.id,
        setlang.get_lang(
            message.from.id,
            language
        ),
        nil,
        true,
        false,
        nil,
        setlang.get_keyboard(message.from.id)
    )
end

return setlang
