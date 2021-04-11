return {
    ['errors'] = {
        ['connection'] = 'Connection error.',
        ['results'] = 'I couldn\'t find any results for that.',
        ['supergroup'] = 'This command can only be used in supergroups.',
        ['admin'] = 'You need to be a moderator or an administrator in this chat in order to use this command.',
        ['unknown'] = 'I don\'t recognize that user. If you would like to teach me who they are, forward a message from them to any chat that I\'m in.',
        ['generic'] = 'An error occured!',
        ['use'] = 'You are not allowed to use this!',
        ['private'] = 'You can only use this command in private chat!',
        ['nobeta'] = 'No betatesters group!, for see actual beta build go to BETATESTERS GROUP and send this command, and use the menu for select our device.'
    },
    ['addcommand'] = {
        ['1'] = 'Please specify the command in the format <code>/command - description</code>',
        ['2'] = 'I couldn\'t retrieve my commands!',
        ['3'] = 'The command description can\'t be longer than 256 characters!',
        ['4'] = 'An unknown error occurred! I couldn\'t add your command!',
        ['5'] = 'Success! Command added.'
    },
    ['addrule'] = {
        ['1'] = 'Please specify the rule you would like to add!',
        ['2'] = 'You don\'t have any rules to add to! Please set group rules using /setrules!',
        ['3'] = 'I couldn\'t add that rule, as it would make the length of the rules longer than Telegram\'s 4096 character limit!',
        ['4'] = 'I couldn\'t add that rule, it appears it contains invalid Markdown formatting!',
        ['5'] = 'Successfully updated the rules!'
    },
    ['addslap'] = {
        ['1'] = 'You can only use this command in groups!',
        ['2'] = 'The slap cannot contain curly braces apart from placeholders!',
        ['3'] = 'The slap cannot be any longer than 256 characters in length!',
        ['4'] = 'I\'ve successfully added that slap as a possibility for /slap in this group!',
        ['5'] = 'You must include placeholders in your slap. Use {ME} for the person executing and {THEM} for the victim.'
    },
    ['administration'] = {
        ['1'] = 'Enable Administration',
        ['2'] = 'Disable Administration',
        ['3'] = 'Anti-Spam Settings',
        ['4'] = 'Warning Settings',
        ['5'] = 'Vote-Ban Settings',
        ['6'] = 'Welcome New Users?',
        ['7'] = 'Send Rules On Join?',
        ['8'] = 'Send Rules In Group?',
        ['9'] = 'Back',
        ['10'] = 'Next',
        ['11'] = 'Word Filter',
        ['12'] = 'Anti-Bot',
        ['13'] = 'Anti-Link',
        ['14'] = 'Log Actions?',
        ['15'] = 'Anti-RTL',
        ['16'] = 'Anti-Spam Action',
        ['17'] = 'Ban',
        ['18'] = 'Kick',
        ['19'] = 'Delete Commands?',
        ['20'] = 'Force Group Language?',
        ['21'] = 'Send Settings In Group?',
        ['22'] = 'Delete Reply On Action?',
        ['23'] = 'Require Captcha?',
        ['24'] = 'Use Inline Captcha?',
        ['25'] = 'Ban SpamWatch-flagged users?',
        ['26'] = 'Number of warnings until %s:',
        ['27'] = 'Upvotes needed to ban:',
        ['28'] = 'Downvotes needed to dismiss:',
        ['29'] = 'Deleted %s, and its matching link from the database!',
        ['30'] = 'There were no entries found in the database matching "%s"!',
        ['31'] = 'You\'re not an administrator in that chat!',
        ['32'] = 'The minimum number of upvotes required for a vote-ban is %s.',
        ['33'] = 'The maximum number of upvotes required for a vote-ban is %s.',
        ['34'] = 'The minimum number of downvotes required for a vote-ban is %s.',
        ['35'] = 'The maximum number of downvotes required for a vote-ban is %s.',
        ['36'] = 'The maximum number of warnings is %s.',
        ['37'] = 'The minimum number of warnings is %s.',
        ['38'] = 'You can add one or more words to the word filter by using /filter <word(s)>',
        ['39'] = 'You will no longer be reminded that the administration plugin is disabled. To enable it, use /administration.',
        ['40'] = 'That\'s not a valid chat!',
        ['41'] = 'You don\'t appear to be an administrator in that chat!',
        ['42'] = 'My administrative functionality can only be used in groups/channels! If you\'re looking for help with using my administrative functionality, check out the "Administration" section of /help! Alternatively, if you wish to manage the settings for a group you administrate, you can do so here by using the syntax /administration <chat>.',
        ['43'] = 'Use the keyboard below to adjust the administration settings for <b>%s</b>:',
        ['44'] = 'Please send me a [private message](https://t.me/%s), so that I can send you this information.',
        ['45'] = 'I have sent you the information you requested via private chat.',
        ['46'] = 'Remove Channel Pins?',
        ['47'] = 'Remove Other Pins?',
        ['48'] = 'Remove Pasted Code?',
        ['49'] = 'Prevent Inline Bots?',
        ['50'] = 'Kick Media On Join?',
        ['51'] = 'Enable Plugins For Admins?',
        ['52'] = 'Kick URLs On Join?'
    },
    ['afk'] = {
        ['1'] = 'Sorry, I\'m afraid this feature is only available to users with a public @username!',
        ['2'] = '%s has returned after being AFK for %s!',
        ['3'] = 'Note',
        ['4'] = '%s is now AFK.%s'
    },
    ['antispam'] = {
        ['1'] = 'Disable',
        ['2'] = 'Enable',
        ['3'] = 'Disable limit',
        ['4'] = 'Enable limits on %s',
        ['5'] = 'All Administration Settings',
        ['6'] = '%s [%s] has kicked %s [%s] from %s [%s] for hitting the configured anti-spam limit for [%s] media.',
        ['7'] = 'Kicked %s for hitting the configured antispam limit for [%s] media.',
        ['8'] = 'The maximum limit is 100.',
        ['9'] = 'The minimum limit is 1.',
        ['10'] = 'Modify the anti-spam settings for %s below:',
        ['11'] = 'Hey %s, if you\'re going to send code that is longer than %s characters in length, please do so using /paste in <a href="https://t.me/%s">private chat with me</a>!',
        ['12'] = '%s <code>[%s]</code> has %s %s <code>[%s]</code> from %s <code>[%s]</code> for sending Telegram invite link(s).\n#chat%s #user%s',
        ['13'] = '%s %s for sending Telegram invite link(s).',
        ['14'] = 'Hey, I noticed you\'ve got anti-link enabled and you\'re currently not allowing your users to mention a chat you\'ve just mentioned, if you\'d like to allowlist it, use /allowlink <links>.',
        ['15'] = 'Kicked %s <code>[%s]</code> from %s <code>[%s]</code> for sending media within their first few messages.\n#chat%s #user%s',
        ['16'] = 'Kicked %s <code>[%s]</code> from %s <code>[%s]</code> for sending a URL within their first few messages.\n#chat%s #user%s',
        ['17'] = 'Action',
        ['18'] = 'Kick',
        ['19'] = 'Ban',
        ['20'] = 'Mute'
    },
    ['appstore'] = {
        ['1'] = 'View on iTunes',
        ['2'] = 'rating',
        ['3'] = 'ratings'
    },
    ['authspotify'] = {
        ['1'] = 'You are already authorised using that account.',
        ['2'] = 'Authorising, please wait...',
        ['3'] = 'A connection error occured. Are you sure you replied with the correct link? It should look like',
        ['4'] = 'Successfully authorised your Spotify account!'
    },
    ['avatar'] = {
        ['1'] = 'I couldn\'t retrieve the profile photos for that user, please ensure you specified a valid username or numerical ID.',
        ['2'] = 'That user doesn\'t have any profile photos.',
        ['3'] = 'That user doesn\'t have that many profile photos!',
        ['4'] = 'That user has opted-out of data-collecting functionality, therefore I am not able to show you any of their profile photos.',
        ['5'] = 'User: %s\nPhoto: %s/%s\nSend /avatar %s [offset] to @%s to view a specific photo of this user',
        ['6'] = 'User: %s\nPhoto: %s/%s\nUse /avatar %s [offset] to view a specific photo of this user'
    },
    ['ban'] = {
        ['1'] = 'Which user would you like me to ban? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot ban this user because they are a moderator or an administrator in this chat.',
        ['3'] = 'I cannot ban this user because they have already left this chat.',
        ['4'] = 'I cannot ban this user because they have already been banned from this chat.',
        ['5'] = 'I need to have administrative permissions in order to ban this user. Please amend this issue, and try again.',
        ['6'] = '%s <code>[%s]</code> has banned %s <code>[%s]</code> from %s <code>[%s]</code>%s.\n%s %s',
        ['7'] = '%s has banned %s%s.'
    },
    ['bash'] = {
        ['1'] = 'Please specify a command to run!',
        ['2'] = 'Success!'
    },
    ['blocklist'] = {
        ['1'] = 'Which user would you like me to blocklist? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot blocklist this user because they are a moderator or an administrator in this chat.',
        ['3'] = 'I cannot blocklist this user because they have already left this chat.',
        ['4'] = 'I cannot blocklist this user because they have already been banned from this chat.',
        ['5'] = '%s <code>[%s]</code> has blocklisted %s <code>[%s]</code> from using %s <code>[%s]</code> in %s <code>[%s]</code>%s.\n%s %s',
        ['6'] = '%s has blocklisted %s from using %s%s.'
    },
    ['blocklistchat'] = {
        ['1'] = '%s has now been blocklisted, and I will leave whenever I am added there!',
        ['2'] = '%s is a user, this command is only for blocklisting chats such as groups and channels!',
        ['3'] = '%s doesn\'t appear to be a valid chat!'
    },
    ['bugr'] = {
        ['1'] = 'Success! Your bug report has been sent. The ID of this report is #%s.',
        ['2'] = 'There was a problem whilst reporting that bug! Ha, the irony!'
    },
    ['calc'] = {
        ['1'] = 'Click to send the result.',
        ['2'] = '"%s" was an unexpected word!',
        ['3'] = 'You cannot have a unit before a number!'
    },
    ['captionbotai'] = {
        ['1'] = 'I really cannot describe that picture!'
    },
    ['cats'] = {
        ['1'] = 'Meow!'
    },
    ['channel'] = {
        ['1'] = 'You are not allowed to use this!',
        ['2'] = 'You don\'t appear to be an administrator in that chat anymore!',
        ['3'] = 'I couldn\'t send your message, are you sure I still have permission to send messages in that chat?',
        ['4'] = 'Your message has been sent!',
        ['5'] = 'I was unable to retrieve a list of administrators for that chat!',
        ['6'] = 'You don\'t appear to be an administrator in that chat!',
        ['7'] = 'Please specify the message to send, using the syntax /channel <channel> <message>.',
        ['8'] = 'Are you sure you want to send this message? This is how it will look:',
        ['9'] = 'Yes, I\'m sure!',
        ['10'] = 'That message contains invalid Markdown formatting! Please correct your syntax and try again.'
    },
    ['chatroulette'] = {
        ['1'] = 'Hey! Please don\'t send messages longer than %s characters. We don\'t want to annoy the other user!',
        ['2'] = '*Anonymous said:*\n```\n%s\n```\nTo end your session, send /endchat.',
        ['3'] = 'I\'m afraid I lost connection from the other user! To begin a new chat, please send /chatroulette!',
        ['4'] = 'The other person you were chatting with has ended the session. To start a new one, send /chatroulette.',
        ['5'] = 'Successfully ended your session. To start a new one, send /chatroulette.',
        ['6'] = 'I have successfully removed you from the list of available users.',
        ['7'] = 'You don\'t have a session set up at the moment. To start one, send /chatroulette.',
        ['8'] = 'Finding you a session, please wait...',
        ['9'] = 'I\'m afraid there aren\'t any available users right now, but I have added you to the list of available users! To stop this completely, please send /endchat.',
        ['10'] = 'I have successfully paired you with another user to chat to! Please remember to be kind to them! To end the chat, send /endchat.',
        ['11'] = 'I\'m afraid the user who I tried to pair you with has since blocked me. Please try and send /chatroulette again to try and connect to me!',
        ['12'] = 'I have successfully paired you with another user to chat to! Please remember to be kind to them! To end the chat, send /endchat.'
    },
    ['commandstats'] = {
        ['1'] = 'No commands have been sent in this chat!',
        ['2'] = '<b>Command statistics for:</b> %s\n\n%s\n<b>Total commands sent:</b> %s',
        ['3'] = 'The command statistics for this chat have been reset!',
        ['4'] = 'I could not reset the command statistics for this chat. Perhaps they have already been reset?'
    },
    ['control'] = {
        ['1'] = 'Pfft, you wish!',
        ['2'] = '%s is reloading...'
    },
    ['copypasta'] = {
        ['1'] = 'The replied-to text musn\'t be any longer than %s characters!'
    },
    ['coronavirus'] = {
        ['1'] = [[*COVID-19 Statistics for:* %s

*New confirmed cases:* %s
*Total confirmed cases:* %s
*New deaths:* %s
*Total deaths:* %s
*New recovered cases:* %s
*Total recovered cases:* %s]]
    },
    ['counter'] = {
        ['1'] = 'I couldn\'t add a counter to that message!'
    },
    ['custom'] = {
        ['1'] = 'Success! That message will now be sent every time somebody uses %s!',
        ['2'] = 'The trigger "%s" does not exist!',
        ['3'] = 'The trigger "%s" has been deleted!',
        ['4'] = 'You don\'t have any custom triggers set!',
        ['5'] = 'Custom commands for %s:\n',
        ['6'] = 'To create a new, custom command, use the following syntax:\n/custom new #trigger <value>. To list all current triggers, use /custom list. To delete a trigger, use /custom del #trigger.'
    },
    ['delete'] = {
        ['1'] = 'I could not delete that message. Perhaps the message is too old or non-existent?'
    },
    ['demote'] = {
        ['1'] = 'Which user would you like me to demote? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot demote this user because they are not a moderator or an administrator in this chat.',
        ['3'] = 'I cannot demote this user because they have already left this chat.',
        ['4'] = 'I cannot demote this user because they have already been kicked from this chat.'
    },
    ['dice'] = {
        ['1'] = 'The minimum range is %s.',
        ['2'] = 'The maximum range and count are both %s.',
        ['3'] = 'The maximum range is %s, and the maximum count is %s.',
        ['4'] = '%s rolls with a range of %s:\n'
    },
    ['doge'] = {
        ['1'] = 'Please enter the text you want to Doge-ify. Each sentence should be separated using slashes or new lines.'
    },
    ['donate'] = {
        ['1'] = '<b>Hello, %s!</b>\n\nIf you\'re feeling generous, you can contribute to the One project by making a monetary donation of any amount. This will go towards server costs and any time and resources used to develop One. This is an optional act, however it is greatly appreciated and your name will also be listed publically on One Channel\'s.\n\nIf you\'re still interested, you can donate <a href="https://paypal.me/badwolfalfa">here</a>. Thank you for your continued support!'
    },
    ['duckduckgo'] = {
        ['1'] = 'I\'m not sure what that is!'
    },
    ['eightball'] = {
        ['1'] = 'Yes.',
        ['2'] = 'No.',
        ['3'] = 'It is likely so.',
        ['4'] = 'Well, uh... I\'d ask again later, if I were you.'
    },
    ['exec'] = {
        ['1'] = 'Please select the language you would like to execute your code in:',
        ['2'] = 'An error occured! The connection timed-out. Were you trying to make me lag?',
        ['3'] = 'You have selected "%s" – are you sure?',
        ['4'] = 'Back',
        ['5'] = 'I\'m sure',
        ['6'] = 'Please enter a snippet of code that you would like to run. You don\'t need to specify the language, we will do that afterwards!',
        ['7'] = 'Please select the language you would like to execute your code in:'
    },
    ['facebook'] = {
        ['1'] = 'An error occured!',
        ['2'] = 'Please enter the name of the Facebook user you would like to get the profile picture of.',
        ['3'] = 'View @%s on Facebook'
    },
    ['fact'] = {
        ['1'] = 'Generate Another'
    },
    ['fban'] = {
        ['1'] = 'Which user would you like me to Fed-ban? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot Fed-ban this user because they are a moderator or an administrator in this chat.'
    },
    ['flickr'] = {
        ['1'] = 'You searched for:',
        ['2'] = 'Please enter a search query (that is, what you want me to search Flickr for, i.e. "Big Ben" will return a photograph of Big Ben in London).',
        ['3'] = 'More Results'
    },
    ['fortune'] = {
        ['1'] = 'Click to send your fortune!'
    },
    ['frombinary'] = {
        ['1'] = 'Please enter the binary value you would like to convert to a string.',
        ['2'] = 'Malformed binary!'
    },
    ['game'] = {
        ['1'] = 'Total wins: %s\nTotal losses: %s\nBalance: %s onecoins',
        ['2'] = 'Join Game',
        ['3'] = 'This game has already ended!',
        ['4'] = 'It\'s not your turn!',
        ['5'] = 'You are not part of this game!',
        ['6'] = 'You cannot go here!',
        ['7'] = 'You are already part of this game!',
        ['8'] = 'This game has already started!',
        ['9'] = '%s [%s] is playing against %s [%s]\nIt is currently %s\'s turn!',
        ['10'] = '%s won the game against %s!',
        ['11'] = '%s drew the game against %s!',
        ['12'] = 'Waiting for opponent...',
        ['13'] = 'Tic-Tac-Toe',
        ['14'] = 'Click to send the game to your chat!',
        ['15'] = 'Statistics for %s:\n',
        ['16'] = 'Play Tic-Tac-Toe!'
    },
    ['gblocklist'] = {
        ['1'] = 'Please reply-to the user you\'d like to globally blocklist, or specify them by username/ID.',
        ['2'] = 'I couldn\'t get information about "%s", please check it\'s a valid username/ID and try again.',
        ['3'] = 'That\'s a %s, not a user!'
    },
    ['gif'] = {
        ['1'] = 'Please enter a search query (that is, what you want me to search GIPHY for, i.e. "cat" will return a GIF of a cat).'
    },
    ['godwords'] = {
        ['1'] = 'Please enter a numerical value, between 1 and 64!',
        ['2'] = 'That number is too small, please specify one between 1 and 64!',
        ['3'] = 'That number is too large, please specify one between 1 and 64!'
    },
    ['gallowlist'] = {
        ['1'] = 'Please reply-to the user you\'d like to globally allowlist, or specify them by username/ID.',
        ['2'] = 'I couldn\'t get information about "%s", please check it\'s a valid username/ID and try again.',
        ['3'] = 'That\'s a %s, not a user!'
    },
    ['hackernews'] = {
        ['1'] = 'Top Stories from Hacker News:'
    },
    ['help'] = {
        ['1'] = 'No results found!',
        ['2'] = 'There were no features found matching "%s", please try and be more specific!',
        ['3'] = '\n\nArguments: <required> [optional]\n\nSearch for a feature or get help with a command by using my inline search functionality - just mention me in any chat using the syntax @%s <search query>.',
        ['4'] = 'Previous',
        ['5'] = 'Next',
        ['6'] = 'Back',
        ['7'] = 'Search',
        ['8'] = 'You are on page %s of %s!',
        ['9'] = [[
I can perform many administrative actions in your groups, just add me as an administrator and send /administration to adjust the settings for your group.
Here are some administrative commands and a brief comment regarding what they do:

• /pin <text> - Send a Markdown-formatted message which can be edited by using the same command with different text, to save you from having to re-pin a message if you can't edit it (which happens if the message is older than 48 hours)

• /ban - Ban a user by replying to one of their messages, or by specifying them by username/ID

• /kick - Kick (ban and then unban) a user by replying to one of their messages, or by specifying them by username/ID

• /unban - Unban a user by replying to one of their messages, or by specifying them by username/ID

• /setrules <text> - Set the given Markdown-formatted text as the group rules, which will be sent whenever somebody uses /rules
        ]],
        ['10'] = [[
• /setwelcome - Set the given Markdown-formatted text as a welcome message that will be sent every time a user joins your group (the welcome message can be disabled in the administration menu, accessible via /administration). You can use placeholders to automatically customise the welcome message for each user. Use $user\_id to insert the user's numerical ID, $chat\_id to insert the chat's numerical ID, $name to insert the user's name, $title to insert the chat title and $username to insert the user's username (if the user doesn't have an @username, their name will be used instead, so it is best to avoid using this with $name)

• /warn - Warn a user, and ban them when they hit the maximum number of warnings

• /mod - Promote the replied-to user, giving them access to administrative commands such as /ban, /kick, /warn etc. (this is useful when you don't want somebody to have the ability to delete messages!)

• /demod - Demote the replied-to user, stripping them from their moderation status and revoking their ability to use administrative commands

• /staff - View the group's creator, administrators, and moderators in a neatly-formatted list
        ]],
        ['11'] = [[
• /report - Forwards the replied-to message to all administrators and alerts them of the current situation

• /setlink <URL> - Set the group's link to the given URL, which will be sent whenever somebody uses /link

• /links <text> - Allowlists all of the Telegram links found in the given text (includes @username links)
        ]],
   --     ['12'] = 'Below are some links you might find useful:',
   --     ['13'] = 'Development',
   --     ['14'] = 'Channel',
   --     ['15'] = 'Support',
   --     ['16'] = 'FAQ',
   --     ['17'] = 'Source',
        ['18'] = 'Donate',
   --     ['19'] = 'Rate',
   --     ['20'] = 'Administration Log',
        ['21'] = 'Admin Settings',
        ['22'] = 'Plugins',
        ['23'] = [[
<b>Hi %s! My name's %s, it's a pleasure to meet you</b> %s

I understand many commands, which you can learn more about by pressing the "Commands" button using the attached keyboard.

%s <b>Tip:</b> Use the "Settings" button to change how I work%s!

%s <b>Find me useful, or just want to help?</b> Donations are very much appreciated, use /donate for more information!
        ]],
        ['24'] = 'in'
    },
    ['id'] = {
        ['1'] = 'I\'m sorry, but I don\'t recognize that user. To teach me who they are, forward a message from them to me or get them to send me a message.',
        ['2'] = 'Queried Chat:',
        ['3'] = 'This Chat:',
        ['4'] = 'Click to send the result!'
    },
    ['imdb'] = {
        ['1'] = 'Previous',
        ['2'] = 'Next',
        ['3'] = 'You are on page %s of %s!'
    },
    ['import'] = {
        ['1'] = 'I don\'t recognize that chat!',
        ['2'] = 'That\'s not a supergroup, therefore I cannot import any settings from it!',
        ['3'] = 'Successfully imported administrative settings & toggled plugins from %s to %s!'
    },
    ['info'] = {
        ['1'] = [[
```
Redis:
%s Config File: %s
%s Mode: %s
%s TCP Port: %s
%s Version: %s
%s Uptime: %s days
%s Process ID: %s
%s Expired Keys: %s

%s User Count: %s
%s Group Count: %s

System:
%s OS: %s
```
        ]]
    },
    ['instagram'] = {
        ['1'] = '@%s on Instagram'
    },
    ['ipsw'] = {
        ['1'] = '<b>%s</b> iOS %s\n\n<code>MD5 sum: %s\nSHA1 sum: %s\nFile size: %s GB</code>\n\n<i>%s %s</i>',
        ['2'] = 'This firmware is no longer being signed!',
        ['3'] = 'This firmware is still being signed!',
        ['4'] = 'Please select your model:',
        ['5'] = 'Please select your firmware version:',
        ['6'] = 'Please select your device type:',
        ['7'] = 'iPod Touch',
        ['8'] = 'iPhone',
        ['9'] = 'iPad',
        ['10'] = 'Apple TV',
        ['11'] = 'MacBook',
        ['12'] = 'HomePod',
        ['13'] = 'iBridge',
        ['14'] = 'Mac Mini'
    },

['recovery'] = {
        ['1'] = '<b>%s</b> \n\nCustom Recovery: %s\n<i>%s %s</i>',
        ['2'] = 'This its not a actually valid Custom Recovery!',
        ['3'] = 'This its a good Custom Recovery for OneOS!',
        ['4'] = 'Please select your model:',
        ['5'] = 'Please select your recovery:',
        ['6'] = 'Select Your Device for Recovery Download \n\n*for flash recovery use actually custom recovery after download the file\n flash it with image - recovery partition \n\nor use fastboot with this command: \nfastboot flash recovery IMAGENAME.img\n remember substitute IMAGENAME with the name of the file*:',
        ['7'] = '',
        ['11'] = 'POCO',
        ['13'] = 'MI',
        ['15'] = 'CHANGELOG',
        ['14'] = 'REDMI'
    },

    ['onebeta'] = {
        ['1'] = '<b>%s</b> \n\nOneOS: %s\n\nMIUI: %s\n<i>%s %s</i>',
        ['2'] = 'This its not a new beta build!',
        ['3'] = 'This its a new beta build!',
        ['4'] = 'Please select your model:',
        ['5'] = 'Please select your firmware version:',
        ['6'] = 'Select Your Device for OneOS BETA BUILD *only work on beta testers group*:',
        ['7'] = '',
        ['11'] = 'POCO',
        ['13'] = 'MI',
        ['15'] = 'CHANGELOG',
        ['14'] = 'REDMI'
    },

    ['ispwned'] = {
        ['1'] = 'That account was found in the following leaks:'
    },
    ['isup'] = {
        ['1'] = 'This website appears to be up, maybe it\'s just you?',
        ['2'] = 'That doesn\'t appear to be a valid site!',
        ['3'] = 'It\'s not just you, this website looks down from here.'
    },
    ['itunes'] = {
        ['1'] = 'Name:',
        ['2'] = 'Artist:',
        ['3'] = 'Album:',
        ['4'] = 'Track:',
        ['5'] = 'Disc:',
        ['6'] = 'The original query could not be found, you\'ve probably deleted the original message.',
        ['7'] = 'The artwork can be found below:',
        ['8'] = 'Please enter a search query (that is, what you want me to search iTunes for, i.e. "Green Day American Idiot" will return information about the first result for American Idiot by Green Day).',
        ['9'] = 'Get Album Artwork'
    },
    ['kick'] = {
        ['1'] = 'Which user would you like me to kick? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot kick this user because they are a moderator or an administrator in this chat.',
        ['3'] = 'I cannot kick this user because they have already left this chat.',
        ['4'] = 'I cannot kick this user because they have already been kicked from this chat.',
        ['5'] = 'I need to have administrative permissions in order to kick this user. Please amend this issue, and try again.'
    },
    ['lastfm'] = {
        ['1'] = '%s\'s last.fm username has been set to "%s".',
        ['2'] = 'Your last.fm username has been forgotten!',
        ['3'] = 'You don\'t currently have a last.fm username set!',
        ['4'] = 'Please specify your last.fm username or set it with /fmset.',
        ['5'] = 'No history was found for this user.',
        ['6'] = '%s is currently listening to:\n',
        ['7'] = '%s last listened to:\n',
        ['8'] = 'Unknown',
        ['9'] = 'Click to send the result.'
    },
    ['lmgtfy'] = {
        ['1'] = 'Let me Google that for you!'
    },
    ['location'] = {
        ['1'] = 'You don\'t have a location set. What would you like your new location to be?'
    },
    ['logchat'] = {
        ['1'] = 'Please enter the username or numerical ID of the chat you wish to log all administrative actions into.',
        ['2'] = 'Checking to see whether that chat is valid...',
        ['3'] = 'I\'m sorry, it appears you\'ve either specified an invalid chat, or you\'ve specified a chat I haven\'t been added to yet. Please rectify this and try again.',
        ['4'] = 'You can\'t set a user as your log chat!',
        ['5'] = 'You don\'t appear to be an administrator in that chat!',
        ['6'] = 'It seems I\'m already logging administrative actions into that chat! Use /logchat to specify a new one.',
        ['7'] = 'That chat is valid, I\'m now going to try and send a test message to it, just to ensure I have permission to post!',
        ['8'] = 'Hello, World - this is a test message to check my posting permissions - if you\'re reading this, then everything went OK!',
        ['9'] = 'All done! From now on, any administrative actions in this chat will be logged into %s - to change the chat you want me to log administrative actions into, just send /logchat.'
    },
    ['lua'] = {
        ['1'] = 'Please enter a string of Lua to execute!'
    },
    ['lyrics'] = {
        ['1'] = 'Spotify',
        ['2'] = 'Show Lyrics',
        ['3'] = 'Please enter a search query (that is, what song/artist/lyrics you want me to get lyrics for, i.e. "Green Day Basket Case" will return the lyrics for the song Basket Case by Green Day).'
    },
    ['minecraft'] = {
        ['1'] = '<b>%s has changed his/her username %s time</b>',
        ['2'] = '<b>%s has changed his/her username %s times</b>',
        ['3'] = 'Previous',
        ['4'] = 'Next',
        ['5'] = 'Back',
        ['6'] = 'UUID',
        ['7'] = 'Avatar',
        ['8'] = 'Username History',
        ['9'] = 'Please select an option:',
        ['10'] = 'Please enter the username of the Minecraft player you would like to view information about (i.e. sending "Notch" will view information about the player Notch).',
        ['11'] = 'Minecraft usernames are between 3 and 16 characters long.'
    },
    ['msglink'] = {
        ['1'] = 'You can only use this command in supergroups and channels.',
        ['2'] = 'This %s must be public, with a @username.',
        ['3'] = 'Please reply to the message you\'d like to get a link for.'
    },
    ['mute'] = {
        ['1'] = 'Which user would you like me to mute? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot mute this user because they are already muted in this chat.',
        ['3'] = 'I cannot mute this user because they are a moderator or an administrator in this chat.',
        ['4'] = 'I cannot mute this user because they have already left (or been kicked from) this chat.',
        ['5'] = 'I need to have administrative permissions in order to mute this user. Please amend this issue, and try again.'
    },
    ['myspotify'] = {
        ['1'] = 'Profile',
        ['2'] = 'Following',
        ['3'] = 'Recently Played',
        ['4'] = 'Currently Playing',
        ['5'] = 'Top Tracks',
        ['6'] = 'Top Artists',
        ['7'] = 'You don\'t appear to be following any artists!',
        ['8'] = 'Your Top Artists',
        ['9'] = 'You don\'t appear to have any tracks in your library!',
        ['10'] = 'Your Top Tracks',
        ['11'] = 'You don\'t appear to be following any artists!',
        ['12'] = 'Artists You Follow',
        ['13'] = 'You don\'t appear to have recently played any tracks!',
        ['14'] = '<b>Recently Played</b>\n%s %s\n%s %s\n%s Listened to at %s:%s on %s/%s/%s.',
        ['15'] = 'The request has been accepted for processing, but the processing has not been completed.',
        ['16'] = 'You don\'t appear to be listening to anything right now!',
        ['17'] = 'Currently Playing',
        ['18'] = 'An error occured whilst re-authorising your Spotify account!',
        ['19'] = 'Successfully re-authorised your Spotify account! Processing your original request...',
        ['20'] = 'Re-authorising your Spotify account, please wait...',
        ['21'] = 'You need to authorise One in order to connect your Spotify account. Click [here](https://accounts.spotify.com/en/authorize?client_id=%s&response_type=code&redirect_uri=%s&scope=user-library-read,playlist-read-private,playlist-read-collaborative,user-read-private,user-read-email,user-follow-read,user-top-read,user-read-playback-state,user-read-recently-played,user-read-currently-playing,user-modify-playback-state) and press the green "OKAY" button to link One to your Spotify account. After you\'ve done that, send the link you were redirected to (it should begin with "%s", followed by a unique code) in reply to this message.',
        ['22'] = 'Playlists',
        ['23'] = 'Use Inline Mode',
        ['24'] = 'Lyrics',
        ['25'] = 'No devices were found.',
        ['26'] = 'You don\'t appear to have any playlists.',
        ['27'] = 'Your Playlists',
        ['28'] = '%s %s [%s tracks]',
        ['29'] = '%s %s [%s]\nSpotify %s user\n\n<b>Devices:</b>\n%s',
        ['30'] = 'Playing previous track...',
        ['31'] = 'You are not a premium user!',
        ['32'] = 'I could not find any devices.',
        ['33'] = 'Playing next track...',
        ['34'] = 'Resuming track...',
        ['35'] = 'Your device is temporarily unavailable...',
        ['36'] = 'No devices were found!',
        ['37'] = 'Pausing track...',
        ['38'] = 'Now playing',
        ['39'] = 'Shuffling your music...',
        ['40'] = 'That\'s not a valid volume. Please specify a number between 0 and 100.',
        ['41'] = 'The volume has been set to %s%%!',
        ['42'] = 'This message is using an old version of this plugin, please request a new one by sending /myspotify!'
    },
    ['name'] = {
        ['1'] = 'The name I currently respond to is "%s" - to change this, use /name <text> (where <text> is what you want me to respond to).',
        ['2'] = 'My new name needs to be between 2 and 32 characters long!',
        ['3'] = 'My name may only contain alphanumeric characters!',
        ['4'] = 'I will now respond to "%s", instead of "%s" - to change this, use /name <text> (where <text> is what you want me to respond to).'
    },
    ['netflix'] = {
        ['1'] = 'Read more.'
    },
    ['news'] = {
        ['1'] = '"<code>%s</code>" isn\'t a valid Lua pattern.',
        ['2'] = 'I couldn\'t retrieve a list of sources.',
        ['3'] = '<b>News sources found matching</b> "<code>%s</code>":\n\n%s',
        ['4'] = '<b>Here are the current available news sources you can use with</b> /news<b>. Use</b> /nsources &lt;query&gt; <b>to search the list of news sources for a more specific set of results. Searches are matched using Lua patterns</b>\n\n%s',
        ['5'] = 'You don\'t have a preferred news source. Use /setnews <source> to set one. View a list of sources using /nsources, or narrow down the results by using /nsources <query>.',
        ['6'] = 'Your current preferred news source is %s. Use /setnews <source> to change it. View a list of sources using /nsources, or narrow down the results by using /nsources <query>.',
        ['7'] = 'Your preferred source is already set to %s! Use /news to view the current top story.',
        ['8'] = 'That\'s not a valid news source. View a list of sources using /nsources, or narrow down the results by using /nsources <query>.',
        ['9'] = 'Your preferred news source has been updated to %s! Use /news to view the current top story.',
        ['10'] = 'That\'s not a valid source, use /nsources to view a list of available sources. If you have a preferred source, use /setnews <source> to automatically have news from that source sent when you send /news, without any arguments needed.',
        ['11'] = 'Read more.'
    },
    ['nick'] = {
        ['1'] = 'Your nickname has now been forgotten!',
        ['2'] = 'Your nickname has been set to "%s"!'
    },
    ['ninegag'] = {
        ['1'] = 'Read More'
    },
    ['optout'] = {
        ['1'] = 'You have opted-in to having data you send collected! Use /optout to opt-out.',
        ['2'] = 'You have opted-out of having data you send collected! Use /optin to opt-in.'
    },
    ['paste'] = {
        ['1'] = 'Please select a service to upload your paste to:'
    },
    ['pay'] = {
        ['1'] = 'You currently have %s onecoins. Earn more by winning games of Tic-Tac-Toe, using /game - You will win 100 onecoins for every game you win, and you will lose 50 for every game you lose.',
        ['2'] = 'You must use this command in reply to the user you\'d like to send onecoins to.',
        ['3'] = 'Please specify the amount of onecoins you\'d like to give %s.',
        ['4'] = 'The amount specified should be a numerical value, of which can be no less than 0.',
        ['5'] = 'You can\'t send money to yourself!',
        ['6'] = 'You don\'t have enough funds to complete that transaction!',
        ['7'] = '%s onecoins have been sent to %s. Your new balance is %s onecoins.'
    },
    ['pin'] = {
        ['1'] = 'You haven\'t set a pin before. Use /pin <text> to set one. Markdown formatting is supported.',
        ['2'] = 'Here is the last message generated using /pin.',
        ['3'] = 'I found an existing pin in the database, but the message I sent it in seems to have been deleted, and I can\'t find it anymore. You can set a new one with /pin <text>. Markdown formatting is supported.',
        ['4'] = 'There was an error whilst updating your pin. Either the text you entered contained invalid Markdown syntax, or the pin has been deleted. I\'m now going to try and send you a new pin, which you\'ll be able to find below - if you need to modify it then, after ensuring the message still exists, use /pin <text>.',
        ['5'] = 'I couldn\'t send that text because it contains invalid Markdown syntax.',
        ['6'] = 'Click here to see the pin, updated to contain the text you gave me.'
    },
    ['pokedex'] = {
        ['1'] = 'Name: %s\nID: %s\nType: %s\nDescription: %s'
    },
    ['prime'] = {
        ['1'] = 'Please enter a number between 1 and 99999.',
        ['2'] = '%s is a prime number!',
        ['3'] = '%s is NOT a prime number...'
    },
    ['promote'] = {
        ['1'] = 'I cannot promote this user because they are a moderator or an administrator of this chat.',
        ['2'] = 'I cannot promote this user because they have already left this chat.',
        ['3'] = 'I cannot promote this user because they have already been kicked from this chat.'
    },
    ['quote'] = {
        ['1'] = 'This user has opted out of data-storing functionality.',
        ['2'] = 'There are no saved quotes for %s! You can save one by using /save in reply to a message they send.'
    },
    ['randomsite'] = {
        ['1'] = 'Generate Another'
    },
    ['randomword'] = {
        ['1'] = 'Generate Another',
        ['2'] = 'Your random word is <b>%s</b>!'
    },
    ['report'] = {
        ['1'] = 'Please reply to the message you would like to report to the group\'s administrators.',
        ['2'] = 'You can\'t report your own messages, are you just trying to be funny?',
        ['3'] = '<b>%s needs help in %s!</b>',
        ['4'] = 'Click here to view the reported message.',
        ['5'] = 'I\'ve successfully reported that message to %s admin(s)!'
    },
    ['rms'] = {
        ['1'] = 'Holy GNU!'
    },
    ['save'] = {
        ['1'] = 'This user has opted out of data-storing functionality.',
        ['2'] = 'That message has been saved in my database, and added to the list of possible responses for when /quote is used in reply to %s!'
    },
    ['sed'] = {
        ['1'] = '%s\n\n<i>%s didn\'t mean to say this!</i>',
        ['2'] = '%s\n\n<i>%s has admitted defeat.</i>',
        ['3'] = '%s\n\n<i>%s isn\'t sure if they were mistaken...</i>',
        ['4'] = 'Screw you, <i>when am I ever wrong?</i>',
        ['5'] = '"<code>%s</code>" isn\'t a valid Lua pattern.',
        ['6'] = 'Hey %s, %s seems to think you meant:\n<i>%s</i>',
        ['7'] = 'Yes',
        ['8'] = 'No',
        ['9'] = 'Not sure',
        ['10'] = 'Just edit your message, idiot.'
    },
    ['setgrouplang'] = {
        ['1'] = 'This group\'s language has been set to %s!',
        ['2'] = 'This group\'s language is currently %s.\nPlease note that some strings may not be translated as of yet. If you\'d like to change your language, select one using the keyboard below:',
        ['3'] = 'The option to force users to use the same language in this group is currently disabled. This setting should be toggled from /administration but, to make things easier for you, I\'ve included a button below.',
        ['4'] = 'Enable',
        ['5'] = 'Disable'
    },
    ['setlang'] = {
        ['1'] = 'Your language has been set to %s!',
        ['2'] = 'Your language is currently %s.\nPlease note that some strings may not be translated as of yet. If you\'d like to change your language, select one using the keyboard below:'
    },
    ['setlink'] = {
        ['1'] = 'That\'s not a valid URL.',
        ['2'] = 'Link set successfully!'
    },
    ['setrules'] = {
        ['1'] = 'Invalid Markdown formatting.',
        ['2'] = 'Successfully set the new rules!'
    },
    ['setwelcome'] = {
        ['1'] = 'What would you like the welcome message to be? The text you specify will be Markdown-formatted and sent every time a user joins the chat (the welcome message can be disabled in the administration menu, accessible via /administration). You can use placeholders to automatically customise the welcome message for each user. Use $user_id to insert the user\'s numerical ID, $chat_id to insert the chat\'s numerical ID, $name to insert the user\'s name, $title to insert the chat\'s title and $username to insert the user\'s username (if the user doesn\'t have an @username, their name will be used instead, so it is best to avoid using this in conjunction with $name).',
        ['2'] = 'There was an error formatting your message, please check your Markdown syntax and try again.',
        ['3'] = 'The welcome message for %s has successfully been updated!'
    },
    ['share'] = {
        ['1'] = 'Share'
    },
    ['shorten'] = {
        ['1'] = 'Please select a URL shortener using the buttons below:'
    },
    ['shsh'] = {
        ['1'] = 'I couldn\'t fetch any SHSH blobs for that ECID, please ensure it\'s valid and you have saved them using https://shsh.host.',
        ['2'] = 'SHSH blobs for that device are available for the following versions of iOS:\n',
        ['3'] = 'View SHSH'
    },
    ['statistics'] = {
        ['1'] = 'No messages have been sent in this chat!',
        ['2'] = '<b>Statistics for:</b> %s\n\n%s\n<b>Total messages sent:</b> %s',
        ['3'] = 'The statistics for this chat have been reset!',
        ['4'] = 'I could not reset the statistics for this chat. Perhaps they have already been reset?'
    },
    ['steam'] = {
        ['1'] = 'Your Steam username has been set to "%s".',
        ['2'] = '"%s" isn\'t a valid Steam username.',
        ['3'] = '%s has been a user on Steam since %s, on %s. They last logged off at %s, on %s. Click <a href="%s">here</a> to view their Steam profile.',
        ['4'] = '%s, AKA "%s",'
    },
    ['synonym'] = {
        ['1'] = 'You could use the word <b>%s</b>, instead of %s.'
    },
    ['thoughts'] = {
        ['1'] = '%s\n\nPositive: <code>%s%% [%s]</code>\nNegative: <code>%s%% [%s]</code>\nIndifferent: <code>%s%% [%s]</code>\nTotal thoughts: <code>%s</code>'
    },
    ['tobinary'] = {
        ['1'] = 'Please enter the string you would like to convert to binary.'
    },
    ['trust'] = {
        ['1'] = 'I cannot trust this user because they are a moderator or an administrator of this chat.',
        ['2'] = 'I cannot trust this user because they have already left this chat.',
        ['3'] = 'I cannot trust this user because they have already been kicked from this chat.'
    },
    ['unmute'] = {
        ['1'] = 'Which user would you like me to unmute? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot unmute this user because they are not currently muted in this chat.',
        ['3'] = 'I cannot unmute this user because they are a moderator or an administrator in this chat.',
        ['4'] = 'I cannot unmute this user because they have already left (or been kicked from) this chat.'
    },
    ['untrust'] = {
        ['1'] = 'Which user would you like me to untrust? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot untrust this user because they are a moderator or an administrator in this chat.',
        ['3'] = 'I cannot untrust this user because they have already left this chat.',
        ['4'] = 'I cannot untrust this user because they have already been kicked from this chat.'
    },
    ['upload'] = {
        ['1'] = 'Please reply to the file you\'d like to download to the server. It must be <= 20 MB.',
        ['2'] = 'That file is too large. It must be <= 20 MB.',
        ['3'] = 'I couldn\'t get this file, it\'s probably too old.',
        ['4'] = 'There was an error whilst retrieving this file.',
        ['5'] = 'Successfully downloaded the file to the server - it can be found at <code>%s</code>!'
    },
    ['version'] = {
        ['1'] = '@%s AKA %s `[%s]` is running One %s, created by [BadWolf](https://t.me/lobomalo_soydegatita). The source code is available on [GitHub](https://github.com/One-Bots/oneteamBot).'
    },
    ['voteban'] = {
        ['1'] = 'Which user would you like to open up a vote-ban for? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot setup a vote-ban for this user because they are a moderator or an administrator in this chat.',
        ['3'] = 'I cannot setup a vote-ban for this user because they have already left (or been kicked from) this chat.',
        ['4'] = 'Should %s [%s] be banned from %s? %s upvotes are required for an immediate ban, and %s downvotes are required for this vote to be closed.',
        ['5'] = 'Yes [%s]',
        ['6'] = 'No [%s]',
        ['7'] = 'The people have spoken. I have banned %s [%s] from %s because %s people voted for me to do so.',
        ['8'] = 'The required upvote amount was reached, however, I was unable to ban %s - perhaps they\'ve left the group or been promoted since we opened the vote to ban them? It\'s either that, or I no longer have the administrative privileges required in order to perform this action!',
        ['9'] = 'The people have spoken. I haven\'t banned %s [%s] from %s because the required %s people downvoted the decision to ban them.',
        ['10'] = 'You upvoted the decision to ban %s [%s]!',
        ['11'] = 'Your current vote has been retracted, use the buttons again to re-submit your vote.',
        ['12'] = 'You downvoted the decision to ban %s [%s]!',
        ['13'] = 'A vote-ban has already been opened for this user!'
    },
    ['weather'] = {
        ['1'] = 'You don\'t have a location set. Use /setloc <location> to set one.',
        ['2'] = 'It\'s currently %s (feels like %s) in %s. %s'
    },
    ['welcome'] = {
        ['1'] = 'Group Rules'
    },
    ['allowlist'] = {
        ['1'] = 'Which user would you like me to allowlist? You can specify this user by their @username or numerical ID.',
        ['2'] = 'I cannot allowlist this user because they are a moderator or an administrator in this chat.',
        ['3'] = 'I cannot allowlist this user because they have already left this chat.',
        ['4'] = 'I cannot allowlist this user because they have already been banned from this chat.'
    },
    ['betaprofile'] = {
        ['1'] = '/betaprofile - Developer beta profiles to access the latest versions of iOS, it is advisable to download this profile from the device you want to use for it, if you want to block OTA updates, simply install the profile 🚫 NO OTAs.',
        ['2'] = 'Developer beta profiles to access the latest versions of iOS, it is advisable to download this profile from the device you want to use for it, if you want to block OTA updates, simply install the profile 🚫 NO OTAs.'
    }
}
