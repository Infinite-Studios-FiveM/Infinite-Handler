Infinite = Infinite or {};
Infinite.Anticheat = Infinite.Anticheat or {};
Infinite.Anticheat.Token = Infinite.Anticheat.Token or nil;
Infinite.Config = Infinite.Config or {};
Infinite.Config.DevelopmentMode = Infinite.Config.DevelopmentMode or false;
QBCore = QBCore or exports['qb-core']:GetCoreObject();

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