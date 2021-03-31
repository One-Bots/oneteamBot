local allowlist = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function allowlist:init()
    allowlist.commands = oneteam.commands(self.info.username):command('allowlist').table
    allowlist.help = '/allowlist [user] - Blocklists a user from using the bot in the current chat. This command can only be used by moderators and administrators of a supergroup.'
end

function allowlist:on_message(message, _, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(message, language.errors.supergroup)
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    end
    local reason = false
    local input = message.reply and message.reply.from.id or oneteam.input(message.text)
    if not input then
        local success = oneteam.send_force_reply(message, language['allowlist']['1'])
        if success then
            oneteam.set_command_action(message.chat.id, success.result.message_id, '/allowlist')
        end
        return
    elseif not message.reply then
        if input:match('^.- .-$') then
            input, reason = input:match('^(.-) (.-)$')
        end
    elseif oneteam.input(message.text) then
        reason = oneteam.input(message.text)
    end
    if tonumber(input) == nil and not input:match('^%@') then
        input = '@' .. input
    end
    local user = oneteam.get_user(input) -- Resolve the username/ID to a user object.
    if not user then
        return oneteam.send_reply(message, language.errors.unknown)
    elseif user.result.id == self.info.id then
        return
    end
    user = user.result
    local status = oneteam.get_chat_member(message.chat.id, user.id)
    if not status then
        return oneteam.send_reply(message, language.errors.generic)
    elseif oneteam.is_group_admin(message.chat.id, user.id) then -- We won't try and allowlist moderators and administrators.
        return oneteam.send_reply(message, language['allowlist']['2'])
    elseif status.result.status == 'left' or status.result.status == 'kicked' then -- Check if the user is in the group or not.
        local output = status.result.status == 'left' and language['allowlist']['3'] or language['allowlist']['4']
        return oneteam.send_reply(message, output)
    end
    redis:set('group_allowlist:' .. message.chat.id .. ':' .. user.id, true)
    oneteam.increase_administrative_action(message.chat.id, user.id, 'allowlists')
    reason = reason and ', for ' .. reason or ''
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local allowlisted_username = oneteam.get_formatted_user(user.id, user.first_name, 'html')
    local bot_username = oneteam.get_formatted_user(self.info.id, self.info.first_name, 'html')
    local output
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        output = string.format(language['allowlist']['5'], admin_username, message.from.id, allowlisted_username, user.id, bot_username, self.info.id, oneteam.escape_html(message.chat.title), message.chat.id, reason, '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. user.id)
        oneteam.send_message(log_chat, output, 'html')
    else
        output = string.format(language['allowlist']['6'], admin_username, allowlisted_username, bot_username, reason)
        oneteam.send_message(message.chat.id, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
        oneteam.delete_message(message.chat.id, message.message_id)
    end
    return
end

return allowlist