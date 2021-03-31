local kick = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function kick:init()
    kick.commands = oneteam.commands(self.info.username):command('kick').table
    kick.help = '/kick [user] - Kicks a user from the current chat. This command can only be used by moderators and administrators of a supergroup.'
end

function kick:on_message(message, _, language)
    if message.chat.type ~= 'supergroup' then
        oneteam.send_reply(message, language['errors']['supergroup'])
        return false, 'The chat is not a supergroup!'
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        oneteam.send_reply(message, language['errors']['admin'])
        return false, 'That user is not an admin/mod in this chat!'
    end
    local reason = false
    local user = false
    local input = oneteam.input(message)
    -- Check the message object for any users this command
    -- is intended to be executed on.
    if message.reply then
        user = message.reply.from.id
        reason = input
    elseif input and input:match(' ') then
        user, reason = input:match('^(.-) (.-)$')
    elseif input then
        user = input
    end
    if not user then
        local success = oneteam.send_force_reply(message, language['kick']['1'])
        if success then
            redis:set('action:' .. message.chat.id .. ':' .. success.result.message_id, '/kick')
        end
        return
    end
    if reason and type(reason) == 'string' and reason:match('^[Ff][Oo][Rr] ') then
        reason = reason:match('^[Ff][Oo][Rr] (.-)$')
    end
    if tonumber(user) == nil and not user:match('^%@') then
        user = '@' .. user
    end
    local user_object = oneteam.get_user(user) -- Resolve the username/ID to a user object.
    if not user_object then
        oneteam.send_reply(message, language['errors']['unknown'])
        return false, 'No user object was found!'
    elseif user_object.result.id == self.info.id then
        return false, 'The user given was the bot!'
    end
    user_object = user_object.result
    local status, error_message = oneteam.get_chat_member(message.chat.id, user_object.id)
    if not status then
        oneteam.send_reply(message, language['errors']['generic'])
        return false, error_message
    elseif oneteam.is_group_admin(message.chat.id, user_object.id) then
    -- We won't try and kick moderators and administrators.
        oneteam.send_reply(message, language['kick']['2'])
        return false, 'That user is an admin/mod in this chat!'
    elseif status.result.status == 'left' or status.result.status == 'kicked' then -- Check if the user is in the group or not.
        local output = status.result.status == 'left' and language['kick']['3'] or language['kick']['4']
        oneteam.send_reply(message, output)
        return false, output
    end
    local success = oneteam.kick_chat_member(message.chat.id, user_object.id) -- Attempt to kick the user from the group.
    if not success then -- Since we've ruled everything else out, it's safe to say if it wasn't a success
    -- then the bot isn't an administrator in the group.
        return oneteam.send_reply(message, language['kick']['5'])
    end
    oneteam.increase_administrative_action(message.chat.id, user_object.id, 'kicks')
    reason = reason and '\nReason: ' .. reason or ''
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local kicked_username = oneteam.get_formatted_user(user_object.id, user_object.first_name, 'html')
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has kicked %s <code>[%s]</code> from %s <code>[%s]</code>%s.\n%s %s'
        output = string.format(output, admin_username, message.from.id, kicked_username, user_object.id, oneteam.escape_html(message.chat.title), message.chat.id, reason, '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. user_object.id)
        oneteam.send_message(log_chat, output, 'html')
    else
        local output = '%s has kicked %s%s.'
        output = string.format(output, admin_username, kicked_username, reason)
        oneteam.send_message(message.chat.id, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
    end
    return oneteam.delete_message(message.chat.id, message.message_id)
end

return kick