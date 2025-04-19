Infinite = Infinite or {};
Infinite.Config = Infinite.Config or {};
local ESX = nil;
local QBCore = nil;

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

Citizen.CreateThread(function()
    if Infinite.Config.Framework == 'qb-core' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Infinite.Config.Framework == 'qbox' then
        QBCore = exports['qbox-core']:GetCoreObject()
    elseif Infinite.Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

function GetCurrentCharacter()
    local result = TriggerServerCallback('infinite-framework:ObtainCharacter')
    return result;
end

exports('GetCurrentCharacter', GetCurrentCharacter

--[[
    ESX Exports
]]

if Infinite.Config.Framework == 'esx' then
    local function ObtainItemList() 
        return TriggerServerCallback('infinite-handler:ObtainItemList')
    end

    exports('GetItemList', ObtainItemList)

    RegisterNetEvent('immense-handler:PerformNotification', function(message, type)
        ESX.ShowNotification(message, type)
    end)

    local function GetJobData()
        -- returns job and grade
        local playerData = ESX.GetPlayerData()
        local job = playerData.job.name
        local grade = playerData.job.grade.level
        return {job = job, grade = grade}
    end

    exports('GetJobData', GetJobData)

    local function ObtainPlayerCash()
        return TriggerServerCallback('infinite-handler:ObtainPlayerCash')
    end

    exports('GetPlayerCash', ObtainPlayerCash)
end

if Infinite.Config.Framework == 'qb-core' or Infinite.Config.Framework == 'qbox' then
    local function ObtainItemList() 
        return QBCore.Shared.Items
    end

    exports('GetItemList', ObtainItemList)

    local function GetJobData()
        -- returns job and grade
        local playerData = QBCore.Functions.GetPlayerData()
        local job = playerData.job.name
        local grade = playerData.job.grade.level
        return {job = job, grade = grade}
    end

    exports('GetJobData', GetJobData)

    local function ObtainPlayerCash()
        return TriggerServerCallback('infinite-handler:ObtainPlayerCash')
    end

    exports('GetPlayerCash', ObtainPlayerCash)
end
