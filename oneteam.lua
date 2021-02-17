local oneteam = {}
local https = require('ssl.https')
local ltn12 = require('ltn12')
local json = require('dkjson')
local redis = dofile('libs/redis.lua')
local configuration = require('configuration')
local api = require('telegram-bot-lua.core').configure(configuration.bot_token)
local tools = require('telegram-bot-lua.tools')
local socket = require('socket')
local utils = dofile('libs/utils.lua')
local html = require('htmlEntities')

local plugin_list = {}
local administrative_plugin_list = {}
local inline_plugin_list = {}

function oneteam:init()
    if oneteam.is_reloading then
        configuration = require('configuration')
        oneteam.is_reloading = false
    end
    self.info = api.info -- Set the bot's information to the object fetched from the Telegram bot API.
    oneteam.info = api.info
    self.plugins = {} -- Make a table for the bot's plugins.
    self.api = api
    self.tools = tools
    self.configuration = configuration
    self.beta_plugins = {}
    self.chats = {}
    self.users = {}
    self.replies = {}
    for k, v in ipairs(configuration.plugins) do -- Iterate over all of the configured plugins.
        local true_path = v
        for _, p in pairs(configuration.administrative_plugins) do
            if v == p then
                true_path = 'administration.' .. v
            end
        end
        for _, p in pairs(configuration.beta_plugins) do
            if v == p then
                table.insert(self.beta_plugins, v)
            end
        end
        local plugin = require('plugins.' .. true_path) -- Load each plugin.
        if not plugin then
            error('Invalid plugin: ' .. true_path)
        elseif oneteam.is_duplicate(configuration.plugins, v) then
            error('Duplicate plugin: ' .. v)
        end
        plugin.is_administrative = true_path:match('^administration%.') and true or false
        self.plugins[k] = plugin
        self.plugins[k].name = v
        if self.beta_plugins[v] then
            plugin.is_beta_plugin = true
        end
        if plugin.init then -- If the plugin has an `init` function, run it.
            plugin.init(self, configuration)
        end
        plugin.is_administrative = (self.plugins[k].name == 'administration' or true_path:match('^administration%.')) and true or false
        -- By default, a plugin doesn't have inline functionality; but, if it does, set it to `true` appropriately.
        plugin.is_inline = plugin.on_inline_query and true or false
        plugin.commands = plugin.commands or {} -- If the plugin hasn't got any commands configured, then set a blank
        -- table, so when it comes to iterating over the commands later on, the bot won't encounter any problems.
        if plugin.help and not plugin.is_beta_plugin then -- If the plugin has help documentation, then insert it into other tables (where necessary).
            if plugin.is_administrative then
                table.insert(administrative_plugin_list, plugin.help)
            else
                table.insert(plugin_list, plugin.help)
                if plugin.is_inline then -- If the plugin is inline and has documentation, then insert the documentation into
                -- the `inline_plugin_list` table.
                    table.insert(inline_plugin_list, plugin.help)
                end
            end
            plugin.help = 'Usage:\n' .. plugin.help:gsub('%. (Alias)', '.\n%1') -- Make the plugin's documentation style all nicely unified, for consistency.
        end
        self.plugin_list = plugin_list
        self.inline_plugin_list = inline_plugin_list
        self.administrative_plugin_list = administrative_plugin_list
    end
    print(configuration.connected_message)
    local info_message = '\tUsername: @' .. self.info.username .. '\n\tName: ' .. self.info.name .. '\n\tID: ' .. self.info.id
    print('\n' .. info_message .. '\n')
    if redis:get('oneteam:version') ~= configuration.version then
        local success = dofile('migrate.lua')
        print(success)
    end
    self.version = configuration.version
    -- Make necessary database changes if the version has changed.
    if not redis:get('oneteam:version') or redis:get('oneteam:version') ~= self.version then
        redis:set('oneteam:version', self.version)
    end
    self.last_update = self.last_update or 0 -- If there is no last update known, make it 0 so the bot doesn't encounter any problems when it tries to add the necessary increment.
    self.last_backup = self.last_backup or os.date('%V')
    self.last_cron = self.last_cron or os.date('%M')
    self.last_cache = self.last_cache or os.date('%d')
    local init_message = '<pre>' .. configuration.connected_message .. '\n\n' .. oneteam.escape_html(info_message) .. '\n\n\tPlugins loaded: ' .. #configuration.plugins - #configuration.administrative_plugins .. '\n\tAdministrative plugins loaded: ' .. #configuration.administrative_plugins .. '</pre>'
    oneteam.send_message(configuration.log_chat, init_message:gsub('\t', ''), 'html')
    for _, admin in pairs(configuration.admins) do
        oneteam.send_message(admin, init_message:gsub('\t', ''), 'html')
    end
    local shutdown = redis:get('oneteam:shutdown')
    if shutdown then
        local chat_id, message_id = shutdown:match('^(%-?%d+):(%d*)$')
        oneteam.edit_message_text(chat_id, message_id, 'Successfully rebooted!')
        redis:del('oneteam:shutdown')
    end
    return true
end

-- Set a bunch of function aliases, for consistency & compatibility.
for i, v in pairs(api) do
    oneteam[i] = v
end
for i, v in pairs(tools) do
    oneteam[i] = v
end
for i, v in pairs(utils) do
    if i ~= 'init' then
        oneteam[i] = v
    end
end

function oneteam:run(_, token)
-- oneteam's main long-polling function which repeatedly checks the Telegram bot API for updates.
-- The objects received in the updates are then further processed through object-specific functions.
    token = token or configuration.bot_token
    assert(token, 'You need to enter your Telegram bot API token in configuration.lua, or pass it as the second argument when using the oneteam:run() function!')
    oneteam.is_running = oneteam.init(self) -- Initialise the bot.
    utils.init(self, configuration)
    while oneteam.is_running do -- Perform the main loop whilst the bot is running.
        local success = api.get_updates( -- Check the Telegram bot API for updates.
            configuration.updates.timeout,
            self.last_update + 1,
            configuration.updates.limit,
            json.encode(
                {
                    'message',
                    'edited_message',
                    'inline_query',
                    'callback_query'
                }
            ),
            configuration.use_beta_endpoint or false
        )
        if success and success.result then
            for _, v in ipairs(success.result) do
                self.last_update = v.update_id
                self.execution_time = socket.gettime()
                if v.message or v.edited_message then
                    if v.edited_message then
                        v.message = v.edited_message
                        v.edited_message = nil
                        v.message.old_date = v.message.date
                        v.message.date = v.message.edit_date
                        v.message.edit_date = nil
                        v.message.is_edited = true
                    else
                        v.message.is_edited = false
                    end
                    if v.message.reply_to_message then
                        v.message.reply = v.message.reply_to_message -- Make the `update.message.reply_to_message`
                        -- object `update.message.reply` to make any future handling easier.
                        v.message.reply_to_message = nil -- Delete the old value by setting its value to nil.
                    end
                    oneteam.on_message(self, v.message)
                    if configuration.debug then
                        print(
                            string.format(
                                '%s[36m[Update #%s] Message%s from %s to %s: %s%s[0m',
                                string.char(27),
                                v.update_id,
                                v.message.is_edited and ' edit' or '',
                                v.message.from.id,
                                v.message.chat.id,
                                v.message.text,
                                string.char(27)
                            )
                        )
                    end
                elseif v.inline_query then
                    oneteam.on_inline_query(self, v.inline_query)
                    if configuration.debug then
                        print(
                            string.format(
                                '%s[35m[Update #%s] Inline query from %s%s[0m',
                                string.char(27),
                                v.update_id,
                                v.inline_query.from.id,
                                string.char(27)
                            )
                        )
                    end
                elseif v.callback_query then
                    if v.callback_query.message and v.callback_query.message.reply_to_message then
                        v.callback_query.message.reply = v.callback_query.message.reply_to_message
                        v.callback_query.message.reply_to_message = nil
                    end
                    oneteam.on_callback_query(self, v.callback_query.message, v.callback_query)
                    if configuration.debug then
                        print(
                            string.format(
                                '%s[33m[Update #%s] Callback query from %s%s[0m',
                                string.char(27),
                                v.update_id,
                                v.callback_query.from.id,
                                string.char(27)
                            )
                        )
                    end
                end
                self.result_time = socket.gettime() - self.execution_time
                if configuration.debug then
                    print('Update #' .. v.update_id .. ' took ' .. self.result_time .. ' seconds to process.')
                end
            end
        else
            oneteam.log_error('There was an error retrieving updates from the Telegram bot API!')
        end
        if self.last_backup ~= os.date('%V') then -- If it's been a week since the last backup, perform another backup.
            self.last_backup = os.date('%V') -- Set the last backup time to now, since we're
            -- now performing one!
            print(io.popen('./backup.sh'):read('*all'))
        end
        if self.last_cron ~= os.date('%M') then -- Perform minutely CRON jobs.
            self.last_cron = os.date('%M')
            for i = 1, #self.plugins do
                local plugin = self.plugins[i]
                if plugin and plugin.cron then
                    local cron_success, res = pcall(function()
                        plugin.cron(self, configuration)
                    end)
                    if not cron_success then
                        oneteam.exception(self, res, 'CRON: ' .. i, configuration.log_chat)
                    end
                end
            end
        end
        if self.last_cache ~= os.date('%d') then -- Reset the bot's cache.
            self.last_cache = os.date('%d')
            self.chats = {}
            self.users = {}
            self.replies = {}
        end
    end
    print(self.info.first_name .. ' is shutting down...')
end

function oneteam:on_message(message)

    -- If the message is old or is missing necessary fields/values, then we'll stop and allow the bot to start processing the next update(s).
    -- If the message was sent from a blocklisted chat, then we'll stop because we don't want the bot to respond there.
    if not oneteam.is_valid(message) then
        return false
    elseif redis:get('blocklisted_chats:' .. message.chat.id) then
        return oneteam.leave_chat(message.chat.id)
    end
    message = oneteam.sort_message(message) -- Process the message.
    self.is_user_blocklisted, self.is_globally_blocklisted, self.is_globally_banned = oneteam.is_user_blocklisted(message)
    -- We only want this functionality if the bot owner has been granted API permission to SpamWatch!
    self.is_spamwatch_blocklisted = configuration.keys.spamwatch ~= '' and oneteam.is_spamwatch_blocklisted(message) or false

    if self.is_globally_banned and message.chat.type ~= 'private' then -- Only for the worst of the worst
        oneteam.ban_chat_member(message.chat.id, message.from.id)
    end
    local language = require('languages.' .. oneteam.get_user_language(message.from.id))
    if oneteam.is_group(message) and oneteam.get_setting(message.chat.id, 'force group language') then
        language = require('languages.' .. (oneteam.get_value(message.chat.id, 'group language') or 'en_us'))
    end
    self.language = language
    if oneteam.process_spam(message, configuration) then
        return false
    end

    -- Perform the following actions if the user isn't blocklisted.
    if not self.is_user_blocklisted then
        oneteam.process_afk(self, message)
        oneteam.process_language(self, message)
        if message.text then
            message = oneteam.process_natural_language(self, message)
        end
        message = oneteam.process_stickers(message)
        message = oneteam.check_links(message, false, true, false, true)
        message = oneteam.process_deeplinks(message)
        -- If the user isn't current AFK, and they say they're going to be right back, we can
        -- assume that they are now going to be AFK, so we'll help them out and set them that
        -- way by making the message text the /afk command, which will later trigger the plugin.
        if (message.text:lower():match('^i?\'?l?l? ?[bg][rt][bg].?$') and not redis:hget('afk:' .. message.from.id, 'since')) then
            message.text = '/afk'
        end
        -- A boolean value to decide later on, whether the message is intended for the current plugin from the iterated table.
        message = oneteam.process_nicknames(message)
        if not self.chats[tostring(message.chat.id)] then
            self.chats[tostring(message.chat.id)] = message.chat
            self.chats[tostring(message.chat.id)].disabled_plugins = redis:smembers('disabled_plugins:' .. message.chat.id) or {}
        end
        if message.reply then
            if not self.replies[tostring(message.chat.id)] then
                self.replies[tostring(message.chat.id)] = {}
            end
            if not self.replies[tostring(message.chat.id)][tostring(message.message_id)] then
                self.replies[tostring(message.chat.id)][tostring(message.message_id)] = message.reply
            end
            if self.replies[tostring(message.chat.id)][tostring(message.reply.message_id)] then
                message.reply.reply = self.replies[tostring(message.chat.id)][tostring(message.reply.message_id)]
            end
        end
    end
    self.is_command = false
    self.is_command_done = false
    self.is_allowed_beta_access = false
    self.is_telegram = false

    -- If the message is one of those pesky Telegram channel pins, it won't send a service message. We'll trick it.
    if message.from.id == 777000 and message.forward_from_chat and message.forward_from_chat.type == 'channel' then
        self.is_telegram = true
        message.is_service_message = true
        message.service_message = 'pinned_message'
        message.pinned_message = {
            ['text'] = message.text,
            ['date'] = message.date,
            ['chat'] = message.chat,
            ['from'] = message.from,
            ['message_id'] = message.message_id,
            ['entities'] = message.entities,
            ['forward_from_message_id'] = message.forward_from_message_id,
            ['forward_from_chat'] = message.forward_from_chat,
            ['forward_date'] = message.forward_date
        }
    end

    if message.text:match('^[/!#][%w_]+') and message.chat.type == 'supergroup' then
        local command, input = message.text:lower():match('^[/!#]([%w_]+)(.*)$')
        local all = redis:hgetall('chat:' .. message.chat.id .. ':aliases')
        for alias, original in pairs(all) do
            if command == alias then
                message.text = '/' .. original .. input
                message.is_alias = true
                break
            end
        end
    end

    -- This is the main loop which iterates over configured plugins and runs the appropriate functions.
    for _, plugin in ipairs(self.plugins) do
        if not oneteam.is_plugin_disabled(self, plugin.name, message) then
            if plugin.is_beta_plugin and oneteam.is_global_admin(message.from.id) then
                self.is_allowed_beta_access = true
            end
            if not plugin.is_beta_plugin or (plugin.is_beta_plugin and self.is_allowed_beta_access) then
                local commands = #plugin.commands or {}
                for i = 1, commands do
                    if message.text:match(plugin.commands[i]) and oneteam.is_plugin_allowed(plugin.name, self.is_user_blocklisted, configuration) and not self.is_command_done and not self.is_telegram and (not message.is_edited or oneteam.is_global_admin(message.from.id)) then
                        self.is_command = true
                        message.command = plugin.commands[i]:match('([%w_%-]+)')
                        if plugin.on_message then
                            local old_message = message.text
                            if oneteam.is_global_admin(message.from.id) and message.text:match('^.- && .-$') then
                                message.text = message.text:match('^(.-) && .-$')
                            end
                            local success, result = pcall(function()
                                return plugin.on_message(self, message, configuration, language)
                            end)
                            message.text = old_message
                            if not success then
                                oneteam.exception(self, result, string.format('%s: %s', message.from.id, message.text), configuration.log_chat)
                            end
                            if oneteam.get_setting(message.chat.id, 'delete commands') and self.is_command and not redis:sismember('chat:' .. message.chat.id .. ':no_delete', tostring(plugin.name)) and not message.is_natural_language then
                                oneteam.delete_message(message.chat.id, message.message_id)
                            end
                            self.is_command_done = true
                        end
                    end
                end
            end

            -- Allow plugins to handle new chat participants.
            if message.new_chat_members and plugin.on_member_join then
                local success, result = pcall(function()
                    return plugin.on_member_join(self, message, configuration, language)
                end)
                if not success then
                    oneteam.exception(self, result, string.format('%s: %s', message.from.id, message.text),
                    configuration.log_chat)
                end
            end

            -- Allow plugins to handle every new message (handy for anti-spam).
            if (message.text or message.is_media) and plugin.on_new_message then
                local success, result = pcall(function()
                    return plugin.on_new_message(self, message, configuration, language)
                end)
                if not success then
                    oneteam.exception(self, result, string.format('%s: %s', message.from.id, message.text or tostring(message.media_type),
                    configuration.log_chat))
                end
            end

            -- Allow plugins to handle service messages, and pass the type of service message before the message object.
            if message.is_service_message and plugin.on_service_message then
                local success, result = pcall(function()
                    return plugin.on_service_message(self, message.service_message:gsub('_', ' '), message, configuration, language)
                end)
                if not success then
                    oneteam.exception(self, result, string.format('%s: %s', message.from.id, message.text or tostring(message.media_type),
                    configuration.log_chat))
                end
            end
        end
    end
    oneteam.process_message(self, message)
    self.is_done = true
    self.is_command_done = false
    self.is_ai = false
    return
end

function oneteam:on_inline_query(inline_query)
    if not inline_query.from then
        return false, 'No `inline_query.from` object was found!'
    elseif redis:get('global_blocklist:' .. inline_query.from.id) then
        return false, 'This user is globally blocklisted!'
    end
    local language = require('languages.' .. oneteam.get_user_language(inline_query.from.id))
    inline_query.offset = inline_query.offset and tonumber(inline_query.offset) or 0
    for _, plugin in ipairs(self.plugins) do
        local plugins = plugin.commands or {}
        for i = 1, #plugins do
            local command = plugin.commands[i]
            if not inline_query then
                return false, 'No `inline_query` object was found!'
            end
            if inline_query.query:match(command)
            and plugin.on_inline_query
            then
                local success, result = pcall(
                    function()
                        return plugin.on_inline_query(self, inline_query, configuration, language)
                    end
                )
                if not success then
                    local exception = string.format('%s: %s', inline_query.from.id, inline_query.query)
                    oneteam.exception(self, result, exception, configuration.log_chat)
                    return false, result
                elseif not result then
                    return api.answer_inline_query(
                        inline_query.id,
                        api.inline_result()
                        :id()
                        :type('article')
                        :title(configuration.errors.results)
                        :description(plugin.help)
                        :input_message_content(api.input_text_message_content(plugin.help))
                    )
                end
            end
        end
    end
    if not inline_query.query or inline_query.query:gsub('%s', '') == '' then
        local offset = inline_query.offset and tonumber(inline_query.offset) or 0
        local list = oneteam.get_inline_list(self.info.username, offset)
        if #list == 0 then
            local title = 'No more results found!'
            local description = 'There were no more inline features found. Use @' .. self.info.username .. ' <query> to search for more information about commands matching the given search query.'
            return oneteam.send_inline_article(inline_query.id, title, description)
        end
        return oneteam.answer_inline_query(inline_query.id, json.encode(list), 0, false, tostring(offset + 50))
    end
    local help = require('plugins.help')
    return help.on_inline_query(self, inline_query, configuration, language)
end

function oneteam:on_callback_query(message, callback_query)
    if not callback_query.from then return false end
    if not callback_query.message or not callback_query.message.chat then
        message = {
            ['chat'] = {},
            ['message_id'] = callback_query.inline_message_id,
            ['from'] = callback_query.from
        }
    else
        message = callback_query.message
        message.exists = true
        message = oneteam.process_nicknames(message)
        callback_query = oneteam.process_nicknames(callback_query)
    end
    if not self.chats[tostring(message.chat.id)] then
        self.chats[tostring(message.chat.id)] = message.chat
        self.chats[tostring(message.chat.id)].disabled_plugins = redis:smembers('disabled_plugins:' .. message.chat.id) or {}
    end
    local language = require('languages.' .. oneteam.get_user_language(callback_query.from.id))
    if message.chat.id and oneteam.is_group(message) and oneteam.get_setting(message.chat.id, 'force group language') then
        language = require('languages.' .. (oneteam.get_value(message.chat.id, 'group language') or 'en_gb'))
    end
    self.language = language
    if redis:get('global_blocklist:' .. callback_query.from.id) and not callback_query.data:match('^join_captcha') and not oneteam.is_global_admin(callback_query.from.id) then
        return false, 'This user is globally blocklisted!'
    elseif message and message.exists then
        if message.reply and message.chat.type ~= 'channel' and callback_query.from.id ~= message.reply.from.id and not callback_query.data:match('^game:') and not callback_query.data:match('^report:') and not oneteam.is_global_admin(callback_query.from.id) then
            local output = 'Only ' .. message.reply.from.first_name .. ' can use this!'
            return oneteam.answer_callback_query(callback_query.id, output)
        end
    end
    for _, plugin in ipairs(self.plugins) do
        if not callback_query.data or not callback_query.from then
            return false
        elseif plugin.name == callback_query.data:match('^(.-):.-$') and plugin.on_callback_query then
            callback_query.data = callback_query.data:match('^[%a_]+:(.-)$')
            if not callback_query.data then
                plugin = callback_query.data
                callback_query = ''
            end
            local success, result = pcall(
                function()
                    return plugin.on_callback_query(self, callback_query, message or false, configuration, language)
                end
            )
            if not success then
                oneteam.send_message(configuration.admins[1], json.encode(callback_query, {indent=true}))
                -- oneteam.answer_callback_query(callback_query.id, language['errors']['generic'])
                local exception = string.format('%s: %s', callback_query.from.id, callback_query.data)
                oneteam.exception(self, result, exception, configuration.log_chat)
                return false, result
            end
        end
    end
    return true
end

oneteam.send_message = api.send_message


-- A variant of oneteam.send_message(), optimised for sending a message as a reply that forces a
-- reply back from the user.
function oneteam.send_force_reply(message, text, parse_mode, disable_web_page_preview, token)
    local success = api.send_message(
        message,
        text,
        parse_mode,
        disable_web_page_preview,
        false,
        message.message_id,
        '{"force_reply":true,"selective":true}',
        token
    )
    return success
end

function oneteam.get_chat(chat_id, only_api, token)
    local user = oneteam.get_user(chat_id)
    if user then
        return user
    end
    local success = api.get_chat(chat_id, token)
    if only_api then -- stops antispam using usernames stored in the database
        return success
    elseif success and success.result.type == 'private' then
        oneteam.process_user(success.result)
    elseif success then
        oneteam.process_chat(success.result)
    end
    chat_id = success and success.result.id or chat_id
    local result = redis:hgetall('chat:' .. tostring(chat_id) .. ':info')
    if not result or type(result) == 'table' and not next(result) then
        return false
    end
    success.result = result
    if not success.result.id then
        success.result.id = chat_id
        redis:hset('chat:' .. chat_id .. ':info', 'id', chat_id)
    end
    return success
end

function oneteam:is_plugin_disabled(plugin, message)
    if not plugin or not message then
        return false
    end
    plugin = plugin:lower():gsub('^administration/', '')
    if oneteam.table_contains(configuration.permanent_plugins, plugin) then
        return false
    elseif type(message) ~= 'table' then
        message = {
            ['chat'] = {
                ['id'] = message
            }
        }
        if tostring(message.chat.id):match('^%-100') then
            message.chat.type = 'supergroup'
        else
            message.chat.type = 'private'
        end
    end
    if not self.chats[tostring(message.chat.id)] then
        self.chats[tostring(message.chat.id)] = message.chat
    end
    if not self.chats[tostring(message.chat.id)].disabled_plugins then
        self.chats[tostring(message.chat.id)].disabled_plugins = redis:smembers('disabled_plugins:' .. message.chat.id)
    end
    if not oneteam.table_contains(self.chats[tostring(message.chat.id)].disabled_plugins, plugin) then
        return false
    end
    local exists = redis:sismember('disabled_plugins:' .. message.chat.id, plugin)
    return exists and true or false
end

function oneteam:exception(err, message, log_chat)
    local output = string.format(
        '[%s]\n%s: %s\n%s\n',
        os.date('%X'),
        self.info.username,
        oneteam.escape_html(err) or '',
        oneteam.escape_html(message)
    )
    if log_chat then
        return oneteam.send_message(
            log_chat,
            string.format('<pre>%s</pre>', output),
            'html'
        )
    end
    return output
end

function oneteam.is_group_admin(chat_id, user_id, is_real_admin)
    if not chat_id or not user_id then
        return false
    elseif oneteam.is_global_admin(chat_id) or oneteam.is_global_admin(user_id) then
        return true
    elseif not is_real_admin and oneteam.is_group_mod(chat_id, user_id) then
        return true
    end
    local user, res = oneteam.get_chat_member(chat_id, user_id)
    if not user or not user.result then
        return false, res
    elseif user.result.status == 'creator' or user.result.status == 'administrator' then
        return true, res
    end
    return false, user.result.status
end

function oneteam.is_group_mod(chat_id, user_id)
    if not chat_id or not user_id then
        return false
    elseif redis:sismember('administration:' .. chat_id .. ':mods', user_id) then
        return true
    end
    return false
end

function oneteam.process_chat(chat)
    chat.id_str = tostring(chat.id)
    if chat.type == 'private' then
        return oneteam.process_user(chat)
    end
    if not redis:hexists('chat:' .. chat.id .. ':info', 'id') then
        print(
            string.format(
                '%s[34m[+] Added the chat %s to the database!%s[0m',
                string.char(27),
                chat.username and '@' .. chat.username or chat.id,
                string.char(27)
            )
        )
    end
    redis:hset('chat:' .. chat.id .. ':info', 'title', chat.title)
    redis:hset('chat:' .. chat.id .. ':info', 'type', chat.type)
    if chat.username then
        chat.username = chat.username:lower()
        redis:hset('chat:' .. chat.id .. ':info', 'username', chat.username)
        redis:set('username:' .. chat.username, chat.id)
        if not redis:sismember('chat:' .. chat.id .. ':usernames', chat.username) then
            redis:sadd('chat:' .. chat.id .. ':usernames', chat.username)
        end
    end
    redis:hset('chat:' .. chat.id .. ':info', 'id', chat.id)
    return chat
end

function oneteam.process_user(user)
    if not user then return user end
    if not user.id or not user.first_name then return false end
    redis:hset('user:' .. user.id .. ':info', 'id', user.id)
    local new = false
    user.name = user.first_name
    if user.last_name then
        user.name = user.name .. ' ' .. user.last_name
    end
    if not redis:hget('user:' .. user.id .. ':info', 'id') and configuration.debug then
        print(
            string.format(
                '%s[34m[+] Added the user %s to the database!%s%s[0m',
                string.char(27),
                user.username and '@' .. user.username or user.id,
                user.language_code and ' Language: ' .. user.language_code or '',
                string.char(27)
            )
        )
        new = true
    elseif configuration.debug then
        print(
            string.format(
                '%s[34m[+] Updated information about the user %s in the database!%s%s[0m',
                string.char(27),
                user.username and '@' .. user.username or user.id,
                user.language_code and ' Language: ' .. user.language_code or '',
                string.char(27)
            )
        )
    end
    redis:hset('user:' .. user.id .. ':info', 'type', 'private')
    redis:hset('user:' .. user.id .. ':info', 'name', user.name)
    redis:hset('user:' .. user.id .. ':info', 'first_name', user.first_name)
    if user.last_name then
        redis:hset('user:' .. user.id .. ':info', 'last_name', user.last_name)
    else
        redis:hdel('user:' .. user.id .. ':info', 'last_name')
    end
    if user.username then
        user.username = user.username:lower()
        redis:hset('user:' .. user.id .. ':info', 'username', user.username)
        redis:set('username:' .. user.username, user.id)
        if not redis:sismember('user:' .. user.id .. ':usernames', user.username) then
            redis:sadd('user:' .. user.id .. ':usernames', user.username)
        end
    else
        redis:hdel('user:' .. user.id .. ':info', 'username')
    end
    if user.language_code then
        if oneteam.does_language_exist(user.language_code) and not redis:hget('chat:' .. user.id .. ':settings', 'language') then
        -- If a translation exists for the user's language code, and they haven't selected
        -- a language already, then set it as their primary language!
            redis:hset('chat:' .. user.id .. ':settings', 'language', user.language_code)
        end
        redis:hset('user:' .. user.id .. ':info', 'language_code', user.language_code)
    else
        redis:hdel('user:' .. user.id .. ':info', 'language_code')
    end
    redis:hset('user:' .. user.id .. ':info', 'is_bot', tostring(user.is_bot))
    if new then
        redis:hset('user:' .. user.id .. ':info', 'id', user.id)
    end
    if redis:get('nick:' .. user.id) then
        user.first_name = redis:get('nick:' .. user.id)
        user.name = user.first_name
        user.last_name = nil
    end
    return user, new
end

function oneteam.sort_message(message)
    message.is_natural_language = false
    message.text = message.text or message.caption or '' -- Ensure there is always a value assigned to message.text.
    message.text = message.text:gsub('^/(%a+)%_', '/%1 ')
    if message.text:match('^[/!#]start .-$') then -- Allow deep-linking through the /start command.
        message.text = '/' .. message.text:match('^[/!#]start (.-)$')
    end
    message.is_media = oneteam.is_media(message)
    message.media_type = oneteam.media_type(message)
    message.file_id = oneteam.file_id(message)
    message.is_alias = false -- We sort this later.
    message.is_service_message, message.service_message = oneteam.service_message(message)
    if message.caption_entities then
        message.entities = message.caption_entities
        message.caption_entities = nil
    end
    if message.from.language_code then
        message.from.language_code = message.from.language_code:lower():gsub('%-', '_') -- make it fit with the names of our language files
        if message.from.language_code:len() == 2 and message.from.language_code ~= 'en' then
            message.from.language_code = message.from.language_code .. '_' .. message.from.language_code
        elseif message.from.language_code:len() == 2 or message.from.language_code == 'root' then -- not sure why but some english users were having `root` return as their language
            message.from.language_code = 'en_us'
        end
    end
    message.reply = message.reply and oneteam.sort_message(message.reply) or nil
    if message.from then
        message.from = oneteam.process_user(message.from)
    end
    if message.reply then
        message.reply.from = oneteam.process_user(message.reply.from)
    end
    if message.forward_from then
        message.forward_from = oneteam.process_user(message.forward_from)
    end
    if message.chat and message.chat.type ~= 'private' then
        -- Add the user to the set of users in the current chat.
        if configuration.administration.store_chat_members and message.from then
            if not redis:sismember('chat:' .. message.chat.id .. ':users', message.from.id) then
                redis:sadd('chat:' .. message.chat.id .. ':users', message.from.id)
            end
        end
        if message.new_chat_members then
            message.chat = oneteam.process_chat(message.chat)
            for i = 1, #message.new_chat_members do
                if configuration.administration.store_chat_users then
                    redis:sadd('chat:' .. message.chat.id .. ':users', message.new_chat_members[i].id) -- add users to the chat's set in the database
                end
                message.new_chat_members[i] = oneteam.process_user(message.new_chat_members[i])
            end
        elseif message.left_chat_member then -- if they've left the chat then there's no need for them to be in the set anymore
            message.chat = oneteam.process_chat(message.chat)
            message.left_chat_member = oneteam.process_user(message.left_chat_member)
            if configuration.administration.store_chat_users then
                redis:srem('chat:' .. message.chat.id .. ':users', message.left_chat_member.id)
            end
        end
    end
    if message.text and message.chat and message.reply and message.reply.from and message.reply.from.id == api.info.id then
        local action = redis:get('action:' .. message.chat.id .. ':' .. message.reply.message_id)
        -- If an action was saved for the replied-to message (as part of a multiple step command), then
        -- we'll get information about the action.
        if action then
            message.text = action .. ' ' .. message.text -- Concatenate the saved action's command
            -- with the new `message.text`.
            message.reply = nil -- This caused some issues with administrative commands which would
            -- prioritise replied-to users over users given by arguments.
            redis:del(action) -- Delete the action for this message, since we've done what we needed to do
            -- with it now.
        end
    end
    if message.entities then
        for n, entities in pairs(message.entities) do
            if entities.type == 'text_mention' then
                message.text = message.text:gsub(message.entities[n].user.first_name, message.entities[n].user.id)
            end
        end
    end
    return message
end

function oneteam.is_global_admin(id)
    for _, v in pairs(configuration.admins) do
        if id == v then
            return true
        end
    end
    return false
end

function oneteam.get_user(input, force_api, is_id_plugin, cache_only)
    if tonumber(input) == nil and input then -- check it's not an ID
        input = input:match('^%@?(.-)$')
        input = redis:get('username:' .. input:lower())
    end
    if not input or tonumber(input) == nil then -- if it's still not an ID then we'll give up
        return false
    end
    local user = redis:hgetall('user:' .. tostring(input) .. ':info')
    if is_id_plugin and user.id then
        local success = oneteam.get_chat(user.id) -- Try and get latest info about the user for the ID plugin
        if success then
            return success
        end
    end
    if user.username and not cache_only then
        local scrape, scrape_res = https.request('https://t.me/' .. user.username)
        if scrape_res == 200 then
            local bio = scrape:match('%<div class="tgme_page_description "%>(.-)%</div%>')
            if bio then
                bio = bio:gsub('%b<>', '')
                bio = html.decode(bio)
                user.bio = bio
            end
        end
    end
    if user.id then
        return {
            ['result'] = {
                ['id'] = tonumber(user.id),
                ['type'] = user.type,
                ['name'] = user.name,
                ['first_name'] = user.first_name,
                ['last_name'] = user.last_name,
                ['username'] = user.username,
                ['is_bot'] = user.is_bot,
                ['bio'] = user.bio
            }
        }
    end
    if force_api then
        return oneteam.get_chat(input)
    end
    return false
end

function oneteam.get_inline_list(username, offset)
    offset = offset and tonumber(offset) or 0
    local inline_list = {}
    table.sort(inline_plugin_list)
    for k, v in pairs(inline_plugin_list) do
        if k > offset and k < offset + 50 then -- The bot API only accepts a maximum of 50 results, hence we need the offset.
            v = v:gsub('\n', ' ')
            table.insert(
                inline_list,
                oneteam.inline_result()
                :type('article')
                :id(tostring(k))
                :title(v:match('^(/.-) %- .-$'))
                :description(v:match('^/.- %- (.-)$'))
                :input_message_content(
                    oneteam.input_text_message_content(
                        string.format(
                            '• %s - %s\n\nTo use this command inline, you must use the syntax:\n@%s %s',
                            v:match('^(/.-) %- .-$'),
                            v:match('^/.- %- (.-)$'),
                            username,
                            v:match('^(/.-) %- .-$')
                        )
                    )
                )
                :reply_markup(
                    oneteam.inline_keyboard():row(
                        oneteam.row():switch_inline_query_button('Show me how!', v:match('^(/.-) '))
                    )
                )
            )
        end
    end
    return inline_list
end

function oneteam:get_help(is_administrative, chat_id)
    local list_to_use = is_administrative == true and administrative_plugin_list or plugin_list
    local help = {}
    local count = 1
    table.sort(list_to_use)
    for _, v in pairs(list_to_use) do
        if v:match('^/.- %- .-$') then
            -- Do some replacement for plugins that have different primary commands to their plugin name.
            local to_match = v:gsub('/np', '/lastfm'):gsub('/r/', '/reddit '):gsub('/s/', '/sed '):gsub('(/cat)', '%1s')
            local plugin = to_match:match('^/([%w_]+) .-$')
            if not chat_id or not oneteam.is_plugin_disabled(self, plugin, chat_id) then
                local command, description = v:match('^(.-) %- (.-)$')
                local parameters = ' '
                if not command then oneteam.send_message(configuration.admins[1], v) end
                if command:match(' [%[<]') then
                    command, parameters = command:match('^(.-)( .-)$')
                    parameters = '<code>' .. oneteam.escape_html(parameters) .. '</code> '
                end
                local output = command .. parameters .. '- <em>' .. oneteam.escape_html(description) .. '</em>'
                table.insert(help, utf8.char(8226) .. ' ' .. output)
                count = count + 1
            end
        end
    end
    return help
end

function oneteam.format_time(seconds)
    if not seconds or tonumber(seconds) == nil then
        return false
    end
    seconds = tonumber(seconds) -- Make sure we're handling a numerical value
    local minutes = math.floor(seconds / 60)
    if minutes == 0 then
        return seconds ~= 1 and seconds .. ' seconds' or seconds .. ' second'
    elseif minutes < 60 then
        return minutes ~= 1 and minutes .. ' minutes' or minutes .. ' minute'
    end
    local hours = math.floor(seconds / 3600)
    if hours == 0 then
        return minutes ~= 1 and minutes .. ' minutes' or minutes .. ' minute'
    elseif hours < 24 then
        return hours ~= 1 and hours .. ' hours' or hours .. ' hour'
    end
    local days = math.floor(seconds / 86400)
    if days == 0 then
        return hours ~= 1 and hours .. ' hours' or hours .. ' hour'
    elseif days < 7 then
        return days ~= 1 and days .. ' days' or days .. ' day'
    end
    local weeks = math.floor(seconds / 604800)
    if weeks == 0 then
        return days ~= 1 and days .. ' days' or days .. ' day'
    else
        return weeks ~= 1 and weeks .. ' weeks' or weeks .. ' week'
    end
end

function oneteam.does_language_exist(language)
    return pcall( -- nice and simple, perform a pcall to require the language, and if it errors then it doesn't exist
        function()
            return require('languages.' .. language)
        end
    )
end

function oneteam.save_to_file(content, file_path)
    if not content then
        return false
    end
    file_path = file_path or ('/tmp/temp_' .. os.time() .. '.txt')
    local file = io.open(file_path, 'w+')
    file:write(tostring(content))
    file:close()
    return true
end

function oneteam.insert_keyboard_row(keyboard, first_text, first_callback, second_text, second_callback, third_text, third_callback)
-- todo: get rid of this function as it's dirty, who only allows 3 buttons in a row??
    table.insert(
        keyboard['inline_keyboard'],
        {
            {
                ['text'] = first_text,
                ['callback_data'] = first_callback
            },
            {
                ['text'] = second_text,
                ['callback_data'] = second_callback
            },
            {
                ['text'] = third_text,
                ['callback_data'] = third_callback
            }
        }
    )
    return keyboard
end

function oneteam.is_user_blocklisted(message)
    if not message or not message.from or not message.chat then
        return false, false, false
    elseif oneteam.is_global_admin(message.from.id) then
        return false, false, false
    end
    local gbanned = redis:get('global_ban:' .. message.from.id) -- Check if the user is globally
    -- blocklisted from using the bot.
    local group = redis:get('group_blocklist:' .. message.chat.id .. ':' .. message.from.id) -- Check
    -- if the user is blocklisted from using the bot in the current group.
    local gblocklisted = redis:get('global_blocklist:' .. message.from.id)
    return group, gblocklisted, gbanned
end

function oneteam.is_spamwatch_blocklisted(message, force_check)
    if tonumber(message) ~= nil then -- Add support for passing just the user ID too!
        message = {
            ['from'] = {
                ['id'] = tonumber(message)
            }
        }
    elseif not message or not message.from then
        return false, nil, 'No valid message object was passed! It needs to have a message.from as well!', 404
    end
    local is_cached = redis:get('not_blocklisted:' .. message.from.id)
    if is_cached and not force_check then -- We don't want to perform an HTTPS call every time the bot sees a chat!
        return false, nil, 'That user is cached as not blocklisted!', 404
    end
    local response = {}
    local _ = https.request(
        {
            ['url'] = 'https://api.spamwat.ch/banlist/' .. message.from.id,
            ['method'] = 'GET',
            ['headers'] = {
                ['Authorization'] = 'Bearer ' .. configuration.keys.spamwatch
            },
            ['sink'] = ltn12.sink.table(response)
        }
    )
    response = table.concat(response)
    local jdat = json.decode(response)
    if not jdat then
        return false, nil, 'The server appears to be offline', 521
    elseif jdat.error then
        if jdat.code == 404 then -- The API returns a 404 code when the user isn't in the SpamWatch database
            redis:set('not_blocklisted:' .. message.from.id, true)
            redis:expire('not_blocklisted:' .. message.from.id, 604800) -- Let the key last a week!
        end
        return false, jdat, jdat.error, jdat.code
    elseif jdat.id then
        return true, jdat, 'Success', 200
    end
    return false, jdat, 'Error!', jdat.code or 404
end

function oneteam:process_afk(message) -- Checks if the message references an AFK user and tells the
-- person mentioning them that they are marked AFK. If a user speaks and is currently marked as AFK,
-- then the bot will announce their return along with how long they were gone for.
    if message.from.username
    and redis:hget('afk:' .. message.from.id, 'since')
    and not oneteam.is_plugin_disabled(self, 'afk', message)
    and not message.text:match('^[/!#]afk')
    and not message.text:lower():match('^i?\'?l?l? ?[bg][rt][bg].?$')
    then
        local since = os.time() - tonumber(redis:hget('afk:' .. message.from.id, 'since'))
        redis:hdel('afk:' .. message.from.id, 'since')
        redis:hdel('afk:' .. message.from.id, 'note')
        local keys = redis:keys('afk:' .. message.from.id .. ':replied:*')
        if #keys > 0 then
            for _, key in pairs(keys) do
                redis:del(key)
            end
        end
        local output = message.from.first_name .. ' has returned, after being /AFK for ' .. oneteam.format_time(since) .. '.'
        oneteam.send_message(message.chat.id, output)
    elseif (message.text:match('@[%w_]+') -- If a user gets mentioned, check to see if they're AFK.
    or message.reply) and not redis:get('afk:' .. message.from.id .. ':replied:' .. message.chat.id) then
        local username = message.reply and message.reply.from.id or message.text:match('@([%w_]+)')
        local success = oneteam.get_user(username)
        if not success or not success.result or not success.result.id then
            return false
        end
        local exists = redis:hexists('afk:' .. success.result.id, 'since')
        if success and success.result and exists then -- If all the checks are positive, the mentioned user is AFK, so we'll tell the person mentioning them that this is the case!
            if message.reply then
                redis:set('afk:' .. message.from.id .. ':replied:' .. message.chat.id, true)
            end
            local output = success.result.first_name .. ' is currently AFK!'
            local note = redis:hget('afk:' .. message.from.id, 'note')
            if note then
                output = output .. '\nNote: ' .. note
            end
            oneteam.send_reply(message, output)
        end
    end
end

function oneteam.process_stickers(message)
    if message.chat.type == 'supergroup' and message.sticker then
        -- Process each sticker to see if they are one of the configured, command-performing stickers.
        for _, v in pairs(configuration.stickers.ban) do
            if message.sticker.file_unique_id == v then
                message.text = '/ban'
            end
        end
        for _, v in pairs(configuration.stickers.warn) do
            if message.sticker.file_unique_id == v then
                message.text = '/warn'
            end
        end
        for _, v in pairs(configuration.stickers.kick) do
            if message.sticker.file_unique_id == v then
                message.text = '/kick'
            end
        end
    end
    return message
end

function oneteam:process_natural_language(message)
    local text = message.text:lower()
    local name = self.info.first_name:lower()
    if text:match(name .. '.- ban @?[%w_-]+ ?') then
        message.text = '/ban ' .. text:match(name .. '.- ban (@?[%w_-]+) ?')
    elseif text:match(name .. '.- warn @?[%w_-]+ ?') then
        message.text = '/warn ' .. text:match(name .. '.- warn (@?[%w_-]+) ?')
    elseif text:match(name .. '.- kick @?[%w_-]+ ?') then
        message.text = '/kick ' .. text:match(name .. '.- kick (@?[%w_-]+) ?')
    elseif text:match(name .. '.- unban @?[%w_-]+ ?') then
        message.text = '/unban ' .. text:match(name .. '.- unban (@?[%w_-]+) ?')
    elseif text:match(name .. '.- resume my music') then
        local myspotify = require('plugins.myspotify')
        local success = myspotify.reauthorise_account(message.from.id, configuration)
        local output = success and myspotify.play(message.from.id) or 'An error occured whilst trying to connect to your Spotify account, are you sure you\'ve connected me to it?'
        oneteam.send_message(message.chat.id, output)
    end
    message.is_natural_language = true
    return message
end

function oneteam.process_spam(message)
    if message.forward_from then return false end
    local msg_count = tonumber(
        redis:get('antispam:' .. message.chat.id .. ':' .. message.from.id) -- Check to see if the user
        -- has already sent 1 or more messages to the current chat, in the past 5 seconds.
    )
    or 1 -- If this is the first time the user has posted in the past 5 seconds, we'll make it 1 accordingly.
    redis:setex(
        'antispam:' .. message.chat.id .. ':' .. message.from.id,
        configuration.administration.global_antispam.ttl, -- set the TTL
        msg_count + 1 -- Increase the current message count by 1.
    )
    if msg_count == configuration.administration.global_antispam.message_warning_amount -- If the user has sent x messages in the past y seconds, send them a warning.
    -- and not oneteam.is_global_admin(message.from.id)
    and message.chat.type == 'private' then
    -- Don't run the antispam plugin if the user is configured as a global admin in `configuration.lua`.
        oneteam.send_reply( -- Send a warning message to the user who is at risk of being blocklisted for sending
        -- too many messages.
            message,
            string.format(
                'Hey %s, please don\'t send that many messages, or you\'ll be forbidden to use me for 24 hours!',
                message.from.username and '@' .. message.from.username or message.from.name
            )
        )
    elseif msg_count == configuration.administration.global_antispam.message_blocklist_amount -- If the user has sent x messages in the past y seconds, blocklist them globally from
    -- using the bot for 24 hours.
    -- and not oneteam.is_global_admin(message.from.id) -- Don't blocklist the user if they are configured as a global
    -- admin in `configuration.lua`.
    then
        redis:set('global_blocklist:' .. message.from.id, true)
        if configuration.administration.global_antispam.blocklist_length ~= -1 and configuration.administration.global_antispam.blocklist_length ~= 'forever' then
            redis:expire('global_blocklist:' .. message.from.id, configuration.administration.global_antispam.blocklist_length)
        end
        return oneteam.send_reply(
            message,
            string.format(
                'Sorry, %s, but you have been blocklisted from using me for the next 24 hours because you have been spamming!',
                message.from.username and '@' .. message.from.username or message.from.name
            )
        )
    end
    return false
end

function oneteam:process_language(message)
    if message.from.language_code then
        if not oneteam.does_language_exist(message.from.language_code) then
            if not redis:sismember('oneteam:missing_languages', message.from.language_code) then -- If we haven't stored the missing language file, add it into the database.
                redis:sadd('oneteam:missing_languages', message.from.language_code)
            end
            if (message.text == '/start' or message.text == '/start@' .. self.info.username) and message.chat.type == 'private' then
               
            end
        elseif redis:sismember('oneteam:missing_languages', message.from.language_code) then
        -- If the language file is found, yet it's recorded as missing in the database, it's probably
        -- new, so it is deleted from the database to prevent confusion when processing this list!
            redis:srem('oneteam:missing_languages', message.from.language_code)
        end
    end
end

function oneteam.process_deeplinks(message)
    if message.text:match('^/[%a_]+_%-%d+$') and message.chat.type == 'private' then
        message.text = message.text:gsub('^(/[%a_]+)_(.-)$', '%1 %2')
    end
    return message
end

function oneteam.toggle_setting(chat_id, setting, value)
    value = (type(value) ~= 'string' and tostring(value) ~= 'nil') and value or true
    if not chat_id or not setting then
        return false
    elseif not redis:hexists('chat:' .. chat_id .. ':settings', tostring(setting)) then
        return redis:hset('chat:' .. chat_id .. ':settings', tostring(setting), value)
    end
    return redis:hdel('chat:' .. chat_id .. ':settings', tostring(setting))
end

function oneteam.get_usernames(user_id)
    if not user_id then
        return false
    elseif tonumber(user_id) == nil then
        user_id = tostring(user_id):match('^@(.-)$') or tostring(user_id)
        user_id = redis:get('username:' .. user_id:lower())
        if not user_id then
            return false
        end
    end
    return redis:smembers('user:' .. user_id .. ':usernames')
end

function oneteam.check_links(message, get_links, only_valid, allowlist, return_message, delete)
    message.is_invite_link = false
    message.is_valid_invite_link = false
    local links = {}
    if message.entities then
        for i = 1, #message.entities do
            if message.entities[i].type == 'text_link' then
                message.text = message.text .. ' ' .. message.entities[i].url
            end
        end
    end
    for n in message.text:gmatch('%@[%w_]+') do
        table.insert(links, n:match('^%@([%w_]+)$'))
    end
    for n in message.text:gmatch('[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/[%w_]+') do
        table.insert(links, n:match('/([Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/[%w_]+)$'))
    end
    for n in message.text:gmatch('[Tt]%.[Mm][Ee]/[%w_]+') do
        if not n:match('/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]$') then
            table.insert(links, n:match('/([%w_]+)$'))
        end
    end
    for n in message.text:gmatch('[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/[%w_]+') do
        table.insert(links, n:match('/([Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/[%w_]+)$'))
    end
    for n in message.text:gmatch('[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[%w_]+') do
        if not n:match('/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]$') then
            table.insert(links, n:match('/([%w_]+)$'))
        end
    end
    for n in message.text:gmatch('[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/[%w_]+') do
        table.insert(links, n:match('/([Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/[%w_]+)$'))
    end
    for n in message.text:gmatch('[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[%w_]+') do
        if not n:match('/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]$') then
            table.insert(links, n:match('/([%w_]+)$'))
        end
    end
    for n in message.text:gmatch('[Tt][Gg]://[Jj][Oo][Ii][Nn]%?[Ii][Nn][Vv][Ii][Tt][Ee]=[%w_]+') do
        table.insert(links, '[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/' .. n:match('=([%w_]+)$'))
    end
    for n in message.text:gmatch('[Tt][Gg]://[Rr][Ee][Ss][Oo][Ll][Vv][Ee]%?[Dd][Oo][Mm][Aa][Ii][Nn]=[%w_]+') do
        table.insert(links, n:match('=([%w_]+)$'))
    end
    if allowlist then
        local count = 0
        for _, v in pairs(links) do
            v = v:match('^[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]') and v or v:lower()
            if delete then
                redis:del('allowlisted_links:' .. message.chat.id .. ':' .. v)
            else
                redis:set('allowlisted_links:' .. message.chat.id .. ':' .. v, true)
            end
            count = count + 1
        end
        return string.format(
            '%s link%s ha%s been %s in this chat!',
            count,
            count == 1 and '' or 's',
            count == 1 and 's' or 've',
            delete and 'blocklisted' or 'allowlisted'
        )
    end
    local checked = {}
    local valid = {}
    for _, v in pairs(links) do
        if not oneteam.is_allowlisted_link(v:lower(), message.chat.id) then
            if v:match('^[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/') then
                message.is_invite_link = true
                if only_valid then
                    local str, res = https.request('https://t.me/' .. v)
                    if res == 200 and str and str:match('tgme_page_title') then
                        table.insert(valid, v)
                        message.is_valid_invite_link = true
                    end
                end
                if not get_links then
                    return return_message and message or true
                end
            elseif not oneteam.table_contains(checked, v:lower()) then
                if not oneteam.get_user(v:lower()) then
                    local success = oneteam.get_chat('@' .. v:lower(), true)
                    if success and success.result and success.result.type ~= 'private' and success.result.id ~= message.chat.id then
                        message.is_invite_link = true
                        if not get_links then
                            return return_message and message or true
                        end
                        table.insert(valid, v:lower())
                    end
                    table.insert(checked, v:lower())
                end
            end
        end
    end
    if get_links then
        if only_valid then
            return valid
        end
        return checked
    end
    return return_message and message or false
end

function oneteam:process_message(message)
    if not message.chat then
        return true
    end
    if message.chat and message.chat.type ~= 'private' and not oneteam.service_message(message) and not oneteam.is_plugin_disabled(self, 'statistics', message) and not oneteam.is_privacy_enabled(message.from.id) and not self.is_blocklisted then
        redis:incr('messages:' .. message.from.id .. ':' .. message.chat.id)
    end
    if message.new_chat_members and oneteam.get_setting(message.chat.id, 'use administration') and oneteam.get_setting(message.chat.id, 'antibot') and not oneteam.is_group_admin(message.chat.id, message.from.id) and not oneteam.is_global_admin(message.from.id) then
        local kicked = {}
        local usernames = {}
        for _, v in pairs(message.new_chat_members) do
            if v.username and v.username:lower():match('bot$') and v.id ~= message.from.id and v.id ~= self.info.id and tostring(v.is_bot) == 'true' then
                local success = oneteam.kick_chat_member(message.chat.id, v.id)
                if success then
                    table.insert(kicked, oneteam.escape_html(v.first_name) .. ' [' .. v.id .. ']')
                    table.insert(usernames, '@' .. v.username)
                end
            end
        end
        if #kicked > 0 and #usernames > 0 and #kicked == #usernames then
            local log_chat = oneteam.get_log_chat(message.chat.id)
            oneteam.send_message(log_chat, string.format('<pre>%s [%s] has kicked %s from %s [%s] because anti-bot is enabled.</pre>', oneteam.escape_html(self.info.first_name), self.info.id, table.concat(kicked, ', '), oneteam.escape_html(message.chat.title), message.chat.id), 'html')
            return oneteam.send_message(message, string.format('Kicked %s because anti-bot is enabled.', table.concat(usernames, ', ')))
        end
    end
end

function oneteam.process_nicknames(message)
    local nickname = redis:hget('user:' .. message.from.id .. ':info', 'nickname')
    if nickname then
        message.from.original_name = message.from.name
        message.from.has_nickname = true
        message.from.name = nickname
        message.from.first_name = nickname
        message.from.last_name = nil
    else
        message.from.has_nickname = false
    end
    if message.reply then
        nickname = redis:hget('user:' .. message.reply.from.id .. ':info', 'nickname')
        if nickname then
            message.reply.from.original_name = message.reply.from.name
            message.reply.from.has_nickname = true
            message.reply.from.name = nickname
            message.reply.from.first_name = nickname
            message.reply.from.last_name = nil
        else
            message.reply.from.has_nickname = false
        end
    end
    return message
end

return oneteam
