local autoGhost = {}
local myHero = Heroes.GetLocal()
local myTeam = Entity.GetTeamNum(myHero)

autoGhost.enabled = Menu.AddOptionBool({'Custom', 'Auto Ghost'}, 'Enabled', false)

function autoGhost.OnGameStart()
    myHero = Heroes.GetLocal()
    myTeam = Entity.GetTeamNum(myHero)
end

function autoGhost.useGhost(ent)
    if Entity.GetTeamNum(ent) == myTeam then return end -- phantom is enemy
    local vecBetween = Entity.GetOrigin(ent):Distance(Entity.GetOrigin(myHero))
    if vecBetween:Length2D() > 100 then return end -- + phantom jumped on us
    if not NPC.HasItem(myHero, 'item_ghost') then return end -- + we have ghost

    for k, v in pairs(Abilities.GetAll()) do
        if Ability.GetName(v) == 'item_ghost' then
            Ability.CastNoTarget(v)
        end
    end
end

function autoGhost.OnModifierCreate(ent, mod)
    if not Menu.IsEnabled(autoGhost.enabled) then return end

    if Modifier.GetName(mod) == 'modifier_phantom_assassin_phantom_strike' then
        autoGhost.useGhost(ent)
    end
end

return autoGhost