local setgrouplang = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')
local json = require('dkjson')

function setgrouplang:init()
    setgrouplang.commands = oneteam.commands(self.info.username):command('setgrouplang').table
    setgrouplang.help = '/setgrouplang - Allows you to force oneteam to respond to all members of the current chat in the selected language.'
end

setgrouplang.languages = {
    ['en_us'] = 'English 🇺🇸',
    ['es_es'] = 'Spanish 🇪🇸'
}

setgrouplang.languages_short = {
    ['en_gb'] = '🇬🇧',
    ['es_es'] = '🇪🇸'
}

function setgrouplang.get_keyboard(chat_id, language)
    local keyboard = {
        ['inline_keyboard'] = {
            {}
        }
    }
    local total = 0
    for _, v in pairs(setgrouplang.languages_short)
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
    for k, v in pairs(setgrouplang.languages_short)
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
                ['callback_data'] = 'setgrouplang:' .. chat_id .. ':' .. k
            }
        )
    end
    table.insert(
        keyboard.inline_keyboard,
        {
            {
                ['text'] = language['setgrouplang']['5'],
                ['callback_data'] = 'administration:' .. chat_id .. ':force_group_language'
            }
        }
    )
    return keyboard
end

function setgrouplang.set_lang(chat_id, locale, lang, language)
    redis:hset(
        'chat:' .. chat_id .. ':info',
        'group language',
        locale
    )
    return string.format(
        language['setgrouplang']['1'],
        lang
    )
end

function setgrouplang.get_lang(chat_id, language)
    local lang = oneteam.get_value(
        chat_id,
        'group language'
    )
    or 'en_gb'
    for k, v in pairs(setgrouplang.languages)
    do
        if k == lang
        then
            lang = v
            break
        end
    end
    return string.format(
        language['setgrouplang']['2'],
        lang
    )
end

function setgrouplang:on_callback_query(callback_query, message, configuration, language)
    if not message
    or (
        message
        and message.date <= 1493668000
    )
    then
        return -- We don't want to process requests from messages before the language
        -- functionality was re-implemented, it could cause issues!
    elseif not oneteam.is_group_admin(
        message.chat.id,
        callback_query.from.id
    )
    then
        return oneteam.answer_callback_query(
            callback_query.id,
            language['errors']['admin']
        )
    end
    local chat_id, new_language = callback_query.data:match('^(.-)%:(.-)$')
    if not chat_id
    or not new_language
    or tostring(message.chat.id) ~= chat_id
    then
        return
    elseif not oneteam.get_setting(
        message.chat.id,
        'force group language'
    )
    then
        redis:hset(
            'chat:' .. message.chat.id .. ':settings',
            'force group language',
            true
        )
    end
    return oneteam.edit_message_text(
        message.chat.id,
        message.message_id,
        setgrouplang.set_lang(
            chat_id,
            new_language,
            setgrouplang.languages[new_language],
            language
        ),
        nil,
        true,
        setgrouplang.get_keyboard(
            chat_id,
            language
        )
    )
end

function setgrouplang:on_message(message, configuration, language)
    if not oneteam.is_group_admin(
        message.chat.id,
        message.from.id
    )
    then
        return oneteam.send_reply(
            message,
            language['errors']['admin']
        )
    elseif message.chat.type ~= 'supergroup'
    then
        return oneteam.send_reply(
            message,
            language['errors']['supergroup']
        )
    end
    if not oneteam.get_setting(
        message.chat.id,
        'force group language'
    )
    then
        return oneteam.send_message(
            message.chat.id,
            language['setgrouplang']['3'],
            nil,
            true,
            false,
            nil,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    language['setgrouplang']['4'],
                    'administration:' .. message.chat.id .. ':force_group_language'
                )
            )
        )
    end
    return oneteam.send_message(
        message.chat.id,
        setgrouplang.get_lang(
            message.chat.id,
            language
        ),
        nil,
        true,
        false,
        nil,
        setgrouplang.get_keyboard(
            message.chat.id,
            language
        )
    )
end

return setgrouplang