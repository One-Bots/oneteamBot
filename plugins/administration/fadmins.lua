local fadmins = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function fadmins:init()
    fadmins.commands = oneteam.commands(self.info.username):command('fadmins'):command('fa').table
    fadmins.help = '/fadmins [Fed UUID] - View a list of users who are admins in your Fed. If you have multiple Feds, you will need to specify the Fed by its UUID. Alias: /fa.'
end

function fadmins.on_message(_, message)
    local input = oneteam.input(message.text)
    input = (input and input:match('^%w+%-%w+%-%w+%-%w+%-%w+$')) and input or false
    local feds = redis:keys('fed:*')
    local owned = {}
    for _, fed in pairs(feds) do
        if oneteam.is_fed_creator(fed:match('^fed:(.-)$'), message.from.id) then
            table.insert(owned, fed:match('^fed:(.-)$'))
        end
    end
    if input and oneteam.table_contains(owned, input) then
        feds = redis:smembers('fedadmins:' .. input)
    elseif #owned == 0 then
        return oneteam.send_reply(message, 'You don\'t own any Feds! To create your own, use /newfed <Fed name>.')
    elseif input then
        return oneteam.send_reply(message, 'I\'m afraid it looks like you don\'t own that Fed, therefore you can\'t view the list of admins for it!')
    else
        if #owned > 1 then
            return oneteam.send_reply(message, 'You own multiple Feds! You need to specify which Fed you want to view the admins for by using /fadmins <Fed UUID>. To view a list of Feds you own, use /myfeds.')
        end
        feds = redis:smembers('fedadmins:' .. owned[1])
        input = owned[1]
    end
    local title = redis:hget('fed:' .. input, 'title')
    local output = { 'The following users are admin in <b>' .. oneteam.escape_html(title) .. '</b>:\n' }
    for _, admin in pairs(feds) do
        local user = oneteam.get_user(admin).result
        local name = oneteam.get_formatted_user(user.id, user.first_name, 'html')
        table.insert(output, oneteam.symbols.bullet .. ' ' .. name .. ' <code>[' .. user.id .. ']</code>' )
    end
    table.insert(output, '\nTo promote more users, use <code>/fpromote [user] ' .. input .. '</code>')
    output = table.concat(output, '\n')
    return oneteam.send_reply(message, output, 'html')
end

return fadmins