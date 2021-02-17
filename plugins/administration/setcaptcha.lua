local setcaptcha = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function setcaptcha:init()
    setcaptcha.commands = oneteam.commands(self.info.username):command('setcaptcha').table
    setcaptcha.help = '/setcaptcha - Allows admins to configure CAPTCHA settings.'
end

function setcaptcha.on_callback_query(_, callback_query, message, configuration, language)
    local action, new, chat_id = callback_query.data:match('^(.-):(.-):(.-)$')
    if not action or not new or not chat_id then
        return oneteam.answer_callback_query(callback_query.id)
    elseif not oneteam.is_group_admin(chat_id, callback_query.from.id) then
        return oneteam.answer_callback_query(callback_query.id, language.errors.admin)
    end
    new = tonumber(new)
    local captchas = configuration.administration.captcha.files
    local length = oneteam.get_setting(chat_id, 'captcha length') or configuration.administration.captcha.length.default
    length = math.floor(length)
    local next_length = length + 1
    local prev_length = length - 1
    local size = oneteam.get_setting(chat_id, 'captcha size') or configuration.administration.captcha.size.default
    size = math.floor(size)
    local next_size = size + 1
    local prev_size = size - 1
    local current = oneteam.get_setting(chat_id, 'captcha font') or 1
    current = math.floor(current)
    local font_name = captchas[current] or captchas[1]
    local next_font_pos = current + 1
    local prev_font_pos = current - 1
    local timeout = oneteam.get_setting(chat_id, 'captcha timeout') or configuration.administration.captcha.timeout.default
    timeout = math.floor(timeout)
    local next_timeout = timeout + 1
    local prev_timeout = timeout - 1
    if action == 'font' then
        if tonumber(new) < 1 then
            new = #captchas
        elseif tonumber(new) > #captchas then
            new = 1
        end
        font_name = captchas[new]
        if not font_name then
            return oneteam.answer_callback_query(callback_query.from.id, 'This font is no longer available!')
        end
        redis:hset('chat:' .. chat_id .. ':settings', 'captcha font', new)
        if next_font_pos > #captchas then
            next_font_pos = 1
        end
        prev_font_pos = new - 1
        if prev_font_pos < 1 then
            prev_font_pos = #captchas
        end
    elseif action == 'length' then
        if tonumber(new) < configuration.administration.captcha.length.min then
            new = configuration.administration.captcha.length.max
        elseif tonumber(new) > configuration.administration.captcha.length.max then
            new = configuration.administration.captcha.length.min
        end
        redis:hset('chat:' .. chat_id .. ':settings', 'captcha length', new)
        length = new
        next_length = new + 1
        if next_length > configuration.administration.captcha.length.max then
            next_length = configuration.administration.captcha.length.min
        end
        prev_length = new - 1
        if prev_length < configuration.administration.captcha.length.min then
            prev_length = configuration.administration.captcha.length.max
        end
    elseif action == 'size' then
        if tonumber(new) < configuration.administration.captcha.size.min then
            new = configuration.administration.captcha.size.max
        elseif tonumber(new) > configuration.administration.captcha.size.max then
            new = configuration.administration.captcha.size.min
        end
        redis:hset('chat:' .. chat_id .. ':settings', 'captcha size', new)
        size = new
        next_size = new + 1
        if next_size > configuration.administration.captcha.size.max then
            next_size = configuration.administration.captcha.size.min
        end
        prev_size = new - 1
        if prev_size < configuration.administration.captcha.size.min then
            prev_size = configuration.administration.captcha.size.max
        end
    elseif action == 'timeout' then
        if tonumber(new) < configuration.administration.captcha.timeout.min then
            new = configuration.administration.captcha.timeout.max
        elseif tonumber(new) > configuration.administration.captcha.timeout.max then
            new = configuration.administration.captcha.timeout.min
        end
        redis:hset('chat:' .. chat_id .. ':settings', 'captcha timeout', new)
        timeout = new
        next_timeout = new + 1
        if next_timeout > configuration.administration.captcha.timeout.max then
            next_timeout = configuration.administration.captcha.timeout.min
        end
        prev_timeout = new - 1
        if prev_timeout < configuration.administration.captcha.timeout.min then
            prev_timeout = configuration.administration.captcha.timeout.max
        end
    end
    font_name = font_name:gsub('^%l', string.upper):gsub('%.[to]tf$', '')
    local keyboard = oneteam.inline_keyboard():row(
        oneteam.row():callback_data_button('CAPTCHA Length', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:length:' .. prev_length .. ':' .. chat_id)
        :callback_data_button(length, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:length:' .. next_length .. ':' .. chat_id)
    ):row(
        oneteam.row():callback_data_button('Font Size', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:size:' .. prev_size .. ':' .. chat_id)
        :callback_data_button(size, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:size:' .. next_size .. ':' .. chat_id)
    ):row(
        oneteam.row():callback_data_button('Font Family', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:font:' .. prev_font_pos .. ':' .. chat_id)
        :callback_data_button(font_name, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:font:' .. next_font_pos .. ':' .. chat_id)
    ):row(
        oneteam.row():callback_data_button('CAPTCHA Timeout (Minutes)', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:timeout:' .. prev_timeout .. ':' .. chat_id)
        :callback_data_button(timeout, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:timeout:' .. next_timeout .. ':' .. chat_id)
    ):row(
        oneteam.row():callback_data_button('Done', 'dismiss')
    )
    return oneteam.edit_message_reply_markup(message.chat.id, message.message_id, nil, keyboard)
end

function setcaptcha:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(message, language.errors.supergroup)
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    end
    local captcha = configuration.administration.captcha
    local length = oneteam.get_setting(message.chat.id, 'captcha length') or configuration.administration.captcha.length.default
    length = math.floor(length)
    local next_length = length + 1
    local prev_length = length - 1
    local size = oneteam.get_setting(message.chat.id, 'captcha size') or configuration.administration.captcha.size.default
    size = math.floor(size)
    local next_size = size + 1
    local prev_size = size - 1
    local font_file = oneteam.get_setting(message.chat.id, 'captcha font') or 1
    font_file = math.floor(font_file)
    local font_name = configuration.administration.captcha.files[tonumber(font_file)]
    font_name = font_name:gsub('^%l', string.upper):gsub('%.[to]tf$', '')
    local timeout = oneteam.get_setting(message.chat.id, 'captcha timeout') or configuration.administration.captcha.timeout.default
    timeout = math.floor(timeout)
    local next_timeout = timeout + 1
    local prev_timeout = timeout - 1
    local font_pos = 1
    for pos, font in pairs(captcha.files) do
        if font == font_file then
            font_pos = pos
        end
    end
    local next_font_pos = font_pos + 1
    if next_font_pos > #captcha.files then
        next_font_pos = 1
    end
    local prev_font_pos = font_pos - 1
    if prev_font_pos < 1 then
        prev_font_pos = #captcha.files
    end
    local keyboard = oneteam.inline_keyboard():row(
        oneteam.row():callback_data_button('CAPTCHA Length', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:length:' .. prev_length .. ':' .. message.chat.id)
        :callback_data_button(length, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:length:' .. next_length .. ':' .. message.chat.id)
    ):row(
        oneteam.row():callback_data_button('Font Size', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:size:' .. prev_size .. ':' .. message.chat.id)
        :callback_data_button(size, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:size:' .. next_size .. ':' .. message.chat.id)
    ):row(
        oneteam.row():callback_data_button('Font Family', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:font:' .. prev_font_pos .. ':' .. message.chat.id)
        :callback_data_button(font_name, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:font:' .. next_font_pos .. ':' .. message.chat.id)
    ):row(
        oneteam.row():callback_data_button('CAPTCHA Timeout (Minutes)', 'setcaptcha')
    ):row(
        oneteam.row()
        :callback_data_button(oneteam.symbols.back, 'setcaptcha:timeout:' .. prev_timeout .. ':' .. message.chat.id)
        :callback_data_button(timeout, 'setcaptcha')
        :callback_data_button(oneteam.symbols.next, 'setcaptcha:timeout:' .. next_timeout .. ':' .. message.chat.id)
    ):row(
        oneteam.row():callback_data_button('Done', 'dismiss')
    )
    local output = 'Use the keyboard below to adjust the CAPTCHA settings in <b>%s</b>:'
    output = string.format(output, oneteam.escape_html(message.chat.title))
    if oneteam.get_setting(message.chat.id, 'settings in group') then
        return oneteam.send_message(message.chat.id, output, 'html', true, false, nil, keyboard)
    else
        local success = oneteam.send_message(message.from.id, output, 'html', true, false, nil, keyboard)
        if not success then
            return oneteam.send_reply(message, 'You need to [private message me](https://t.me/' .. self.info.username:lower() .. ') before I can send you this!', true, true)
        end
        return oneteam.send_reply(message, 'I\'ve sent you the CAPTCHA configuration panel [via private message](https://t.me/' .. self.info.username:lower() .. ')!', true, true)
    end
end

return setcaptcha