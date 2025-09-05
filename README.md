# 🎯 dz1_pedScale - Sistema de Escala de Personagens

Sistema completo e multiframework para alterar a escala (tamanho) de personagens no FiveM, com interface NUI moderna e sincronização em tempo real.

## 📋 Características

- ✅ **Multiframework**: Suporte para ESX, QBCore, VRP e Standalone
- ✅ **Interface NUI**: Frontend moderno e responsivo
- ✅ **Sincronização**: Todos os jogadores veem as alterações em tempo real
- ✅ **Persistência**: Salva escala em JSON por identificador do jogador
- ✅ **Eventos Públicos**: API para outros scripts
- ✅ **Sistema de Permissões**: Configurável por framework
- ✅ **Notificações**: Sistema de notificações integrado
- ✅ **Responsivo**: Interface adaptável a diferentes resoluções

## 🚀 Instalação

1. **Baixe o resource** para a pasta `resources`
2. **Configure o framework** em `shared/config.lua`
3. **Adicione ao server.cfg**:
   ```cfg
   ensure dz1_pedScale
   ```
4. **Reinicie o servidor**

## ⚙️ Configuração

### Framework
```lua
-- shared/config.lua
Config.framework = {
    type = 'esx', -- 'esx', 'qb', 'vrp', 'standalone'
    -- Configurações específicas do framework
}
```

### Escalas
```lua
Config.scale = {
    default = 1.0,    -- Escala padrão
    min = 0.1,        -- Escala mínima
    max = 10.0,       -- Escala máxima
    precision = 1,    -- Casas decimais
    step = 0.1        -- Incremento do slider
}
```

### Sincronização
```lua
Config.sync = {
    distance = 50.0,  -- Distância de sincronização
    interval = 2000   -- Intervalo de verificação (ms)
}
```

## 🎮 Como Usar

### Interface do Jogador
- **Comando**: `/scalePed` ou **F6**
- **Slider**: Arraste para ajustar a escala
- **Presets**: Botões para escalas rápidas
- **Reset**: Botão para voltar ao normal (1.0)

### Presets Disponíveis
- 🏃 **Pequeno**: 0.5m
- 👤 **Normal**: 1.0m
- 🏢 **Grande**: 2.0m
- 🦕 **Gigante**: 5.0m
- 🏔️ **Máximo**: 10.0m

## 🔧 API para Desenvolvedores

### Eventos do Servidor

#### Definir Escala de Jogador
```lua
-- Sintaxe
TriggerEvent('dz1_pedScale:setPlayerScale', playerId, scale)

-- Exemplo
TriggerEvent('dz1_pedScale:setPlayerScale', 1, 2.5)
```

#### Parâmetros
- `playerId` (number): ID do jogador
- `scale` (number): Escala desejada (0.1 - 10.0)

### Eventos do Cliente

#### Definir Própria Escala
```lua
-- Sintaxe
TriggerEvent('dz1_pedScale:setPlayerScale', scale)

-- Exemplo
TriggerEvent('dz1_pedScale:setPlayerScale', 1.5)
```

#### Mostrar Notificação
```lua
-- Sintaxe
TriggerClientEvent('dz1_pedScale:showNotification', source, data)

-- Exemplo
TriggerClientEvent('dz1_pedScale:showNotification', source, {
    message = 'Escala aplicada com sucesso!',
    type = 'success',
    duration = 5000
})
```

### Exemplos de Uso

#### Sistema de Admin
```lua
RegisterCommand('setheight', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local scale = tonumber(args[2])
    
    if targetId and scale then
        TriggerEvent('dz1_pedScale:setPlayerScale', targetId, scale)
    end
end)
```

#### Sistema de Presets
```lua
local heightPresets = {
    ['anão'] = 0.5,
    ['gigante'] = 3.0,
    ['titan'] = 5.0
}

RegisterCommand('preset', function(source, args, rawCommand)
    local preset = args[1]
    if heightPresets[preset] then
        TriggerEvent('dz1_pedScale:setPlayerScale', source, heightPresets[preset])
    end
end)
```

#### Integração com Eventos
```lua
RegisterNetEvent('myevent:setPlayerHeight', function(playerId, height)
    if height >= 0.1 and height <= 10.0 then
        TriggerEvent('dz1_pedScale:setPlayerScale', playerId, height)
    end
end)
```

## 📁 Estrutura de Arquivos

```
dz1_pedScale/
├── fxmanifest.lua          # Manifest do resource
├── README.md               # Esta documentação
├── example_usage.lua       # Exemplos de uso
├── shared/
│   ├── config.lua          # Configurações principais
│   └── framework.lua       # Sistema de frameworks
├── src/
│   ├── client.lua          # Lógica do cliente
│   └── server.lua          # Lógica do servidor
└── html/
    ├── index.html          # Interface NUI
    ├── style.css           # Estilos CSS
    └── script.js           # Lógica JavaScript
```

## 🔒 Sistema de Permissões

### Configuração por Framework

#### ESX
```lua
Config.permissions = {
    ['esx'] = {
        groups = {'admin', 'moderator'},
        jobs = {'police', 'admin'}
    }
}
```

#### QBCore
```lua
Config.permissions = {
    ['qb'] = {
        groups = {'god', 'admin'},
        jobs = {'police', 'admin'}
    }
}
```

#### VRP
```lua
Config.permissions = {
    ['vrp'] = {
        groups = {'admin', 'moderator'},
        users = {'steam:110000100000000'}
    }
}
```

## 💾 Sistema de Salvamento

### Formato JSON
```json
{
    "playerScales": {
        "steam:110000100000000": 2.0,
        "license:abc123def456": 1.5
    },
    "timestamp": 1640995200
}
```

### Identificadores por Framework
- **ESX**: Steam ou License
- **QBCore**: License
- **VRP**: Steam
- **Standalone**: Steam ou License

## 🎨 Personalização da Interface

### Cores
```css
:root {
    --primary-color: #007bff;
    --success-color: #28a745;
    --warning-color: #ffc107;
    --danger-color: #dc3545;
    --background: rgba(255, 255, 255, 0.95);
}
```

### Tamanhos
```css
:root {
    --container-width: 400px;
    --slider-height: 8px;
    --button-height: 45px;
    --border-radius: 12px;
}
```

## 🐛 Solução de Problemas

### Problemas Comuns

#### Personagem voando
- **Causa**: Escala muito alta
- **Solução**: Use escalas entre 0.1 e 10.0

#### Interface não abre
- **Causa**: Erro no JavaScript
- **Solução**: Verifique o console do navegador (F12)

#### Sincronização não funciona
- **Causa**: Distância muito baixa
- **Solução**: Aumente `Config.sync.distance`

#### Escala não salva
- **Causa**: Erro de permissão de arquivo
- **Solução**: Verifique permissões da pasta do resource

### Logs de Debug
```lua
-- Ativar logs detalhados
Config.debug = true
```

## 📊 Limitações

- **Escala mínima**: 0.1 (10cm)
- **Escala máxima**: 10.0 (10 metros)
- **Distância de sync**: 50 unidades
- **Frameworks suportados**: ESX, QBCore, VRP, Standalone

## 🔄 Atualizações

### Versão 1.0.0
- ✅ Sistema básico de escala
- ✅ Interface NUI
- ✅ Sincronização básica

### Versão 1.1.0
- ✅ Suporte multiframework
- ✅ Sistema de permissões
- ✅ Salvamento em JSON

### Versão 1.2.0
- ✅ Eventos públicos
- ✅ Notificações integradas
- ✅ Interface responsiva

## 📞 Suporte

Para suporte e dúvidas:
- **GitHub**: [Link do repositório]
- **Discord**: [Link do servidor]
- **Email**: [Seu email]

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

**Desenvolvido com ❤️ para a comunidade FiveM**
