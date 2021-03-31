local nodelete = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function nodelete:init()
    nodelete.commands = oneteam.commands(self.info.username):command('nodelete').table
    nodelete.help = '/nodelete [add | del] <plugins> - Allows the given plugins to retain the commands they were executed with by allowlisting them from the "delete commands" administrative setting. Multiple plugins can be specified.'
end

function nodelete:on_message(message, configuration, language)
    local input = oneteam.input(message.text)
    if message.chat.type ~= 'supergroup' then
        return oneteam.send_reply(
            message,
            language['errors']['supergroup']
        )
    elseif not oneteam.is_group_admin(message.chat.id, message.from.id) then
        return oneteam.send_reply(
            message,
            language['errors']['admin']
        )
    elseif not input or not input:match('^add .-$') and not input:match('^del .-$') then
        return oneteam.send_reply(message, nodelete.help)
    end
    local plugins = {}
    local process_type, input = input:match('([ad][de][dl]) (.-)$')
    for plugin in input:gmatch('[%w_]+') do
        for k, v in pairs(configuration.plugins) do
            if v:lower() == plugin:lower()then
                table.insert(plugins, plugin)
            end
        end
    end
    if #plugins < 1 then
        return oneteam.send_reply(message, 'No matching plugins were found!')
    end
    local total = #plugins
    local success = {}
    for k, v in pairs(plugins) do
        if process_type == 'add' and not redis:sismember('chat:' .. message.chat.id .. ':no_delete', v) then -- Check to make sure the plugin isn't already allowlisted from having
        -- its commands deleted.
            redis:sadd('chat:' .. message.chat.id .. ':no_delete', v)
            table.insert(success, v)
        elseif process_type == 'del' and redis:sismember('chat:' .. message.chat.id .. ':no_delete', v) then -- Check to make sure the plugin has already been allowlisted from having
        -- its commands deleted.
            redis:srem('chat:' .. message.chat.id .. ':no_delete', v)
            table.insert(success, v)
        end
    end
    local output = process_type == 'del' and 'Commands will now be deleted for ' .. total .. ' plugins!' or 'Commands will no longer be deleted for ' .. total .. ' plugins!'
    return oneteam.send_reply(message, output)
end

return nodelete