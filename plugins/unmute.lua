local unmute = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function unmute:init()
    unmute.commands = oneteam.commands(self.info.username):command('unmute').table
    unmute.help = '/unmute [user] - Unmutes a user in the current chat. This command can only be used by group admins.'
end

function unmute:on_message(message, _, language)
    if message.chat.type ~= 'supergroup' then
        local output = language['errors']['supergroup']
        return oneteam.send_reply(message, output)
    end
    local reason = false
    local user = false
    local input = oneteam.input(message)
    -- check the message object for any users this command
    -- is intended to be executed on
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
        local output = 'You need to specify the user you\'d like to unmute, either by username/ID or in reply.'
        local success = oneteam.send_force_reply(message, output)
        if success then
            oneteam.set_command_action(message.chat.id, success.result.message_id, '/unmute')
        end
        return
    end
    if reason and type(reason) == 'string' and reason:match('^[Ff][Oo][Rr] ') then
        reason = reason:match('^[Ff][Oo][Rr] (.-)$')
    end
    if tonumber(user) == nil and not user:match('^%@') then
        user = '@' .. user
    end
    local user_object = oneteam.get_user(user) or oneteam.get_chat(user) -- resolve the username/ID to a user object
    if not user_object then
        local output = language['errors']['unknown']
        return oneteam.send_reply(message, output)
    elseif user_object.result.id == self.info.id then
        return false -- we don't want to use this on ourselves
    end
    local bot_status = oneteam.get_chat_member(message.chat.id, self.info.id)
    if not bot_status then
        return false
    elseif not bot_status.result.can_restrict_members then
        return oneteam.send_reply(message, 'It appears I don\'t have the required permissions required in order to unmute that user. Please amend this and try again!')
    end
    user_object = user_object.result
    local status = oneteam.get_chat_member(message.chat.id, user_object.id)
    local is_admin = oneteam.is_group_admin(message.chat.id, user_object.id)
    if not status then
        return oneteam.send_reply(message, 'I couldn\'t retrieve any information about that user!')
    elseif is_admin then -- we won't try and unmute moderators and administrators.
        return oneteam.send_reply(message, 'I can\'t unmute that user because they\'re an admin in this chat!')
    end
    local default_permissions = oneteam.get_chat(message.chat.id)
    if not default_permissions then
        return oneteam.send_reply(message, 'I couldn\'t get the default permissions for this group!')
    end
    default_permissions = default_permissions.result.permissions or {
        ['can_send_messages'] = true,
        ['can_send_media_messages'] = true,
        ['can_send_other_messages'] = true,
        ['can_send_web_page_previews'] = true
    }
    local success = oneteam.restrict_chat_member(message.chat.id, user_object.id, os.time(), default_permissions) -- attempt to unmute the user in the group, restoring the user to the original group permissions
    if not success then
        return oneteam.send_reply(message, 'I couldn\'t unmute that user in this group, because it appears I don\'t have permission to!')
    end
    reason = reason and ', for ' .. reason or ''
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local unmuted_username = oneteam.get_formatted_user(user_object.id, user_object.first_name, 'html')
    redis:hincrby('chat:' .. message.chat.id .. ':' .. user_object.id, 'unmutes', 1)
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has unmuted %s <code>[%s]</code> in %s <code>[%s]</code>%s.'
        output = string.format(output, admin_username, message.from.id, unmuted_username, user_object.id, oneteam.escape_html(message.chat.title), message.chat.id, reason)
        oneteam.send_message(log_chat, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
    end
    local output = '%s has unmuted %s%s.'
    output = string.format(output, admin_username, unmuted_username, reason)
    return oneteam.send_message(message.chat.id, output, 'html')
end

return unmute