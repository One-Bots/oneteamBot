local unbanpack = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function unbanpack:init()
    unbanpack.commands = oneteam.commands(self.info.username):command('unbanpack'):command('ubp').table
    unbanpack.help = '/unbanpack - Unbans the replied-to sticker\'s pack. This command can only be used by moderators and administrators of a supergroup. Alias: /ubp.'
end


function unbanpack:on_message(message, _, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(message, language.errors.supergroup)
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    elseif not message.reply then
        return oneteam.send_reply(message, 'Please reply to a sticker from the sticker set you\'d like to unban.')
    elseif not message.reply.sticker then
        return oneteam.send_reply(message, 'You must use this command in reply to a sticker!')
    elseif not message.reply.sticker.set_name then
        return oneteam.send_reply(message, 'That sticker isn\'t from a set, it\'s just a file - I\'m afraid I can\'t unban that!')
    end
    local set_name = message.reply.sticker.set_name
    if not redis:sismember('banned_sticker_packs:' .. message.chat.id, set_name) then
        oneteam.send_reply(message, 'That [sticker pack](https://t.me/addstickers/' .. set_name .. ') isn\'t currently banned in this chat! To ban it, send /banpack in reply to one of the stickers from it!', true, true)
    end
    redis:srem('banned_sticker_packs:' .. message.chat.id, set_name)
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has unbanned the sticker pack <a href="https://t.me/addstickers/%s">%s</a> in %s <code>[%s]</code>.\n#chat%s #user%s'
        local admin = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
        output = string.format(output, admin, message.from.id, set_name, set_name, oneteam.escape_html(message.chat.title), message.chat.id, tostring(message.chat.id):gsub('^%-100', ''), message.from.id)
        oneteam.send_message(log_chat, output, 'html')
    end
    return oneteam.send_reply(message, 'I\'ve successfully unbanned [that sticker pack](https://t.me/addstickers/' .. set_name .. ') in this chat!', true, true)
end

return unbanpack