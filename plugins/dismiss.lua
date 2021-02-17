local dismiss = {}
local oneteam = require('oneteam')

function dismiss.on_callback_query(_, _, message)
    if message then
        return oneteam.delete_message(message.chat.id, message.message_id)
    end
    return
end

return dismiss