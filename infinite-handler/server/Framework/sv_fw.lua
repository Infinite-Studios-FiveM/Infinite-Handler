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

Citizen.CreateThread(function()
    Infinite.Anticheat.GenerateToken()
end)

exports('GetDevMode', GetDevMode)
exports('GetAnticheatToken', GetAnticheatToken)

RegisterServerEvent('infinite-framework:obtainToken', function()
    TriggerClientEvent('infinite-framework:obtainToken', source, Infinite.Anticheat.Token)
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

    local function ObtainMoneyType(src, moneyType)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end

        if moneyType == 'cash' then
            return xPlayer.getMoney()
        elseif moneyType == 'bank' then
            return xPlayer.getAccount('bank').money
        elseif moneyType == 'black_money' then
            return xPlayer.getAccount('black_money').money
        end

        return 0 -- Default to 0 if no valid type is found
    end

    local function RemoveMoneyType(src, moneyType, amount)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end

        if moneyType == 'cash' then
            xPlayer.removeMoney(amount)
        elseif moneyType == 'bank' then
            xPlayer.removeAccountMoney('bank', amount)
        elseif moneyType == 'black_money' then
            xPlayer.removeAccountMoney('black_money', amount)
        end
    end

    local function GiveMoneyType(src, moneyType, amount)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end

        if moneyType == 'cash' then
            xPlayer.addMoney(amount)
        elseif moneyType == 'bank' then
            xPlayer.addAccountMoney('bank', amount)
        elseif moneyType == 'black_money' then
            xPlayer.addAccountMoney('black_money', amount)
        end
    end

    RegisterServerCallback('infinite-handler:ObtainPlayerCash', function(source)
        return ObtainMoneyType(source, 'cash')
    end)

    exports('GiveItem', GiveItem)
    exports('RemoveItem', RemoveItem)
    exports('HasItem', HasItem)
    exports('ObtainMoneyType', ObtainMoneyType)
    exports('RemoveMoneyType', RemoveMoneyType)
    exports('GiveMoneyType', GiveMoneyType)
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

    local function ObtainMoneyType(src, moneyType)
        local player = QBCore.Functions.GetPlayer(src) -- Get the player object.
        if not player then return end

        if moneyType == 'cash' then
            return player.PlayerData.money['cash'] or 0
        elseif moneyType == 'bank' then
            return player.PlayerData.money['bank'] or 0
        elseif moneyType == 'black_money' then
            return player.PlayerData.money['black_money'] or 0
        end

        return 0 -- Default to 0 if no valid type is found
    end

    local function RemoveMoneyType(src, moneyType, amount)
        local player = QBCore.Functions.GetPlayer(src) -- Get the player object.
        if not player then return end

        if moneyType == 'cash' then
            player.Functions.RemoveMoney('cash', amount, 'infinite-handler:RemoveMoneyType')
        elseif moneyType == 'bank' then
            player.Functions.RemoveMoney('bank', amount, 'infinite-handler:RemoveMoneyType')
        elseif moneyType == 'black_money' then
            player.Functions.RemoveMoney('black_money', amount, 'infinite-handler:RemoveMoneyType')
        end
    end

    local function GiveMoneyType(src, moneyType, amount)
        local player = QBCore.Functions.GetPlayer(src) -- Get the player object.
        if not player then return end

        if moneyType == 'cash' then
            player.Functions.AddMoney('cash', amount, 'infinite-handler:GiveMoneyType')
        elseif moneyType == 'bank' then
            player.Functions.AddMoney('bank', amount, 'infinite-handler:GiveMoneyType')
        elseif moneyType == 'black_money' then
            player.Functions.AddMoney('black_money', amount, 'infinite-handler:GiveMoneyType')
        end
    end

    RegisterServerCallback('infinite-handler:ObtainPlayerCash', function(source)
        return ObtainMoneyType(source, 'cash')
    end )
    
    exports('GiveItem', GiveItem)
    exports('RemoveItem', RemoveItem)
    exports('HasItem', HasItem)
    exports('ObtainMoneyType', ObtainMoneyType)
    exports('RemoveMoneyType', RemoveMoneyType)
    exports('GiveMoneyType', GiveMoneyType)
end