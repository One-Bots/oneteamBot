local help = {}
local oneteam = require('oneteam')

function help:init(configuration)
    help.commands = oneteam.commands(self.info.username):command('help'):command('start').table
    help.help = '/help [plugin] - A help-orientated menu is sent if no arguments are given. If arguments are given, usage information for the given plugin is sent instead. Alias: /start.'
    help.per_page = configuration.limits.help.per_page
end

function help.get_initial_keyboard()
    return oneteam.inline_keyboard():row(
        oneteam.row():callback_data_button(
            'Admin Help',
            'help:acmds'
        ):callback_data_button(
            'Commands',
            'help:cmds'
        )
    ):row(
        oneteam.row():switch_inline_query_button(
            'Inline Mode',
            '/'
        ):callback_data_button(
            'Settings',
            'help:settings'
        )
    )
end

function help.get_plugin_page(arguments_list, page)
    local plugin_count = #arguments_list
    local page_begins_at = tonumber(page) * help.per_page - (help.per_page - 1)
    local page_ends_at = tonumber(page_begins_at) + (help.per_page - 1)
    if tonumber(page_ends_at) > tonumber(plugin_count) then
        page_ends_at = tonumber(plugin_count)
    end
    local page_plugins = {}
    for i = tonumber(page_begins_at), tonumber(page_ends_at) do
        local plugin = arguments_list[i]
        if i < tonumber(page_ends_at) then
            plugin = plugin .. '\n'
        end
        table.insert(page_plugins, plugin)
    end
    return table.concat(page_plugins, '\n')
end

function help.get_back_keyboard()
    return oneteam.inline_keyboard():row(
        oneteam.row():callback_data_button(
            oneteam.symbols.back .. ' Back',
            'help:back'
        )
    )
end

function help.on_inline_query(_, inline_query, _, language)
    local offset = inline_query.offset and tonumber(inline_query.offset) or 0
    local output = oneteam.get_inline_help(inline_query.query, offset)
    if not next(output) and offset == 0 then
        output = string.format(language['help']['2'], inline_query.query)
        return oneteam.send_inline_article(inline_query.id, language['help']['1'], output)
    end
    offset = tostring(offset + 50)
    return oneteam.answer_inline_query(inline_query.id, output, 0, false, offset)
end

function help:on_callback_query(callback_query, message, _, language)
    if callback_query.data == 'cmds' then
        local arguments_list = oneteam.get_help(self, false, message.chat.id)
        local plugin_count = #arguments_list
        local page_count = math.floor(tonumber(plugin_count) / help.per_page)
        if math.floor(tonumber(plugin_count) / help.per_page) ~= tonumber(plugin_count) / help.per_page then
            page_count = page_count + 1
        end
        local output = help.get_plugin_page(arguments_list, 1)
        output = output .. oneteam.escape_html(string.format(language['help']['3'], self.info.username))
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            'html',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['4'],
                    'help:results:0'
                ):callback_data_button(
                    '1/' .. page_count,
                    'help:pages:1:' .. page_count
                ):callback_data_button(
                    language['help']['5'] .. ' ' .. oneteam.symbols.next,
                    'help:results:2'
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                ):switch_inline_query_current_chat_button(
                    '🔎 ' .. language['help']['7'],
                    '/'
                )
            )
        )
    elseif callback_query.data:match('^results:%d*$') then
        local new_page = callback_query.data:match('^results:(%d*)$')
        local arguments_list = oneteam.get_help(self, false, message.chat.id)
        local plugin_count = #arguments_list
        local page_count = math.floor(tonumber(plugin_count) / help.per_page)
        if math.floor(tonumber(plugin_count) / help.per_page) ~= tonumber(plugin_count) / help.per_page then
            page_count = page_count + 1
        end
        if tonumber(new_page) > tonumber(page_count) then
            new_page = 1
        elseif tonumber(new_page) < 1 then
            new_page = tonumber(page_count)
        end
        local output = help.get_plugin_page(arguments_list, new_page)
        output = output .. oneteam.escape_html(string.format(language['help']['3'], self.info.username))
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            'html',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['4'],
                    'help:results:' .. math.floor(tonumber(new_page) - 1)
                ):callback_data_button(
                    new_page .. '/' .. page_count,
                    'help:pages:' .. new_page .. ':' .. page_count
                ):callback_data_button(
                    language['help']['5'] .. ' ' .. oneteam.symbols.next,
                    'help:results:' .. math.floor(tonumber(new_page) + 1)
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                ):switch_inline_query_current_chat_button(
                    '🔎 ' .. language['help']['7'],
                    '/'
                )
            )
        )
    elseif callback_query.data == 'acmds' then
        local arguments_list = oneteam.get_help(self, true, message.chat.id)
        local plugin_count = #arguments_list
        local page_count = math.floor(tonumber(plugin_count) / help.per_page)
        if math.floor(tonumber(plugin_count) / help.per_page) ~= tonumber(plugin_count) / help.per_page then
            page_count = page_count + 1
        end
        local output = help.get_plugin_page(arguments_list, 1)
        output = output .. oneteam.escape_html(string.format(language['help']['3'], self.info.username))
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            'html',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['4'],
                    'help:aresults:0'
                ):callback_data_button(
                    '1/' .. page_count,
                    'help:pages:1:' .. page_count
                ):callback_data_button(
                    language['help']['5'] .. ' ' .. oneteam.symbols.next,
                    'help:aresults:2'
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                )
            )
        )
    elseif callback_query.data:match('^aresults:%d*$') then
        local new_page = callback_query.data:match('^aresults:(%d*)$')
        local arguments_list = oneteam.get_help(self, true, message.chat.id)
        local plugin_count = #arguments_list
        local page_count = math.floor(tonumber(plugin_count) / help.per_page)
        if math.floor(tonumber(plugin_count) / help.per_page) ~= tonumber(plugin_count) / help.per_page then
            page_count = page_count + 1
        end
        if tonumber(new_page) > tonumber(page_count) then
            new_page = 1
        elseif tonumber(new_page) < 1 then
            new_page = tonumber(page_count)
        end
        local output = help.get_plugin_page(arguments_list, new_page)
        output = output .. oneteam.escape_html(string.format(language['help']['3'], self.info.username))
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            'html',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['4'],
                    'help:aresults:' .. math.floor(tonumber(new_page) - 1)
                ):callback_data_button(
                    new_page .. '/' .. page_count,
                    'help:pages:' .. new_page .. ':' .. page_count
                ):callback_data_button(
                    language['help']['5'] .. ' ' .. oneteam.symbols.next,
                    'help:aresults:' .. math.floor(tonumber(new_page) + 1)
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                )
            )
        )
    elseif callback_query.data:match('^pages:%d*:%d*$') then
        local current_page, total_pages = callback_query.data:match('^pages:(%d*):(%d*)$')
        return oneteam.answer_callback_query(
            callback_query.id,
            string.format(language['help']['8'], current_page, total_pages)
        )
    elseif callback_query.data:match('^ahelp:') then
        return oneteam.answer_callback_query(callback_query.id, 'This is an old keyboard, please request a new one using /help!')
    elseif callback_query.data == 'links' then
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            language['help']['12'],
            nil,
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():url_button(
                    language['help']['18'],
                    'https://paypal.me/badwolfalfa'
            ):row(
                ):url_button(
                    'Twitter',
                    'https://twitter.com/intent/user?screen_name=revostechs'
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                )
            )
        )
    elseif callback_query.data == 'channels' then
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            language['help']['12'],
            nil,
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():url_button(
                    'no context',
                    'https://t.me/no_context'
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                )
            )
        )
    elseif callback_query.data == 'settings' then
        if message.chat.type == 'supergroup' and not oneteam.is_group_admin(message.chat.id, callback_query.from.id) then
            return oneteam.answer_callback_query(callback_query.id, language['errors']['admin'])
        end
        return oneteam.edit_message_reply_markup(
            message.chat.id,
            message.message_id,
            nil,
            (
                message.chat.type == 'supergroup'
                and oneteam.is_group_admin(
                    message.chat.id,
                    callback_query.from.id
                )
            )
            and oneteam.inline_keyboard()
            :row(
                oneteam.row():callback_data_button(
                    language['help']['21'], 'administration:' .. message.chat.id .. ':page:1'
                ):callback_data_button(
                    language['help']['22'], 'plugins:' .. message.chat.id .. ':page:1'
                )
            )
            :row(
                oneteam.row():callback_data_button(
                    language['help']['6'],
                    'help:back'
                )
            ) or oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    language['help']['22'], 'plugins:' .. message.chat.id .. ':page:1'
                )
            ):row(
                oneteam.row():callback_data_button(
                    language['help']['6'], 'help:back'
                )
            )
        )
    elseif callback_query.data == 'back' then
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            string.format(
                language['help']['23'],
                oneteam.escape_html(callback_query.from.first_name),
                oneteam.escape_html(self.info.first_name),
                utf8.char(128513),
                utf8.char(128161),
                message.chat.type ~= 'private' and ' ' .. language['help']['24'] .. ' ' .. oneteam.escape_html(message.chat.title) or '',
                utf8.char(128176)
            ),
            'html',
            true,
            help.get_initial_keyboard(message.chat.type == 'supergroup' and message.chat.id or false)
        )
    end
end

function help:on_message(message, _, language)
    local input = oneteam.input(message.text)
    if input and input:match('^[/!]?%w+$') then
        local plugin_documentation = false
        input = input:match('^/') and input or '/' .. input
        for _, v in pairs(self.plugin_list) do
            if v:match(input) then
                plugin_documentation = v
            end
        end
        if not plugin_documentation then -- if it wasn't a normal plugin, it might be an administrative one
            for _, v in pairs(self.administrative_plugin_list) do
                if v:match(input) then
                    plugin_documentation = v
                end
            end
        end
        plugin_documentation = plugin_documentation or 'I couldn\'t find a plugin matching that command!'
        plugin_documentation = plugin_documentation .. '\n\nTo see all commands, just send /help.'
        return oneteam.send_reply(message, plugin_documentation)
    end
    return oneteam.send_message(
        message.chat.id,
        string.format(
            language['help']['23'],
            oneteam.escape_html(message.from.first_name),
            oneteam.escape_html(self.info.first_name),
            utf8.char(128513),
            utf8.char(128161),
            message.chat.type ~= 'private' and ' ' .. language['help']['24'] .. ' ' .. oneteam.escape_html(message.chat.title) or '',
            utf8.char(128176)
        ),
        'html',
        false,
        true,
        nil,
        help.get_initial_keyboard(message.chat.type == 'supergroup' and message.chat.id or false)
    )
end

return help
