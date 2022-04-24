local hooks = {}

local gameTimeFunction = GameRules.GetGameTime -- Var for OnUpdate

local myHero = Heroes.GetLocal() -- Local Hero
local myTeam = Entity.GetTeamNum(myHero)
local heroName = NPC.GetUnitName(myHero)

local mouse1 = Enum.ButtonCode.KEY_MOUSE1 -- Var to check if clicked on pos

local p = {"Hero Specific", "Strength", "Pudge", "Hook positions"} -- Path to HeroesCore options
local font = Renderer.LoadFont("Tahoma", 18, Enum.FontWeight.NORMAL)
local clr = {}

local lastSpot = Vector(0, 0, 0)
local blockActions = false -- Var to not allow pudge ruin block
local onlyOneTeam = true

local gameTimeFunction = GameRules.GetGameTime
hooks.HeroesCoreTimer = 0
hooks.HeroesCoreTimerInterval = 0.5

local hooksPosDire = {} -- Place TO hook dire (you are radiant)
    hooksPosDire["mid1"] = Vector(12, -498, 0)
    hooksPosDire["mid2"] = Vector(-973, -1413, 128) -- need axe
    hooksPosDire["hard1"] = Vector(-7201, 2261, 128)
    hooksPosDire["hard2"] = Vector(-6841, 2302, 128)
    hooksPosDire["hard3"] = Vector(-5336, 2196, 128)
    hooksPosDire["hard4"] = Vector(-6890, 4383, 128)
    hooksPosDire["hard5"] = Vector(-5150, 4861, 128)
    hooksPosDire["hard6"] = Vector(-4919, 4877, 128)
    hooksPosDire["forest1"] = Vector(1022, -2355, 256) -- need axe
    hooksPosDire["ez1"] = Vector(4544, -5477, 128)
    hooksPosDire["ez2"] = Vector(4930, -5348, 128)
    hooksPosDire["ez3"] = Vector(5799, -6442, 128)
    hooksPosDire["ez4"] = Vector(6022, -6458, 128) -- need axe
    hooksPosDire["ez5"] = Vector(7062, -4964, 128)
local hooksPosRadiant = {}
    hooksPosRadiant["before1min"] = Vector(2552, -4638, 128)
    hooksPosRadiant["mid1"] = Vector(-632, 1571, 128)
    hooksPosRadiant["mid2"] = Vector(1119, 224, 128) -- need axe
    hooksPosRadiant["hard1"] = Vector(4957, -2242, 128)
    hooksPosRadiant["hard2"] = Vector(7456, -2346, 128)
    hooksPosRadiant["hard3"] = Vector(7062, -4964, 128)
    hooksPosRadiant["ez1"] = Vector(-4811, 5223, 128)
    hooksPosRadiant["ez2"] = Vector(-6890, 4383, 128)
    hooksPosRadiant["ez3"] = Vector(-5144, 6662, 128)

    HeroesCore.UseCurrentPath(NPC.GetUnitName(Heroes.GetLocal()) == "npc_dota_hero_pudge")

    hooks.enabled = HeroesCore.AddOptionBool(p, "Enabled", false)
    hooks.onlyOneTeam = HeroesCore.AddOptionBool(p, "Only for your current team", true)
    hooks.boxColor = HeroesCore.AddOptionColorPicker(p, "Box color", 255, 255, 255, 255)

    HeroesCore.AddMenuIcon({"Hero Specific", "Strength", "Pudge"}, "panorama/images/heroes/icons/npc_dota_hero_pudge_png.vtex_c") -- путь p более конкретный чем Hero Specific/Pudge
    HeroesCore.AddMenuIcon(p, "panorama/images/spellicons/pudge_meat_hook_png.vtex_c")
    HeroesCore.AddOptionIcon(hooks.enabled, "~/MenuIcons/Enable/enable_check_boxed.png")
    HeroesCore.AddOptionIcon(hooks.onlyOneTeam, "~/MenuIcons/Enable/enable_ios.png")

function hooks.checkCoords(imgX, imgY, mouseX, mouseY)
    local x1, x2 = imgX, imgX+20
    local y1, y2 = imgY, imgY+20
    if (mouseX>x2 or mouseX<x1 or mouseY>y2 or mouseY<y1) then return false end
    return true
end

function hooks.drawFromTable(hooksPos)
    for _, pos in pairs(hooksPos) do
        local x, y, visible = Renderer.WorldToScreen(pos)
        local mouseX, mouseY = Input.GetCursorPos()

        if not visible then goto continue end
        Renderer.SetDrawColor(clr.r, clr.g, clr.b, clr.a)
        Renderer.DrawFilledRect(x, y, 20, 20)

        if Input.IsKeyDownOnce(mouse1) then
            if hooks.checkCoords(x, y, mouseX, mouseY) then
                NPC.MoveTo(myHero, pos, false)
                lastSpot = pos
            end
        end
        ::continue::
    end
end

function hooks.OnGameStart() 
    myHero = Heroes.GetLocal()
    myTeam = Entity.GetTeamNum(myHero)
    heroName = NPC.GetUnitName(myHero)
end

function hooks.OnUpdate()
    if not Menu.IsEnabled(hooks.enabled) then return end
    if not Heroes.GetLocal() then return end
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_pudge" then return end

    local gameTime = gameTimeFunction()
    if hooks.HeroesCoreTimer < gameTime then
        hooks.HeroesCoreTimer = gameTime + hooks.HeroesCoreTimerInterval
        onlyOneTeam = Menu.IsEnabled(hooks.onlyOneTeam)
        clr = Menu.GetValue(hooks.boxColor)
    end

    if blockActions then
        Engine.ExecuteCommand("+dota_stop")
    end
end

function hooks.OnStartSound(sound)
    if ((sound.name == "Hero_Pudge.AttackHookRetract") or (sound.name == "Hero_Pudge.Hook.Retract.Persona")) then
        if lastSpot:Distance(Entity.GetOrigin(myHero)):Length() < 100 then
            blockActions = true
        end
    elseif sound.name == "Hero_Pudge.AttackHookRetractStop" then
        blockActions = false
    end
end

function hooks.OnDraw()
    if not Menu.IsEnabled(hooks.enabled) then return end
    if not Heroes.GetLocal() then return end
    if heroName ~= "npc_dota_hero_pudge" then return end

    if onlyOneTeam then
        if myTeam == 3 then hooks.drawFromTable(hooksPosRadiant)
        else hooks.drawFromTable(hooksPosDire) end
    else
        hooks.drawFromTable(hooksPosDire)
        hooks.drawFromTable(hooksPosRadiant)
    end
end

return hooks