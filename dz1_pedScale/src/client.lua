local isScaling = false
local currentScale = 1.0
local DEFAULT_PED_HEIGHT = 1.0
local isUIVisible = false
local syncedScales = {}
local syncThread = nil

local kvpStorage = {}
function kvpStorage.loadPlayerScale()
    local savedScale = GetResourceKvpFloat("player_scale")
    return savedScale ~= 0.0 and savedScale or 1.0
end

function kvpStorage.savePlayerScale(scale)
    SetResourceKvpFloat("player_scale", scale)
end

local function norm(vec)
    local mag = math.sqrt(vec.x ^ 2 + vec.y ^ 2 + vec.z ^ 2)
    if mag > 0 then
        return vec / mag
    end
    return vec
end

local function applyScaleToEntity(ped, scale)
    local forward, right, upVector, position = GetEntityMatrix(ped)

    local forwardNorm = norm(forward) * scale
    local rightNorm = norm(right) * scale
    local upNorm = norm(upVector) * scale

    local zOffset = (1.0 - scale) * DEFAULT_PED_HEIGHT * 0.5
    local adjustedZ = position.z - zOffset

    if GetEntitySpeed(ped) > 0 then
        adjustedZ = adjustedZ - zOffset
    else
        adjustedZ = adjustedZ + zOffset
    end

    SetEntityMatrix(ped,
        forwardNorm.x, forwardNorm.y, forwardNorm.z,
        rightNorm.x, rightNorm.y, rightNorm.z,
        upNorm.x, upNorm.y, upNorm.z,
        position.x, position.y, adjustedZ
    )
end

local function applyScaleToOtherPlayer(playerId, scale)
    local playerPed = GetPlayerPed(playerId)
    if not DoesEntityExist(playerPed) then return end
    
    if playerId == PlayerId() then return end
    
    syncedScales[playerId] = scale
    
    CreateThread(function()
        while syncedScales[playerId] and DoesEntityExist(playerPed) do
            applyScaleToEntity(playerPed, scale)
            Wait(100)
        end
    end)
end

local function startScale(scale)
    isScaling = true
    currentScale = scale
    kvpStorage.savePlayerScale(scale)

    CreateThread(function()
        while isScaling do
            local ped = PlayerPedId()
            if DoesEntityExist(ped) then
                applyScaleToEntity(ped, scale)
            end
            Wait(0)
        end
    end)
    
    TriggerServerEvent('dz1_pedScale:setScale', scale)
end

local function stopScale()
    isScaling = false
    currentScale = 1.0
    kvpStorage.savePlayerScale(1.0)
    
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        applyScaleToEntity(ped, 1.0)
    end
    
    TriggerServerEvent('dz1_pedScale:setScale', 1.0)
end

local function showUI()
    if isUIVisible then return end
    
    isUIVisible = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showUI',
        data = {
            currentScale = currentScale,
            minScale = Config.scale.min,
            maxScale = Config.scale.max,
            step = Config.scale.step,
            enableKeyboardControls = true,
            enablePresets = true,
            lang = Config.lang
        }
    })
end

local function hideUI()
    if not isUIVisible then return end
    
    isUIVisible = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideUI'
    })
end

local function startSyncThread()
    if syncThread then return end
    
    syncThread = CreateThread(function()
        while isUIVisible do
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local players = GetActivePlayers()
            
            for _, player in ipairs(players) do
                local targetPed = GetPlayerPed(player)
                if targetPed ~= playerPed and DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(coords - targetCoords)
                    
                    if distance <= Config.sync.distance then
                        TriggerServerEvent('dz1_pedScale:requestSync', GetPlayerServerId(player))
                    end
                end
            end
            
            Wait(Config.sync.interval)
        end
        syncThread = nil
    end)
end

local function stopSyncThread()
    if syncThread then
        syncThread = nil
    end
end

RegisterCommand(Config.commandName, function()
    showUI()
    startSyncThread()
end)

RegisterKeyMapping(Config.commandName, 'Abrir Interface de Escala', 'keyboard', 'F6')

RegisterNUICallback('applyScale', function(data, cb)
    local scale = tonumber(data.scale)
    if scale then
        scale = tonumber(math.floor(scale * 10) / 10)
        
        if scale >= Config.scale.min and scale <= Config.scale.max then
            if scale == 1.0 then
                stopScale()
            else
                startScale(scale)
            end
            cb('ok')
        else
            cb('error')
        end
    else
        cb('error')
    end
end)

RegisterNUICallback('resetScale', function(data, cb)
    stopScale()
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    hideUI()
    stopSyncThread()
    cb('ok')
end)

RegisterNetEvent('dz1_pedScale:receivePlayerScale', function(sourcePlayerId, scale)
    applyScaleToOtherPlayer(sourcePlayerId, scale)
end)

RegisterNetEvent('dz1_pedScale:showNotification', function(data)
    SendNUIMessage({
        action = 'showNotification',
        message = data.message,
        type = data.type or 'info',
        duration = data.duration or 5000
    })
end)

RegisterNetEvent('dz1_pedScale:setPlayerScale', function(scale)
    if scale and scale >= Config.scale.min and scale <= Config.scale.max then
        if scale == 1.0 then
            stopScale()
        else
            startScale(scale)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        currentScale = kvpStorage.loadPlayerScale()
        if currentScale ~= 1.0 then
            startScale(currentScale)
        end
    end
end)

AddEventHandler('playerSpawned', function()
    local savedScale = kvpStorage.loadPlayerScale()
    if savedScale and savedScale == 1.0 then return end
    startScale(savedScale)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    stopScale()
end)