local unfban = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function unfban:init()
    unfban.commands = oneteam.commands(self.info.username):command('unfban'):command('unfedban'):command('ufb').table
    unfban.help = '/unfban [user] - Unbans a user from the current chat and the Fed the group is part of. This command can only be used by Fed admins. Aliases: /unfedban, /ufb.'
end

function unfban:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup' then
        local output = language['errors']['supergroup']
        return oneteam.send_reply(message, output)
    end
    local fed_ids = oneteam.get_feds(message.chat.id)
    if #fed_ids == 0 then
        return oneteam.send_reply(message, 'This group isn\'t part of a fed. Ask a group admin to join one!')
    end
    local is_admin_feds = {}
    for _, fed in pairs(fed_ids) do
        if oneteam.is_fed_admin(fed, message.from.id) then
            table.insert(is_admin_feds, fed)
        end
    end
    if #is_admin_feds == 0 then
        return oneteam.send_reply(message, 'You need to be a Fed admin in at least one of this group\'s Feds in order to be able to use this command!')
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
        local output = language['fban']['1']
        local success = oneteam.send_force_reply(message, output)
        if success then
            oneteam.set_command_action(message.chat.id, success.result.message_id, '/unfban')
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
        return false -- don't let the bot Fed-ban itself
    end
    user_object = user_object.result
    local status = oneteam.get_chat_member(message.chat.id, user_object.id)
    local is_admin = oneteam.is_group_admin(message.chat.id, user_object.id)
    if not status then
        local output = language['errors']['generic']
        return oneteam.send_reply(message, output)
    elseif is_admin then -- we won't try and Fed-ban moderators and administrators.
        local output = 'I can\'t unban that user from the Fed because they\'re an admin in one of the groups!'
        return oneteam.send_reply(message, output)
    end
    local success = oneteam.fed_unban_chat_member(message.chat.id, user_object.id, is_admin_feds) -- attempt to Fed-ban the user from the group
    if not success then
        oneteam.send_reply(message, 'I couldn\'t unban that user in this group, because it appears I don\'t have permission to! I have still removed them from the Fed-ban list(s) though!')
    end
    for _, fed in pairs(is_admin_feds) do
        oneteam.increase_administrative_action(message.chat.id, user_object.id, 'unfbans')
        redis:hdel('fedban:' .. fed .. ':' .. user_object.id, 'banned_by')
        redis:hdel('fedban:' .. fed .. ':' .. user_object.id, 'time')
        redis:hdel('fedban:' .. fed .. ':' .. user_object.id, 'reason')
        redis:srem('fedbans:' ..fed, tonumber(user_object.id))
    end
    reason = reason and ', for ' .. reason or ''
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local unbanned_username = oneteam.get_formatted_user(user_object.id, user_object.first_name, 'html')
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has Fed-unbanned %s <code>[%s]</code> from %s <code>[%s]</code>%s.\n%s %s'
        if #is_admin_feds > 1 then
            output = '%s <code>[%s]</code> has Fed-unbanned %s <code>[%s]</code> from %s in the following Feds:<pre>%s</pre>\n%s %s'
            output = string.format(output, admin_username, message.from.id, unbanned_username, user_object.id, oneteam.escape_html(message.chat.title), table.concat(is_admin_feds, '\n'), '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. user_object.id)
        else
            output = string.format(output, admin_username, message.from.id, unbanned_username, user_object.id, oneteam.escape_html(message.chat.title), message.chat.id, reason, '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. user_object.id)
        end
        oneteam.send_message(log_chat, output, 'html')
    else
        local output = '%s has Fed-unbanned %s%s.'
        if #is_admin_feds > 1 then
            output = '%s has Fed-unbanned %s%s; in the following Feds:<pre>%s</pre>'
            output = string.format(output, admin_username, unbanned_username, reason, table.concat(is_admin_feds, '\n'))
        else
            output = string.format(output, admin_username, unbanned_username, reason)
        end
        oneteam.send_message(message.chat.id, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
    end
    return oneteam.delete_message(message.chat.id, message.message_id)
end

return unfban