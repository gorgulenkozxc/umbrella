local tg = {}

local path = {'Custom', 'Show tower glyph'}
local font = Renderer.LoadFont('Tahoma', 18, Enum.FontWeight.NORMAL)

tg.enabled = Menu.AddOptionBool(path, 'Enabled', false)
tg.behaviour = Menu.AddOptionCombo(path, 'Behaviour', {'All', 'Only enemy', 'Only ally'}, 1)
tg.color = Menu.AddOptionColorPicker(path, 'Text color', 255, 255, 255, 255)
tg.lasthit = Menu.AddOptionBool(path, 'Try last hit', false)

local localPlayer, localHero
local glyph = false
local towersVecs = {}

local gameTimeFunction = GameRules.GetGameTime

function initVariables()
    localPlayer = Players.GetLocal()
    localHero = Heroes.GetLocal()
end
initVariables()

local function insertTower(tower, glyphEnd)
    if not NPC.HasModifier(tower, 'modifier_fountain_glyph') then return end
    towersVecs[glyphEnd] = Entity.GetOrigin(tower)
end

function tg.OnModifierCreate(ent, mod)
    if Modifier.GetName(mod) ~= 'modifier_fountain_glyph' then return end
    glyph = true

    towersVecs = {}   
    local behaviour = Menu.GetValue(tg.behaviour)
    local team = Entity.GetTeamNum(localPlayer)
    local glyphEnd = Modifier.GetDieTime(mod)
    for _, tower in pairs(Towers.GetAll()) do
        if behaviour == 0 then
            insertTower(tower, glyphEnd)
        end
        if behaviour == 1 then -- only enemy towers
            if team ~= Entity.GetTeamNum(tower) then
                insertTower(tower, glyphEnd)
            end
        end
        if behaviour == 2 then -- only ally towers
            if team == Entity.GetTeamNum(tower) then
                insertTower(tower, glyphEnd)
            end
        end
    end
end

local function tryLastHit(tower)
    if not Menu.IsEnabled(tg.lasthit) then return end
    if not NPC.IsEntityInRange(localHero, tower, NPC.GetAttackRange(localHero) + 200) then return end -- 200 is correction due to tower radius
    if NPC.GetTrueDamage(localHero) * NPC.GetPhysicalDamageReduction(tower) < Entity.GetHealth(tower) then return end
    Player.AttackTarget(localPlayer, localHero, tower)
end

function tg.OnModifierDestroy(ent, mod)
    if Modifier.GetName(mod) == 'modifier_fountain_glyph' then
        glyph = false
        towerVecs = {}
        tryLastHit(ent)
    end
end

function tg.OnDraw()
    if not Menu.IsEnabled(tg.enabled) then return end
    if not glyph then return end
    for glyphEnd, towerVec in pairs(towersVecs) do
        local x, y, visible = Renderer.WorldToScreen(towerVec)
        if visible then
            local clr = Menu.GetValue(tg.color) 
            Renderer.SetDrawColor(clr.r, clr.g, clr.b)
            Renderer.DrawText(font, x, y, math.floor(10 * (glyphEnd - gameTimeFunction())) * 0.1 + 0.1)
        end
    end
end

return tg
