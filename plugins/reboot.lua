local reboot = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function reboot:init()
    reboot.commands = oneteam.commands(self.info.username):command('reboot'):command('shutdown'):command('reload').table
end

function reboot:on_new_message(message)
    if not oneteam.is_global_admin(message.from.id) then
        return false
    elseif not message.text then
        return false
    elseif message.text:match('^.- && .-$') then
        local first, second = message.text:match('^(.-) && (.-)$')
        if not first:match('^[/!#]') then
            message.text = first
            oneteam.on_message(self, message)
        end
        message.text = second
        return oneteam.on_message(self, message)
    end
    return
end

function reboot:on_message(message)
    if not oneteam.is_global_admin(message.from.id) or message.date < (os.time() - 2) then
        return false
    end
    if message.text:match('^[/!#]reload') then
        local success = oneteam.send_message(message.chat.id, 'Reloading...')
        for pkg, _ in pairs(package.loaded) do -- Disable all of oneteam's plugins and languages.
            if pkg:match('^plugins%.') or pkg:match('^languages%.') then
                package.loaded[pkg] = nil
            end
        end
        package.loaded['libs.utils'] = nil
        package.loaded['configuration'] = nil
        oneteam.is_reloading = true
        oneteam.init(self)
        return oneteam.edit_message_text(message.chat.id, success.result.message_id, 'Successfully reloaded')
    end
    package.loaded['oneteam'] = require('oneteam')
    oneteam.is_running = false
    local success = oneteam.send_message(message.chat.id, 'Shutting down...')
    redis:set('oneteam:shutdown', tostring(message.chat.id) .. ':' .. tostring(success.result.message_id))
    return success
end

return reboot