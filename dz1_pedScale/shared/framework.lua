Framework = {}

local ESX = nil
local QBCore = nil

Framework.Config = Config.framework.type
Framework.ESXConfig = Config.framework.esx
Framework.QBConfig = Config.framework.qb
Framework.VRPConfig = Config.framework.vrp

function Framework.isAdmin(source)
    if Framework.Config == 'esx' and ESX then
        local player = ESX.GetPlayerFromId(source)
        if player then
            local group = player.getGroup()
            return group == 'admin' or group == 'superadmin' or group == 'god'
        end
    elseif Framework.Config == 'qb' and QBCore then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            return QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god')
        end
    elseif Framework.Config == 'vrp' then
        local Proxy = module("vrp","lib/Proxy")
        local vRP = Proxy.getInterface("vRP")
     
        local user = vRP.getUserId(source)
        if user then
            local perm = false
            for k, v in pairs(Config.framework.vrp.adminGroups) do
                perm = vRP.hasPermission(user,v)
                if perm then 
                    break
                end
            end
            return perm
        end
    end
    
    return false
end

function Framework.showNotification(source, message, type, duration)
    TriggerClientEvent('dz1_pedScale:showNotification', source, {
        message = message,
        type = type or 'info',
        duration = duration or 5000
    })
end

if Framework.Config == 'esx' then
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent(Framework.ESXConfig.getSharedObject, function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end)
elseif Framework.Config == 'qb' then
    Citizen.CreateThread(function()
        while QBCore == nil do
            QBCore = exports[Framework.QBConfig.resourceName]:GetCoreObject()
            Citizen.Wait(0)
        end
    end)
end

return Framework