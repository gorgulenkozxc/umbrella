local dmg = {}
dmg.heroes = {}

local localPlayer = {}
local path = {'Custom', 'Nyx Damage Panel'}
local font = Renderer.LoadFont('Tahoma', 18, Enum.FontWeight.NORMAL)
local settings = {}

local gameTimeFunction = GameRules.GetGameTime
dmg.checkTimer = 0
dmg.checkTimerInterval = 0.5

dmg.enabled = Menu.AddOptionBool(path, 'Enabled', false)
dmg.offsetX = Menu.AddOptionSlider(path, 'Offset X', -200, 200, 0)
dmg.offsetY = Menu.AddOptionSlider(path, 'Offset Y', -200, 200, 25)
dmg.size = Menu.AddOptionSlider(path, 'Size', 5, 30, 10)
dmg.showText = Menu.AddOptionBool(path, 'Show text', false)
dmg.threshold = Menu.AddOptionSlider(path, 'Threshold', 0, 200, 100)
dmg.color100 = Menu.AddOptionColorPicker(path, '100% kill', 66, 245, 117, 255)
dmg.color50 = Menu.AddOptionColorPicker(path, 'quite possible kill', 229, 232, 65, 255)
dmg.color0 = Menu.AddOptionColorPicker(path, 'not possible kill', 245, 66, 66, 255)


local damagesWiki = {
    impale = {100, 160, 220, 280},
    impaleTalant = 130,
    vendetta = {300, 450, 600},
    dagon = {400, 500, 600, 700, 800},
    
    manaBurn = {2.3, 3.2, 4.1, 5},
    manaBurnBonus = 0.5
}

local function initVariables()
    localPlayer.player = Players.GetLocal()
    localPlayer.hero = Heroes.GetLocal()
    localPlayer.team = Entity.GetTeamNum(localPlayer.player)
    localPlayer.name = NPC.GetUnitName(localPlayer.hero)
    
    dmg.checkTimer = gameTimeFunction() + dmg.checkTimerInterval
    settings.offsetX = Menu.GetValue(dmg.offsetX)
    settings.offsetY = Menu.GetValue(dmg.offsetY)
    settings.threshold = Menu.GetValue(dmg.threshold)
    settings.showText = Menu.IsEnabled(dmg.showText)
    settings.color100 = Menu.GetValue(dmg.color100)
    settings.color50 = Menu.GetValue(dmg.color50)
    settings.color0 = Menu.GetValue(dmg.color0)
    settings.size = Menu.GetValue(dmg.size)
end
initVariables()

local function getManaBurnDamage(hero)
    local int = Hero.GetIntellectTotal(hero)
    local mana = NPC.GetMana(hero)
    local manaBurnFactor = damagesWiki.manaBurn[localPlayer.manaBurnLevel] or 0
    if localPlayer.manaBurnBonus then
        manaBurnFactor = manaBurnFactor + damagesWiki.manaBurnBonus
    end
    local manaBurn = int * manaBurnFactor

    if mana < manaBurn then return math.floor(mana)
    else return math.floor(manaBurn) end
end

local function drawDmgInfo(id, hero)
    if not Entity.IsAlive(hero) or dmg.heroes[id] == nil or not NPC.IsVisible(hero) then return end
    local x, y, visible = Renderer.WorldToScreen(Entity.GetOrigin(hero))
    if not visible then return end

    local left = dmg.heroes[id] - getManaBurnDamage(hero)
    local clr
    if left < 0 then
        if left + settings.threshold < 0 then
            clr = settings.color100
        else
            clr = settings.color50
        end
    else
        clr = settings.color0
    end
    Renderer.SetDrawColor(clr.r, clr.g, clr.b, clr.a)

    if (settings.showText) then
        Renderer.DrawText(font, x + settings.offsetX, y + settings.offsetY, left)
    else
        Renderer.DrawFilledRect(x + settings.offsetX, y + settings.offsetY, settings.size, settings.size)
    end
end

local function updateDmg()
    -- Own damage
    localPlayer.magicalAmplify = 1
    localPlayer.magical = 0
    localPlayer.physical = 0
    localPlayer.pure = 0
    localPlayer.manaBurnBonus = false
    localPlayer.manaBurnLevel = 0
    
    local impale = NPC.GetAbility(localPlayer.hero, 'nyx_assassin_impale')
    local manaBurn = NPC.GetAbility(localPlayer.hero, 'nyx_assassin_mana_burn')
    local vendetta = NPC.GetAbility(localPlayer.hero, 'nyx_assassin_vendetta')
    
    if Ability.IsReady(impale) then impale = Ability.GetLevel(impale)
    else impale = 0 end

    if Ability.IsReady(manaBurn) then localPlayer.manaBurnLevel = Ability.GetLevel(manaBurn)
    else localPlayer.manaBurnLevel = 0 end
    
    if Ability.IsReady(vendetta) or NPC.HasModifier(localPlayer.hero, 'modifier_nyx_assassin_vendetta') then
        vendetta = Ability.GetLevel(vendetta)
    else vendetta = 0 end
    
    local dagon = 5
    local dagonReady = false
    
    while dagon > 0 do
        if dagon == 1 then
            if NPC.HasItem(localPlayer.hero, 'item_dagon') then
                dagonReady = Ability.IsReady(NPC.GetItem(localPlayer.hero, 'item_dagon'))
                break
            end
        end
        if NPC.HasItem(localPlayer.hero, 'item_dagon_' .. dagon) then
            dagonReady = Ability.IsReady(NPC.GetItem(localPlayer.hero, 'item_dagon_' .. dagon))
            break
        end
        dagon = dagon - 1
    end

    if not dagonReady then dagon = 0 end
    
    -- +8% magical damage | +130 impale damage | manaburn +0.5 bonus
    for _, ability in pairs(Abilities.GetAll()) do
        if Ability.GetLevel(ability) == 0 then goto continue end
        local name = Ability.GetName(ability)
        if string.find(name, 'special_bonus_spell_amplify') then
            localPlayer.magicalAmplify = 1 + 0.01 * tonumber(string.sub(name, -1))
        end
        if name == 'special_bonus_unique_nyx_2' then
            localPlayer.magical = localPlayer.magical + damagesWiki.impaleTalant
        end
        if name == 'special_bonus_unique_nyx_5' then
            localPlayer.manaBurnBonus = true
        end
        ::continue::
    end
    
    localPlayer.magical = localPlayer.magical + (damagesWiki.impale[impale] or 0) + (damagesWiki.dagon[dagon] or 0)
    localPlayer.physical = NPC.GetTrueDamage(localPlayer.hero) or 0
    localPlayer.pure = localPlayer.pure + (damagesWiki.vendetta[vendetta] or 0)
    
    localPlayer.magical = localPlayer.magical * localPlayer.magicalAmplify
    localPlayer.physical = localPlayer.physical * 3
    -- Own damage
    
    -- Cache damages
    dmg.heroes = {}
    for id, hero in pairs(Heroes.GetAll()) do
        if localPlayer.team == Entity.GetTeamNum(hero) then goto continue end
        
        local canAttack = 1
        if NPC.HasModifier(hero, 'modifier_ghost_state') or
            NPC.HasModifier(hero, 'modifier_item_ethereal_blade_ethereal') or
            NPC.HasModifier(hero, 'modifier_necrolyte_sadist_active') then
            canAttack = 0
        end
        dmg.heroes[id] = math.floor(Entity.GetHealth(hero)
            - localPlayer.magical * NPC.GetMagicalArmorDamageMultiplier(hero)
            - localPlayer.physical * NPC.GetPhysicalDamageReduction(hero) * canAttack
            - localPlayer.pure * canAttack)
        ::continue::
    end
    -- Cache damages
end
updateDmg()

function dmg.OnGameStart()
    initVariables()
end

function dmg.OnUpdate()
    if localPlayer.name ~= 'npc_dota_hero_nyx_assassin' then return end
    if not Menu.IsEnabled(dmg.enabled) then return end
    
    local gameTime = gameTimeFunction()
    if dmg.checkTimer < gameTime then
        dmg.checkTimer = gameTime + dmg.checkTimerInterval
        settings.offsetX = Menu.GetValue(dmg.offsetX)
        settings.offsetY = Menu.GetValue(dmg.offsetY)
        settings.threshold = Menu.GetValue(dmg.threshold)
        settings.showText = Menu.IsEnabled(dmg.showText)
        settings.color100 = Menu.GetValue(dmg.color100)
        settings.color50 = Menu.GetValue(dmg.color50)
        settings.color0 = Menu.GetValue(dmg.color0)
        settings.size = Menu.GetValue(dmg.size)
        updateDmg()
    end
end

function dmg.OnDraw()
    if localPlayer.name ~= 'npc_dota_hero_nyx_assassin' then return end
    if not Menu.IsEnabled(dmg.enabled) then return end
    
    for id, hero in pairs(Heroes.GetAll()) do
        if localPlayer.team ~= Entity.GetTeamNum(hero) then
            drawDmgInfo(id, hero)
        end
    end
end

return dmg
