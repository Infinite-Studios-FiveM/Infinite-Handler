Infinite = Infinite or {};
Infinite.Config = Infinite.Config or {};

local Character = {};
local Token = 'Neek'

Citizen.CreateThread(function()
    TriggerServerEvent('infinite-framework:obtainToken')

    if Infinite.Config.DevelopmentMode then
        SetRichPresence("1/1 | Developing @ Infinite Studios")
        SetDiscordAppId(1349464552185794663)
        SetDiscordRichPresenceAsset('infinite_studios')
        SetDiscordRichPresenceAssetSmall("infinite_studios") -- The name of the small picture you added in the application.
        SetDiscordRichPresenceAssetSmallText("Discord: discord.gg/9RvWUh8pNk")
        SetDiscordRichPresenceAction(0, "Click To Join", "https://discord.gg/9RvWUh8pNk")
    end
end)

function GetCurrentCharacter()
    local result = TriggerServerCallback('infinite-framework:ObtainCharacter')
    return result;
end

exports('GetCurrentCharacter', GetCurrentCharacter)