local channel = {}
local oneteam = require('oneteam')
local socket = require('socket')
local json = require('dkjson')
local redis = require('libs.redis')

function channel:init()
    channel.commands = oneteam.commands(self.info.username):command('channel'):command('ch'):command('msg').table
    channel.help = '/channel <channel> <message> - Sends a message to a Telegram channel/group. The channel/group can be specified via ID or username. Messages can be formatted with Markdown. Users can only send messages to channels/groups they own/administrate. Aliases: /ch, /msg.'
end

function channel:on_callback_query(callback_query, message, configuration, language)
    local request = redis:hget('temp:channel', callback_query.data)
    if not request then
        return false
    end
    request = json.decode(request)
    if request.from ~= callback_query.from.id then
        return oneteam.answer_callback_query(callback_query.id, language['channel']['1'])
    elseif not oneteam.is_group_admin(request.target, request.from) then
        return oneteam.answer_callback_query(callback_query.id, language['channel']['2'])
    end
    local success = oneteam.send_message(request.target, request.text, 'markdown')
    if not success then
        return oneteam.edit_message_text(message.chat.id, message.message_id, language['channel']['3'])
    end
    redis:hdel('temp:channel', callback_query.data)
    return oneteam.edit_message_text(message.chat.id, message.message_id, language['channel']['4'])
end

function channel:on_message(message, configuration, language)
    if message.chat.type == 'channel' then
        return false
    end
    local input = oneteam.input(message)
    if not input then
        return oneteam.send_reply(message, channel.help)
    end
    local target = oneteam.get_word(input)
    if tonumber(target) == nil and not target:match('^@') then
        target = '@' .. target
    end
    target = oneteam.get_chat_id(target) or target
    local admin_list = oneteam.get_chat_administrators(target)
    if not admin_list and not oneteam.is_global_admin(message.from.id) then
        return oneteam.send_reply(message, language['channel']['5'])
    elseif not oneteam.is_global_admin(message.from.id) then -- Make configured owners an exception.
        local is_admin = false
        for _, admin in ipairs(admin_list.result) do
            if admin.user.id == message.from.id then
                is_admin = true
            end
        end
        if not is_admin then
            return oneteam.send_reply(message, language['channel']['6'])
        end
    end
    local text = input:match(' (.-)$')
    if not text then
        return oneteam.send_reply(message, language['channel']['7'])
    end
    local request_id = tostring(socket.gettime()):gsub('%D', '')
    local keyboard = json.encode({
        ['inline_keyboard'] = {
            {
                {
                    ['text'] = language['channel']['9'],
                    ['callback_data'] = 'channel:' .. request_id
                }
            }
        }
    })
    local temp_text = '*' .. language['channel']['8'] .. '*\n\n' .. text
    local success = oneteam.send_message(message.chat.id, temp_text, 'markdown', true, false, nil, keyboard)
    if not success then
        return oneteam.send_reply(message, language['channel']['10'])
    end
    local payload = json.encode({
        ['target'] = target,
        ['text'] = text,
        ['from'] = message.from.id
    })
    redis:hset('temp:channel', request_id, payload)
    return success
end

return channel