local exp = {}

local max = math.max
local floor = math.floor
local ceil = math.ceil

local function mod(a, b)
    return a - (math.floor(a/b)*b)
end


-- ██╗░░░██╗░█████╗░██████╗░██╗░█████╗░██████╗░██╗░░░░░███████╗░██████╗
-- ██║░░░██║██╔══██╗██╔══██╗██║██╔══██╗██╔══██╗██║░░░░░██╔════╝██╔════╝
-- ╚██╗░██╔╝███████║██████╔╝██║███████║██████╦╝██║░░░░░█████╗░░╚█████╗░
-- ░╚████╔╝░██╔══██║██╔══██╗██║██╔══██║██╔══██╗██║░░░░░██╔══╝░░░╚═══██╗
-- ░░╚██╔╝░░██║░░██║██║░░██║██║██║░░██║██████╦╝███████╗███████╗██████╔╝
-- ░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚══════╝╚══════╝╚═════╝░
local p = {"Utility", "Experience calc"} -- Path to menu options

local fullW, fullH = Renderer.GetScreenSize(); -- Full width, full height (1920, 1080)
local defX, defY = floor(fullW * 0,73), floor(fullH * 0,0185) -- (1400, 20)

local fontSize = 18
local font = Renderer.LoadFont("Tahoma", fontSize, Enum.FontWeight.NORMAL)
local def = {}
def["r"] = 255; def["g"] = 255; def["g"] = 255; def["a"] = 255
local steal = {}
steal["r"] = 255; steal["g"] = 255; steal["g"] = 255; steal["a"] = 255

local gameTimeFunction = GameRules.GetGameTime
exp.menuTimer = 0
exp.menuTimerInterval = 0.5
exp.mainTimer = 0
exp.mainTimerInterval = 0.3

local myHero = Heroes.GetLocal()

local onlyLane = true
local extraInfo = true

local meeleNames = { 
    "npc_dota_creep_badguys_melee", 
    "npc_dota_creep_badguys_melee_upgraded",
    "npc_dota_creep_badguys_melee_upgraded_mega",
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_melee_upgraded",
    "npc_dota_creep_goodguys_melee_upgraded_mega"
}
local rangeNames = { 
    "npc_dota_creep_badguys_ranged", 
    "npc_dota_creep_badguys_ranged_upgraded",
    "npc_dota_creep_badguys_ranged_upgraded_mega",
    "npc_dota_creep_goodguys_ranged",
    "npc_dota_creep_goodguys_ranged_upgraded",
    "npc_dota_creep_goodguys_ranged_upgraded_mega"
}
local siegeNames = {
    "npc_dota_badguys_siege",
    "npc_dota_badguys_siege_upgraded",
    "npc_dota_badguys_siege_upgraded_mega",
    "npc_dota_goodguys_siege",
    "npc_dota_goodguys_siege_upgraded",
    "npc_dota_goodguys_siege_upgraded_mega"
}
--

-- Text position
local StatusScreenPos = {}
StatusScreenPos.x = 0
StatusScreenPos.y = 0
--

-- Outer variables
local expSum = 0
local stealingHeroesAround = 0
local creepsToNextLevel = {} -- "m", "r", "s", "w"
local allCreepsAround = {}
local laneCreepsAround = {}
local laneCreepsAroundTypes = {}
laneCreepsAroundTypes["m"] = 0
laneCreepsAroundTypes["r"] = 0
laneCreepsAroundTypes["s"] = 0
local enemyCreeps = {}
local expToLvl = {}
expToLvl["lvl"] = 0
expToLvl["perc"] = 0
local need = 0
--

-- Experience variables
local expWiki = {}
expWiki.heroLevelsInExp = {
    0, 230, 600, 1080, 1660, 2260, 2980, 3730, 4620, 5550, 6520, 7530, 9805, 11055, 12330, 13630, 14955, 16455, 18045, 19645, 21495, 23595, 25945, 28545, 32045, 36545, 42045, 48545, 56045
}
expWiki.expSources = {}
    expWiki.expSources["npc_dota_creep_badguys_ranged"] = 69
    expWiki.expSources["npc_dota_creep_badguys_ranged_upgraded"] = 22
    expWiki.expSources["npc_dota_creep_badguys_ranged_upgraded_mega"] = 22
    expWiki.expSources["npc_dota_creep_goodguys_ranged"] = 69
    expWiki.expSources["npc_dota_creep_goodguys_ranged_upgraded"] = 22
    expWiki.expSources["npc_dota_creep_goodguys_ranged_upgraded_mega"] = 22
    expWiki.expSources["npc_dota_creep_badguys_melee"] = 57
    expWiki.expSources["npc_dota_creep_badguys_melee_upgraded"] = 25
    expWiki.expSources["npc_dota_creep_badguys_melee_upgraded_mega"] = 25
    expWiki.expSources["npc_dota_creep_goodguys_melee"] = 57
    expWiki.expSources["npc_dota_creep_goodguys_melee_upgraded"] = 25
    expWiki.expSources["npc_dota_creep_goodguys_melee_upgraded_mega"] = 25
    expWiki.expSources["npc_dota_goodguys_siege"] = 88
    expWiki.expSources["npc_dota_goodguys_siege_upgraded"] = 88
    expWiki.expSources["npc_dota_goodguys_siege_upgraded_mega"] = 88
    expWiki.expSources["npc_dota_badguys_siege"] = 88
    expWiki.expSources["npc_dota_badguys_siege_upgraded"] = 88
    expWiki.expSources["npc_dota_badguys_siege_upgraded_mega"] = 88
    expWiki.expSources["npc_dota_juggernaut_healing_ward"] = 75
    expWiki.expSources["npc_dota_neutral_kobold"] = 14
    expWiki.expSources["npc_dota_neutral_kobold_tunneler"] = 17
    expWiki.expSources["npc_dota_neutral_kobold_taskmaster"] = 30
    expWiki.expSources["npc_dota_neutral_centaur_outrunner"] = 32
    expWiki.expSources["npc_dota_neutral_centaur_khan"] = 90
    expWiki.expSources["npc_dota_neutral_fel_beast"] = 26
    expWiki.expSources["npc_dota_neutral_polar_furbolg_champion"] = 66
    expWiki.expSources["npc_dota_neutral_polar_furbolg_ursa_warrior"] = 90
    expWiki.expSources["npc_dota_neutral_warpine_raider"] = 76
    expWiki.expSources["npc_dota_neutral_mud_golem"] = 32
    expWiki.expSources["npc_dota_neutral_mud_golem_split"] = 18
    expWiki.expSources["npc_dota_neutral_mud_golem_split_doom"] = 18
    expWiki.expSources["npc_dota_neutral_ogre_mauler"] = 32
    expWiki.expSources["npc_dota_neutral_ogre_magi"] = 48
    expWiki.expSources["npc_dota_neutral_giant_wolf"] = 40
    expWiki.expSources["npc_dota_neutral_alpha_wolf"] = 60
    expWiki.expSources["npc_dota_neutral_wildkin"] = 26
    expWiki.expSources["npc_dota_neutral_enraged_wildkin"] = 90
    expWiki.expSources["npc_dota_neutral_satyr_soulstealer"] = 46
    expWiki.expSources["npc_dota_neutral_satyr_hellcaller"] = 90
    expWiki.expSources["npc_dota_neutral_jungle_stalker"] = 95
    expWiki.expSources["npc_dota_neutral_elder_jungle_stalker"] = 124
    expWiki.expSources["npc_dota_neutral_prowler_acolyte"] = 50
    expWiki.expSources["npc_dota_neutral_prowler_shaman"] = 95
    expWiki.expSources["npc_dota_neutral_rock_golem"] = 95
    expWiki.expSources["npc_dota_neutral_granite_golem"] = 124
    expWiki.expSources["npc_dota_neutral_ice_shaman"] = 124
    expWiki.expSources["npc_dota_neutral_frostbitten_golem"] = 95
    expWiki.expSources["npc_dota_neutral_big_thunder_lizard"] = 124
    expWiki.expSources["npc_dota_neutral_small_thunder_lizard"] = 95
    expWiki.expSources["npc_dota_neutral_gnoll_assassin"] = 30
    expWiki.expSources["npc_dota_neutral_ghost"] = 42
    expWiki.expSources["npc_dota_wraith_ghost"] = 14
    expWiki.expSources["npc_dota_neutral_dark_troll"] = 42
    expWiki.expSources["npc_dota_neutral_dark_troll_warlord"] = 90
    expWiki.expSources["npc_dota_neutral_satyr_trickster"] = 24
    expWiki.expSources["npc_dota_neutral_forest_troll_berserker"] = 28
    expWiki.expSources["npc_dota_neutral_forest_troll_high_priest"] = 28
    expWiki.expSources["npc_dota_neutral_harpy_scout"] = 26
    expWiki.expSources["npc_dota_neutral_harpy_storm"] = 42
    expWiki.expSources["npc_dota_neutral_black_drake"] = 95
    expWiki.expSources["npc_dota_neutral_black_dragon"] = 124
    expWiki.expSources["npc_dota_necronomicon_warrior_1"] = 50
    expWiki.expSources["npc_dota_necronomicon_warrior_2"] = 100
    expWiki.expSources["npc_dota_necronomicon_warrior_3"] = 150
    expWiki.expSources["npc_dota_necronomicon_archer_1"] = 50
    expWiki.expSources["npc_dota_necronomicon_archer_2"] = 100
    expWiki.expSources["npc_dota_necronomicon_archer_3"] = 150
    expWiki.expSources["npc_dota_observer_wards"] = 100
    expWiki.expSources["npc_dota_flying_courier"] = 349
    expWiki.expSources["npc_dota_shadow_shaman_ward_1"] = 31
    expWiki.expSources["npc_dota_venomancer_plague_ward_1"] = 20
    expWiki.expSources["npc_dota_venomancer_plague_ward_2"] = 25
    expWiki.expSources["npc_dota_venomancer_plague_ward_3"] = 30
    expWiki.expSources["npc_dota_venomancer_plague_ward_4"] = 35
    expWiki.expSources["npc_dota_lesser_eidolon"] = 12
    expWiki.expSources["npc_dota_furion_treant_1"] = 12
    expWiki.expSources["npc_dota_furion_treant_2"] = 12
    expWiki.expSources["npc_dota_furion_treant_3"] = 12
    expWiki.expSources["npc_dota_furion_treant_4"] = 12
    expWiki.expSources["npc_dota_furion_treant_large"] = 30
    expWiki.expSources["npc_dota_invoker_forged_spirit"] = 31
    expWiki.expSources["npc_dota_broodmother_spiderling"] = 9
    expWiki.expSources["npc_dota_broodmother_spiderite"] = 3
    expWiki.expSources["npc_dota_dark_troll_warlord_skeleton_warrior"] = 4
    expWiki.expSources["npc_dota_clinkz_skeleton_archer"] = 20
    expWiki.expSources["npc_dota_roshan"] = 400
    expWiki.expSources["npc_dota_roshan_halloween"] = 1789
    expWiki.expSources["npc_dota_roshan_halloween_minion"] = 100
    expWiki.expSources["npc_dota_warlock_golem_1"] = 98
    expWiki.expSources["npc_dota_warlock_golem_2"] = 98
    expWiki.expSources["npc_dota_warlock_golem_3"] = 98
    expWiki.expSources["npc_dota_warlock_golem_scepter_1"] = 98
    expWiki.expSources["npc_dota_warlock_golem_scepter_2"] = 98
    expWiki.expSources["npc_dota_warlock_golem_scepter_3"] = 98
    expWiki.expSources["npc_dota_scout_hawk"] = 20
    expWiki.expSources["npc_dota_greater_hawk"] = 77
    expWiki.expSources["npc_dota_beastmaster_hawk"] = 77
    expWiki.expSources["npc_dota_beastmaster_hawk_1"] = 77
    expWiki.expSources["npc_dota_beastmaster_hawk_2"] = 77
    expWiki.expSources["npc_dota_beastmaster_hawk_3"] = 77
    expWiki.expSources["npc_dota_beastmaster_hawk_4"] = 77
    expWiki.expSources["npc_dota_beastmaster_boar"] = 59
    expWiki.expSources["npc_dota_beastmaster_greater_boar"] = 59
    expWiki.expSources["npc_dota_beastmaster_boar_1"] = 60
    expWiki.expSources["npc_dota_beastmaster_boar_2"] = 70
    expWiki.expSources["npc_dota_beastmaster_boar_3"] = 80
    expWiki.expSources["npc_dota_beastmaster_boar_4"] = 90
    expWiki.expSources["npc_dota_weaver_swarm"] = 20
    expWiki.expSources["npc_dota_gyrocopter_homing_missile"] = 20
    expWiki.expSources["npc_dota_lycan_wolf1"] = 20
    expWiki.expSources["npc_dota_lycan_wolf2"] = 20
    expWiki.expSources["npc_dota_lycan_wolf3"] = 20
    expWiki.expSources["npc_dota_lycan_wolf4"] = 20
    expWiki.expSources["npc_dota_lycan_wolf_lane"] = 10
    expWiki.expSources["npc_dota_lone_druid_bear1"] = 300
    expWiki.expSources["npc_dota_visage_familiar1"] = 41
    expWiki.expSources["npc_dota_wisp_spirit"] = 12
    expWiki.expSources["npc_dota_beastmaster_axe"] = 12
    expWiki.expSources["npc_dota_troll_warlord_axe"] = 12
    expWiki.expSources["npc_dota_creep_goodguys_melee_diretide"] = 62
    expWiki.expSources["npc_dota_creep_goodguys_ranged_diretide"] = 41
    expWiki.expSources["npc_dota_creep_badguys_melee_diretide"] = 62
    expWiki.expSources["npc_dota_creep_badguys_ranged_diretide"] = 41
    expWiki.expSources["npc_dota_goodguys_siege_diretide"] = 100
    expWiki.expSources["npc_dota_badguys_siege_diretide"] = 100
    expWiki.expSources["npc_dota_halloween_chaos_unit"] = 25
    expWiki.expSources["npc_dota_greevil"] = 200
    expWiki.expSources["npc_dota_loot_greevil"] = 200
    expWiki.expSources["npc_dota_techies_stasis_trap"] = 6
    expWiki.expSources["npc_dota_bounty_hunter_bear_trap"] = 6
    expWiki.expSources["npc_dota_techies_remote_mine"] = 6
    expWiki.expSources["npc_dota_lich_ice_spire"] = 20
    expWiki.expSources["npc_dota_goodguys_cny_beast"] = 250
    expWiki.expSources["npc_dota_badguys_cny_beast"] = 250
    expWiki.expSources["npc_dota_mutation_pocket_roshan"] = 150
    expWiki.expSources["npc_dota_grimstroke_ink_creature"] = 10
    expWiki.expSources["npc_dota_treant_life_bomb"] = 6
--


-- ███╗░░░███╗███████╗███╗░░██╗██╗░░░██╗
-- ████╗░████║██╔════╝████╗░██║██║░░░██║
-- ██╔████╔██║█████╗░░██╔██╗██║██║░░░██║
-- ██║╚██╔╝██║██╔══╝░░██║╚████║██║░░░██║
-- ██║░╚═╝░██║███████╗██║░╚███║╚██████╔╝
-- ╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚══╝░╚═════╝░
exp.enabled = Menu.AddOptionBool(p, "Enabled", true)
exp.extraInfo = Menu.AddOptionBool(p, "Extra info", true)
exp.onlyLane = Menu.AddOptionBool(p, "Only lane creeps", true)
exp.fontSize = Menu.AddOptionSlider(p, "Font size:", 8, 42, 18)
exp.posX = Menu.AddOptionSlider(p, "Pos x:", 0, fullW, defX)
exp.posY = Menu.AddOptionSlider(p, "Pos y:", 0, fullH, defY)
exp.fontColor = Menu.AddOptionColorPicker(p, "Text color", def["r"], def["g"], def["b"], def["a"])
exp.stealingFontColor = Menu.AddOptionColorPicker(p, "Text color when stealing", steal["r"], steal["g"], steal["b"], steal["a"])
Menu.AddMenuIcon(p, "~/Overwolf/hard_support.png")


HeroesCore.AddOptionIcon(exp.enabled, "~/MenuIcons/Enable/enable_check_boxed.png")

HeroesCore.AddOptionIcon(exp.enabled, "~/MenuIcons/Enable/enable_check_boxed.png")
HeroesCore.AddOptionIcon(exp.extraInfo, "~/MenuIcons/Enable/enable_ios.png")
HeroesCore.AddOptionIcon(exp.onlyLane, "~/MenuIcons/Enable/enable_ios.png")
HeroesCore.AddOptionIcon(exp.fontSize, "~/MenuIcons/size.png")
HeroesCore.AddOptionIcon(exp.posX, "~/MenuIcons/edit.png")
HeroesCore.AddOptionIcon(exp.posY, "~/MenuIcons/edit.png")

-- ░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗
-- ██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║
-- ██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║
-- ██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║
-- ╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║
-- ░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝

-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░
function exp.updateMenu()
    StatusScreenPos.x, StatusScreenPos.y = Menu.GetValue(exp.posX), Menu.GetValue(exp.posY)

    local c = Menu.GetValue(exp.fontColor)
    def["r"], def["g"], def["b"], def["a"] = c.r, c.g, c.b, c.a
    c = Menu.GetValue(exp.stealingFontColor)
    steal["r"], steal["g"], steal["b"], steal["a"] = c.r, c.g, c.b, c.a

    local newFontSize = Menu.GetValue(exp.fontSize)
    if fontSize ~=  newFontSize then font = Renderer.LoadFont("Tahoma", newFontSize, Enum.FontWeight.NORMAL) end

    onlyLane = Menu.IsEnabled(exp.onlyLane)
    extraInfo = Menu.IsEnabled(exp.extraInfo)
end

local function stringInList(items, item)
    for _, v in pairs(items) do
        if v == item then
            return true
        end
    end

    return false
end

function exp.updateInfo()
    expSum = 0
    allCreepsAround = {}
    laneCreepsAround = {}
    enemyCreeps = {}

    local unitsAround = Entity.GetUnitsInRadius(myHero, 1500, Enum.TeamType.TEAM_ENEMY)
    
    local m = 0
    local r = 0
    local s = 0

    local ins = table.insert -- ins(table_to_insert, value_to_insert)

    -- Get all creeps around local hero
    for _, unit in pairs(unitsAround) do
        local name = NPC.GetUnitName(unit)
        if not expWiki.expSources[name] then goto continue end
        
        local isCreep = NPC.IsCreep(unit)
        local isLaneCreep = NPC.IsLaneCreep(unit)

        if onlyLane then
            if isLaneCreep then
                expSum = expSum + expWiki.expSources[name]/(stealingHeroesAround+1)
            end
        else
            expSum = expSum + expWiki.expSources[name]/(stealingHeroesAround+1)
        end
        
        -- If unit isn't creep then you don't want him to
        -- affect creeps stats and just skip it
        if not isCreep then goto continue  end
        ins(allCreepsAround, unit)

        if not NPC.IsLaneCreep(unit) then goto continue end
        ins(laneCreepsAround, unit)

        if stringInList(meeleNames, name) then 
            m = m + 1
        elseif stringInList(rangeNames, name) then
            r = r + 1
        elseif stringInList(siegeNames, name) then
            s = s + 1
        end

        ::continue::
    end
    --

    local creepsAround = {}
    if onlyLane then
        creepsAround = laneCreepsAround
    else
        creepsAround = allCreepsAround
    end

    local maxHeroes = 0
    -- Get all heroes around each creep
    for _, creep in pairs(creepsAround) do
        local name = NPC.GetUnitName(creep)
        -- For enemy creep our teammate is enemy 🤯
        local heroesAroundCreep = Entity.GetHeroesInRadius(creep, 1500, Enum.TeamType.TEAM_ENEMY)
        if #heroesAroundCreep > maxHeroes then maxHeroes = #heroesAroundCreep end
    end
    --
    stealingHeroesAround = max(maxHeroes-1, 0)
    laneCreepsAroundTypes["m"] = m
    laneCreepsAroundTypes["r"] = r
    laneCreepsAroundTypes["s"] = s

    -- Experience calculation
    local curExp = Hero.GetCurrentXP(myHero)
    local totalExp = curExp + expSum
    local curLvl = 1
    
    local nextLvl = 1
    local nextExp = 1

    for lvl = 1, #expWiki.heroLevelsInExp do
        if curExp < expWiki.heroLevelsInExp[lvl] then
            curLvl = lvl-1
            break
        end
    end

    for lvl = 1, #expWiki.heroLevelsInExp do
        if totalExp < expWiki.heroLevelsInExp[lvl] then
            nextLvl = lvl-1
            break
        end
    end
    nextExp = expWiki.heroLevelsInExp[nextLvl+1] - expWiki.heroLevelsInExp[nextLvl]

    expToLvl["lvl"] = nextLvl
    expToLvl["perc"] = ceil(100*(totalExp - expWiki.heroLevelsInExp[nextLvl]) / nextExp)

    need = expWiki.heroLevelsInExp[curLvl+1] - curExp
    --
end


-- ███╗░░░███╗░█████╗░██╗███╗░░██╗  ██╗░░░░░░█████╗░░█████╗░██████╗░
-- ████╗░████║██╔══██╗██║████╗░██║  ██║░░░░░██╔══██╗██╔══██╗██╔══██╗
-- ██╔████╔██║███████║██║██╔██╗██║  ██║░░░░░██║░░██║██║░░██║██████╔╝
-- ██║╚██╔╝██║██╔══██║██║██║╚████║  ██║░░░░░██║░░██║██║░░██║██╔═══╝░
-- ██║░╚═╝░██║██║░░██║██║██║░╚███║  ███████╗╚█████╔╝╚█████╔╝██║░░░░░
-- ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝  ╚══════╝░╚════╝░░╚════╝░╚═╝░░░░░
function exp.OnGameStart() 
    myHero = Heroes.GetLocal()
end

function exp.OnUpdate()
    if not Menu.IsEnabled(exp.enabled) then return end
    if not Heroes.GetLocal() then return end

    local gameTime = gameTimeFunction()
    if exp.menuTimer < gameTime then
        exp.menuTimer = gameTime + exp.menuTimerInterval
        exp.updateMenu()
    end

    if exp.mainTimer < gameTime then
        exp.mainTimer = gameTime + exp.mainTimerInterval
        exp.updateInfo()
    end
end

function exp.OnDraw()
    if not Menu.IsEnabled(exp.enabled) then return end
    if not Heroes.GetLocal() then return end

    if stealingHeroesAround ~= 0 then
        Renderer.SetDrawColor(steal["r"], steal["g"], steal["b"], steal["a"])
    else
        Renderer.SetDrawColor(def["r"], def["g"], def["b"], def["a"])
    end

    local d = 20 -- pixels between lines of text
    local x, y = StatusScreenPos.x, StatusScreenPos.y

    local lStealing = "Stealing: " .. stealingHeroesAround
    local lAllCreeps = "All creeps: " .. (#allCreepsAround)
    local lLaneCreeps = "Lane creeps: " .. (#laneCreepsAround)
    local lTypes = "M:" .. laneCreepsAroundTypes["m"] .. "  R:" .. laneCreepsAroundTypes["r"] .. "  S:" .. laneCreepsAroundTypes["s"]
    local lFactExp = "Exp: " .. ceil(expSum)
    local lExpToLvl = "Lvl: " .. expToLvl["lvl"] .. " + " .. expToLvl["perc"] .. "%"
    local lNeed = "Need: " .. need

-- Teammates around creeps that are in range of your expreience gain
-- [Extra] Number of creeps around you
-- [Extra] M - Meele, R - range, S - siege
-- [Extra] Experience from creeps around you
-- Experience that you will receive, and it's value as "plus" percent to your level
-- [For example: You 1 lvl, 84/230 exp (36.52%). On the line one meele creep, that gives you 88 exp after death
-- 88 is 38.26% from 230, so result will be 36.52+38.26=74.78%]
-- If line contains more than 1 lvl for you, it will show +X lvl, Y%]
-- How much exp do you need to next level

-- OnlyLane + Extra: lStealing, lLaneCreeps, lTypes, lFactExp, lExpToLvl, lNeed
-- OnlyLane: lStealing, lLaneCreeps, lExpToLvl, lNeed
-- Extra: lStealing, lAllCreeps, lFactExp, lExpToLvl, lNeed
-- None: lStealing, lExpToLvl, lNeed

    if onlyLane and extraInfo then
        Renderer.DrawText(font, x, y+d*0, lStealing)
        Renderer.DrawText(font, x, y+d*1, lLaneCreeps)
        Renderer.DrawText(font, x, y+d*2, lTypes)
        Renderer.DrawText(font, x, y+d*3, lFactExp)
        Renderer.DrawText(font, x, y+d*4, lExpToLvl)
        Renderer.DrawText(font, x, y+d*5, lNeed)
    elseif onlyLane then
        Renderer.DrawText(font, x, y+d*0, lStealing)
        Renderer.DrawText(font, x, y+d*1, lLaneCreeps)
        Renderer.DrawText(font, x, y+d*2, lExpToLvl)
        Renderer.DrawText(font, x, y+d*3, lNeed)
    elseif extraInfo then
        Renderer.DrawText(font, x, y+d*0, lStealing)
        Renderer.DrawText(font, x, y+d*1, lAllCreeps)
        Renderer.DrawText(font, x, y+d*2, lFactExp)
        Renderer.DrawText(font, x, y+d*3, lExpToLvl)
        Renderer.DrawText(font, x, y+d*4, lNeed)
    else
        Renderer.DrawText(font, x, y+d*0, lStealing)
        Renderer.DrawText(font, x, y+d*1, lExpToLvl)
        Renderer.DrawText(font, x, y+d*2, lNeed)
    end

end

return exp


-- ░█████╗░██████╗░███████╗░█████╗░████████╗███████╗██████╗░  ██████╗░██╗░░░██╗
-- ██╔══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗  ██╔══██╗╚██╗░██╔╝
-- ██║░░╚═╝██████╔╝█████╗░░███████║░░░██║░░░█████╗░░██║░░██║  ██████╦╝░╚████╔╝░
-- ██║░░██╗██╔══██╗██╔══╝░░██╔══██║░░░██║░░░██╔══╝░░██║░░██║  ██╔══██╗░░╚██╔╝░░
-- ╚█████╔╝██║░░██║███████╗██║░░██║░░░██║░░░███████╗██████╔╝  ██████╦╝░░░██║░░░
-- ░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═════╝░  ╚═════╝░░░░╚═╝░░░

-- ░██████╗░██████╗██████╗░░█████╗░███╗░░██╗██╗░░██╗███████╗██████╗░░██████╗░██╗░░██╗░█████╗░██╗░░░██╗██╗░░░░░
-- ██╔════╝██╔════╝██╔══██╗██╔══██╗████╗░██║██║░██╔╝██╔════╝██╔══██╗██╔════╝░██║░░██║██╔══██╗██║░░░██║██║░░░░░
-- ╚█████╗░╚█████╗░██████╔╝███████║██╔██╗██║█████═╝░█████╗░░██║░░██║██║░░██╗░███████║██║░░██║██║░░░██║██║░░░░░
-- ░╚═══██╗░╚═══██╗██╔══██╗██╔══██║██║╚████║██╔═██╗░██╔══╝░░██║░░██║██║░░╚██╗██╔══██║██║░░██║██║░░░██║██║░░░░░
-- ██████╔╝██████╔╝██║░░██║██║░░██║██║░╚███║██║░╚██╗███████╗██████╔╝╚██████╔╝██║░░██║╚█████╔╝╚██████╔╝███████╗
-- ╚═════╝░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═╝░░╚═╝╚══════╝╚═════╝░░╚═════╝░╚═╝░░╚═╝░╚════╝░░╚═════╝░╚══════╝

-- 𝘵.𝘮𝘦/𝘴𝘶𝘣𝘹𝘺𝘷
