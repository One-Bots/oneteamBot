local currency = {}
local oneteam = require('oneteam')
local https = require('ssl.https')

function currency:init()
    currency.commands = oneteam.commands(self.info.username):command('currency'):command('convert'):command('cash').table
    currency.help = '/currency <amount> <from> to <to> - Converts exchange rates for various currencies via Google Finance. Aliases: /convert, /cash.'
    currency.url = 'https://www.google.com/finance/converter?from=%s&to=%s&a=%s'
end

function currency.on_message(_, message, _, language)
    local input = oneteam.input(message.text:upper())
    if input then
        input = input:gsub('%$', 'USD'):gsub('€', 'EUR'):gsub('£', 'GBP')
    end
    if not input or not input:match('^.- %a%a%a TO %a%a%a$') then
        return oneteam.send_reply(message, currency.help)
    end
    local amount, from, to = input:match('^(.-) (%a%a%a) TO (%a%a%a)$')
    amount = tonumber(amount) or 1
    local result = 1
    if from ~= to then
        local str, res = https.request(string.format(currency.url, from, to, amount))
        if res ~= 200 then
            return oneteam.send_reply(message, language.errors.connection)
        end
        str = str:match('<span class=bld>(.-) %u+</span>')
        if not str then
            return oneteam.send_reply(message, language.errors.results)
        end
        result = string.format('%.2f', str)
    end
    result = string.format('%s %s = %s %s', amount, from, result, to)
    return oneteam.send_message(message.chat.id, result)
end

return currency