local join_captcha = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')
local captcha_lib = require('captcha')

function join_captcha.cron(_, configuration)
    local keys = redis:keys('chat:*:captcha:*')
    for _, key in pairs(keys) do
        local chat_id, user_id = key:match('^chat:(%-?%d+):captcha:(%d+)$')
        if not redis:get('captcha:' .. chat_id .. ':' .. user_id) then
            local message_id = redis:hget(key, 'id')
            oneteam.delete_message(chat_id, message_id)
            local user = oneteam.get_user(user_id, nil, nil, true)
            local kicked_user = oneteam.get_formatted_user(user_id, user.result.first_name, 'html')
            local action = oneteam.get_setting(chat_id, 'ban not kick')
            local punishment = action and 'Banned' or 'Kicked'
            local timeout = oneteam.get_setting(chat_id, 'captcha timeout') or configuration.administration.captcha.timeout.default
            timeout = math.floor(timeout)
            if punishment == 'Banned' then
                action = oneteam.ban_chat_member
            else action = oneteam.kick_chat_member end
            local success = action(chat_id, user_id)
            if not success then
                oneteam.wipe_redis_captcha(chat_id, user_id)
            else
                local output = punishment .. ' ' .. kicked_user .. ' <code>[' .. user_id .. ']</code> %sbecause they didn\'t complete the CAPTCHA within %s minutes!'
                if oneteam.get_setting(chat_id, 'log administrative actions') then
                    local chat = oneteam.get_chat(chat_id)
                    local log_output = output
                    if chat then
                        local title = oneteam.escape_html(chat.result.title)
                        title = 'from ' .. title .. ' <code>[' .. chat.result.id .. ']</code> '
                        log_output = string.format(log_output, title, timeout)
                        log_output = log_output .. '\n#chat' .. tostring(chat.result.id):gsub('^%-100', '') .. ' #user' .. user_id
                    else
                        log_output = string.format(log_output, '')
                    end
                    oneteam.send_message(oneteam.get_log_chat(chat_id), log_output, 'html')
                else
                    output = string.format(output, '', timeout)
                    oneteam.send_message(chat_id, output, 'html')
                end
                oneteam.wipe_redis_captcha(chat_id, user_id)
            end
        end
    end
end

function join_captcha.on_callback_query(_, callback_query, message)
    if not callback_query.data:match('^.-:.-:.-$') then
        return false
    end
    local chat_id, user_id, guess = callback_query.data:match('^(.-):(.-):(.-)$')
    if callback_query.from.id ~= tonumber(user_id) then
        return oneteam.answer_callback_query(callback_query.id, 'This isn\'t your CAPTCHA!')
    end
    local correct = oneteam.get_captcha_text(chat_id, callback_query.from.id)
    if not correct then
        return oneteam.answer_callback_query(callback_query.id, 'An error occurred. Please contact an admin if this keeps happening!', true)
    end
    local message_id = oneteam.get_captcha_id(chat_id, callback_query.from.id)
    local default_permissions = oneteam.get_chat(message.chat.id, true)
    if guess:lower() == correct:lower() then
        local success
        if not default_permissions then
            success = oneteam.restrict_chat_member(chat_id, callback_query.from.id, 'forever', true, true, true, true, true, false, false, false)
        else
            success = oneteam.restrict_chat_member(chat_id, callback_query.from.id, 'forever', default_permissions.result.permissions)
        end
        if not success then
            return oneteam.send_message(message.chat.id, 'I could not give a user their permissions. You may have to do this manually!')
        end
        oneteam.wipe_redis_captcha(chat_id, callback_query.from.id)
        oneteam.answer_callback_query(callback_query.id, 'Success! You may now speak!')
        return oneteam.delete_message(chat_id, message_id)
    else
        if oneteam.get_setting(chat_id, 'log administrative actions') then
            local failed_username = oneteam.get_formatted_user(callback_query.from.id, callback_query.from.first_name, 'html')
            local chat_title = oneteam.escape_html(message.chat.title)
            local output = '%s <code>[%s]</code> failed the CAPTCHA in %s <code>[%s]</code>. They guessed <code>%s</code> but the correct answer was <code>%s</code>.\n#chat%s #user%s'
            output = string.format(output, failed_username, user_id, chat_title, chat_id, guess, correct, tostring(chat_id):gsub('^%-100', ''), user_id)
            local log_chat = oneteam.get_log_chat(chat_id)
            oneteam.send_message(log_chat, output, 'html')
        end
        oneteam.wipe_redis_captcha(chat_id, callback_query.from.id)
        oneteam.answer_callback_query(callback_query.id, 'You got it wrong! Re-join the group and try again, or consult an admin if you wish to be unmuted!')
        return oneteam.delete_message(chat_id, message_id)
    end
end

function join_captcha.on_member_join(_, message, configuration)
    if not oneteam.get_setting(message.chat.id, 'require captcha') or message.new_chat_participant.is_bot then
        return false
    elseif oneteam.get_captcha_id(message.chat.id, message.new_chat_participant.id) then
        return oneteam.send_reply(message, 'You still need to complete your CAPTCHA in order to speak!')
    end
    local chat_member = oneteam.get_chat_member(message.chat.id, message.new_chat_participant.id)
    if not chat_member then -- we can't even get info about the user? abort! abort!
        return false
    end
    local download_location = configuration.download_location
    if download_location:match('/$') then
        download_location = download_location:match('^(.-)/$')
    end
    local new_captcha = captcha_lib.new()
    local size = oneteam.get_setting(message.chat.id, 'captcha size') or configuration.administration.captcha.size.default
    size = math.floor(size)
    local length = oneteam.get_setting(message.chat.id, 'captcha length') or configuration.administration.captcha.length.default
    length = math.floor(length)
    local captchas = configuration.administration.captcha.files
    local current = oneteam.get_setting(message.chat.id, 'captcha font') or 1
    current = math.floor(current)
    local font = captchas[current] or captchas[1]
    local timeout = oneteam.get_setting(message.chat.id, 'captcha timeout') or configuration.administration.captcha.timeout.default
    new_captcha:setlength(length)
    new_captcha:setfontsize(size)
    new_captcha:setpath(download_location)
    new_captcha:setformat('jpg')
    new_captcha:setfontsfolder(configuration.fonts_directory .. '/' .. font)
    local generated_captcha, correct = new_captcha:generate()
    local username = oneteam.get_formatted_user(message.new_chat_participant.id, message.new_chat_participant.first_name)
    local msg = string.format('Hey, %s! Please enter the above CAPTCHA using the buttons below before you can speak! You will be removed in 5 minutes if you don\'t do this.\n_Click to expand the image on Android devices!_', username)
    captchas = oneteam.random_string(length, 5)
    table.insert(captchas, correct)
    table.sort(captchas)
    local callback_data = string.format('join_captcha:%s:%s', message.chat.id, message.new_chat_participant.id)
    local keyboard = oneteam.inline_keyboard():row(
        oneteam.row()
        :callback_data_button(captchas[1], callback_data .. ':' .. captchas[1])
        :callback_data_button(captchas[2], callback_data .. ':' .. captchas[2])
        :callback_data_button(captchas[3], callback_data .. ':' .. captchas[3])
    ):row(
        oneteam.row()
        :callback_data_button(captchas[4], callback_data .. ':' .. captchas[4])
        :callback_data_button(captchas[5], callback_data .. ':' .. captchas[5])
        :callback_data_button(captchas[6], callback_data .. ':' .. captchas[6])
    )
    local success = oneteam.send_photo(message.chat.id, generated_captcha, msg, 'markdown', false, nil, keyboard)
    if not success then
        error('No success!')
        os.execute('rm ' .. generated_captcha)
        return false
    end
    os.execute('rm ' .. generated_captcha)
    local restrict = oneteam.restrict_chat_member(message.chat.id, message.new_chat_participant.id, 'forever', false, false, false, false, false, false, false, false)
    if restrict then
        oneteam.set_captcha(message.chat.id, message.new_chat_participant.id, correct, success.result.message_id, math.floor(timeout * 60))
        oneteam.delete_message(message.chat.id, message.message_id)
    else
        error('Could not restrict ChatMember!')
    end
    return
end

return join_captcha