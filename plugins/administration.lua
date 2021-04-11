local administration = {}
local oneteam = require('oneteam')
local json = require('dkjson')
local redis = dofile('libs/redis.lua')
local configuration = require('configuration')

function administration:init()
    administration.commands = oneteam.commands(self.info.username)
    :command('administration')
    :command('admins')
    :command('staff')
    :command('trusted')
    :command('muted')
    :command('links')
    :command('whitelistlink')
    :command('whitelistlinks')
    :command('config').table
end

function administration.get_initial_keyboard(chat_id, page)
    if not oneteam.get_setting(chat_id, 'use administration') then
        return oneteam.inline_keyboard():row(oneteam.row():callback_data_button('Enable Administration', 'administration:' .. chat_id .. ':toggle'))
    end
    if not page or tonumber(page) <= 1 then
        return oneteam.inline_keyboard()
        :row(oneteam.row():callback_data_button('Disable Administration', 'administration:' .. chat_id .. ':toggle'))
        :row(
            oneteam.row()
            :callback_data_button('Anti-Spam Settings', 'antispam:' .. chat_id)
            :callback_data_button('Warning Settings', 'administration:' .. chat_id .. ':warnings')
        )
        :row(oneteam.row():callback_data_button('Vote-Ban Settings', 'administration:' .. chat_id .. ':voteban'))
        :row(
            oneteam.row()
            :callback_data_button('Welcome New Users?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'welcome message') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':welcome_message:1'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Send Rules On Join?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'send rules on join') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':rules_on_join:1'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Send Rules In Group?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'send rules in group') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':rules_in_group:1'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Next', 'administration:' .. chat_id .. ':page:2')
        )
        :row(
            oneteam.row()
            :callback_data_button('Exit', 'help:settings:'..chat_id)
        )
    elseif tonumber(page) == 2 then
        return oneteam.inline_keyboard()
        :row(
            oneteam.row()
            :callback_data_button('Word Filter', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'word filter') and 'On' or 'Off',
                'administration:' .. chat_id .. ':word_filter:2'
            )
        )
        --[[ :row(
            oneteam.row()
            :callback_data_button('Anti-Porn', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'anti porn') and 'On' or 'Off',
                'administration:' .. chat_id .. ':anti_porn:2'
            )
        ) ]]
        :row(
            oneteam.row()
            :callback_data_button('Anti-Bot', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'antibot') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':antibot:2'
            )
            :callback_data_button('Anti-Link', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'antilink') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':antilink:2'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Log Actions?', 'administration:' .. chat_id .. ':log:keyboard')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'log administrative actions') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':log:toggle'
            )
            :callback_data_button('Anti-RTL', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'antirtl') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':rtl:2'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Anti-Spam Action', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'ban not kick') and 'Ban' or 'Kick',
                'administration:' .. chat_id .. ':action:2'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Delete Commands?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'delete commands') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':delete_commands:2'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Force Group Language?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'force group language') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':force_group_language:2'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Require Capcha', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'require captcha') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':require_captcha:2'
            ))
        :row(
            oneteam.row()
            :callback_data_button('Back', 'administration:' .. chat_id .. ':page:1')
            :callback_data_button('Next', 'administration:' .. chat_id .. ':page:3')
        )
        :row(
            oneteam.row()
            :callback_data_button('Exit', 'help:settings:'..chat_id)
        )
    elseif tonumber(page) >= 3
    then
        return oneteam.inline_keyboard()
        :row(
            oneteam.row()
            :callback_data_button('Send Settings In Group?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'settings in group') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':settings_in_group:3'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Delete Reply On Action?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'delete reply on action') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':delete_reply_on_action:3'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Notify Admins on Actions?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'notify admins actions') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':notify_admins_actions:3'
            )
        )
        :row(oneteam.row():callback_data_button('Trusted Users Permissions', 'administration:' .. chat_id .. ':trusted_permissions'))
        :row(
            oneteam.row()
            :callback_data_button('Delete JoinGroup Messages?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'delete joingroup messages') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':delete_joingroup_messages:3'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Delete LeftGroup Messages?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'delete leftgroup messages') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':delete_leftgroup_messages:3'
            )
        )
        :row(
            oneteam.row()
            :callback_data_button('Apply Global Blacklist?', 'administration:nil')
            :callback_data_button(
                oneteam.get_setting(chat_id, 'apply global blacklist') and utf8.char(9989) or utf8.char(10060),
                'administration:' .. chat_id .. ':apply_global_blacklist:3'
            )
        )
        :row(oneteam.row():callback_data_button('Back', 'administration:' .. chat_id .. ':page:2'))
        :row(
            oneteam.row()
            :callback_data_button('Exit', 'help:settings:'..chat_id)
        )
    end
    return false
end

function administration.get_warnings(chat_id)
    local keyboard = {
        ['inline_keyboard'] = {}
    }
    local current = redis:hget(
        string.format(
            'chat:%s:settings',
            chat_id
        ),
        'max warnings'
    ) or 3
    local ban_kick_status = administration.get_hash_status(
        chat_id,
        'ban_kick'
    )
    local action = 'ban'
    if not ban_kick_status then
        action = 'kick'
    end
    local lower = tonumber(current) - 1
    local higher = tonumber(current) + 1
    table.insert(
        keyboard.inline_keyboard,
        {
            {
                ['text'] = string.format(
                    'Number of warnings until %s:',
                    action
                ),
                ['callback_data'] = 'administration:nil'
            }
        }
    )
    oneteam.insert_keyboard_row(
        keyboard,
        '-',
        'administration:' .. chat_id .. ':max_warnings:' .. lower,
        tostring(current),
        'administration:nil',
        '+',
        'administration:' .. chat_id .. ':max_warnings:' .. higher
    )
    table.insert(
        keyboard.inline_keyboard,
        {
            {
                ['text'] = 'Back',
                ['callback_data'] = 'administration:' .. chat_id .. ':back'
            }
        }
    )
    return keyboard
end

function administration.get_voteban_keyboard(chat_id)
    local keyboard = {
        ['inline_keyboard'] = {}
    }
    local current_required_upvotes = redis:hget(
        string.format(
            'chat:%s:settings',
            chat_id
        ),
        'required upvotes for vote bans'
    ) or 5
    local current_required_downvotes = redis:hget(
        string.format(
            'chat:%s:settings',
            chat_id
        ),
        'required downvotes for vote bans'
    ) or 5
    table.insert(
        keyboard.inline_keyboard,
        {
            {
                ['text'] = 'Upvotes needed to ban:',
                ['callback_data'] = 'administration:nil'
            }
        }
    )
    oneteam.insert_keyboard_row(
        keyboard,
        '-',
        'administration:' .. chat_id .. ':voteban_upvotes:' .. tonumber(current_required_upvotes) - 1,
        tostring(current_required_upvotes),
        'administration:nil',
        '+',
        'administration:' .. chat_id .. ':voteban_upvotes:' .. tonumber(current_required_upvotes) + 1
    )
    table.insert(
        keyboard.inline_keyboard,
        {
            {
                ['text'] = 'Downvotes needed to dismiss:',
                ['callback_data'] = 'administration:nil'
            }
        }
    )
    oneteam.insert_keyboard_row(
        keyboard,
        '-',
        'administration:' .. chat_id .. ':voteban_downvotes:' .. tonumber(current_required_downvotes) - 1,
        tostring(current_required_downvotes),
        'administration:nil',
        '+',
        'administration:' .. chat_id .. ':voteban_downvotes:' .. tonumber(current_required_downvotes) + 1
    )
    table.insert(
        keyboard.inline_keyboard,
        {
            {
                ['text'] = 'Back',
                ['callback_data'] = 'administration:' .. chat_id .. ':page:1'
            }
        }
    )
    return keyboard
end

function administration.get_trusted_permissions(chat_id)
    local keyboard = {
        ['inline_keyboard'] = {}
    }
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'AntiSpam Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions antispam') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:antispam'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Warnings Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions warnings') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:warnings'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Vote-Ban Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions voteban') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:voteban'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'WordFilter Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions wordfilter') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:wordfilter'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'AntiBot Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions antibot') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:antibot'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'AntiLink Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions antilink') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:antilink'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Anti-RTL Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions antirtl') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:antirtl'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'NSFW Filter Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions nsfw') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:nsfw'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'MuteAll Immune:', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'trusted permissions muteall') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':trusted_toggle:muteall'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Back', ['callback_data'] = 'administration:' .. chat_id .. ':page:3'}
    })
    return keyboard
end

function administration.get_logchat_settings(chat_id)
    if not oneteam.get_setting(chat_id, 'log administrative actions') then
        return oneteam.inline_keyboard():row(oneteam.row():callback_data_button('Enable LogChat', 'administration:' .. chat_id .. ':log:toggle'))
    end
    local keyboard = {
        ['inline_keyboard'] = {}
    }
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Disable LogChat', ['callback_data'] = 'administration:' .. chat_id .. ':log:toggle'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Join Group', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log joingroup') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:joingroup'},
        {['text'] = 'Left Group', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log leftgroup') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:leftgroup'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Promote User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log promote') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:promote'},
        {['text'] = 'Demote User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log demote') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:demote'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Blacklist User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log blacklist') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:blacklist'},
        {['text'] = 'Whitelist User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log whitelist') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:whitelist'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Warned User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log warn') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:warn'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Kicked User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log kick') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:kick'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Banned User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log ban') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:ban'},
        {['text'] = 'Unbanned User', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log unban') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:unban'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Trust Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log trust') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:trust'},
        {['text'] = 'Untrust Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log untrust') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:untrust'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Mute Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log mute') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:mute'},
        {['text'] = 'Unmute Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log unmute') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:unmute'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Antispam Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log antispam') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:antispam'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'WordFilter Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log wordfilter') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:wordfilter'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'AntiBot Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log antibot') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:antibot'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'AntiLink Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log antilink') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:antilink'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'AntiRTL Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log antirtl') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:antirtl'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'NSFW Trigger', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log nsfw') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:nsfw'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Muteall Group', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log muteall') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:muteall'},
        {['text'] = 'Unmuteall Group', ['callback_data'] = 'administration:nil'},
        {['text'] = oneteam.get_setting(chat_id, 'log unmuteall') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:' .. chat_id .. ':log:unmuteall'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = "Enable All", ['callback_data'] = 'administration:' .. chat_id .. ':log:all'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = "Disable All", ['callback_data'] = 'administration:' .. chat_id .. ':log:none'}
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Back', ['callback_data'] = 'administration:' .. chat_id .. ':page:2'}
    })
    return keyboard
end

function administration.get_nsfw_keyboard(chat_id)
    local keyboard = {
        ['inline_keyboard'] = {}
    }
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Not Safe For Work', ['callback_data'] = 'administration:'..chat_id..':nsfw:help_general'},
    })
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Filter Enabled?', ['callback_data'] = 'administration:'..chat_id..':nsfw:help'},
        {['text'] = oneteam.get_setting(chat_id, 'nsfw enabled') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:'..chat_id..':nsfw:toggle'},
    })
    if oneteam.get_setting(chat_id, 'nsfw enabled') then
        table.insert(keyboard.inline_keyboard, {
            {['text'] = '-', ['callback_data'] = 'administration:'..chat_id..':nsfw:' .. math.floor((oneteam.get_setting(chat_id, 'nsfw limit') or 80)-10)},
            {['text'] = (oneteam.get_setting(chat_id, 'nsfw limit') or 80).."%", ['callback_data'] = 'administration:' .. chat_id .. ':nsfw:help'},
            {['text'] = '+', ['callback_data'] = 'administration:'..chat_id..':nsfw:' .. math.floor((oneteam.get_setting(chat_id, 'nsfw limit') or 80)+10)}
        })
        table.insert(keyboard.inline_keyboard, {
            {['text'] = 'Detect Images', ['callback_data'] = 'administration:'..chat_id..':nsfw:help'},
            {['text'] = oneteam.get_setting(chat_id, 'nsfw images') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:'..chat_id..':nsfw:images'}
        })
        table.insert(keyboard.inline_keyboard, {
            {['text'] = 'Detect Stickers', ['callback_data'] = 'administration:'..chat_id..':nsfw:help'},
            {['text'] = oneteam.get_setting(chat_id, 'nsfw stickers') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:'..chat_id..':nsfw:stickers'}
        })
        table.insert(keyboard.inline_keyboard, {
            {['text'] = 'Detect GIFs', ['callback_data'] = 'administration:'..chat_id..':nsfw:help'},
            {['text'] = (oneteam.get_setting(chat_id, 'nsfw type gifs') or "avg"):gsub("^%l", string.upper), ['callback_data'] = 'administration:'..chat_id..':nsfw:type_gifs'},
            {['text'] = oneteam.get_setting(chat_id, 'nsfw gifs') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:'..chat_id..':nsfw:gifs'}
        })
        table.insert(keyboard.inline_keyboard, {
            {['text'] = 'Detect Videos', ['callback_data'] = 'administration:'..chat_id..':nsfw:help'},
            {['text'] = (oneteam.get_setting(chat_id, 'nsfw type videos') or "avg"):gsub("^%l", string.upper), ['callback_data'] = 'administration:'..chat_id..':nsfw:type_videos'},
            {['text'] = oneteam.get_setting(chat_id, 'nsfw videos') and utf8.char(9989) or utf8.char(10060), ['callback_data'] = 'administration:'..chat_id..':nsfw:videos'}
        })
        table.insert(keyboard.inline_keyboard, {
            {['text'] = 'Delete NSFW Images?', ['callback_data'] = 'administration:'..chat_id..':nsfw:help_delete'},
            {['text'] = oneteam.get_setting(chat_id, 'nsfw delete') and "🗑"..utf8.char(9989) or "🗑"..utf8.char(10060), ['callback_data'] = 'administration:'..chat_id..':nsfw:delete'}
        })
    end
    table.insert(keyboard.inline_keyboard, {
        {['text'] = 'Back', ['callback_data'] = 'administration:' .. chat_id .. ':page:2'}
    })
    return keyboard
end

function administration.get_hash_status(chat_id, hash_type)
    if redis:get('administration:' .. chat_id .. ':' .. hash_type)
    then
        return true
    end
    return false
end

function administration.warn(message)
    if not oneteam.is_group_admin(
        message.chat.id,
        message.from.id
    ) then
        return oneteam.send_reply(
            message,
            'You must be an administrator to use this command!'
        )
    elseif not message.reply then
        return oneteam.send_reply(
            message,
            'You must use this command via reply to the targeted user\'s message.'
        )
    elseif oneteam.is_group_admin(
        message.chat.id,
        message.reply.from.id
    ) then
        return oneteam.send_reply(
            message,
            'The targeted user is an administrator in this chat.'
        )
    end
    local name = message.reply.from.first_name
    local hash = 'chat:' .. message.chat.id .. ':warnings'
    local amount = redis:hincrby(
        hash,
        message.reply.from.id,
        1
    )
    local maximum = redis:get(
        string.format(
            'administration:%s:max_warnings',
            message.chat.id
        )
    ) or 3
    local text, res
    amount, maximum = tonumber(amount), tonumber(maximum)
    if amount >= maximum then
        text = message.reply.from.first_name .. ' was banned for reaching the maximum number of allowed warnings (' .. maximum .. ').'
        local success = oneteam.ban_chat_member(
            message.chat.id,
            message.reply.from.id
        )
        if not success then
            return oneteam.send_reply(
                message,
                'I couldn\'t ban that user. Please ensure that I\'m an administrator and that the targeted user isn\'t.'
            )
        end
        redis:hdel(
            'chat:' .. message.chat.id .. ':warnings',
            message.reply.from.id
        )
        return oneteam.send_reply(
            message,
            text
        )
    end
    local difference = maximum - amount
    text = '*%s* has been warned `[%d/%d]`'
    local reason = oneteam.input(message.text)
    if reason then
        text = text .. '\n*Reason:* ' .. oneteam.escape_markdown(reason)
    end
    text = text:format(
        oneteam.escape_markdown(name),
        amount,
        maximum
    )
    local keyboard = json.encode(
        {
            ['inline_keyboard'] = {
                {
                    {
                        ['text'] = 'Reset Warnings',
                        ['callback_data'] = string.format(
                            'administration:warn:reset:%s:%s',
                            message.chat.id,
                            message.reply.from.id
                        )
                    },
                    {
                        ['text'] = 'Remove 1 Warning',
                        ['callback_data'] = string.format(
                            'administration:warn:remove:%s:%s',
                            message.chat.id,
                            message.reply.from.id
                        )
                    }
                }
            }
        }
    )
    return oneteam.send_reply(
        message,
        text,
        'markdown',
        true,
        false,
        nil,
        keyboard
    )
end

function administration:on_callback_query(callback_query, message, configuration)
    if callback_query.data == 'nil'
    then
        return oneteam.answer_callback_query(callback_query.id)
    elseif not oneteam.is_group_admin(
        callback_query.data:match('^(%-%d+)'),
        callback_query.from.id
    )
    then
        return oneteam.answer_callback_query(
            callback_query.id,
            'You\'re not an administrator in that chat!'
        )
    end
    local keyboard
    if callback_query.data:match('^%-%d+:voteban$')
    then
        keyboard = administration.get_voteban_keyboard(
            callback_query.data:match('^(%-%d+):voteban$')
        )
    elseif callback_query.data:match('^%-%d+:trusted_permissions$')
    then
        keyboard = administration.get_trusted_permissions(
            callback_query.data:match('^(%-%d+):trusted_permissions$')
        )
    elseif callback_query.data:match('^%-%d+:voteban_upvotes:.-$')
    then
        local chat_id, required_upvotes = callback_query.data:match('^(%-%d+):voteban_upvotes:(.-)$')
        if tonumber(required_upvotes) < configuration.voteban.upvotes.minimum
        then
            return oneteam.answer_callback_query(
                callback_query.id,
                'The minimum number of upvotes required for a vote-ban is 2.'
            )
        elseif tonumber(required_upvotes) > configuration.voteban.upvotes.maximum
        then
            return oneteam.answer_callback_query(
                callback_query.id,
                'The maximum number of upvotes required for a vote-ban is 20.'
            )
        elseif tonumber(required_upvotes) == nil
        then
            return
        end
        redis:hset(
            'chat:' .. chat_id .. ':settings',
            'required upvotes for vote bans',
            tonumber(required_upvotes)
        )
        keyboard = administration.get_voteban_keyboard(chat_id)
    elseif callback_query.data:match('^%-%d+:voteban_downvotes:.-$')
    then
        local chat_id, required_downvotes = callback_query.data:match('^(%-%d+):voteban_downvotes:(.-)$')
        if tonumber(required_downvotes) < configuration.voteban.downvotes.minimum
        then
            return oneteam.answer_callback_query(
                callback_query.id,
                'The minimum number of downvotes required for a vote-ban is 2.'
            )
        elseif tonumber(required_downvotes) > configuration.voteban.downvotes.maximum
        then
            return oneteam.answer_callback_query(
                callback_query.id,
                'The maximum number of downvotes required for a vote-ban is 20.'
            )
        elseif tonumber(required_downvotes) == nil
        then
            return
        end
        redis:hset(
            'chat:' .. chat_id .. ':settings',
            'required downvotes for vote bans',
            tonumber(required_downvotes)
        )
        keyboard = administration.get_voteban_keyboard(chat_id)
    elseif callback_query.data:match('^%-%d+:warnings$')
    then
        local chat_id = callback_query.data:match('^(%-%d+):warnings$')
        keyboard = administration.get_warnings(chat_id)
    elseif callback_query.data:match('^%-%d+:max_warnings:.-$')
    then
        local chat_id, max_warnings = callback_query.data:match('^(%-%d+):max_warnings:(.-)$')
        if tonumber(max_warnings) > configuration.administration.warnings.maximum
        then
            return oneteam.answer_callback_query(
                callback_query.id,
                'The maximum number of warnings is 10.'
            )
        elseif tonumber(max_warnings) < configuration.administration.warnings.minimum
        then
            return oneteam.answer_callback_query(
                callback_query.id,
                'The minimum number of warnings is 2.'
            )
        elseif tonumber(max_warnings) == nil
        then
            return
        end
        redis:hset(
            'chat:' .. chat_id .. ':settings',
            'max warnings',
            tonumber(max_warnings)
        )
        keyboard = administration.get_warnings(chat_id)
    elseif callback_query.data:match('^%-%d+:back$')
    then
        local chat_id = callback_query.data:match('^(%-%d+):back$')
        keyboard = administration.get_initial_keyboard(chat_id)
    elseif callback_query.data:match('^%-%d+:toggle$')
    then
        local chat_id = callback_query.data:match('^(%-%d+):toggle$')
        oneteam.toggle_setting(
            chat_id,
            'use administration'
        )
        keyboard = administration.get_initial_keyboard(chat_id)
    elseif callback_query.data:match('^%-%d+:rtl:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):rtl:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'antirtl'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:rules_on_join:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):rules_on_join:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'send rules on join'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:rules_in_group:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):rules_in_group:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'send rules in group'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:notify_admins_actions:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):notify_admins_actions:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'notify admins actions'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:delete_joingroup_messages:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):delete_joingroup_messages:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'delete joingroup messages'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:delete_leftgroup_messages:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):delete_leftgroup_messages:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'delete leftgroup messages'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:apply_global_blacklist:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):apply_global_blacklist:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'apply global blacklist'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:word_filter:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):word_filter:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'word filter'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
        oneteam.answer_callback_query(
            callback_query.id,
            'You can add one or more words to the word filter by using /filter <word(s)>',
            true
        )
    --[[ elseif callback_query.data:match('^%-%d+:anti_porn:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):anti_porn:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'anti porn'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
        oneteam.answer_callback_query(
            callback_query.id,
            'Now I will punish any pornographic image',
            true
        ) ]]
    elseif callback_query.data:match('^%-%d+:inactive:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):inactive:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'remove inactive users'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:action:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):action:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'ban not kick'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:antibot:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):antibot:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'antibot'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:antilink:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):antilink:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'antilink'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:antispam:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):antispam:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'antispam'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:welcome_message:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):welcome_message:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'welcome message'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:delete_commands:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):delete_commands:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'delete commands'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:trusted_toggle:%a*$')
    then
        local chat_id, trusted_setting = callback_query.data:match('^(%-%d+):trusted_toggle:(%a*)$')
        oneteam.toggle_setting(
            chat_id,
            'trusted permissions '..trusted_setting
        )
        keyboard = administration.get_trusted_permissions(chat_id)
    elseif callback_query.data:match('^%-%d+:misc_responses:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):misc_responses:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'misc responses'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:force_group_language:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):force_group_language:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'force group language'
        )
        if page then
            keyboard = administration.get_initial_keyboard(chat_id, page)
        end
    elseif callback_query.data:match('^%-%d+:require_captcha:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):require_captcha:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'require captcha'
        )
        if page then
            keyboard = administration.get_initial_keyboard(chat_id, page)
        end
    elseif callback_query.data:match('^%-%d+:log:%a*$')
    then
        local chat_id, input = callback_query.data:match('^(%-%d+):log:(%a*)$')
        if input == "keyboard" then
            keyboard = administration.get_logchat_settings(chat_id)
        elseif input == "toggle" then
            oneteam.toggle_setting(chat_id, 'log administrative actions')
            if oneteam.get_setting(chat_id, 'log administrative actions') then
                oneteam.answer_callback_query(callback_query.id, 'You can change what to log at the logchat by hitting the Log Actions? button (I\'ve redirected you to the settings keyboard)', true)
                keyboard = administration.get_logchat_settings(chat_id)
            else
                keyboard = administration.get_initial_keyboard(chat_id, "2")
            end
          elseif input == "all" or input == "none" then
              local settings = {'joingroup', 'leftgroup', 'promote', 'demote', 'blacklist', 'whitelist', 'warn', 'kick', 'ban', 'unban', 'trust', 'untrust', 'mute', 'unmute', 'antispam', 'wordfilter', 'antibot', 'antilink', 'antirtl', 'muteall', 'unmuteall'}
              for k, v in pairs(settings) do
                  if input == "all" then
                      if not redis:hexists('chat:' .. chat_id .. ':settings', 'log '..v) then
                          redis:hset('chat:' .. chat_id .. ':settings', 'log '..v, true)
                      end
                  else
                    if redis:hexists('chat:' .. chat_id .. ':settings', 'log '..v) then
                        redis:hdel('chat:' .. chat_id .. ':settings', 'log '..v, true)
                    end
                  end
              end
              keyboard = administration.get_logchat_settings(chat_id)
          else
              oneteam.toggle_setting(chat_id, 'log '..input)
              keyboard = administration.get_logchat_settings(chat_id)
        end
    elseif callback_query.data:match('^%-%d+:settings_in_group:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):settings_in_group:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'settings in group'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:delete_reply_on_action:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):delete_reply_on_action:(%d*)$')
        oneteam.toggle_setting(
            chat_id,
            'delete reply on action'
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:enable_admins_only:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):enable_admins_only:(%d*)$')
        redis:set(
            string.format(
                'administration:%s:admins_only',
                chat_id
            ),
            true
        )
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:disable_admins_only:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):disable_admins_only:(%d*)$')
        redis:del('administration:' .. chat_id .. ':admins_only')
        keyboard = administration.get_initial_keyboard(chat_id, page)
    elseif callback_query.data:match('^%-%d+:ahelp$')
    then
        keyboard = administration.get_help_keyboard(callback_query.data:match('^(%-%d+):ahelp$'))
        return oneteam.edit_message_text(
            message.chat.id,
            message.message_id,
            administration.get_help_text('back'),
            nil,
            true,
            json.encode(keyboard)
        )
    elseif callback_query.data:match('^%-%d+:ahelp:.-$')
    then
        return administration.on_help_callback_query(
            callback_query,
            callback_query.data:match('^%-%d+:ahelp:.-$')
        )
    elseif callback_query.data:match('^%-%d+:page:%d*$')
    then
        local chat_id, page = callback_query.data:match('^(%-%d+):page:(%d*)$')
        keyboard = administration.get_initial_keyboard(chat_id, page)
        return oneteam.edit_message_reply_markup(
            message.chat.id,
            message.message_id,
            nil,
            json.encode(keyboard)
        )
    elseif callback_query.data == 'dismiss_disabled_message'
    then
        redis:set(
            'administration:' .. message.chat.id .. ':dismiss_disabled_message',
            true
        )
        return oneteam.answer_callback_query(
            callback_query.id,
            'You will no longer be reminded that the administration plugin is disabled. To enable it, use /administration.',
            true
        )
    else
        return false
    end
    return oneteam.edit_message_reply_markup(
        message.chat.id,
        message.message_id,
        nil,
        json.encode(keyboard)
    )
end

function administration.get_help_text(section)
    section = tostring(section)
    if not section or section == nil then
        return false
    elseif section == 'rules' then
        return [[Ensure people behave in your group by setting rules. You can do this using the <code>/setrules</code> command, passing the rules you'd like to set as an argument. These rules can be formatted in Markdown. If you'd like to modify the rules, just repeat the same process, thus overwriting the current rules. To display the group rules, you need to use the <code>/rules</code> command. Only group administrators and moderators can use the <code>/setrules</code> command.]]
    elseif section == 'welcome_message' then
        return [[Enhance the experience your group provides to its users by settings a custom welcome message. This can be done by using the <code>/setwelcome</code> command, passing the welcome message you'd like to set as an argument. This welcome message can be formatted in Markdown. You can use a few placeholders too, to personalise each welcome message. <code>$chat_id</code> will be replaced with the chat's numerical ID, <code>$user_id</code> will be replaced with the newly-joined user's numerical ID, <code>$name</code> will be replaced with the newly-joined user's name, and <code>$title</code> will be replaced with the chat title.]]
    elseif section == 'antispam' then
        return [[Rid of spammers with little effort by using my inbuilt antispam plugin. This is disabled by default. It can be turned on and customised using the <code>/antispam</code> command.]]
    elseif section == 'moderation' then
        return [[Want to promote users but don't feel comfortable with them being able to delete messages or report people for spam? Not to worry, you can allow people to use my administration commands (such as <code>/ban</code> and <code>/kick</code> by replying to one of their messages with the command <code>/mod</code>. If things just aren't working out then you can demote the user by replying to one of their messages with <code>/demod</code>.]]
    elseif section == 'administration' then
        return [[There are 4 main parts to the <i>actual</i> administration part of my functionality. These can be used by all group administrators and moderators. <code>/ban</code>, <code>/kick</code>, <code>/unban</code>, and <code>/warn</code>. <code>/kick</code> and <code>/ban</code> remove the targeted user from the chat. The only difference is that <code>/kick</code> will automatically unban the user after removing them, thus acting as a soft-ban. <code>/unban</code> will unban the targeted user from the chat, and <code>/warn</code> will warn the targeted user. A user will be banned after 3 warnings. <code>/kick</code>, <code>/ban</code>, and <code>/unban</code> can be used in reply to a user, or you can specify the user as an argument via their numerical ID or username (with or without a preceding <code>@</code>).]]
    elseif section == 'back' then
        return [[Learn more about using BarrePolice for administrating your group by navigating using the buttons below:]]
    end
    return false
end

function administration.get_help_keyboard(chat_id)
    return {
        ['inline_keyboard'] = {
            {
                {
                    ['text'] = 'Rules',
                    ['callback_data'] = 'administration:ahelp:rules'
                },
                {
                    ['text'] = 'Welcome Message',
                    ['callback_data'] = 'administration:ahelp:welcome_message'
                }
            },
            {
                {
                    ['text'] = 'antispam',
                    ['callback_data'] = 'administration:ahelp:antispam'
                },
                {
                    ['text'] = 'Moderation',
                    ['callback_data'] = 'administration:ahelp:moderation'
                }
            },
            {
                {
                    ['text'] = 'Administration',
                    ['callback_data'] = 'administration:ahelp:administration'
                }
            },
            {
                {
                    ['text'] = 'Back',
                    ['callback_data'] = 'administration:back:' .. chat_id
                }
            }
        }
    }
end

function administration.on_help_callback_query(callback_query, message)
    local output = administration.get_help_text(callback_query.data:match('^ahelp:(.-)$'))
    if not output then
        return
    end
    local keyboard = administration.get_help_keyboard()
    oneteam.edit_message_text(
        message.chat.id,
        message.message_id,
        output,
        'html',
        true,
        json.encode(keyboard)
    )
end

function administration.format_admin_list(output, chat_id)
    local creator = ''
    local admin_count = 1
    local admins = ''
    for i, admin in pairs(output.result) do
        local user
        local branch = ' ├ '
        if admin.status == 'creator' then
            creator = oneteam.escape_html(admin.user.first_name)
            if admin.user.username then
                creator = string.format(
                    '<a href="https://t.me/%s">%s</a>',
                    admin.user.username,
                    creator
                )
            end
        elseif admin.status == 'administrator' then
            user = oneteam.escape_html(admin.user.first_name)
            if admin.user.username then
                user = string.format(
                    '<a href="https://t.me/%s">%s</a>',
                    admin.user.username,
                    user
                )
            end
            admin_count = admin_count + 1
            if admin_count == #output.result then
                branch = ' └ '
            end
            admins = admins .. branch .. user .. '\n'
        end
    end
    local mod_list = redis:smembers('administration:' .. chat_id .. ':mods')
    local mod_count = 0
    local mods = ''
    if next(mod_list) then
        local branch = ' ├ '
        local user
        for i = 1, #mod_list do
            user = oneteam.get_linked_name(mod_list[i])
            if user then
                if i == #mod_list then
                    branch = ' └ '
                end
                mods = mods .. branch .. user .. '\n'
                mod_count = mod_count + 1
            end
        end
    end
    if creator == '' then
        creator = '-'
    end
    if admins == '' then
        admins = '-'
    end
    if mods == '' then
        mods = '-'
    end
    return string.format(
        '<b>👤 Creator</b>\n└ %s\n\n<b>👥 Admins</b> (%d)\n%s\n<b>👥 Moderators</b> (%d)\n%s',
        creator,
        admin_count - 1,
        admins,
        mod_count,
        mods
    )
end

function administration.admins(message)
    local success = oneteam.get_chat_administrators(message.chat.id)
    if not success then
        return oneteam.send_reply(
            message,
            'I couldn\'t get a list of administrators in this chat.'
        )
    end
    return oneteam.send_reply(
        message,
        administration.format_admin_list(success, message.chat.id),
        'html'
    )
end

function administration.trusted(message)
    local success = oneteam.get_trusted_users(message.chat.id)
    local output = "👨 <b>Trusted Users</b> ("..#success..")\n"
    if not success then
        return oneteam.send_reply(
            message,
            'I couldn\'t get a list of trusted users in this chat.'
        )
    end
    local user_count = 0
    for i, trusted in pairs(success) do
        local user_output
        local user = oneteam.get_user(trusted) or oneteam.get_chat(trusted)
        user_count = user_count + 1
        if user then
            user = user.result
            local branch = ' ├ '
            if user.username then
                user_output = string.format(
                    '<a href="https://t.me/%s">%s</a>',
                    user.username,
                    user.first_name
                )
            else
                user_output = user.first_name
            end
            if user_count == #success then
                branch = ' └ '
            end
            output = output .. branch .. user_output .. '\n'
        else
            redis:srem(
                'administration:' .. message.chat.id .. ':trusted',
                trusted
            )
            oneteam.send_reply(message, "I've untrusted the user <code>" .. trusted .. "</code> as I couldn\'t get his information or is a deleted account")
        end
    end
    return oneteam.send_reply(
        message,
        output,
        'html'
    )
end

function administration.muted(message)
    local success = oneteam.get_muted_users(message.chat.id)
    local output = "🤐 <b>Muted Users</b> ("..#success..")\n"
    if not success then
        return oneteam.send_reply(
            message,
            'I couldn\'t get a list of muted users in this chat.'
        )
    end
    local user_count = 0
    for i, muted in pairs(success) do
        local user_output
        local user = oneteam.get_user(muted) or oneteam.get_chat(muted)
        user_count = user_count + 1
        if user then
            user = user.result
            local branch = ' ├ '
            if user.username then
                user_output = string.format(
                    '<a href="https://t.me/%s">%s</a>',
                    user.username,
                    user.first_name
                )
            else
                user_output = user.first_name
            end
            if user_count == #success then
                branch = ' └ '
            end
            output = output .. branch .. user_output .. '\n'
        end
    end
    return oneteam.send_reply(
        message,
        output,
        'html'
    )
end

function administration.whitelist_links(message)
    local input = oneteam.input(message.text)
    if not input then
        return oneteam.send_reply(message, 'Please specify the URLs or @usernames you\'d like to whitelist.')
    end
    local output = oneteam.check_links(message, false, false, true)
    return oneteam.send_reply(message, output)
end

function administration:on_message(message, configuration)
    if message.chat.type == 'private' then
        local input = oneteam.input(message.text)
        if input then
            if tonumber(input) == nil and not input:match('^%@') then
                input = '@' .. input
            end
            local resolved = oneteam.get_chat(input)
            if resolved and oneteam.is_group_admin(
                resolved.result.id,
                message.from.id
            ) then
                message.chat = resolved.result
            elseif resolved then
                return oneteam.send_reply(
                    message,
                    'That\'s not a valid chat!'
                )
            else
                return oneteam.send_reply(
                    message,
                    'You don\'t appear to be an administrator in that chat!'
                )
            end
        else
            return oneteam.send_reply(
                message,
                'My administrative functionality can only be used in groups/channels! If you\'re looking for help with using my administrative functionality, check out the "Administration" section of /help! Alternatively, if you wish to manage the settings for a group you administrate, you can do so here by using the syntax /administration <chat>.'
            )
        end
    end
    if not oneteam.is_group_admin(
        message.chat.id,
        message.from.id
    ) then
        if message.text:match('^[/!#]admins') or message.text:match('^[/!#]staff') then
            return administration.admins(message)
        elseif message.text:match('^[/!#]rules') then
            return administration.rules(
                message,
                self.info.username:lower()
            )
        elseif message.text:match('^[/!#]ops') or message.text:match('^[/!#]report') then
            return administration.report(
                message,
                self.info.id
            )
        end
        return -- Ignore all other requests from users who aren't administrators in the group.
    elseif message.text:match('^[/!#]links') or message.text:match('^[/!#]whitelistlink') then
        return administration.whitelist_links(message)
    elseif message.text:match('^[/!#]whitelist') then
        return administration.whitelist(
            message,
            self.info
        )
    elseif message.text:match('^[/!#]antispam') or message.text:match('^[/!#]administration') or message.text:match('^[/!#]config') or message.text:match('^[/!#]admin') and not message.text:match('^[/!#]admins') then
        local keyboard = administration.get_initial_keyboard(message.chat.id)
        local recipient = message.from.id
        if oneteam.get_setting(
            message.chat.id,
            'settings in group'
        )
        then
            recipient = message.chat.id
        end
        local success = oneteam.send_message(
            recipient,
            string.format(
                'Use the keyboard below to adjust the administration settings for <b>%s</b>:',
                oneteam.escape_html(message.chat.title)
            ),
            'html',
            true,
            false,
            nil,
            json.encode(keyboard)
        )
        if not success
        and recipient == message.from.id
        then
            return oneteam.send_reply(
                message,
                'Please send me a [private message](https://t.me/' .. self.info.username:lower() .. '), so that I can send you this information.',
                'markdown'
            )
        elseif recipient == message.from.id
        then
            return oneteam.send_reply(
                message,
                'I have sent you the information you requested via private chat.'
            )
        end
        return success
    elseif message.text:match('^[/%!%$]admins') or message.text:match('^[/!#]staff') then
        return administration.admins(message)
    elseif message.text:match('^[/!#]trusted') then
        return administration.trusted(message)
    elseif message.text:match('^[/!#]muted') then
        return administration.muted(message)
    elseif message.text:match('^[/!#]ops') or message.text:match('^[/!#]report') then
        return administration.report(
            message,
            self.info.id
        )
    elseif message.text:match('^[/!#]tempban') then
        return administration.tempban(message)
    end
    return
end

return administration
