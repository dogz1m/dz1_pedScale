Config = {}

Config.commandName = "scalePed"

Config.framework = {
    type = 'vrp',
    esx = {
        resourceName = 'es_extended',
        getSharedObject = 'esx:getSharedObject'
    },
    qb = {
        resourceName = 'qb-core'
    },
    vrp = {
        resourceName = 'vrp',
        adminGroups = {'god.permissao'}
    }
}

Config.scale = {
    default = 1.0,
    min = 0.1,
    max = 3.0,
    precision = 1,
    step = 0.1
}

Config.sync = {
    distance = 50.0,
    interval = 1000,
    enablePermissionCheck = true
}

Config.permissions = {
    enabled = true,
    identifierType = 'discord',
    allowedUsers = {}
}

Config.ui = {
    showNotifications = true,
    animations = true
}

Config.development = {
    enableLogs = true
}

Config.lang = {
    default = 'pt',
    pt = {
        title = 'Sistema de Escala',
        scaleLabel = 'Escala:',
        applyButton = 'Aplicar',
        resetButton = 'Resetar',
        closeButton = 'Fechar',
        noPermission = 'Você não tem permissão para usar este comando!',
        invalidScale = 'Escala inválida!',
        command = 'Abrir Interface de Escala',
        systemLoaded = 'Sistema de escala carregado!',
        keyboardHelp = 'Use /scalePed ou F6 para abrir a interface',
        systemUnloaded = 'Sistema de escala descarregado!',
        scaleApplied = 'Escala %.1f aplicada com sucesso!'
    }
}

function Config.getText(key)
    local lang = Config.lang[Config.lang.default] or Config.lang.pt
    return lang[key] or key
end