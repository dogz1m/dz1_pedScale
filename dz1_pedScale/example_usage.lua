-- EXEMPLO DE USO DO SISTEMA DE ESCALA
-- Este arquivo mostra como usar o sistema de escala de outros scripts

-- ==========================================
-- EVENTOS DISPONÍVEIS PARA OUTROS SCRIPTS
-- ==========================================

-- 1. SETAR ESCALA DE UM JOGADOR ESPECÍFICO (SERVIDOR)
-- Uso: TriggerEvent('dz1_pedScale:setPlayerScale', playerId, scale)
-- Exemplo:
RegisterCommand('setheight', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local scale = tonumber(args[2])
    
    if targetId and scale then
        TriggerEvent('dz1_pedScale:setPlayerScale', targetId, scale)
    else
        print('Uso: /setheight [playerId] [scale]')
    end
end)

-- 2. SETAR ESCALA DO PRÓPRIO JOGADOR (CLIENTE)
-- Uso: TriggerEvent('dz1_pedScale:setPlayerScale', scale)
-- Exemplo:
RegisterCommand('myheight', function(source, args, rawCommand)
    local scale = tonumber(args[1])
    
    if scale then
        TriggerEvent('dz1_pedScale:setPlayerScale', scale)
    else
        print('Uso: /myheight [scale]')
    end
end)

-- ==========================================
-- EXEMPLOS DE INTEGRAÇÃO
-- ==========================================

-- Exemplo 1: Sistema de Admin
RegisterCommand('adminheight', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local scale = tonumber(args[2])
    
    if IsPlayerAceAllowed(source, 'command.admin') then
        if targetId and scale then
            TriggerEvent('dz1_pedScale:setPlayerScale', targetId, scale)
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"[ADMIN]", string.format("Escala %.1f aplicada ao jogador %d", scale, targetId)}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[ADMIN]", "Uso: /adminheight [playerId] [scale]"}
            })
        end
    end
end)

-- Exemplo 2: Sistema de Eventos
RegisterNetEvent('myevent:setPlayerHeight', function(playerId, height)
    local src = source
    
    if height >= 0.1 and height <= 10.0 then
        TriggerEvent('dz1_pedScale:setPlayerScale', playerId, height)
        
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            args = {"[EVENTO]", string.format("Altura %.1f aplicada!", height)}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            args = {"[EVENTO]", "Altura deve estar entre 0.1 e 10.0"}
        })
    end
end)

-- Exemplo 3: Sistema de Presets
local heightPresets = {
    ['anão'] = 0.5,
    ['pequeno'] = 0.8,
    ['normal'] = 1.0,
    ['grande'] = 1.5,
    ['gigante'] = 3.0,
    ['titan'] = 5.0
}

RegisterCommand('preset', function(source, args, rawCommand)
    local preset = args[1]
    
    if heightPresets[preset] then
        local scale = heightPresets[preset]
        TriggerEvent('dz1_pedScale:setPlayerScale', source, scale)
        
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {"[PRESET]", string.format("Preset '%s' aplicado! (%.1f)", preset, scale)}
        })
    else
        local presets = table.concat(table.keys(heightPresets), ', ')
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            args = {"[PRESET]", "Presets disponíveis: " .. presets}
        })
    end
end)

-- ==========================================
-- FUNÇÕES AUXILIARES
-- ==========================================

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- ==========================================
-- DOCUMENTAÇÃO DOS EVENTOS
-- ==========================================

--[[
EVENTOS DO SISTEMA DE ESCALA:

1. dz1_pedScale:setPlayerScale (SERVIDOR)
   - Parâmetros: playerId (number), scale (number)
   - Descrição: Define a escala de um jogador específico
   - Exemplo: TriggerEvent('dz1_pedScale:setPlayerScale', 1, 2.0)

2. dz1_pedScale:setPlayerScale (CLIENTE)
   - Parâmetros: scale (number)
   - Descrição: Define a escala do próprio jogador
   - Exemplo: TriggerEvent('dz1_pedScale:setPlayerScale', 1.5)

3. dz1_pedScale:receivePlayerScale (CLIENTE)
   - Parâmetros: playerId (number), scale (number)
   - Descrição: Recebe a escala de outro jogador (sincronização)
   - Uso: Automático pelo sistema

4. dz1_pedScale:showNotification (CLIENTE)
   - Parâmetros: data (table)
   - Descrição: Mostra notificação no frontend
   - Exemplo: TriggerClientEvent('dz1_pedScale:showNotification', source, {message = 'Teste', type = 'info'})

CONFIGURAÇÕES:
- Escala mínima: 0.1
- Escala máxima: 10.0
- Precisão: 1 casa decimal
- Distância de sincronização: 50.0 unidades
- Salvamento: JSON com identificador do jogador

SALVAMENTO:
- Arquivo: config_backup.json
- Formato: JSON com playerScales[identifier] = scale
- Identificadores: Steam (VRP), License (QBCore), Steam/License (ESX)
--]]
