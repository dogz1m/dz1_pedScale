# 🔧 Documentação Técnica - dz1_pedScale

Documentação técnica completa para desenvolvedores que desejam integrar ou modificar o sistema de escala de personagens.

## 📋 Índice

1. [Arquitetura do Sistema](#arquitetura-do-sistema)
2. [API Completa](#api-completa)
3. [Estrutura de Dados](#estrutura-de-dados)
4. [Sistema de Eventos](#sistema-de-eventos)
5. [Integração com Frameworks](#integração-com-frameworks)
6. [Modificações Avançadas](#modificações-avançadas)
7. [Debugging](#debugging)

## 🏗️ Arquitetura do Sistema

### Fluxo de Dados
```
Cliente (NUI) → Cliente (Lua) → Servidor → Outros Clientes
     ↓              ↓             ↓           ↓
  Interface    Aplicação      Sincronização  Visualização
   HTML/CSS    da Escala      e Persistência  da Escala
```

### Componentes Principais

#### 1. **Cliente (src/client.lua)**
- Gerencia a interface NUI
- Aplica escala ao personagem
- Sincroniza com outros jogadores
- Salva escala localmente (KVP)

#### 2. **Servidor (src/server.lua)**
- Valida permissões
- Gerencia sincronização
- Salva dados em JSON
- Distribui eventos

#### 3. **Interface (html/)**
- **index.html**: Estrutura da interface
- **style.css**: Estilos e responsividade
- **script.js**: Lógica de interação

#### 4. **Configuração (shared/)**
- **config.lua**: Configurações principais
- **framework.lua**: Integração com frameworks

## 🔌 API Completa

### Eventos do Servidor

#### `dz1_pedScale:setPlayerScale`
Define a escala de um jogador específico.

```lua
-- Sintaxe
TriggerEvent('dz1_pedScale:setPlayerScale', playerId, scale)

-- Parâmetros
-- playerId (number): ID do jogador
-- scale (number): Escala desejada (0.1 - 10.0)

-- Exemplo
TriggerEvent('dz1_pedScale:setPlayerScale', 1, 2.5)
```

#### `dz1_pedScale:setScale`
Define a escala do próprio jogador.

```lua
-- Sintaxe
TriggerEvent('dz1_pedScale:setScale', scale)

-- Parâmetros
-- scale (number): Escala desejada (0.1 - 10.0)

-- Exemplo
TriggerEvent('dz1_pedScale:setScale', 1.5)
```

### Eventos do Cliente

#### `dz1_pedScale:receivePlayerScale`
Recebe a escala de outro jogador (sincronização).

```lua
-- Sintaxe
RegisterNetEvent('dz1_pedScale:receivePlayerScale', function(playerId, scale)
    -- Lógica de sincronização
end)

-- Parâmetros
-- playerId (number): ID do jogador
-- scale (number): Escala recebida
```

#### `dz1_pedScale:showNotification`
Mostra notificação no frontend.

```lua
-- Sintaxe
TriggerClientEvent('dz1_pedScale:showNotification', source, data)

-- Parâmetros
-- source (number): ID do jogador
-- data (table): Dados da notificação
--   - message (string): Texto da notificação
--   - type (string): Tipo ('info', 'success', 'warning', 'error')
--   - duration (number): Duração em ms (opcional)

-- Exemplo
TriggerClientEvent('dz1_pedScale:showNotification', source, {
    message = 'Escala aplicada com sucesso!',
    type = 'success',
    duration = 5000
})
```

#### `dz1_pedScale:setPlayerScale`
Define a escala do próprio jogador (cliente).

```lua
-- Sintaxe
RegisterNetEvent('dz1_pedScale:setPlayerScale', function(scale)
    -- Aplica escala localmente
end)

-- Parâmetros
-- scale (number): Escala desejada (0.1 - 10.0)
```

### Callbacks NUI

#### `applyScale`
Aplica escala via interface.

```javascript
// Sintaxe
fetch('applyScale', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ scale: 2.0 })
})

// Parâmetros
// scale (number): Escala desejada (0.1 - 10.0)
```

#### `resetScale`
Reseta escala para 1.0.

```javascript
// Sintaxe
fetch('resetScale', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
})
```

#### `closeUI`
Fecha a interface.

```javascript
// Sintaxe
fetch('closeUI', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
})
```

## 📊 Estrutura de Dados

### Configuração Principal
```lua
Config = {
    framework = {
        type = 'esx', -- 'esx', 'qb', 'vrp', 'standalone'
        -- Configurações específicas
    },
    scale = {
        default = 1.0,
        min = 0.1,
        max = 10.0,
        precision = 1,
        step = 0.1
    },
    sync = {
        distance = 50.0,
        interval = 2000
    },
    permissions = {
        -- Configurações de permissão
    }
}
```

### Dados de Escala
```lua
-- Estrutura no servidor
playerScales = {
    [playerId] = scale, -- Escala atual por jogador
    [identifier] = scale -- Escala salva por identificador
}

-- Estrutura no cliente
local isScaling = false
local currentScale = 1.0
local syncedScales = {} -- Escalas de outros jogadores
```

### Arquivo JSON
```json
{
    "playerScales": {
        "steam:110000100000000": 2.0,
        "license:abc123def456": 1.5
    },
    "timestamp": 1640995200
}
```

## 🔄 Sistema de Eventos

### Fluxo de Sincronização

#### 1. **Aplicação de Escala**
```
Jogador A → Interface NUI → Cliente A → Servidor → Outros Clientes
```

#### 2. **Sincronização Automática**
```
Cliente A → Servidor → Cliente B → Aplicação Visual
```

#### 3. **Persistência**
```
Cliente A → Servidor → JSON → Carregamento Futuro
```

### Eventos Internos

#### Cliente
- `dz1_pedScale:setScale` - Aplica escala local
- `dz1_pedScale:receivePlayerScale` - Recebe escala de outro jogador
- `dz1_pedScale:showNotification` - Mostra notificação

#### Servidor
- `dz1_pedScale:setPlayerScale` - Define escala de jogador
- `dz1_pedScale:requestSync` - Solicita sincronização
- `dz1_pedScale:setScale` - Aplica escala própria

## 🔗 Integração com Frameworks

### ESX
```lua
-- shared/framework.lua
if Config.framework.type == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    
    function Framework.hasAccess(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getGroup() == 'admin'
    end
end
```

### QBCore
```lua
-- shared/framework.lua
if Config.framework.type == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    
    function Framework.hasAccess(source)
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.permission == 'god'
    end
end
```

### VRP
```lua
-- shared/framework.lua
if Config.framework.type == 'vrp' then
    local vRP = require('vrp')
    
    function Framework.hasAccess(source)
        local user_id = vRP.getUserId(source)
        return vRP.hasPermission(user_id, 'admin.permission')
    end
end
```

## 🛠️ Modificações Avançadas

### Adicionar Novo Framework

#### 1. **Configuração**
```lua
-- shared/config.lua
Config.framework = {
    type = 'meuframework',
    -- Configurações específicas
}
```

#### 2. **Implementação**
```lua
-- shared/framework.lua
if Config.framework.type == 'meuframework' then
    -- Inicialização do framework
    local MeuFramework = exports['meuframework']:getSharedObject()
    
    function Framework.hasAccess(source)
        -- Lógica de verificação de permissão
        return MeuFramework.hasPermission(source, 'admin')
    end
    
    function Framework.getPlayerIdentifier(source)
        -- Retorna identificador único do jogador
        return MeuFramework.getIdentifier(source)
    end
end
```

### Modificar Lógica de Escala

#### 1. **Alterar Cálculo de Altura**
```lua
-- src/client.lua
local function applyScaleToEntity(ped, scale)
    -- Sua lógica personalizada aqui
    local customZOffset = calculateCustomHeight(scale)
    -- Aplicar escala
end
```

#### 2. **Adicionar Validações**
```lua
-- src/server.lua
local function validateScale(scale)
    -- Validações personalizadas
    if scale < 0.1 or scale > 10.0 then
        return false
    end
    
    -- Sua validação personalizada
    if scale > 5.0 and not hasSpecialPermission(source) then
        return false
    end
    
    return true
end
```

### Personalizar Interface

#### 1. **Adicionar Novos Presets**
```html
<!-- html/index.html -->
<button class="preset-btn" data-scale="15.0" title="Aplicar tamanho colossal">
    <i class="fas fa-mountain"></i>
    <span id="presetColossal">Colossal</span>
</button>
```

#### 2. **Modificar Estilos**
```css
/* html/style.css */
.preset-btn[data-scale="15.0"] {
    background: linear-gradient(45deg, #ff6b6b, #ff8e8e);
    color: white;
}
```

## 🐛 Debugging

### Ativar Logs Detalhados
```lua
-- shared/config.lua
Config.debug = true
```

### Logs de Cliente
```lua
-- src/client.lua
if Config.debug then
    print(string.format('[dz1_pedScale] Aplicando escala %.1f ao jogador %d', scale, playerId))
end
```

### Logs de Servidor
```lua
-- src/server.lua
if Config.debug then
    print(string.format('[dz1_pedScale] Salvando escala %.1f para jogador %d', scale, source))
end
```

### Debug da Interface
```javascript
// html/script.js
if (Config.debug) {
    console.log('Aplicando escala:', scale);
}
```

### Verificar Sincronização
```lua
-- Comando de debug
RegisterCommand('debugscale', function()
    print('Escalas ativas:')
    for playerId, scale in pairs(playerScales) do
        print(string.format('Jogador %d: %.1f', playerId, scale))
    end
end)
```

## 📈 Performance

### Otimizações Implementadas
- **Threads otimizadas**: Wait(0) apenas quando necessário
- **Sincronização inteligente**: Apenas jogadores próximos
- **Cache de dados**: Evita recálculos desnecessários
- **Validação client-side**: Reduz chamadas ao servidor

### Métricas Recomendadas
- **FPS**: Mantém 60+ FPS
- **Latência**: < 100ms para sincronização
- **Memória**: < 10MB por jogador
- **CPU**: < 1% de uso médio

## 🔒 Segurança

### Validações Implementadas
- **Range de escala**: 0.1 - 10.0
- **Permissões**: Verificação por framework
- **Sanitização**: Validação de entrada
- **Rate limiting**: Prevenção de spam

### Boas Práticas
- **Sempre validar**: Entrada do usuário
- **Usar permissões**: Verificar acesso
- **Logar ações**: Para auditoria
- **Testar limites**: Escalas extremas

## 📝 Exemplos Completos

### Sistema de Admin Completo
```lua
-- admin_system.lua
local AdminScale = {}

function AdminScale.setPlayerHeight(source, targetId, height)
    if not AdminScale.hasPermission(source) then
        return false, 'Sem permissão'
    end
    
    if not AdminScale.validateHeight(height) then
        return false, 'Altura inválida'
    end
    
    TriggerEvent('dz1_pedScale:setPlayerScale', targetId, height)
    return true, 'Altura aplicada com sucesso'
end

function AdminScale.hasPermission(source)
    -- Sua lógica de permissão
    return IsPlayerAceAllowed(source, 'command.admin')
end

function AdminScale.validateHeight(height)
    return height >= 0.1 and height <= 10.0
end

-- Comando
RegisterCommand('adminheight', function(source, args)
    local targetId = tonumber(args[1])
    local height = tonumber(args[2])
    
    local success, message = AdminScale.setPlayerHeight(source, targetId, height)
    
    TriggerClientEvent('chat:addMessage', source, {
        color = success and {0, 255, 0} or {255, 0, 0},
        args = {"[ADMIN]", message}
    })
end)
```

### Sistema de Eventos
```lua
-- event_system.lua
local EventScale = {}

function EventScale.startEvent(eventName, participants)
    for _, playerId in ipairs(participants) do
        local scale = EventScale.getEventScale(eventName)
        TriggerEvent('dz1_pedScale:setPlayerScale', playerId, scale)
    end
end

function EventScale.getEventScale(eventName)
    local scales = {
        ['giant_race'] = 3.0,
        ['dwarf_race'] = 0.5,
        ['normal'] = 1.0
    }
    return scales[eventName] or 1.0
end

-- Uso
EventScale.startEvent('giant_race', {1, 2, 3, 4, 5})
```

---

**Documentação técnica completa para desenvolvedores avançados** 🔧
