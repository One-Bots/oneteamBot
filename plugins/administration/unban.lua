local unban = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function unban:init()
    unban.commands = oneteam.commands(self.info.username):command('unban').table
    unban.help = '/unban [user] - Unbans a user from the current chat. This command can only be used by moderators and administrators of a supergroup.'
end

function unban:on_message(message, _, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(message, language['errors']['supergroup'])
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language['errors']['admin'])
    end
    local reason = false
    local user = false
    local input = oneteam.input(message)
    -- Check the message object for any users this command
    -- is intended to be executed on.
    if message.reply then
        user = message.reply.from.id
        if input then
            reason = input
        end
    elseif input and input:match(' ') then
        user, reason = input:match('^(.-) (.-)$')
    elseif input then
        user = input
    end
    if not user then
        local output = 'Which user would you like me to unban? You can specify this user by their @username or numerical ID.'
        local success = oneteam.send_force_reply(message, output)
        if success then
            redis:set('action:' .. message.chat.id .. ':' .. success.result.message_id, '/unban')
        end
        return
    end
    if tonumber(user) == nil and not user:match('^%@') then
        user = '@' .. user
    end
    user = oneteam.get_user(user) -- Resolve the username/ID to a user object.
    if not user then
        return oneteam.send_reply(message, language['errors']['unknown'])
    elseif user.result.id == self.info.id then
        return
    end
    user = user.result
    local status = oneteam.get_chat_member(message.chat.id, user.id)
    if not status then
        return oneteam.send_reply(message, language['errors']['generic'])
    elseif status.result.status == 'creator' or status.result.status == 'administrator' then -- We won't try and unban administrators.
        return oneteam.send_reply(message, 'I cannot unban this user because they are a moderator or an administrator in this chat.')
    elseif status.result.status == 'member' then -- Check if the user is in the group or not.
        return oneteam.send_reply(message, 'I cannot unban this user because they are still in this chat.')
    end
    local success = oneteam.unban_chat_member(message.chat.id, user.id) -- Attempt to unban the user from the group.
    if not success then -- Since we've ruled everything else out, it's safe to say if it wasn't a success then the bot isn't
    -- an administrator in the group.
        local output = 'I need to have administrative permissions in order to unban this user. Please amend this issue, and try again.'
        return oneteam.send_reply(message, output)
    end
    oneteam.increase_administrative_action(message.chat.id, user.id, 'unbans')
    reason = reason and ', for ' .. reason or ''
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local unbanned_username = oneteam.get_formatted_user(user.id, user.first_name, 'html')
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has unbanned %s <code>[%s]</code> from %s <code>[%s]</code>%s.\n%s %s'
        output = string.format(output, admin_username, message.from.id, unbanned_username, user.id, oneteam.escape_html(message.chat.title), message.chat.id, reason, '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. user.id)
        oneteam.send_message(log_chat, output, 'html')
    else
        local output = '%s has unbanned %s%s.'
        output = string.format(output, admin_username, unbanned_username, reason)
        oneteam.send_message(message.chat.id, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
    end
    return oneteam.delete_message(message.chat.id, message.message_id)
end

return unban