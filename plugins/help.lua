--[[
    Copyright 2017 Diego Barreiro <diego@makeroid.io>
    This code is licensed under the MIT. See LICENSE for details.
]]

local help = {}
local oneteam = require('oneteam')
local https = require('ssl.https')
local url = require('socket.url')
local redis = dofile('libs/redis.lua')
local configuration = require('configuration')

function help:init()
    help.commands = oneteam.commands(self.info.username):command('help'):command('start').table
    help.help = '/help [plugin] - A help-orientated menu is sent if no arguments are given. If arguments are given, usage information for the given plugin is sent instead. Alias: /start.'
end

function help.get_initial_keyboard(message)
    return oneteam.inline_keyboard():row(
        oneteam.row():callback_data_button(
            'Links',
            'help:links'
        ):callback_data_button(
            'Admin Help',
            'help:ahelp:1'
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
            'help:settings:'..message.chat.id
        ):callback_data_button(
            'Channels',
            'help:channels'
        )
    )
end

function help.get_plugin_page(arguments_list, page)
    local plugin_count = #arguments_list
    local page_begins_at = tonumber(page) * 10 - 9
    local page_ends_at = tonumber(page_begins_at) + 9
    if tonumber(page_ends_at) > tonumber(plugin_count) then
        page_ends_at = tonumber(plugin_count)
    end
    local page_plugins = {}
    for i = tonumber(page_begins_at), tonumber(page_ends_at) do
        table.insert(page_plugins, arguments_list[i])
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

function help:on_inline_query(inline_query, configuration, language)
    local offset = inline_query.offset and tonumber(inline_query.offset) or 0
    local output = oneteam.get_inline_help(inline_query.query, offset)
    if #output == 0 and tonumber(offset) == 0 then
        output = string.format(language['help']['2'], inline_query.query)
        return oneteam.send_inline_article(inline_query.id, language['help']['1'], output)
    end
    offset = tostring(offset + 50)
    return oneteam.answer_inline_query(inline_query.id, output, 0, false, offset)
end

function help:on_callback_query(callback_query, message, configuration, language)
    if callback_query.data == 'cmds' then
        local arguments_list = oneteam.get_help()
        local plugin_count = #arguments_list
        local page_count = math.floor(tonumber(plugin_count) / 10)
        if math.floor(tonumber(plugin_count) / 10) ~= tonumber(plugin_count) / 10 then
            page_count = page_count + 1
        end
        local output = help.get_plugin_page(arguments_list, 1)
        output = output .. string.format(language['help']['3'], self.info.username)
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            nil,
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
        local arguments_list = oneteam.get_help()
        local plugin_count = #arguments_list
        local page_count = math.floor(tonumber(plugin_count) / 10)
        if math.floor(tonumber(plugin_count) / 10) ~= tonumber(plugin_count) / 10 then
            page_count = page_count + 1
        end
        if tonumber(new_page) > tonumber(page_count) then
            new_page = 1
        elseif tonumber(new_page) < 1 then
            new_page = tonumber(page_count)
        end
        local output = help.get_plugin_page(arguments_list, new_page)
        output = output .. string.format(language['help']['3'], self.info.username)
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            nil,
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
    elseif callback_query.data:match('^pages:%d*:%d*$') then
        local current_page, total_pages = callback_query.data:match('^pages:(%d*):(%d*)$')
        return oneteam.answer_callback_query(
            callback_query.id,
            string.format(language['help']['8'], current_page, total_pages)
        )
    elseif callback_query.data == 'ahelp:1' then
        local administration_help_text = language['help']['9']
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            administration_help_text,
            'markdown',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    language['help']['6'],
                    'help:back'
                ):callback_data_button(
                    language['help']['5'],
                    'help:ahelp:2'
                )
            )
        )
    elseif callback_query.data == 'ahelp:2' then
        local administration_help_text = language['help']['10']
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            administration_help_text,
            'markdown',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    language['help']['6'],
                    'help:ahelp:1'
                ):callback_data_button(
                    language['help']['5'],
                    'help:ahelp:3'
                )
            )
        )
    elseif callback_query.data == 'ahelp:3' then
        local administration_help_text = language['help']['11']
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            administration_help_text,
            'markdown',
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():callback_data_button(
                    language['help']['6'],
                    'help:ahelp:2'
                )
            )
        )
    elseif callback_query.data == 'links' then
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            language['help']['12'],
            nil,
            true,
            oneteam.inline_keyboard():row(
                oneteam.row():url_button(
                    language['help']['14'],
                    'https://t.me/Barreeeiroo_Ch'
                ):url_button(
                    language['help']['17'],
                    'https://github.com/barreeeiroo/BarrePolice'
                ):url_button(
                    language['help']['15'],
                    'https://t.me/BarrePolice'
                )
            ):row(
                oneteam.row():url_button(
                    language['help']['19'],
                    'https://t.me/storebot?start=BarrePolice_Bot'
                ):url_button(
                    language['help']['20'],
                    'https://t.me/joinchat/AAAAAEHCFLYFXDzX_SKvrg'
                ):url_button(
                    language['help']['18'],
                    'https://paypal.me/Makeroid'
                )
            ):row(
                oneteam.row():url_button(
                    "Makeroid",
                    'https://t.me/Makeroid'
                ):url_button(
                    "BarrePolice AI",
                    'https://t.me/BarrePoliceBot'
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
                    'Makeroid',
                    'https://t.me/Makeroid'
                )
            ):row(
                oneteam.row():callback_data_button(
                    oneteam.symbols.back .. ' ' .. language['help']['6'],
                    'help:back'
                )
            )
        )
    elseif callback_query.data:match('^settings:%-*%d+$') then
        if message.chat.type == 'supergroup' and not oneteam.is_group_admin(message.chat.id, callback_query.from.id) then
            return oneteam.answer_callback_query(callback_query.id, language['errors']['admin'])
        end
        chat_id = callback_query.data:match('^settings:(%-*%d+)$')
        return oneteam.edit_message_reply_markup(
            message.chat.id,
            message.message_id,
            nil,
            (
                oneteam.is_group(chat_id) and
                oneteam.is_group_admin(
                    chat_id,
                    callback_query.from.id
                )
            )
            and oneteam.inline_keyboard()
            :row(
                oneteam.row():callback_data_button(
                    language['help']['21'], 'administration:' .. chat_id .. ':page:1'
                ):callback_data_button(
                    language['help']['22'], 'plugins:' .. chat_id .. ':page:1'
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
            help.get_initial_keyboard(message)
        )
    end
end

function help:on_message(message, configuration, language)
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
        true,
        false,
        nil,
        help.get_initial_keyboard(message)
    )
end

return help
