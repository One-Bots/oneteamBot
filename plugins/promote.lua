local promote = {}
local oneteam = require('oneteam')
local redis = require('libs.redis')

function promote:init()
    promote.commands = oneteam.commands(self.info.username)
    :command('promote')
    :command('mod').table
    promote.help = '/promote [user] - Promotes a user to a moderator of the current chat. This command can only be used by administrators of a supergroup. Alias: /mod.'
end

function promote:on_message(message, configuration, language)
    if message.chat.type ~= 'supergroup'
    then
        return oneteam.send_reply(
            message,
            language['errors']['supergroup']
        )
    elseif not oneteam.is_group_admin(
        message.chat.id,
        message.from.id,
        true
    )
    then
        return oneteam.send_reply(
            message,
            language['errors']['admin']
        )
    end
    local input = message.reply
    and tostring(message.reply.from.id)
    or oneteam.input(message.text)
    if not input
    then
        return oneteam.send_reply(
            message,
            promote.help
        )
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
    then -- We won't try and promote moderators and administrators.
        return oneteam.send_reply(
            message,
            language['promote']['1']
        )
    elseif status.result.status == 'left'
    or status.result.status == 'kicked'
    then -- Check if the user is in the group or not.
        return oneteam.send_reply(
            message,
            status.result.status == 'left'
            and language['promote']['2']
            or language['promote']['3']
        )
    end
    redis:sadd(
        'administration:' .. message.chat.id .. ':mods',
        user.id
    )
    if redis:hget(
        string.format(
            'chat:%s:settings',
            message.chat.id
        ),
        'log administrative actions'
    )
    then
        oneteam.send_message(
            oneteam.get_log_chat(message.chat.id),
            string.format(
                '<pre>%s%s [%s] has promoted %s%s [%s] in %s%s [%s].</pre>',
                message.from.username
                and '@'
                or '',
                message.from.username
                or oneteam.escape_html(message.from.first_name),
                message.from.id,
                user.username
                and '@'
                or '',
                user.username
                or oneteam.escape_html(user.first_name),
                user.id,
                message.chat.username
                and '@'
                or '',
                message.chat.username
                or oneteam.escape_html(message.chat.title),
                message.chat.id
            ),
            'html'
        )
    end
    return oneteam.send_message(
        message.chat.id,
        string.format(
            '<pre>%s%s has promoted %s%s.</pre>',
            message.from.username
            and '@'
            or '',
            message.from.username
            or oneteam.escape_html(message.from.first_name),
            user.username
            and '@'
            or '',
            user.username
            or oneteam.escape_html(user.first_name)
        ),
        'html'
    )
end

return promote