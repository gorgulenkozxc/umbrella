local autoMsg = {}

local path = {"Custom", "Auto Message"}

local messages = {}
local localPlayer

-- Edit here ↓
messages.atTheEnd = {"ggwp", "gg, swap commends", "gg ez mid", "?"}

messages.onKill = {
    "?",
    "do you need pause?",
    "why u died?",
    "1000-7?",
    "993-7?",
    "ez bot",
    "why so sick?",
    "забавно, чел",
    "ты слишком простой для меня",
    ":)",
    ":(",
    "офай нахуй",
    "зачем ты живёшь?",
    "zxc и ты покойник",
    "трахать?",
    "не спим блять",
    "спокойной ночи",
    "доброе утро",
    "еблан?",
    "пчел...",
    "мне тебя жаль, чел",
    "чел, да ты же clown",
    "забавно, чел",
    "трахнул позера :(",
    "да, кажется я его убил",
    "фиксирую дауна",
    "прив чд? кд?",
    "шпрота?",
    "го похрустим пальчиками"
}
-- Edit here ↑

autoMsg.enabled = Menu.AddOptionBool(path, "Enabled", false)
autoMsg.msgAtTheEnd = Menu.AddOptionCombo(path, "Ancient Destroy", messages.atTheEnd, 1)
autoMsg.msgOnKill = Menu.AddOptionCombo(path, "After kill", messages.onKill, 1)
autoMsg.onKillRation = Menu.AddOptionSlider(path, "Chance (20% = 1 message per 5 kills)", 0, 100, 20)
autoMsg.onKillRandom = Menu.AddOptionBool(path, "Use random message on kill")
autoMsg.atTheEndRandom = Menu.AddOptionBool(path, "Use random message on ancient")

local function initVariables()
    localPlayer = Players.GetLocal()
end
initVariables()

local function sendMessage(menuOption)
    local l_messages, random, i

    if menuOption == autoMsg.msgAtTheEnd then
        l_messages = messages.atTheEnd
        random = Menu.IsEnabled(autoMsg.atTheEndRandom)
        i = Menu.GetValue(autoMsg.msgAtTheEnd) + 1
    else
        if menuOption == autoMsg.msgOnKill then
            if Menu.GetValue(autoMsg.onKillRation) < math.random(0, 100) then
                return
            end
            l_messages = messages.onKill
            random = Menu.IsEnabled(autoMsg.onKillRandom)
            i = Menu.GetValue(autoMsg.msgOnKill) + 1
        else
            return -- place for your callbacks
        end
    end

    if random then
        i = math.random(#l_messages)
    end

    Engine.ExecuteCommand("say " .. l_messages[i])
end

function autoMsg.OnGameStart()
    initVariables()
end

function autoMsg.OnStartSound(sound)
    if not Menu.IsEnabled(autoMsg.enabled) then
        return
    end

    if sound.name == "Dire.ancient.Destruction" then
        sendMessage(autoMsg.msgAtTheEnd)
    end

    if sound.name == "Radiant.ancient.Destruction" then
        sendMessage(autoMsg.msgAtTheEnd)
    end
end

function autoMsg.OnChatEvent(chatEvent)
    if not Menu.IsEnabled(autoMsg.enabled) then
        return
    end
    if chatEvent.type ~= Enum.DotaChatMessage.CHAT_MESSAGE_HERO_KILL then
        return
    end

    for k, v in pairs(chatEvent) do
        if (string.sub(k, 1, 8) == "playerid") and (k ~= "playerid_1") and (v == Player.GetPlayerID(localPlayer)) then
            sendMessage(autoMsg.msgOnKill)
        end
    end
end

return autoMsg
