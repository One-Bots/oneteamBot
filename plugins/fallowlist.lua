local fallowlist = {}
local oneteam = require('oneteam')

function fallowlist:init()
    fallowlist.commands = oneteam.commands(self.info.username):command('fallowlist'):command('fal').table
    fallowlist.help = '/fallowlist [user] - Allowlists a user from the current chat\'s Feds. Only works per chat, not per fed. This command can only be used by Fed admins. Alias: /fal.'
end

function fallowlist:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup' then
        local output = language['errors']['supergroup']
        return oneteam.send_reply(message, output)
    end
    local fed_ids = oneteam.get_feds(message.chat.id)
    if #fed_ids == 0 then
        return oneteam.send_reply(message, 'This group isn\'t part of a fed. Ask a group admin to join one!')
    end
    local user = message.reply and message.reply.from.id or oneteam.input(message.text)
    if not user then
        local output = 'You need to specify the user you\'d like to allowlist from the Fed, either by username/ID or in reply.'
        local success = oneteam.send_force_reply(message, output)
        if success then
            oneteam.set_command_action(message.chat.id, success.result.message_id, '/fallowlist')
        end
        return
    end
    if tonumber(user) == nil and not user:match('^%@') then
        user = '@' .. user
    end
    local user_object = oneteam.get_user(user) -- resolve the username/ID to a user object
    if not user_object then
        local output = language['errors']['unknown']
        return oneteam.send_reply(message, output)
    elseif user_object.result.id == self.info.id then
        return false -- don't let the bot Fed-allowlist itself
    end
    user_object = user_object.result
    local status = oneteam.get_chat_member(message.chat.id, user_object.id)
    local is_admin = oneteam.is_group_admin(message.chat.id, user_object.id)
    if not status then
        local output = language['errors']['generic']
        return oneteam.send_reply(message, output)
    elseif is_admin or status.result.status == ('creator' or 'administrator') then -- we won't try and Fed-allowlist moderators and administrators.
        local output = 'I can\'t allowlist that user from the Fed because they\'re an admin in one of the groups!'
        return oneteam.send_reply(message, output)
    end
    oneteam.fed_allowlist(message.chat.id, user_object.id)
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
        local allowlisted_username = oneteam.get_formatted_user(user_object.id, user_object.first_name, 'html')
        local output = '%s <code>[%s]</code> has Fed-allowlisted %s <code>[%s]</code> from %s <code>[%s]</code>.'
        if #fed_ids > 1 then
            output = '%s <code>[%s]</code> has Fed-allowlisted %s <code>[%s]</code> from %s in the following Feds:<pre>%s</pre>'
            output = string.format(output, admin_username, message.from.id, allowlisted_username, user_object.id, oneteam.escape_html(message.chat.title), table.concat(fed_ids, '\n'))
        else
            output = string.format(output, admin_username, message.from.id, allowlisted_username, user_object.id, oneteam.escape_html(message.chat.title), message.chat.id)
        end
        oneteam.send_message(message.chat.id, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
    end
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local allowlisted_username = oneteam.get_formatted_user(user_object.id, user_object.first_name, 'html')
    local output = '%s has Fed-allowlisted %s.'
    if #fed_ids > 1 then
        output = '%s has Fed-allowlisted %s; in the following Feds:<pre>%s</pre>'
        output = string.format(output, admin_username, allowlisted_username, table.concat(fed_ids, '\n'))
    else
        output = string.format(output, admin_username, allowlisted_username)
    end
    return oneteam.send_message(message.chat.id, output, 'html')
end

return fallowlist