Infinite = Infinite or {};
Infinite.Anticheat = Infinite.Anticheat or {};
Infinite.Anticheat.Token = Infinite.Anticheat.Token or nil;
Infinite.Config = Infinite.Config or {};
Infinite.Config.DevelopmentMode = Infinite.Config.DevelopmentMode or false;
local ESX = nil;
local QBCore = nil;
-- QBCore = QBCore or exports['qb-core']:GetCoreObject();

Infinite.Anticheat.GenerateToken = function()
    local letters = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}
    Infinite.Anticheat.Token = 'Infinite-' ..math.random(1111, 4444) .. letters[math.random(1, #letters)] .. letters[math.random(1, #letters)] .. math.random(1111, 9999) .. letters[math.random(1, #letters)] .. letters[math.random(1, #letters)] .. letters[math.random(1, #letters)] .. letters[math.random(1, #letters)] .. letters[math.random(1, #letters)]
    print('^4[infinite-handler] ^8 Anticheat Token Generated ^7[^6' .. Infinite.Anticheat.Token .. '^7]')
    TriggerClientEvent('infinite-framework:obtainToken', -1, Infinite.Anticheat.Token)
end

local function GetDevMode()
    return Infinite.DeveloperMode;
end

local function GetAnticheatToken()
    return Infinite.Anticheat.Token;
end

local function GetCurrentCharacter(source) -- Gets the current character of the player by source or returns false.
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    local parsedChar = {
        id = player.PlayerData.citizenid,
        first_name = player.PlayerData.charinfo.firstname,
        last_name = player.PlayerData.charinfo.lastname,
        job = player.PlayerData.job.name,
        rank = player.PlayerData.job.grade.level,
        cash = player.PlayerData.money.cash,
        bank = player.PlayerData.money.bank,
        gender = player.PlayerData.charinfo.gender
    }

    return parsedChar;
end

local function GetUserFromCID(citizenid)
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if not player then return {character = false} end

    return {
        character = {
            id = player.PlayerData.citizenid,
            first_name = player.PlayerData.charinfo.firstname,
            last_name = player.PlayerData.charinfo.lastname,
            job = player.PlayerData.job.name,
            rank = player.PlayerData.job.grade.level,
            cash = player.PlayerData.money.cash,
            bank = player.PlayerData.money.bank,
            gender = player.PlayerData.charinfo.gender
        },
        source = player.PlayerData.source,
    }
end

local function SetRank(source, rank)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    player.Functions.SetJob(player.PlayerData.job.name, rank)
    player.Functions.Save()
end

local function SetJob(source, job)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    player.Functions.SetJob(job, player.PlayerData.job.grade.level)
    player.Functions.Save()
end

local function RemoveBank(source, amount)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    player.Functions.RemoveMoney('bank', amount)
    player.Functions.Save()
end

local function RemoveCash(source, amount)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    player.Functions.RemoveMoney('cash', amount)
    player.Functions.Save()
end

local function AddBank(source, amount)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    player.Functions.AddMoney('bank', amount)
    player.Functions.Save()
end

local function AddCash(source, amount)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    player.Functions.AddMoney('cash', amount)
    player.Functions.Save()
end

local function GetBank(source)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    return player.PlayerData.money.bank;
end

local function GetCash(source)
    local src = source;
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return false end

    return player.PlayerData.money.cash;
end

Citizen.CreateThread(function()
    Infinite.Anticheat.GenerateToken()
end)

exports('GetDevMode', GetDevMode)
exports('GetAnticheatToken', GetAnticheatToken)
exports('GetCurrentCharacter', GetCurrentCharacter)
exports('GetUserFromCID', GetUserFromCID)
exports('SetRank', SetRank)
exports('SetJob', SetJob)
exports('RemoveBank', RemoveBank)
exports('RemoveCash', RemoveCash)
exports('AddBank', AddBank)
exports('AddCash', AddCash)
exports('GetBank', GetBank)
exports('GetCash', GetCash)

RegisterServerEvent('infinite-framework:obtainToken', function()
    TriggerClientEvent('infinite-framework:obtainToken', source, Infinite.Anticheat.Token)
end)

RegisterServerCallback('infinite-framework:ObtainCharacter', function(source)
    return GetCurrentCharacter(source)
end)

--[[
    ESX Exports
]]

if Infinite.Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    local function ObtainItemList() 
        local result = exports.oxmysql:executeSync('SELECT * FROM items')
        local itemList = {}

        for _, item in pairs(result) do
            itemList[item.name] = {
                name = item.name,
                label = item.label,
                weight = (item.weight or 1), -- Convert to grams if you want QBCore-style
                type = item.type or "item",       -- Default to "item"
                image = item.name .. ".png",      -- Assumes icon name matches item name
                unique = false,                   -- ESX doesn't use this, default to false
                useable = item.usable or false,
                shouldClose = true,               -- Assumed behavior
                combinable = nil,                 -- Optional for custom logic
                description = item.label          -- Fallback description using label
            }
        end
    
        return itemList
    end

    exports('ObtainItemList', ObtainItemList)

    RegisterServerCallback('infinite-handler:ObtainItemList', function(source)
        return ObtainItemList()
    end)

    local function GiveItem(src, item, amount, metaData)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end
    
        -- ESX supports basic metadata as part of `info` parameter if the inventory system supports it
        -- But most core ESX systems only use `item`, `count`
        xPlayer.addInventoryItem(item, amount)
    end
    
    local function RemoveItem(src, item, amount)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end
    
        xPlayer.removeInventoryItem(item, amount)
    end
    
    local function HasItem(src, item, amount)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
    
        local invItem = xPlayer.getInventoryItem(item)
        if not invItem or invItem.count < amount then
            return false
        end
    
        return true
    end    

    exports('GiveItem', GiveItem)
    exports('RemoveItem', RemoveItem)
    exports('HasItem', HasItem)
end

--[[
    QBCore Exports
]]
if Infinite.Config.Framework == 'qb-core' or Infinite.Config.Framework == 'qbox' then
    QBCore = exports['qb-core']:GetCoreObject()
    local function ObtainItemList() 
        return QBCore.Shared.Items
    end

    exports('ObtainItemList', ObtainItemList)

    RegisterServerCallback('infinite-handler:ObtainItemList', function(source)
        return ObtainItemList()
    end)

    local function GiveItem(src, item, amount, metaData)
        -- ox_inventory:
        --[[
            exports['ox_inventory']:AddItem(src, item, amount, metaData)
        ]]

        -- qb-inventory:
        exports['qb-inventory']:AddItem(src, item, amount, false, metaData or false, 'infinite-handler:GiveItem') -- Add the item to the player inventory.
    end

    local function RemoveItem(src, item, amount)
        -- ox_inventory:
        --[[
            exports['ox_inventory']:RemoveItem(src, item, amount)
        ]]

        -- qb-inventory:
        exports['qb-inventory']:RemoveItem(src, item, amount) -- Remove the item from the player inventory.
    end

    local function HasItem(src, item, amount)
        -- ox_inventory:
        --[[
            return exports['ox_inventory']:Search(src, 'count', item) >= amount
        ]]

        -- qb-inventory:
        local player = QBCore.Functions.GetPlayer(src) -- Get the player object.
        local targetPlayerItem = player.Functions.GetItemByName(item);
        if not targetPlayerItem then return false end -- If the item is not found, return false.

        return targetPlayerItem.amount >= amount -- Check if the player has the item.
    end
    
    exports('GiveItem', GiveItem)
    exports('RemoveItem', RemoveItem)
    exports('HasItem', HasItem)
end