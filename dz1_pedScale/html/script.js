const scaleSlider = document.getElementById('scaleSlider');
const scaleValue = document.getElementById('scaleValue');
const applyBtn = document.getElementById('applyBtn');
const resetBtn = document.getElementById('resetBtn');
const closeBtn = document.getElementById('closeBtn');
const app = document.getElementById('app');
const presetBtns = document.querySelectorAll('.preset-btn');

let currentScale = 1.0;

const defaultConfig = {
    minScale: 0.1,
    maxScale: 3.0,
    defaultScale: 1.0,
    scaleStep: 0.1,
    enableAnimations: true,
    enableKeyboardControls: true,
    enablePresets: true
};

let config = { ...defaultConfig };

const RESOURCE_NAME = 'dz1_pedScale';

class NotificationManager {
    constructor() {
        this.container = document.getElementById('notificationContainer');
        this.notifications = new Map();
        this.defaultDuration = 5000;
    }

    show(message, type = 'info', duration = null, options = {}) {
        const id = this.generateId();
        const notificationDuration = duration !== null ? duration : this.defaultDuration;
        
        const config = {
            id: id,
            message: message,
            type: type,
            duration: notificationDuration,
            closable: true,
            icon: this.getIcon(type),
            ...options
        };

        const notification = this.createNotification(config);
        
        this.container.appendChild(notification);
        this.notifications.set(id, notification);

        setTimeout(() => {
            notification.classList.add('show');
        }, 10);

        if (notificationDuration > 0) {
            setTimeout(() => {
                this.hide(id);
            }, notificationDuration);
        }

        return id;
    }

    hide(id) {
        const notification = this.notifications.get(id);
        if (!notification) return;

        notification.classList.add('hide');
        
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
            this.notifications.delete(id);
        }, 300);
    }

    hideAll() {
        this.notifications.forEach((notification, id) => {
            this.hide(id);
        });
    }

    createNotification(config) {
        const notification = document.createElement('div');
        notification.className = `notification ${config.type}`;
        notification.setAttribute('data-id', config.id);

        const icon = document.createElement('span');
        icon.className = 'notification-icon';
        icon.innerHTML = config.icon;

        const content = document.createElement('span');
        content.className = 'notification-content';
        content.textContent = config.message;

        let closeBtn = null;
        if (config.closable) {
            closeBtn = document.createElement('button');
            closeBtn.className = 'notification-close';
            closeBtn.innerHTML = '×';
            closeBtn.onclick = () => this.hide(config.id);
        }

        let progressBar = null;
        if (config.duration > 0) {
            progressBar = document.createElement('div');
            progressBar.className = 'notification-progress';
            progressBar.style.width = '100%';
            progressBar.style.transitionDuration = `${config.duration}ms`;
            
            setTimeout(() => {
                progressBar.style.width = '0%';
            }, 10);
        }

        notification.appendChild(icon);
        notification.appendChild(content);
        if (closeBtn) notification.appendChild(closeBtn);
        if (progressBar) notification.appendChild(progressBar);

        return notification;
    }

    generateId() {
        return 'notification_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    getIcon(type) {
        const icons = {
            success: '<i class="fas fa-check-circle"></i>',
            error: '<i class="fas fa-exclamation-circle"></i>',
            warning: '<i class="fas fa-exclamation-triangle"></i>',
            info: '<i class="fas fa-info-circle"></i>',
            primary: '<i class="fas fa-bell"></i>'
        };
        return icons[type] || icons.info;
    }

    success(message, duration = null, options = {}) {
        return this.show(message, 'success', duration, options);
    }

    error(message, duration = null, options = {}) {
        return this.show(message, 'error', duration, options);
    }

    warning(message, duration = null, options = {}) {
        return this.show(message, 'warning', duration, options);
    }

    info(message, duration = null, options = {}) {
        return this.show(message, 'info', duration, options);
    }

    primary(message, duration = null, options = {}) {
        return this.show(message, 'primary', duration, options);
    }
}

const notificationManager = new NotificationManager();

function showNotification(message, type = 'info', duration = 5000) {
    return notificationManager.show(message, type, duration);
}

function AddTextComponentString(text, type = 'info', duration = 5000) {
    return showNotification(text, type, duration);
}

function applyConfig() {
    if (!config) {
        console.warn('Config não está disponível');
        return;
    }
    
    scaleSlider.min = config.minScale || 0.1;
    scaleSlider.max = config.maxScale || 3.0;
    scaleSlider.step = config.scaleStep || 0.1;
    
    const labels = document.querySelectorAll('.slider-labels span');
    if (labels.length >= 2) {
        labels[0].textContent = (config.minScale || 0.1) + 'm';
        labels[1].textContent = (config.maxScale || 3.0) + 'm';
    }
    
    const presetContainer = document.querySelector('.preset-buttons');
    if (config.enablePresets === false && presetContainer) {
        presetContainer.style.display = 'none';
    }
    
    applyResponsiveDesign();
    
    if (config.lang) {
        applyTranslations();
    }
}

function applyTranslations() {
    if (!config || !config.lang) {
        console.warn('Config.lang não está disponível, pulando traduções');
        return;
    }
    
    const elements = {
        'headerTitle': 'title',
        'headerSubtitle': 'subtitle',
        'scaleTitle': 'label',
        'scaleDescription': 'description',
        'scaleUnit': 'scaleUnit',
        'sliderMin': 'sliderMin',
        'sliderMax': 'sliderMax',
        'presetSmall': 'small',
        'presetNormal': 'normal',
        'presetLarge': 'large',
        'resetBtnText': 'reset',
        'applyBtnText': 'apply',
        'footerInfo': 'help'
    };
    
    for (const [elementId, translationKey] of Object.entries(elements)) {
        const element = document.getElementById(elementId);
        if (element && config.lang && config.lang[translationKey]) {
            element.textContent = config.lang[translationKey];
        }
    }
    
    const tooltips = {
        'closeBtn': 'close',
        'scaleSlider': 'slider',
        'resetBtn': 'reset',
        'applyBtn': 'apply'
    };
    
    for (const [elementId, tooltipKey] of Object.entries(tooltips)) {
        const element = document.getElementById(elementId);
        if (element && config.lang && config.lang.tooltips && config.lang.tooltips[tooltipKey]) {
            element.title = config.lang.tooltips[tooltipKey];
        }
    }
    
    const presetButtons = document.querySelectorAll('.preset-btn');
    presetButtons.forEach(btn => {
        if (config.lang && config.lang.tooltips && config.lang.tooltips.preset) {
            btn.title = config.lang.tooltips.preset;
        }
    });
}

function applyResponsiveDesign() {
    const container = document.querySelector('.container');
    const isMobile = window.innerWidth <= 768;
    const isTablet = window.innerWidth <= 1024 && window.innerWidth > 768;
    
    if (isMobile) {
        container.classList.add('mobile');
        container.classList.remove('tablet', 'desktop');
    } else if (isTablet) {
        container.classList.add('tablet');
        container.classList.remove('mobile', 'desktop');
    } else {
        container.classList.add('desktop');
        container.classList.remove('mobile', 'tablet');
    }
    
    const presetBtns = document.querySelectorAll('.preset-btn');
    presetBtns.forEach(btn => {
        if (isMobile) {
            btn.classList.add('mobile');
        } else {
            btn.classList.remove('mobile');
        }
    });
}

function updateDisplay() {
    const minScale = config && config.minScale ? config.minScale : 0.1;
    const maxScale = config && config.maxScale ? config.maxScale : 3.0;
    
    const clampedScale = Math.max(minScale, Math.min(maxScale, currentScale));
    if (clampedScale !== currentScale) {
        currentScale = clampedScale;
    }
    
    scaleValue.textContent = currentScale.toFixed(1);
    scaleSlider.value = currentScale;
    updateApplyButton();
}

function updateApplyButton() {
    const value = parseFloat(scaleSlider.value);
    const applyBtnText = document.getElementById('applyBtnText');
    const applyBtn = document.getElementById('applyBtn');
    
    if (value === 1.0) {
        applyBtnText.textContent = 'Aplicar (Normal)';
        applyBtn.removeAttribute('data-has-info');
    } else if (value < 1.0) {
        applyBtnText.textContent = `Aplicar (${value.toFixed(1)}m - Pequeno)`;
        applyBtn.setAttribute('data-has-info', 'true');
    } else if (value <= 2.0) {
        applyBtnText.textContent = `Aplicar (${value.toFixed(1)}m - Grande)`;
        applyBtn.setAttribute('data-has-info', 'true');
    } else {
        applyBtnText.textContent = `Aplicar (${value.toFixed(1)}m - Máximo)`;
        applyBtn.setAttribute('data-has-info', 'true');
    }
}

function updatePresetButtons() {
    presetBtns.forEach(btn => {
        const scale = parseFloat(btn.dataset.scale);
        if (Math.abs(scale - currentScale) < 0.05) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
}

function resetToDefault() {
    currentScale = config && config.defaultScale ? config.defaultScale : 1.0;
    updateDisplay();
    updatePresetButtons();
    showNotification('Escala resetada para o padrão', 'info', 2000);
}

function applyScale() {
    const scale = parseFloat(scaleSlider.value);
    
    const minScale = config && config.minScale ? config.minScale : 0.1;
    const maxScale = config && config.maxScale ? config.maxScale : 3.0;
    
    const clampedScale = Math.max(minScale, Math.min(maxScale, scale));
    
    if (clampedScale !== scale) {
        scaleSlider.value = clampedScale;
        currentScale = clampedScale;
        updateDisplay();
        updatePresetButtons();
        showNotification(`Escala ajustada para ${clampedScale}m (limite: ${minScale}m - ${maxScale}m)`, 'warning', 3000);
    } else {
        currentScale = scale;
        updateDisplay();
        updatePresetButtons();
    }
    
    showNotification('Aplicando escala...', 'info', 2000);
    
    fetch(`https://${RESOURCE_NAME}/applyScale`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            scale: currentScale
        })
    }).then(() => {
        showNotification(`Escala aplicada: ${scale.toFixed(1)}m`, 'success', 3000);
        hideUI();
    }).catch(error => {
        console.error('Erro ao aplicar escala:', error);
        showNotification('Erro ao aplicar escala!', 'error', 4000);
    });
}

function showUI(initialScale = 1.0) {
    currentScale = initialScale;
    updateDisplay();
    updatePresetButtons();
    updateApplyButton();
    app.classList.remove('hidden');
    applyResponsiveDesign();
}

function hideUI() {
    app.classList.add('hidden');
    fetch(`https://${RESOURCE_NAME}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    }).catch(() => {});
}

document.addEventListener('DOMContentLoaded', function() {
    scaleSlider.addEventListener('input', function() {
        const scale = parseFloat(this.value);
        const minScale = config && config.minScale ? config.minScale : 0.1;
        const maxScale = config && config.maxScale ? config.maxScale : 3.0;
        
        const clampedScale = Math.max(minScale, Math.min(maxScale, scale));
        
        if (clampedScale !== scale) {
            this.value = clampedScale;
            currentScale = clampedScale;
        } else {
            currentScale = scale;
        }
        
        updateDisplay();
        updatePresetButtons();
    });

    presetBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const scale = parseFloat(this.dataset.scale);
            const minScale = config && config.minScale ? config.minScale : 0.1;
            const maxScale = config && config.maxScale ? config.maxScale : 3.0;
            
            const clampedScale = Math.max(minScale, Math.min(maxScale, scale));
            currentScale = clampedScale;
            scaleSlider.value = clampedScale;
            updateDisplay();
            updatePresetButtons();
            
                const presetNames = {
        0.5: 'Pequeno',
        1.0: 'Normal',
        2.0: 'Grande',
        3.0: 'Máximo'
    };
            
            const presetName = presetNames[scale] || 'Personalizado';
            showNotification(`Preset ${presetName} selecionado`, 'info', 1500);
        });
    });

    closeBtn.addEventListener('click', function() {
        hideUI();
    });

    resetBtn.addEventListener('click', function() {
        resetToDefault();
    });

    applyBtn.addEventListener('click', function() {
        applyScale();
    });

    document.addEventListener('keydown', function(e) {
        if (app.classList.contains('hidden')) return;
        
        if (e.key === 'Escape') {
            hideUI();
        } else if (e.key === 'Enter') {
            applyScale();
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            const step = config.scaleStep || 0.1;
            const newScale = Math.min(currentScale + step, config.maxScale || 3.0);
            currentScale = newScale;
            scaleSlider.value = newScale;
            updateDisplay();
            updatePresetButtons();
        } else if (e.key === 'ArrowDown') {
            e.preventDefault();
            const step = config.scaleStep || 0.1;
            const newScale = Math.max(currentScale - step, config.minScale || 0.1);
            currentScale = newScale;
            scaleSlider.value = newScale;
            updateDisplay();
            updatePresetButtons();
        }
    });
});

window.addEventListener('resize', function() {
    applyResponsiveDesign();
});

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showUI':
            if (data.config) {
                config = { ...defaultConfig, ...data.config };
                if (data.config.lang) {
                    config.lang = { ...config.lang, ...data.config.lang };
                }
                applyConfig();
            }
            showUI(data.scale || config.defaultScale);
            break;
        case 'hideUI':
            hideUI();
            break;
        case 'updateScale':
            currentScale = data.scale || config.defaultScale;
            updateDisplay();
            updatePresetButtons();
            break;
        case 'updateConfig':
            config = { ...defaultConfig, ...data.config };
            if (data.config.lang) {
                config.lang = { ...config.lang, ...data.config.lang };
            }
            applyConfig();
            break;
        case 'showNotification':
            showNotification(
                data.message || 'Notificação',
                data.type || 'info',
                data.duration || 5000
            );
            break;
    }
});

document.addEventListener('selectstart', function(e) {
    e.preventDefault();
});

document.addEventListener('contextmenu', function(e) {
    e.preventDefault();
});

document.addEventListener('dragstart', function(e) {
    e.preventDefault();
});

document.addEventListener('drop', function(e) {
    e.preventDefault();
});