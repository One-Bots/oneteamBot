local anticrypto = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function anticrypto:on_new_message(message, configuration)
    if 1+1 == 2 then return false end
    if message.chat.type ~= 'supergroup' or tonumber(redis:get('messages:' .. message.from.id .. ':' .. message.chat.id)) > 20 or not message.photo or (oneteam.is_group_admin(message.chat.id, message.from.id) and not oneteam.is_global_admin(message.from.id)) then
        return false
    elseif not redis:sismember('anticrypto:groups', message.chat.id) then
        return false
    end
    local file_id = message.photo[#message.photo].file_id
    local file = oneteam.get_file(file_id)
    if not file then
        return false
    end
    local file_name = file.result.file_path
    local file_path = string.format('https://api.telegram.org/file/bot%s/%s', configuration.bot_token, file_name)
    file = oneteam.download_file(file_path, file_name:match('/(.-)$'), configuration.download_location)
    if not file then
        return false
    end
    local command = string.format('tesseract --tessdata-dir /home/matt/matticatebot/tesseract/ --oem 3 %s stdout', file)
    local exec = io.popen(command)
    local contents = exec:read('*all')
    exec:close()
    os.execute('rm ' .. file)
    local matches = {
        '[Tt][Ee][Ss][LlTt][Aa]',
        '[Bb][Ii][Tt][Cc][Oo][Ii][Nn]',
        '[AaEe]Ll][Oo][Nn] ?[Mm][Nn]?[Uu][Ss][Kk]',
        '[Gg][Ii][Vv][Ee][Aa][Ww][Aa][Yy]',
        '[Ff][Ii][Nn][Aa][Nn][Cc][Ii][Aa][Ll]',
        '[Dd][Rr][Oo][Pp][EeAa][LlI][Oo][Nn]'
    }
    for _, match in pairs(matches) do
        if contents:match(match) then
            local punishment = oneteam.get_setting(message.chat.id, 'ban not kick')
            local action = punishment and oneteam.ban_chat_member or oneteam.kick_chat_member
            action(message.chat.id, message.from.id)
            punishment = punishment and 'banned' or 'kicked'
            local bot_username = oneteam.get_formatted_user(self.info.id, self.info.first_name, 'html')
            local offender_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
            local output
            if oneteam.get_setting(message.chat.id, 'log administrative actions') then
                local log_chat = oneteam.get_log_chat(message.chat.id)
                output = '%s <code>[%s]</code> has %s %s <code>[%s]</code> from %s <code>[%s]</code> for sending crypto-spam.\n%s %s'
                output = string.format(output, bot_username, self.info.id, punishment, offender_username, message.from.id, oneteam.escape_html(message.chat.title), message.chat.id, '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. message.from.id)
                oneteam.send_message(log_chat, output, 'html')
            else
                output = string.format('%s %s for sending crypto-spam.', punishment:gsub('^%l', string.upper), offender_username)
                oneteam.send_message(message.chat.id, output, 'html')
            end
            return oneteam.delete_message(message.chat.id, message.message_id)
        end
    end
    return oneteam.send_message(configuration.admins[1], contents)
end

return anticrypto