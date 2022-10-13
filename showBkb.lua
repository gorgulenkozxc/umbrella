local showBkb = {}
showBkb.heroes = {}

local localPlayer = {}
local bkbImage = Renderer.LoadImage("panorama/images/items/black_king_bar_png.vtex_c")
local path = {"Custom", "Show BKB"}
local settings = {}

local gameTimeFunction = GameRules.GetGameTime
showBkb.checkTimer = 0
showBkb.checkTimerInterval = 0.5

showBkb.enabled = Menu.AddOptionBool(path, "Enabled", false)
showBkb.offsetX = Menu.AddOptionSlider(path, "Offset X", -200, 200, 0)
showBkb.offsetY = Menu.AddOptionSlider(path, "Offset Y", -200, 200, 0)

local function initVariables()
    localPlayer.player = Players.GetLocal()
    localPlayer.team = Entity.GetTeamNum(localPlayer.player)

    showBkb.checkTimer = gameTimeFunction() + showBkb.checkTimerInterval
    settings.offsetX = Menu.GetValue(showBkb.offsetX)
    settings.offsetY = Menu.GetValue(showBkb.offsetY)
end
initVariables()

local function drawBkbState(id, vecPos)
    local x, y, visible = Renderer.WorldToScreen(vecPos)
    if not visible then return end
    if showBkb.heroes[id] == nil then return end
    if (showBkb.heroes[id] ~= 0) then return end

    Renderer.SetDrawColor(255, 255, 255)
    Renderer.DrawImage(bkbImage, x + settings.offsetX, y + settings.offsetY, 25, 20)
end

local function updateBkbs()
    for id, hero in pairs(Heroes.GetAll()) do
        if localPlayer.team ~= Entity.GetTeamNum(hero) then
            showBkb.heroes[id] = Ability.GetCooldown(NPC.GetItem(hero, "item_black_king_bar"))
        end
    end
end

function showBkb.OnUpdate()
    if not Menu.IsEnabled(showBkb.enabled) then return end

    local gameTime = gameTimeFunction()
    if showBkb.checkTimer < gameTime then
        showBkb.checkTimer = gameTime + showBkb.checkTimerInterval
        settings.offsetX = Menu.GetValue(showBkb.offsetX)
        settings.offsetY = Menu.GetValue(showBkb.offsetY)
        updateBkbs()
    end
end

function showBkb.OnDraw()
    if not Menu.IsEnabled(showBkb.enabled) then return end

    for id, hero in pairs(Heroes.GetAll()) do
        if localPlayer.team ~= Entity.GetTeamNum(hero) then
            drawBkbState(id, Entity.GetAbsOrigin(hero))
        end
    end
end

return showBkb
