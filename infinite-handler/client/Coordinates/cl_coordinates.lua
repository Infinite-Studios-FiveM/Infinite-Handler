RegisterCommand('coords', function(source, args)
    local arg = args[1]
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    if not arg then arg = "vector4" end

    if arg == "vector4" then
        SendNUIMessage({
            coords = "vector4("..coords.x..", "..coords.y..", "..coords.z..", "..heading..")"
        })
    elseif arg == "vector3" then
        SendNUIMessage({
            coords = "vector3("..coords.x..", "..coords.y..", "..coords.z..")"
        })
    elseif arg == "vector2" then
        SendNUIMessage({
            coords = "vector2("..coords.x..", "..coords.y..")"
        })
    elseif arg == "coords" then
        SendNUIMessage({
            coords = coords.x..", "..coords.y..", "..coords.z..", "..heading
        })
    end

    -- QBCore.Functions.Notify("Coords have been copied to clipboard", "success")
end)