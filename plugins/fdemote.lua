local fdemote = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function fdemote:init()
    fdemote.commands = oneteam.commands(self.info.username):command('fdemote'):command('feddemote'):command('fd').table
    fdemote.help = '/fdemote [user] - Allows the Fed creator to demote a user (by reply or mention), removing their access to Fed admin commands. If you have multiple feds, please specify the Fed as a second parameter, if not it will pick your first one. Aliases: /feddemote, /fd.'
end

function fdemote:on_message(message, configuration, language)
    local fed, id = oneteam.has_fed(message.from.id)
    local input = oneteam.input(message.text)
    if message.reply and input then
        input = message.reply.from.id .. ' ' .. input
    end
    local input, selected = (message.reply and not input) and tostring(message.reply.from.id) or input, nil
    if input:match('^[@%w_]+ ([%w%-]+)$') then
        input, selected = input:match('^([@%w_]+) ([%w%-]+)$')
    end
    fed, id = oneteam.has_fed(message.from.id, selected)
    if not fed then
        local output = 'You need to have your own Fed in order to use this command!'
        if selected then
            output = 'That\'s not one of your Feds!'
        end
        return oneteam.send_reply(message, output)
    elseif not input then
        return oneteam.send_reply(message, fdemote.help)
    end
    local user = oneteam.get_user(input)
    if not user then
        return oneteam.send_reply(message, 'I couldn\'t find any information about that user! Try sending this in reply to one of their messages.')
    elseif user.result.id == message.from.id then
        return oneteam.send_reply(message, 'You can\'t demote yourself you donut!')
    elseif user.result.id == self.info.id then
        return oneteam.send_reply(message, 'Why do you need to demote me? I control all of the Feds!')
    elseif not oneteam.is_fed_admin(id, user.result.id) then
        return oneteam.send_reply(message, 'That user isn\'t an admin in your Fed anyway!')
    end
    local title = redis:hget('fed:' .. id, 'title')
    redis:srem('fedadmins:' .. id, user.result.id)
    local output = 'Successfully demoted <b>%s</b> from Fed admin in <b>%s</b> <code>[%s]</code>!'
    output = string.format(output, oneteam.escape_html(user.result.first_name), oneteam.escape_html(title), id)
    return oneteam.send_reply(message, output, 'html')
end

return fdemote