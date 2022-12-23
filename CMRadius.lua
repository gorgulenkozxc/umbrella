local cr = {}

local path = {'Custom', 'Freezing Field Radius'}

cr.enabled = Menu.AddOptionBool(path, 'Show', false)
Menu.AddMenuIcon(path, '~/Custom/freezingField.png')
-- https://cartierfam.xyz/storage/freezingField.png

local freezingField = 'modifier_crystal_maiden_freezing_field'
Engine.ExecuteCommand('dota_range_display 0')

function cr.OnModifierCreate(ent, mod)
    if not Menu.IsEnabled(cr.enabled) then return end
    if Modifier.GetName(mod) ~= freezingField then return end
    Engine.ExecuteCommand('dota_range_display 810')
end

function cr.OnModifierDestroy(ent, mod)
    if not Menu.IsEnabled(cr.enabled) then return end
    if Modifier.GetName(mod) ~= freezingField then return end
    Engine.ExecuteCommand('dota_range_display 0')
end

function cr.OnMenuOptionChange(option, oldValue, newValue)
    if option == cr.enabled and newValue == 0 then
        Engine.ExecuteCommand('dota_range_display 0')
    end
end

return cr
