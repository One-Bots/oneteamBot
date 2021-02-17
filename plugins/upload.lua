local upload = {}
local oneteam = require('oneteam')

function upload:init()
    upload.commands = oneteam.commands(self.info.username):command('upload').table
end

function upload:on_message(message, configuration, language)
    if not oneteam.is_global_admin(message.from.id)
    then
        return
    elseif not message.reply
    or not message.reply.document
    then
        return oneteam.send_reply(
            message,
            language['upload']['1']
        )
    elseif tonumber(message.reply.document.file_size) > 20971520
    then
        return oneteam.send_reply(
            message,
            language['upload']['2']
        )
    end
    local file = oneteam.get_file(message.reply.document.file_id)
    if not file
    or not file.result
    or not file.result.file_path
    then
        return oneteam.send_reply(
            message,
            language['upload']['3']
        )
    end
    local success = oneteam.download_file(
        'https://api.telegram.org/file/bot' .. configuration.bot_token .. '/' .. file.result.file_path,
        message.reply.document.file_name,
        configuration['download_location']
    )
    if not success
    then
        return oneteam.send_reply(
            message,
            language['upload']['4']
        )
    end
    return oneteam.send_reply(
        message,
        string.format(
            language['upload']['5'],
            oneteam.escape_html(configuration['download_location'] .. message.reply.document.file_name)
        ),
        'html'
    )
end

return upload