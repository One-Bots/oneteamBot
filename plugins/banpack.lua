local banpack = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function banpack:init()
    banpack.commands = oneteam.commands(self.info.username):command('banpack'):command('bp').table
    banpack.help = '/banpack - Bans, and removes when sent by normal users, any stickers from the replied-to sticker\'s pack. This command can only be used by moderators and administrators of a supergroup, who are also exempt from being disallowed to send stickers from these packs. Alias: /bp.'
end

function banpack:on_new_message(message)
    if message.chat.type ~= 'supergroup' or not message.sticker or not message.sticker.set_name then
        return false
    elseif redis:sismember('banned_sticker_packs:' .. message.chat.id, message.sticker.set_name) and not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.delete_message(message.chat.id, message.message_id)
    end
    return false
end

function banpack:on_message(message, _, language)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(message, language.errors.supergroup)
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(message, language.errors.admin)
    elseif not message.reply then
        return oneteam.send_reply(message, 'Please reply to a sticker from the sticker set you\'d like to ban.')
    elseif not message.reply.sticker then
        return oneteam.send_reply(message, 'You must use this command in reply to a sticker!')
    elseif not message.reply.sticker.set_name then
        return oneteam.send_reply(message, 'That sticker isn\'t from a set, it\'s just a file - I\'m afraid I can\'t ban that!')
    end
    local set_name = message.reply.sticker.set_name
    if redis:sismember('banned_sticker_packs:' .. message.chat.id, set_name) then
        oneteam.send_reply(message, 'That [sticker pack](https://t.me/addstickers/' .. set_name .. ') is already banned in this chat! To unban it, send /unbanpack in reply to one of the stickers from it!', true, true)
    end
    redis:sadd('banned_sticker_packs:' .. message.chat.id, set_name)
    if oneteam.get_setting(message.chat.id, 'log administrative actions') then
        local log_chat = oneteam.get_log_chat(message.chat.id)
        local output = '%s <code>[%s]</code> has banned the sticker pack <a href="https://t.me/addstickers/%s">%s</a> in %s <code>[%s]</code>.\n#chat%s #user%s'
        local admin = oneteam.get_formatted_user(message.from.id, message.from.first_name, 'html')
        output = string.format(output, admin, message.from.id, set_name, set_name, oneteam.escape_html(message.chat.title), message.chat.id, tostring(message.chat.id):gsub('^%-100', ''), message.from.id)
        oneteam.send_message(log_chat, output, 'html')
    end
    return oneteam.send_reply(message, 'I\'ve successfully banned [that sticker pack](https://t.me/addstickers/' .. set_name .. ') in this chat! To unban it, send /unbanpack in reply to a sticker from it - admins can still send these stickers!', true, true)
end

return banpack