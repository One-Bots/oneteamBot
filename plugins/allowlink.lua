local allowlink = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function allowlink:init()
    allowlink.commands = oneteam.commands(self.info.username):command('allowlink'):command('wl').table
    allowlink.help = '/allowlink <links> - Allowlists the given links in the current chat. Requires administrative privileges. Use /allowlink -del <links> to Alias: /wl.'
end

function allowlink:on_callback_query(callback_query, message, _, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.answer_callback_query(callback_query.id, language.errors.supergroup)
    elseif not oneteam.is_group_admin(message.chat.id, callback_query.from.id) then
        return oneteam.answer_callback_query(callback_query.id, language.errors.admin)
    end
    redis:set('allowlisted_links:' .. message.chat.id .. ':' .. callback_query.data, true)
    oneteam.answer_callback_query(callback_query.id, 'Successfully allowlisted that link!', true)
    return oneteam.delete_message(message.chat.id, message.message_id)
end

function allowlink:on_message(message)
    if not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return false
    end
    local input = oneteam.input(message.text)
    local delete = false
    if not input then
        return oneteam.send_reply(message, 'Please specify the URLs or @usernames you\'d like to allowlist.')
    elseif input:match('^%-del .-$') then
        input = input:match('^%-del (.-)$')
        delete = true
    end
    message.text = input
    local output = oneteam.check_links(message, false, false, true, false, delete)
    return oneteam.send_reply(message, output)
end

return allowlink