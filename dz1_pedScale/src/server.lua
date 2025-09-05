local playerScales = {}
local configFile = 'config_backup.json'

local function getPlayerIdentifier(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier then
            local prefix = string.match(identifier, '^([^:]+):')
            if prefix then
                identifiers[prefix] = identifier
            end
        end
    end
    
    if Config.framework.type == 'esx' then
        return identifiers['steam'] or identifiers['license']
    elseif Config.framework.type == 'qb' then
        return identifiers['license']
    elseif Config.framework.type == 'vrp' then
        return identifiers['steam']
    else
        return identifiers['steam'] or identifiers['license']
    end
end

local function loadConfig()
    local data = LoadResourceFile(GetCurrentResourceName(), configFile)
    if data then
        local success, config = pcall(json.decode, data)
        if success and config then
            return config
        end
    end
    return {}
end

local function saveConfig()
    local config = {
        playerScales = playerScales,
        timestamp = os.time()
    }
    
    local jsonData = json.encode(config)
    SaveResourceFile(GetCurrentResourceName(), configFile, jsonData, -1)
end

local function loadPlayerScale(playerId)
    local identifier = getPlayerIdentifier(playerId)
    if not identifier then return 1.0 end
    
    local config = loadConfig()
    return config.playerScales and config.playerScales[identifier] or 1.0
end

local function savePlayerScale(playerId, scale)
    local identifier = getPlayerIdentifier(playerId)
    if not identifier then return end
    
    playerScales[identifier] = scale
    saveConfig()
end

local function validateScale(scale)
    if not scale or type(scale) ~= 'number' then
        return false
    end
    return scale >= Config.scale.min and scale <= Config.scale.max
end

local function notifyPlayer(source, message, type)
    TriggerClientEvent('dz1_pedScale:showNotification', source, {
        message = message,
        type = type or 'info',
        duration = 5000
    })
end

RegisterNetEvent('dz1_pedScale:setScale', function(scale)
    local src = source
    
    if not validateScale(scale) then
        notifyPlayer(src, 'Escala inválida!', 'error')
        return
    end
    
    scale = math.floor(scale * (10 ^ Config.scale.precision)) / (10 ^ Config.scale.precision)
    
    local identifier = getPlayerIdentifier(src)
    if identifier then
        playerScales[identifier] = scale
        savePlayerScale(src, scale)
    end
    
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        if playerId ~= src then
            local targetPed = GetPlayerPed(playerId)
            if targetPed and DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                
                if distance <= Config.sync.distance then
                    TriggerClientEvent('dz1_pedScale:receivePlayerScale', playerId, src, scale)
                end
            end
        end
    end
end)

RegisterNetEvent('dz1_pedScale:requestSync', function(targetPlayerId)
    local src = source
    local targetIdentifier = getPlayerIdentifier(targetPlayerId)
    local targetScale = targetIdentifier and playerScales[targetIdentifier]
    
    if targetScale then
        TriggerClientEvent('dz1_pedScale:receivePlayerScale', src, targetPlayerId, targetScale)
    end
end)

RegisterNetEvent('dz1_pedScale:setPlayerScale', function(targetPlayerId, scale)
    local src = source
    
    if not validateScale(scale) then
        notifyPlayer(src, 'Escala inválida!', 'error')
        return
    end
    
    scale = math.floor(scale * (10 ^ Config.scale.precision)) / (10 ^ Config.scale.precision)
    
    local identifier = getPlayerIdentifier(targetPlayerId)
    if identifier then
        playerScales[identifier] = scale
        savePlayerScale(targetPlayerId, scale)
    end
    
    TriggerClientEvent('dz1_pedScale:setPlayerScale', targetPlayerId, scale)
    
    local playerCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        if playerId ~= targetPlayerId then
            local targetPed = GetPlayerPed(playerId)
            if targetPed and DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                
                if distance <= Config.sync.distance then
                    TriggerClientEvent('dz1_pedScale:receivePlayerScale', playerId, targetPlayerId, scale)
                end
            end
        end
    end
    
    notifyPlayer(src, string.format('Escala %.1f aplicada ao jogador %d', scale, targetPlayerId), 'success')
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local savedScale = loadPlayerScale(src)
    if savedScale and savedScale ~= 1.0 then
        local identifier = getPlayerIdentifier(src)
        if identifier then
            playerScales[identifier] = savedScale
        end
        TriggerClientEvent('dz1_pedScale:setPlayerScale', src, savedScale)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier = getPlayerIdentifier(src)
    if identifier then
        playerScales[identifier] = nil
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local config = loadConfig()
        if config.playerScales then
            playerScales = config.playerScales
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        saveConfig()
    end
end)