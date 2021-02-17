local allowlist = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function allowlist:init()
    allowlist.commands = oneteam.commands(self.info.username):command('allowlist').table
    allowlist.help = '/allowlist [user] - Allowlists a user to use the bot in the current chat. This command can only be used by moderators and administrators of a supergroup.'
end

function allowlist:on_message(message, configuration, language)
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
    and (
        message.reply.from.username
        or tostring(message.reply.from.id)
    )
    or oneteam.input(message.text)
    if not input
    then
        local success = oneteam.send_force_reply(
            message,
            language['allowlist']['1']
        )
        if success
        then
            redis:set(
                string.format(
                    'action:%s:%s',
                    message.chat.id,
                    success.result.message_id
                ),
                '/allowlist'
            )
        end
        return
    elseif not message.reply
    then
        if input:match('^.- .-$')
        then
            reason = input:match(' (.-)$')
            input = input:match('^(.-) ')
        end
    elseif oneteam.input(message.text)
    then
        reason = oneteam.input(message.text)
    end
    if tonumber(input) == nil
    and not input:match('^%@')
    then
        input = '@' .. input
    end
    local user = oneteam.get_user(input)
    or oneteam.get_chat(input) -- Resolve the username/ID to a user object.
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
    )
    or status.result.status == 'creator'
    or status.result.status == 'administrator'
    then -- We won't try and allowlist moderators and administrators.
        return oneteam.send_reply(
            message,
            language['allowlist']['2']
        )
    elseif status.result.status == 'left'
    or status.result.status == 'kicked'
    then -- Check if the user is in the group or not.
        return oneteam.send_reply(
            message,
            status.result.status == 'left'
            and language['allowlist']['3']
            or language['allowlist']['4']
        )
    end
    redis:del('group_allowlist:' .. message.chat.id .. ':' .. user.id)
    redis:hincrby(
        string.format(
            'chat:%s:%s',
            message.chat.id,
            user.id
        ),
        'allowlists',
        1
    )
    if redis:hget(
        string.format(
            'chat:%s:settings',
            message.chat.id
        ),
        'log administrative actions'
    ) then
        oneteam.send_message(
            oneteam.get_log_chat(message.chat.id),
            string.format(
                '<pre>%s%s [%s] has allowlisted %s%s [%s] in %s%s [%s]%s.</pre>',
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
    oneteam.unban_chat_member(message.chat.id, user.id) -- attempt to unban the user too
    return oneteam.send_message(
        message.chat.id,
        string.format(
            '<pre>%s%s has allowlisted %s%s%s.</pre>',
            message.from.username and '@' or '',
            message.from.username or oneteam.escape_html(message.from.first_name),
            user.username and '@' or '',
            user.username or oneteam.escape_html(user.first_name),
            reason and ', for ' .. reason or ''
        ),
        'html'
    )
end

return allowlist