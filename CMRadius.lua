local cr = {}

local path = {'Custom', 'Freezing Field Radius'}

cr.enabled = Menu.AddOptionBool(path, 'Show', false)
Menu.AddMenuIcon(path, '~/Custom/freezingField.png')
-- https://cartierfam.xyz/storage/freezingField.png

local freezingField = 'modifier_crystal_maiden_freezing_field'
local circle
local ulting = false
local localHero = Heroes.GetLocal()

function cr.OnGameStart()
    localHero = Heroes.GetLocal()
end

function cr.OnUpdate()
    if not Menu.IsEnabled(cr.enabled) then return end
    if not ulting then return end
    cr.DrawCircle()
end

function cr.CreateCircle()
    circle = Particle.Create("particles\\ui_mouseactions\\drag_selected_ring.vpcf", Enum.ParticleAttachment.PATTACH_WORLDORIGIN, localHero)
    Particle.SetControlPoint(circle, 0, Entity.GetAbsOrigin(localHero))
    Particle.SetControlPoint(circle, 1, Vector(120, 120, 255))
    Particle.SetControlPoint(circle, 2, Vector(900, 255, 255))
end

function cr.DrawCircle()
    Particle.SetControlPoint(circle, 0, Entity.GetAbsOrigin(localHero))
    Particle.SetControlPoint(circle, 1, Vector(120, 120, 255))
    Particle.SetControlPoint(circle, 2, Vector(900, 255, 255))
end

function cr.DestroyCircle()
    Particle.Destroy(circle)
end

function cr.OnModifierCreate(ent, mod)
    if not Menu.IsEnabled(cr.enabled) then return end
    if Modifier.GetName(mod) ~= freezingField then return end
    cr.CreateCircle()
    ulting = true
end

function cr.OnModifierDestroy(ent, mod)
    if not Menu.IsEnabled(cr.enabled) then return end
    if Modifier.GetName(mod) ~= freezingField then return end
    ulting = false
    cr.DestroyCircle()
end

function cr.OnMenuOptionChange(option, oldValue, newValue)
    if option == cr.enabled and newValue == 0 then
        ulting = false
        cr.DestroyCircle()
    end
end

return cr
