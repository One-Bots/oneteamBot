local save = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function save:init()
    save.commands = oneteam.commands(self.info.username):command('save'):command('s').table
    save.help = '/save - Stores the replied-to message in ' .. self.info.first_name .. '\'s database - of which a randomly-selected, saved message from the said user can be retrieved using /quote. Alias: /s.'
end

function save.on_message(_, message, _, language)
    if not message.reply or (not message.reply.text and not message.reply.voice) then
        return oneteam.send_reply(message, save.help)
    elseif message.reply.forward_from then
        message.reply.from = message.reply.forward_from
    end
    if redis:get('user:' .. message.reply.from.id .. ':opt_out') then
        redis:del('user:' .. message.reply.from.id .. ':quotes')
        return oneteam.send_reply(message, language['save']['1'])
    end
    if message.reply.voice then
        message.reply.text = '$voice:' .. message.reply.voice.file_id
    end
    redis:sadd('user:' .. message.reply.from.id .. ':quotes', message.reply.text)
    local user = oneteam.get_formatted_user(message.reply.from.id, message.reply.from.name, 'html')
    local output = string.format(language['save']['2'], user)
    return oneteam.send_reply(message, output, 'html')
end

return save