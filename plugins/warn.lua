local warn = {}
local oneteam = require('oneteam')
local redis = dofile('libs/redis.lua')

function warn:init()
    warn.commands = oneteam.commands(self.info.username):command('warn'):command('w').table
    warn.help = '/warn [user] - Warns a user in the current chat. This command can only be used by moderators and administrators of a supergroup. Once a user has reached the maximum allowed number of warnings allowed in the chat, the configured action for the chat is performed on them. Alias: /w'
end

function warn:on_callback_query(callback_query, message, configuration)
    if not callback_query
    or not callback_query.data
    or not callback_query.data:match('^%a+%:%-%d+%:%d+$')
    then
        return
    elseif not oneteam.is_group_admin(
        callback_query.data:match('^%a+%:(%-%d+)%:%d+$'),
        callback_query.from.id
    )
    then
        return oneteam.answer_callback_query(
            callback_query.id,
            configuration.errors.admin
        )
    elseif callback_query.data:match('^reset%:%-%d+%:%d+$')
    then
        local chat_id, user_id = callback_query.data:match('^reset%:(%-%d+)%:(%d+)$')
        redis:hdel(
            string.format(
                'chat:%s:%s',
                chat_id,
                user_id
            ),
            'warnings'
        )
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            string.format(
                '<pre>Warnings reset by %s%s!</pre>',
                callback_query.from.username
                and '@'
                or '',
                callback_query.from.username
                or oneteam.escape_html(callback_query.from.first_name)
            ),
            'html'
        )
    elseif callback_query.data:match('^remove%:%-%d+%:%d+$')
    then
        local chat_id, user_id = callback_query.data:match('^remove%:(%-%d+)%:(%d+)$')
        local amount = redis:hincrby(
            string.format(
                'chat:%s:%s',
                chat_id,
                user_id
            ),
            'warnings',
            -1
        )
        if tonumber(amount) < 0
        then
            redis:hincrby(
                string.format(
                    'chat:%s:%s',
                    chat_id,
                    user_id
                ),
                'warnings',
                1
            )
            return oneteam.answer_callback_query(
                callback_query.id,
                'This user hasn\'t got any warnings to be removed!'
            )
        end
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            string.format(
                '<pre>Warning removed by %s%s! [%s/%s]</pre>',
                callback_query.from.username
                and '@'
                or '',
                callback_query.from.username
                or oneteam.escape_html(callback_query.from.first_name),
                redis:hget(
                    string.format(
                        'chat:%s:%s',
                        chat_id,
                        user_id
                    ),
                    'warnings'
                ),
                redis:hget(
                    string.format(
                        'chat:%s:settings',
                        chat_id
                    ),
                    'max warnings'
                )
                or 3
            ),
            'html'
        )
    end
end

function warn:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup'
    then
        return oneteam.send_reply(
            message,
            language['errors']['supergroup']
        )
    elseif not oneteam.is_group_admin(
        message.chat.id,
        message.from.id
    )
    then
        return oneteam.send_reply(
            message,
            language['errors']['admin']
        )
    end
    local reason = false
    local input = message.reply
    and tostring(message.reply.from.id)
    or oneteam.input(message)
    if not input
    then
        return oneteam.send_reply(
            message,
            warn.help
        )
    elseif not message.reply
    and input:match('^%@?%w+ ')
    then
        input, reason = input:match('^(%@?%w+) (.-)$')
    elseif oneteam.input(message.text)
    then
        reason = oneteam.input(message.text)
    end
    if tonumber(input) == nil
    and not input:match('^%@')
    then
        input = '@' .. input
    end
    local success = oneteam.get_user(input)
    if not success then
        user = oneteam.get_chat(input)
    else
        user = oneteam.get_chat(success.result.id)
    end
    if not user
    then
        return oneteam.send_reply(
            message,
            language['errors']['unknown']
        )
    elseif user.result.id == self.info.id
    then
        return
    end
    user = user.result
    local status = oneteam.get_chat_member(
        message.chat.id,
        user.id
    )
    if not status
    then
        return oneteam.send_reply(
            message,
            language['errors']['generic']
        )
    elseif oneteam.is_group_admin(
        message.chat.id,
        user.id
    ) or status.result.status == 'creator'
    or status.result.status == 'administrator'
    then -- We won't try and warn moderators and administrators.
        return oneteam.send_reply(
            message,
            'I cannot warn this user because they are a moderator or an administrator in this chat.'
        )
    elseif oneteam.get_setting(message.chat.id, 'trusted permissions warnings') and oneteam.is_trusted_user(message.chat.id, user.id)
    then
        return oneteam.send_reply(
            message,
            'I cannot warn this user because he is a trusted user and trusted users are immune to warns in this chat.'
        )
    elseif status.result.status == 'left'
    or status.result.status == 'kicked'
    then -- Check if the user is in the group or not.
        return oneteam.send_reply(
            message,
            string.format(
                'I cannot warn this user because they have already %s this chat.',
                (
                    status.result.status == 'left'
                    and 'left'
                )
                or 'been kicked from'
            )
        )
    end
    local amount = redis:hincrby(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'warnings',
        1
    )
    local maximum = redis:hget(
        string.format(
            'chat:%s:settings',
            message.chat.id
        ),
        'max warnings'
    )
    or 3
    if tonumber(amount) >= tonumber(maximum)
    then
        local success = oneteam.ban_chat_member(
            message.chat.id,
            user.id
        )
        if not success
        then -- Since we've ruled everything else out, it's safe to say if it wasn't a
        -- success then the bot isn't an administrator in the group.
            return oneteam.send_reply(
                message,
                'I need to have administrative permissions in order to ban this user. Please amend this issue, and try again.'
            )
        end
    end
    redis:hincrby(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'bans',
        1
    )
    if redis:hget(
        string.format(
            'chat:%s:settings',
            message.chat.id
        ),
        'log administrative actions'
    ) and oneteam.get_setting(message.chat.id, 'log warn') then
        oneteam.send_message(
            oneteam.get_log_chat(message.chat.id),
            string.format(
                '#action #warn #admin_'..tostring(message.from.id)..' #user_'..tostring(user.id)..' #group_'..tostring(message.chat.id):gsub("%-", "")..'\n\n<pre>%s%s [%s] has warned %s%s [%s] in %s%s [%s]%s.</pre>',
                message.from.username and '@' or '',
                message.from.username or oneteam.escape_html(message.from.first_name),
                message.from.id,
                user.username and '@' or '',
                user.username or oneteam.escape_html(user.first_name),
                user.id,
                message.chat.username and '@' or '',
                message.chat.username or oneteam.escape_html(message.chat.title),
                message.chat.id,
                reason and ', for ' .. reason or ''
            ),
            'html'
        )
    end
    if message.reply
    and oneteam.get_setting(
        message.chat.id,
        'delete reply on action'
    )
    then
        oneteam.delete_message(
            message.chat.id,
            message.reply.message_id
        )
    end
    return oneteam.send_message(
        message.chat.id,
        string.format(
            '<pre>%s%s has warned %s%s%s. [%s/%s]</pre>',
            message.from.username and '@' or '',
            message.from.username or oneteam.escape_html(message.from.first_name),
            user.username and '@' or '',
            user.username or oneteam.escape_html(user.first_name),
            reason and ', for ' .. reason or '',
            amount,
            maximum
        ),
        'html',
        true,
        false,
        nil,
        oneteam.inline_keyboard():row(
            oneteam.row()
            :callback_data_button(
                'Reset Warnings',
                string.format(
                    'warn:reset:%s:%s',
                    message.chat.id,
                    user.id
                )
            )
            :callback_data_button(
                'Remove 1 Warning',
                string.format(
                    'warn:remove:%s:%s',
                    message.chat.id,
                    user.id
                )
            )
        )
    )
end

return warn
