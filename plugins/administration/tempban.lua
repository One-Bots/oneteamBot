local tempban = {}
local oneteam = require('oneteam')

function tempban:init()
    tempban.commands = oneteam.commands(self.info.username):command('tempban').table
    tempban.help = '/tempban [user] <length> - Temporarily bans a user from the current chat for the given length. The length should be in the format 1y2mo3w4d5h6m7s. Some natural language is supported too. Temp-bans must be a minimum of 60 seconds in length. This command can only be used by moderators and administrators of a supergroup.'
end

function tempban:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup' then
        local output = language['errors']['supergroup']
        return oneteam.send_reply(message, output)
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        local output = language['errors']['admin']
        return oneteam.send_reply(message, output)
    end
    local user, until_date = false, false
    local input = oneteam.input(message)
    if input:match('^@?[%w_]+ .-$') then
        user, until_date = input:match('^(@?[%w_]+) (.-)$')
    elseif input then
        until_date = input
        if message.reply then
            user = message.reply.from.id
        end
    end
    until_date = oneteam.string_to_time(until_date, true)
    if until_date == false then
        return oneteam.send_reply(message, 'You must specify a length when using this command! This should be in the format 1y2mo3w4d5h6m7s. Some natural language is supported too. Temp-ban must be a minimum of 60 seconds in length.')
    elseif not user then
        return oneteam.send_reply(message, 'You must specify a user to temp-ban. This can be done by mention, reply or ID.')
    end
    until_date = os.time() + until_date
    local user_object = oneteam.get_user(user) -- resolve the username/ID to a user object
    if not user_object then
        return oneteam.send_reply(message, language.errors.unknown)
    elseif user_object.result.id == self.info.id then
        return false -- don't let the bot temp-ban itself
    end
    user_object = user_object.result
    local status = oneteam.get_chat_member(message.chat.id, user_object.id)
    local is_admin = oneteam.is_group_admin(message.chat.id, user_object.id)
    if not status then
        return oneteam.send_reply(message, language.errors.generic)
    elseif is_admin then -- we won't try and tempban moderators and administrators.
        return oneteam.send_reply(message, 'I can\'t temp-ban that user as they\'re an admin in this group!')
    elseif status.result.status == 'kicked' then -- check if the user has already been kicked
        return oneteam.send_reply(message, 'I can\'t temp-ban that user as they\'re already been banned from this chat!')
    end
    local success = oneteam.ban_chat_member(message.chat.id, user_object.id, until_date) -- attempt to temp-ban the user from the group
    if not success then
        return oneteam.send_reply(message, 'I couldn\'t temp-ban that user! Please ensure I have the required permissions and try again!')
    end
    oneteam.increase_administrative_action(message.chat.id, user_object.id, 'tempbans')
    local until_formatted = os.date('%c', until_date):gsub('  ', ' ') .. ' GMT +0'
    local admin_username = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
    local tempbanned_username = oneteam.get_formatted_user(user_object.id, user_object.first_name, 'html')
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has temp-banned %s <code>[%s]</code> from %s <code>[%s]</code> until %s.\n%s %s'
        output = string.format(output, admin_username, message.from.id, tempbanned_username, user_object.id, oneteam.escape_html(message.chat.title), message.chat.id, until_formatted, '#chat' .. tostring(message.chat.id):gsub('^-100', ''), '#user' .. user_object.id)
        oneteam.send_message(log_chat, output, 'html')
    else
        local output = '%s has temp-banned %s until %s.'
        output = string.format(output, admin_username, tempbanned_username, until_formatted)
        oneteam.send_message(message.chat.id, output, 'html')
    end
    if message.reply and oneteam.get_setting(message.chat.id, 'delete reply on action') then
        oneteam.delete_message(message.chat.id, message.reply.message_id)
    end
    return
end

return tempban