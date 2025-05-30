-- Enhanced Hyperdrive System - Q Menu Configuration Panel v2.2.1
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH STEAM WORKSHOP
-- Provides easy access to system configuration through the spawn menu with Steam Workshop addon support

if SERVER then return end

print("[Hyperdrive Config] COMPLETE CODE UPDATE v2.2.1 - Q Menu Configuration being updated")
print("[Hyperdrive Config] Steam Workshop addon configuration support active")

-- Enhanced v2.2.0 theme configuration
local modernTheme = {
    primary = Color(25, 35, 55),
    secondary = Color(45, 65, 95),
    accent = Color(100, 150, 255),
    success = Color(100, 200, 100),
    warning = Color(255, 200, 100),
    error = Color(255, 120, 120),
    text = Color(255, 255, 255),
    textSecondary = Color(200, 200, 200),
    textMuted = Color(150, 150, 150),
    border = Color(80, 120, 180, 100),

    -- New v2.2.0 colors
    fleet = Color(100, 255, 150),
    admin = Color(255, 100, 100),
    stargate = Color(255, 200, 100),
    realtime = Color(150, 255, 200),
    critical = Color(255, 50, 50),
    emergency = Color(255, 0, 0)
}

-- Create the enhanced configuration panel
local function CreateHyperdriveConfigPanel()
    local panel = vgui.Create("DPanel")
    panel:SetSize(800, 750)
    panel:SetPaintBackground(false)

    -- Custom paint function for modern styling
    panel.Paint = function(self, w, h)
        -- Modern glassmorphism background
        draw.RoundedBox(12, 0, 0, w, h, Color(modernTheme.primary.r, modernTheme.primary.g, modernTheme.primary.b, 240))
        draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(modernTheme.secondary.r, modernTheme.secondary.g, modernTheme.secondary.b, 200))

        -- Subtle border glow
        draw.RoundedBox(12, 0, 0, w, 2, modernTheme.accent)
        draw.RoundedBox(12, 0, h - 2, w, 2, Color(modernTheme.accent.r, modernTheme.accent.g, modernTheme.accent.b, 150))
    end

    -- Enhanced title with modern styling
    local titlePanel = vgui.Create("DPanel", panel)
    titlePanel:SetPos(15, 15)
    titlePanel:SetSize(770, 60)
    titlePanel:SetPaintBackground(false)

    titlePanel.Paint = function(self, w, h)
        -- Title background with gradient
        draw.RoundedBoxEx(8, 0, 0, w, h, modernTheme.accent, true, true, false, false)
        draw.RoundedBoxEx(8, 0, h/2, w, h/2, Color(modernTheme.accent.r * 0.7, modernTheme.accent.g * 0.7, modernTheme.accent.b * 0.7), false, false, true, true)

        -- Title text with shadow
        draw.SimpleText("ENHANCED HYPERDRIVE SYSTEM", "DermaLarge", w/2 + 1, 21, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("ENHANCED HYPERDRIVE SYSTEM", "DermaLarge", w/2, 20, modernTheme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Version and subtitle
        local versionText = "v" .. (HYPERDRIVE.Version or "2.1.0") .. " - Advanced Configuration Panel"
        draw.SimpleText(versionText, "DermaDefault", w/2, 40, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Create scrollable panel for configuration options
    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:SetPos(10, 50)
    scroll:SetSize(580, 500)

    local configPanel = vgui.Create("DPanel", scroll)
    configPanel:SetSize(560, 800)
    configPanel:SetPaintBackground(false)

    local yPos = 10

    -- Core System Configuration
    local coreLabel = vgui.Create("DLabel", configPanel)
    coreLabel:SetPos(10, yPos)
    coreLabel:SetSize(540, 25)
    coreLabel:SetText("Core System Settings")
    coreLabel:SetFont("DermaDefaultBold")
    coreLabel:SetTextColor(Color(255, 255, 100))
    yPos = yPos + 30

    -- Ship Core Required
    local shipCoreCheck = vgui.Create("DCheckBoxLabel", configPanel)
    shipCoreCheck:SetPos(20, yPos)
    shipCoreCheck:SetSize(520, 20)
    shipCoreCheck:SetText("Require Ship Core for Hyperdrive Operation")
    shipCoreCheck:SetValue(true)
    shipCoreCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "RequireShipCore", val and "true" or "false")
    end
    yPos = yPos + 25

    -- One Core Per Ship
    local oneCoreCheck = vgui.Create("DCheckBoxLabel", configPanel)
    oneCoreCheck:SetPos(20, yPos)
    oneCoreCheck:SetSize(520, 20)
    oneCoreCheck:SetText("Enforce One Ship Core Per Ship")
    oneCoreCheck:SetValue(true)
    oneCoreCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnforceOneCorePerShip", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-detect Ships
    local autoDetectCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoDetectCheck:SetPos(20, yPos)
    autoDetectCheck:SetSize(520, 20)
    autoDetectCheck:SetText("Auto-detect Ship Structures")
    autoDetectCheck:SetValue(true)
    autoDetectCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "AutoDetectShips", val and "true" or "false")
    end
    yPos = yPos + 35

    -- Resource System Configuration
    local resourceLabel = vgui.Create("DLabel", configPanel)
    resourceLabel:SetPos(10, yPos)
    resourceLabel:SetSize(540, 25)
    resourceLabel:SetText("Spacebuild 3 Resource System")
    resourceLabel:SetFont("DermaDefaultBold")
    resourceLabel:SetTextColor(Color(100, 255, 100))
    yPos = yPos + 30

    -- Enable Resource Core
    local resourceCoreCheck = vgui.Create("DCheckBoxLabel", configPanel)
    resourceCoreCheck:SetPos(20, yPos)
    resourceCoreCheck:SetSize(520, 20)
    resourceCoreCheck:SetText("Enable Ship Core Resource System")
    resourceCoreCheck:SetValue(true)
    resourceCoreCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnableResourceCore", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto Resource Provision
    local autoProvisionCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoProvisionCheck:SetPos(20, yPos)
    autoProvisionCheck:SetSize(520, 20)
    autoProvisionCheck:SetText("Enable Automatic Resource Provision for Welded Entities")
    autoProvisionCheck:SetValue(true)
    autoProvisionCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnableAutoResourceProvision", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Weld Detection
    local weldDetectionCheck = vgui.Create("DCheckBoxLabel", configPanel)
    weldDetectionCheck:SetPos(20, yPos)
    weldDetectionCheck:SetSize(520, 20)
    weldDetectionCheck:SetText("Enable Weld Detection System")
    weldDetectionCheck:SetValue(true)
    weldDetectionCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnableWeldDetection", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-provision percentage slider
    local provisionLabel = vgui.Create("DLabel", configPanel)
    provisionLabel:SetPos(20, yPos)
    provisionLabel:SetSize(200, 20)
    provisionLabel:SetText("Auto-provision Percentage:")
    yPos = yPos + 20

    local provisionSlider = vgui.Create("DNumSlider", configPanel)
    provisionSlider:SetPos(20, yPos)
    provisionSlider:SetSize(520, 20)
    provisionSlider:SetMin(10)
    provisionSlider:SetMax(100)
    provisionSlider:SetDecimals(0)
    provisionSlider:SetValue(50)
    provisionSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "AutoProvisionPercentage", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Shield System Configuration
    local shieldLabel = vgui.Create("DLabel", configPanel)
    shieldLabel:SetPos(10, yPos)
    shieldLabel:SetSize(540, 25)
    shieldLabel:SetText("Shield System Settings")
    shieldLabel:SetFont("DermaDefaultBold")
    shieldLabel:SetTextColor(Color(150, 150, 255))
    yPos = yPos + 30

    -- Enable Shields
    local shieldsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    shieldsCheck:SetPos(20, yPos)
    shieldsCheck:SetSize(520, 20)
    shieldsCheck:SetText("Enable Shield System")
    shieldsCheck:SetValue(true)
    shieldsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnableShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-activate Shields
    local autoShieldsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoShieldsCheck:SetPos(20, yPos)
    autoShieldsCheck:SetSize(520, 20)
    autoShieldsCheck:SetText("Auto-activate Shields During Hyperdrive Charge")
    autoShieldsCheck:SetValue(true)
    autoShieldsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "AutoActivateShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Enhanced CAP Integration Section
    local capLabel = vgui.Create("DLabel", configPanel)
    capLabel:SetPos(10, yPos)
    capLabel:SetSize(540, 25)
    capLabel:SetText("CAP (Carter Addon Pack) Integration")
    capLabel:SetFont("DermaDefaultBold")
    capLabel:SetTextColor(Color(100, 200, 255))
    yPos = yPos + 30

    -- Enable CAP Integration
    local capCheck = vgui.Create("DCheckBoxLabel", configPanel)
    capCheck:SetPos(20, yPos)
    capCheck:SetSize(520, 20)
    capCheck:SetText("Enable CAP (Carter Addon Pack) Integration")
    capCheck:SetValue(true)
    capCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnableCAPIntegration", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Prefer CAP Shields
    local preferCAPCheck = vgui.Create("DCheckBoxLabel", configPanel)
    preferCAPCheck:SetPos(20, yPos)
    preferCAPCheck:SetSize(520, 20)
    preferCAPCheck:SetText("Prefer CAP Shields Over Custom Shields")
    preferCAPCheck:SetValue(true)
    preferCAPCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "PreferCAPShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-create CAP Shields
    local autoCreateCAPCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoCreateCAPCheck:SetPos(20, yPos)
    autoCreateCAPCheck:SetSize(520, 20)
    autoCreateCAPCheck:SetText("Auto-create CAP Shields for Ships Without Shields")
    autoCreateCAPCheck:SetValue(false)
    autoCreateCAPCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "AutoCreateShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- CAP Resource Integration
    local capResourcesCheck = vgui.Create("DCheckBoxLabel", configPanel)
    capResourcesCheck:SetPos(20, yPos)
    capResourcesCheck:SetSize(520, 20)
    capResourcesCheck:SetText("Integrate CAP Resource Systems (ZPM, Naquadah, etc.)")
    capResourcesCheck:SetValue(true)
    capResourcesCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "IntegrateCAPResources", val and "true" or "false")
    end
    yPos = yPos + 25

    -- CAP Effects Integration
    local capEffectsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    capEffectsCheck:SetPos(20, yPos)
    capEffectsCheck:SetSize(520, 20)
    capEffectsCheck:SetText("Use CAP Visual and Audio Effects")
    capEffectsCheck:SetValue(true)
    capEffectsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "UseCAPEffects", val and "true" or "false")
    end
    yPos = yPos + 35

    -- Hull Damage System Configuration
    local hullLabel = vgui.Create("DLabel", configPanel)
    hullLabel:SetPos(10, yPos)
    hullLabel:SetSize(540, 25)
    hullLabel:SetText("Hull Damage System Settings")
    hullLabel:SetFont("DermaDefaultBold")
    hullLabel:SetTextColor(Color(255, 150, 100))
    yPos = yPos + 30

    -- Enable Hull Damage
    local hullCheck = vgui.Create("DCheckBoxLabel", configPanel)
    hullCheck:SetPos(20, yPos)
    hullCheck:SetSize(520, 20)
    hullCheck:SetText("Enable Hull Damage System")
    hullCheck:SetValue(true)
    hullCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnableHullDamage", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto Hull Repair
    local autoRepairCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoRepairCheck:SetPos(20, yPos)
    autoRepairCheck:SetSize(520, 20)
    autoRepairCheck:SetText("Enable Automatic Hull Repair")
    autoRepairCheck:SetValue(true)
    autoRepairCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "HullDamage", "AutoRepairEnabled", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Critical hull threshold slider
    local hullThresholdLabel = vgui.Create("DLabel", configPanel)
    hullThresholdLabel:SetPos(20, yPos)
    hullThresholdLabel:SetSize(200, 20)
    hullThresholdLabel:SetText("Critical Hull Threshold:")
    yPos = yPos + 20

    local hullSlider = vgui.Create("DNumSlider", configPanel)
    hullSlider:SetPos(20, yPos)
    hullSlider:SetSize(520, 20)
    hullSlider:SetMin(5)
    hullSlider:SetMax(50)
    hullSlider:SetDecimals(0)
    hullSlider:SetValue(25)
    hullSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "HullDamage", "CriticalHullThreshold", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Interface System Configuration
    local interfaceLabel = vgui.Create("DLabel", configPanel)
    interfaceLabel:SetPos(10, yPos)
    interfaceLabel:SetSize(540, 25)
    interfaceLabel:SetText("Interface System Settings")
    interfaceLabel:SetFont("DermaDefaultBold")
    interfaceLabel:SetTextColor(Color(255, 200, 100))
    yPos = yPos + 30

    -- Enable USE Key Interfaces
    local useKeyCheck = vgui.Create("DCheckBoxLabel", configPanel)
    useKeyCheck:SetPos(20, yPos)
    useKeyCheck:SetSize(520, 20)
    useKeyCheck:SetText("Enable USE (E) Key Interfaces")
    useKeyCheck:SetValue(true)
    useKeyCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Interface", "EnableUSEKeyInterfaces", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Enable SHIFT Modifier
    local shiftCheck = vgui.Create("DCheckBoxLabel", configPanel)
    shiftCheck:SetPos(20, yPos)
    shiftCheck:SetSize(520, 20)
    shiftCheck:SetText("Enable SHIFT+USE for Ship Core Access")
    shiftCheck:SetValue(true)
    shiftCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Interface", "EnableShiftModifier", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Enable Feedback Messages
    local feedbackCheck = vgui.Create("DCheckBoxLabel", configPanel)
    feedbackCheck:SetPos(20, yPos)
    feedbackCheck:SetSize(520, 20)
    feedbackCheck:SetText("Enable Feedback Messages")
    feedbackCheck:SetValue(true)
    feedbackCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Interface", "EnableFeedbackMessages", val and "true" or "false")
    end
    yPos = yPos + 35

    -- Modern UI System Configuration
    local uiLabel = vgui.Create("DLabel", configPanel)
    uiLabel:SetPos(10, yPos)
    uiLabel:SetSize(540, 25)
    uiLabel:SetText("Modern UI System Settings")
    uiLabel:SetFont("DermaDefaultBold")
    uiLabel:SetTextColor(Color(255, 100, 255))
    yPos = yPos + 30

    -- Enable Modern UI
    local modernUICheck = vgui.Create("DCheckBoxLabel", configPanel)
    modernUICheck:SetPos(20, yPos)
    modernUICheck:SetSize(520, 20)
    modernUICheck:SetText("Enable Modern UI Framework")
    modernUICheck:SetValue(GetConVar("hyperdrive_modern_ui_enabled") and GetConVar("hyperdrive_modern_ui_enabled"):GetBool() or true)
    modernUICheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_modern_ui_enabled", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Glassmorphism
    local glassmorphismCheck = vgui.Create("DCheckBoxLabel", configPanel)
    glassmorphismCheck:SetPos(20, yPos)
    glassmorphismCheck:SetSize(520, 20)
    glassmorphismCheck:SetText("Enable Glassmorphism Design")
    glassmorphismCheck:SetValue(GetConVar("hyperdrive_ui_glassmorphism") and GetConVar("hyperdrive_ui_glassmorphism"):GetBool() or true)
    glassmorphismCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_glassmorphism", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Animations
    local animationsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    animationsCheck:SetPos(20, yPos)
    animationsCheck:SetSize(520, 20)
    animationsCheck:SetText("Enable UI Animations")
    animationsCheck:SetValue(GetConVar("hyperdrive_ui_animations") and GetConVar("hyperdrive_ui_animations"):GetBool() or true)
    animationsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_animations", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Notifications
    local notificationsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    notificationsCheck:SetPos(20, yPos)
    notificationsCheck:SetSize(520, 20)
    notificationsCheck:SetText("Enable UI Notifications")
    notificationsCheck:SetValue(GetConVar("hyperdrive_ui_notifications") and GetConVar("hyperdrive_ui_notifications"):GetBool() or true)
    notificationsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_notifications", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Sound Effects
    local soundEffectsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    soundEffectsCheck:SetPos(20, yPos)
    soundEffectsCheck:SetSize(520, 20)
    soundEffectsCheck:SetText("Enable UI Sound Effects")
    soundEffectsCheck:SetValue(GetConVar("hyperdrive_ui_sounds") and GetConVar("hyperdrive_ui_sounds"):GetBool() or true)
    soundEffectsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_sounds", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Animation Speed Slider
    local animSpeedLabel = vgui.Create("DLabel", configPanel)
    animSpeedLabel:SetPos(20, yPos)
    animSpeedLabel:SetSize(200, 20)
    animSpeedLabel:SetText("Animation Speed:")
    yPos = yPos + 20

    local animSpeedSlider = vgui.Create("DNumSlider", configPanel)
    animSpeedSlider:SetPos(20, yPos)
    animSpeedSlider:SetSize(520, 20)
    animSpeedSlider:SetMin(0.1)
    animSpeedSlider:SetMax(3.0)
    animSpeedSlider:SetDecimals(1)
    animSpeedSlider:SetValue(GetConVar("hyperdrive_ui_anim_speed") and GetConVar("hyperdrive_ui_anim_speed"):GetFloat() or 1.0)
    animSpeedSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_ui_anim_speed", tostring(val))
    end
    yPos = yPos + 25

    -- UI Scale Slider
    local uiScaleLabel = vgui.Create("DLabel", configPanel)
    uiScaleLabel:SetPos(20, yPos)
    uiScaleLabel:SetSize(200, 20)
    uiScaleLabel:SetText("UI Scale:")
    yPos = yPos + 20

    local uiScaleSlider = vgui.Create("DNumSlider", configPanel)
    uiScaleSlider:SetPos(20, yPos)
    uiScaleSlider:SetSize(520, 20)
    uiScaleSlider:SetMin(0.5)
    uiScaleSlider:SetMax(2.0)
    uiScaleSlider:SetDecimals(1)
    uiScaleSlider:SetValue(GetConVar("hyperdrive_ui_scale") and GetConVar("hyperdrive_ui_scale"):GetFloat() or 1.0)
    uiScaleSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_ui_scale", tostring(val))
    end
    yPos = yPos + 25

    -- Notification Duration Slider
    local notifDurationLabel = vgui.Create("DLabel", configPanel)
    notifDurationLabel:SetPos(20, yPos)
    notifDurationLabel:SetSize(200, 20)
    notifDurationLabel:SetText("Notification Duration (seconds):")
    yPos = yPos + 20

    local notifDurationSlider = vgui.Create("DNumSlider", configPanel)
    notifDurationSlider:SetPos(20, yPos)
    notifDurationSlider:SetSize(520, 20)
    notifDurationSlider:SetMin(1.0)
    notifDurationSlider:SetMax(10.0)
    notifDurationSlider:SetDecimals(1)
    notifDurationSlider:SetValue(GetConVar("hyperdrive_ui_notif_duration") and GetConVar("hyperdrive_ui_notif_duration"):GetFloat() or 5.0)
    notifDurationSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_ui_notif_duration", tostring(val))
    end
    yPos = yPos + 25

    -- Max Notifications Slider
    local maxNotifsLabel = vgui.Create("DLabel", configPanel)
    maxNotifsLabel:SetPos(20, yPos)
    maxNotifsLabel:SetSize(200, 20)
    maxNotifsLabel:SetText("Max Notifications:")
    yPos = yPos + 20

    local maxNotifsSlider = vgui.Create("DNumSlider", configPanel)
    maxNotifsSlider:SetPos(20, yPos)
    maxNotifsSlider:SetSize(520, 20)
    maxNotifsSlider:SetMin(1)
    maxNotifsSlider:SetMax(10)
    maxNotifsSlider:SetDecimals(0)
    maxNotifsSlider:SetValue(GetConVar("hyperdrive_ui_max_notifications") and GetConVar("hyperdrive_ui_max_notifications"):GetInt() or 5)
    maxNotifsSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_ui_max_notifications", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Accessibility Options
    local accessibilityLabel = vgui.Create("DLabel", configPanel)
    accessibilityLabel:SetPos(10, yPos)
    accessibilityLabel:SetSize(540, 25)
    accessibilityLabel:SetText("Accessibility Options")
    accessibilityLabel:SetFont("DermaDefaultBold")
    accessibilityLabel:SetTextColor(Color(100, 255, 150))
    yPos = yPos + 30

    -- High Contrast Mode
    local highContrastCheck = vgui.Create("DCheckBoxLabel", configPanel)
    highContrastCheck:SetPos(20, yPos)
    highContrastCheck:SetSize(520, 20)
    highContrastCheck:SetText("High Contrast Mode")
    highContrastCheck:SetValue(GetConVar("hyperdrive_ui_high_contrast") and GetConVar("hyperdrive_ui_high_contrast"):GetBool() or false)
    highContrastCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_high_contrast", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Large Text Mode
    local largeTextCheck = vgui.Create("DCheckBoxLabel", configPanel)
    largeTextCheck:SetPos(20, yPos)
    largeTextCheck:SetSize(520, 20)
    largeTextCheck:SetText("Large Text Mode")
    largeTextCheck:SetValue(GetConVar("hyperdrive_ui_large_text") and GetConVar("hyperdrive_ui_large_text"):GetBool() or false)
    largeTextCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_large_text", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Reduced Motion
    local reducedMotionCheck = vgui.Create("DCheckBoxLabel", configPanel)
    reducedMotionCheck:SetPos(20, yPos)
    reducedMotionCheck:SetSize(520, 20)
    reducedMotionCheck:SetText("Reduced Motion (for motion sensitivity)")
    reducedMotionCheck:SetValue(GetConVar("hyperdrive_ui_reduced_motion") and GetConVar("hyperdrive_ui_reduced_motion"):GetBool() or false)
    reducedMotionCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_reduced_motion", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Color Blind Friendly
    local colorBlindCheck = vgui.Create("DCheckBoxLabel", configPanel)
    colorBlindCheck:SetPos(20, yPos)
    colorBlindCheck:SetSize(520, 20)
    colorBlindCheck:SetText("Color Blind Friendly Mode")
    colorBlindCheck:SetValue(GetConVar("hyperdrive_ui_colorblind_friendly") and GetConVar("hyperdrive_ui_colorblind_friendly"):GetBool() or false)
    colorBlindCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_colorblind_friendly", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Performance Options
    local performanceLabel = vgui.Create("DLabel", configPanel)
    performanceLabel:SetPos(10, yPos)
    performanceLabel:SetSize(540, 25)
    performanceLabel:SetText("Performance Options")
    performanceLabel:SetFont("DermaDefaultBold")
    performanceLabel:SetTextColor(Color(255, 200, 100))
    yPos = yPos + 30

    -- Reduce Animations on Low FPS
    local reduceFPSCheck = vgui.Create("DCheckBoxLabel", configPanel)
    reduceFPSCheck:SetPos(20, yPos)
    reduceFPSCheck:SetSize(520, 20)
    reduceFPSCheck:SetText("Reduce Animations on Low FPS")
    reduceFPSCheck:SetValue(GetConVar("hyperdrive_ui_reduce_on_low_fps") and GetConVar("hyperdrive_ui_reduce_on_low_fps"):GetBool() or true)
    reduceFPSCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_reduce_on_low_fps", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Minimum FPS for Animations
    local minFPSLabel = vgui.Create("DLabel", configPanel)
    minFPSLabel:SetPos(20, yPos)
    minFPSLabel:SetSize(200, 20)
    minFPSLabel:SetText("Minimum FPS for Animations:")
    yPos = yPos + 20

    local minFPSSlider = vgui.Create("DNumSlider", configPanel)
    minFPSSlider:SetPos(20, yPos)
    minFPSSlider:SetSize(520, 20)
    minFPSSlider:SetMin(15)
    minFPSSlider:SetMax(60)
    minFPSSlider:SetDecimals(0)
    minFPSSlider:SetValue(GetConVar("hyperdrive_ui_min_fps") and GetConVar("hyperdrive_ui_min_fps"):GetInt() or 30)
    minFPSSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_ui_min_fps", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Sound System Options
    local soundLabel = vgui.Create("DLabel", configPanel)
    soundLabel:SetPos(10, yPos)
    soundLabel:SetSize(540, 25)
    soundLabel:SetText("Sound System Options")
    soundLabel:SetFont("DermaDefaultBold")
    soundLabel:SetTextColor(Color(150, 255, 150))
    yPos = yPos + 30

    -- Master Volume Slider
    local masterVolumeLabel = vgui.Create("DLabel", configPanel)
    masterVolumeLabel:SetPos(20, yPos)
    masterVolumeLabel:SetSize(200, 20)
    masterVolumeLabel:SetText("Master Sound Volume:")
    yPos = yPos + 20

    local masterVolumeSlider = vgui.Create("DNumSlider", configPanel)
    masterVolumeSlider:SetPos(20, yPos)
    masterVolumeSlider:SetSize(520, 20)
    masterVolumeSlider:SetMin(0.0)
    masterVolumeSlider:SetMax(1.0)
    masterVolumeSlider:SetDecimals(2)
    masterVolumeSlider:SetValue(GetConVar("hyperdrive_sound_volume") and GetConVar("hyperdrive_sound_volume"):GetFloat() or 1.0)
    masterVolumeSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_sound_volume", tostring(val))
        -- Play test sound when adjusting volume
        if HYPERDRIVE.Sounds then
            HYPERDRIVE.Sounds.PlayEffect("beep", nil, {volume = val})
        end
    end
    yPos = yPos + 25

    -- Hyperdrive Volume Slider
    local hyperdriveVolumeLabel = vgui.Create("DLabel", configPanel)
    hyperdriveVolumeLabel:SetPos(20, yPos)
    hyperdriveVolumeLabel:SetSize(200, 20)
    hyperdriveVolumeLabel:SetText("Hyperdrive Engine Volume:")
    yPos = yPos + 20

    local hyperdriveVolumeSlider = vgui.Create("DNumSlider", configPanel)
    hyperdriveVolumeSlider:SetPos(20, yPos)
    hyperdriveVolumeSlider:SetSize(520, 20)
    hyperdriveVolumeSlider:SetMin(0.0)
    hyperdriveVolumeSlider:SetMax(1.0)
    hyperdriveVolumeSlider:SetDecimals(2)
    hyperdriveVolumeSlider:SetValue(GetConVar("hyperdrive_hyperdrive_volume") and GetConVar("hyperdrive_hyperdrive_volume"):GetFloat() or 0.8)
    hyperdriveVolumeSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_hyperdrive_volume", tostring(val))
    end
    yPos = yPos + 25

    -- Shield Volume Slider
    local shieldVolumeLabel = vgui.Create("DLabel", configPanel)
    shieldVolumeLabel:SetPos(20, yPos)
    shieldVolumeLabel:SetSize(200, 20)
    shieldVolumeLabel:SetText("Shield System Volume:")
    yPos = yPos + 20

    local shieldVolumeSlider = vgui.Create("DNumSlider", configPanel)
    shieldVolumeSlider:SetPos(20, yPos)
    shieldVolumeSlider:SetSize(520, 20)
    shieldVolumeSlider:SetMin(0.0)
    shieldVolumeSlider:SetMax(1.0)
    shieldVolumeSlider:SetDecimals(2)
    shieldVolumeSlider:SetValue(GetConVar("hyperdrive_shield_volume") and GetConVar("hyperdrive_shield_volume"):GetFloat() or 0.7)
    shieldVolumeSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_shield_volume", tostring(val))
    end
    yPos = yPos + 25

    -- UI Volume Slider
    local uiVolumeLabel = vgui.Create("DLabel", configPanel)
    uiVolumeLabel:SetPos(20, yPos)
    uiVolumeLabel:SetSize(200, 20)
    uiVolumeLabel:SetText("UI Interaction Volume:")
    yPos = yPos + 20

    local uiVolumeSlider = vgui.Create("DNumSlider", configPanel)
    uiVolumeSlider:SetPos(20, yPos)
    uiVolumeSlider:SetSize(520, 20)
    uiVolumeSlider:SetMin(0.0)
    uiVolumeSlider:SetMax(1.0)
    uiVolumeSlider:SetDecimals(2)
    uiVolumeSlider:SetValue(GetConVar("hyperdrive_ui_volume") and GetConVar("hyperdrive_ui_volume"):GetFloat() or 0.6)
    uiVolumeSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_ui_volume", tostring(val))
    end
    yPos = yPos + 25

    -- Sound Test Button
    local soundTestBtn = vgui.Create("DButton", configPanel)
    soundTestBtn:SetPos(20, yPos)
    soundTestBtn:SetSize(150, 30)
    soundTestBtn:SetText("Test All Sounds")
    soundTestBtn.DoClick = function()
        if HYPERDRIVE.Sounds then
            chat.AddText(Color(100, 255, 100), "[Hyperdrive] Playing sound test sequence...")

            -- Test hyperdrive sounds
            HYPERDRIVE.Sounds.PlayHyperdrive("charge_start", nil, {volume = 0.6})
            timer.Simple(1, function()
                HYPERDRIVE.Sounds.PlayHyperdrive("charge_complete", nil, {volume = 0.6})
            end)

            -- Test shield sounds
            timer.Simple(2, function()
                HYPERDRIVE.Sounds.PlayShield("engage", nil, {volume = 0.6})
            end)

            -- Test UI sounds
            timer.Simple(3, function()
                HYPERDRIVE.Sounds.PlayUI("success", {volume = 0.6})
            end)

            -- Test alert sounds
            timer.Simple(4, function()
                HYPERDRIVE.Sounds.PlayAlert("warning", nil, {volume = 0.5})
            end)

            -- Test effect sounds
            timer.Simple(5, function()
                HYPERDRIVE.Sounds.PlayEffect("power_up", nil, {volume = 0.6})
            end)
        else
            chat.AddText(Color(255, 100, 100), "[Hyperdrive] Sound system not available")
        end
    end
    yPos = yPos + 40

    -- Update panel size to accommodate new content
    configPanel:SetSize(560, 1400)

    -- Action buttons at the bottom
    local buttonPanel = vgui.Create("DPanel", panel)
    buttonPanel:SetPos(10, 660)
    buttonPanel:SetSize(580, 70)
    buttonPanel:SetPaintBackground(false)

    -- First row of buttons
    -- Status button
    local statusBtn = vgui.Create("DButton", buttonPanel)
    statusBtn:SetPos(0, 0)
    statusBtn:SetSize(110, 30)
    statusBtn:SetText("System Status")
    statusBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_status")
    end

    -- Help button
    local helpBtn = vgui.Create("DButton", buttonPanel)
    helpBtn:SetPos(120, 0)
    helpBtn:SetSize(90, 30)
    helpBtn:SetText("Help")
    helpBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_help")
    end

    -- Resource status button
    local resourceBtn = vgui.Create("DButton", buttonPanel)
    resourceBtn:SetPos(220, 0)
    resourceBtn:SetSize(130, 30)
    resourceBtn:SetText("Resource Status")
    resourceBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_sb3_resources")
    end

    -- UI Test button
    local uiTestBtn = vgui.Create("DButton", buttonPanel)
    uiTestBtn:SetPos(360, 0)
    uiTestBtn:SetSize(100, 30)
    uiTestBtn:SetText("Test UI")
    uiTestBtn.DoClick = function()
        -- Test the modern UI system
        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.ShowNotification then
            HYPERDRIVE.UI.ShowNotification("UI Test", "Modern UI system is working correctly!", "success", 3)
        else
            chat.AddText(Color(255, 200, 100), "[Hyperdrive] UI system not fully loaded")
        end

        -- Test animation system
        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.AnimatePanel then
            local testPanel = vgui.Create("DPanel")
            testPanel:SetSize(200, 100)
            testPanel:SetPos(ScrW()/2 - 100, ScrH()/2 - 50)
            testPanel:SetPaintBackground(false)

            testPanel.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(100, 150, 255, 200))
                draw.SimpleText("UI Test Panel", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            HYPERDRIVE.UI.AnimatePanel(testPanel, "fadeIn", 0.5)

            timer.Simple(2, function()
                if IsValid(testPanel) then
                    HYPERDRIVE.UI.AnimatePanel(testPanel, "fadeOut", 0.5, function()
                        if IsValid(testPanel) then
                            testPanel:Remove()
                        end
                    end)
                end
            end)
        end
    end

    -- Close button
    local closeBtn = vgui.Create("DButton", buttonPanel)
    closeBtn:SetPos(470, 0)
    closeBtn:SetSize(110, 30)
    closeBtn:SetText("Close")
    closeBtn.DoClick = function()
        panel:GetParent():Close()
    end

    -- Second row of buttons
    -- Reset to defaults button
    local resetBtn = vgui.Create("DButton", buttonPanel)
    resetBtn:SetPos(0, 35)
    resetBtn:SetSize(140, 30)
    resetBtn:SetText("Reset Defaults")
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset all Enhanced Hyperdrive settings to defaults?",
            "Reset Configuration",
            "Yes, Reset",
            function()
                RunConsoleCommand("hyperdrive_config_reset")
                if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.ShowNotification then
                    HYPERDRIVE.UI.ShowNotification("Configuration Reset", "All settings have been reset to defaults", "success", 3)
                else
                    chat.AddText(Color(100, 255, 100), "[Hyperdrive] Configuration reset to defaults")
                end
            end,
            "Cancel"
        )
    end

    -- Apply UI Settings button
    local applyUIBtn = vgui.Create("DButton", buttonPanel)
    applyUIBtn:SetPos(150, 35)
    applyUIBtn:SetSize(140, 30)
    applyUIBtn:SetText("Apply UI Settings")
    applyUIBtn.DoClick = function()
        -- Reload UI theme
        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.ReloadTheme then
            HYPERDRIVE.UI.ReloadTheme()
        end

        -- Update UI scale configuration
        local scale = GetConVar("hyperdrive_ui_scale") and GetConVar("hyperdrive_ui_scale"):GetFloat() or 1.0
        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.Config then
            HYPERDRIVE.UI.Config.UIScale = scale
        end

        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.ShowNotification then
            HYPERDRIVE.UI.ShowNotification("UI Settings Applied", "UI configuration has been updated", "success", 2)
        else
            chat.AddText(Color(100, 255, 100), "[Hyperdrive] UI settings applied")
        end
    end

    -- Open UI Theme Editor button
    local themeEditorBtn = vgui.Create("DButton", buttonPanel)
    themeEditorBtn:SetPos(300, 35)
    themeEditorBtn:SetSize(140, 30)
    themeEditorBtn:SetText("Theme Editor")
    themeEditorBtn.DoClick = function()
        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.OpenThemeEditor then
            HYPERDRIVE.UI.OpenThemeEditor()
        else
            chat.AddText(Color(255, 200, 100), "[Hyperdrive] Theme editor not available")
        end
    end

    -- Reload UI button
    local reloadUIBtn = vgui.Create("DButton", buttonPanel)
    reloadUIBtn:SetPos(450, 35)
    reloadUIBtn:SetSize(130, 30)
    reloadUIBtn:SetText("Reload UI")
    reloadUIBtn.DoClick = function()
        RunConsoleCommand("lua_run_cl", "if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.Reload then HYPERDRIVE.UI.Reload() end")
        if HYPERDRIVE and HYPERDRIVE.UI and HYPERDRIVE.UI.ShowNotification then
            HYPERDRIVE.UI.ShowNotification("UI Reloaded", "User interface has been reloaded", "info", 2)
        else
            chat.AddText(Color(100, 200, 255), "[Hyperdrive] UI system reloaded")
        end
    end

    return panel
end

-- Create advanced configuration panel
local function CreateAdvancedConfigPanel()
    local panel = vgui.Create("DPanel")
    panel:SetSize(600, 400)

    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:SetPos(5, 5)
    scroll:SetSize(590, 390)

    local configPanel = vgui.Create("DPanel", scroll)
    configPanel:SetSize(570, 600)
    configPanel:SetPaintBackground(false)

    local yPos = 10

    -- Resource Capacities Section
    local capacityLabel = vgui.Create("DLabel", configPanel)
    capacityLabel:SetPos(10, yPos)
    capacityLabel:SetSize(550, 25)
    capacityLabel:SetText("Default Resource Capacities")
    capacityLabel:SetFont("DermaDefaultBold")
    capacityLabel:SetTextColor(Color(100, 255, 200))
    yPos = yPos + 30

    -- Energy capacity
    local energyCapLabel = vgui.Create("DLabel", configPanel)
    energyCapLabel:SetPos(20, yPos)
    energyCapLabel:SetSize(150, 20)
    energyCapLabel:SetText("Energy Capacity (kW):")

    local energyCapSlider = vgui.Create("DNumSlider", configPanel)
    energyCapSlider:SetPos(180, yPos)
    energyCapSlider:SetSize(370, 20)
    energyCapSlider:SetMin(1000)
    energyCapSlider:SetMax(50000)
    energyCapSlider:SetDecimals(0)
    energyCapSlider:SetValue(10000)
    energyCapSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "DefaultEnergyCapacity", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Oxygen capacity
    local oxygenCapLabel = vgui.Create("DLabel", configPanel)
    oxygenCapLabel:SetPos(20, yPos)
    oxygenCapLabel:SetSize(150, 20)
    oxygenCapLabel:SetText("Oxygen Capacity (L):")

    local oxygenCapSlider = vgui.Create("DNumSlider", configPanel)
    oxygenCapSlider:SetPos(180, yPos)
    oxygenCapSlider:SetSize(370, 20)
    oxygenCapSlider:SetMin(500)
    oxygenCapSlider:SetMax(20000)
    oxygenCapSlider:SetDecimals(0)
    oxygenCapSlider:SetValue(5000)
    oxygenCapSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "DefaultOxygenCapacity", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Fuel capacity
    local fuelCapLabel = vgui.Create("DLabel", configPanel)
    fuelCapLabel:SetPos(20, yPos)
    fuelCapLabel:SetSize(150, 20)
    fuelCapLabel:SetText("Fuel Capacity (L):")

    local fuelCapSlider = vgui.Create("DNumSlider", configPanel)
    fuelCapSlider:SetPos(180, yPos)
    fuelCapSlider:SetSize(370, 20)
    fuelCapSlider:SetMin(500)
    fuelCapSlider:SetMax(15000)
    fuelCapSlider:SetDecimals(0)
    fuelCapSlider:SetValue(3000)
    fuelCapSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "DefaultFuelCapacity", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Transfer Rates Section
    local transferLabel = vgui.Create("DLabel", configPanel)
    transferLabel:SetPos(10, yPos)
    transferLabel:SetSize(550, 25)
    transferLabel:SetText("Resource Transfer Rates (Per Second)")
    transferLabel:SetFont("DermaDefaultBold")
    transferLabel:SetTextColor(Color(255, 200, 100))
    yPos = yPos + 30

    -- Energy transfer rate
    local energyTransferLabel = vgui.Create("DLabel", configPanel)
    energyTransferLabel:SetPos(20, yPos)
    energyTransferLabel:SetSize(150, 20)
    energyTransferLabel:SetText("Energy Rate (kW/s):")

    local energyTransferSlider = vgui.Create("DNumSlider", configPanel)
    energyTransferSlider:SetPos(180, yPos)
    energyTransferSlider:SetSize(370, 20)
    energyTransferSlider:SetMin(100)
    energyTransferSlider:SetMax(5000)
    energyTransferSlider:SetDecimals(0)
    energyTransferSlider:SetValue(1000)
    energyTransferSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnergyTransferRate", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Oxygen transfer rate
    local oxygenTransferLabel = vgui.Create("DLabel", configPanel)
    oxygenTransferLabel:SetPos(20, yPos)
    oxygenTransferLabel:SetSize(150, 20)
    oxygenTransferLabel:SetText("Oxygen Rate (L/s):")

    local oxygenTransferSlider = vgui.Create("DNumSlider", configPanel)
    oxygenTransferSlider:SetPos(180, yPos)
    oxygenTransferSlider:SetSize(370, 20)
    oxygenTransferSlider:SetMin(50)
    oxygenTransferSlider:SetMax(2000)
    oxygenTransferSlider:SetDecimals(0)
    oxygenTransferSlider:SetValue(500)
    oxygenTransferSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "OxygenTransferRate", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Auto-provision Settings Section
    local provisionLabel = vgui.Create("DLabel", configPanel)
    provisionLabel:SetPos(10, yPos)
    provisionLabel:SetSize(550, 25)
    provisionLabel:SetText("Auto-provision Settings")
    provisionLabel:SetFont("DermaDefaultBold")
    provisionLabel:SetTextColor(Color(200, 100, 255))
    yPos = yPos + 30

    -- Provision delay
    local delayLabel = vgui.Create("DLabel", configPanel)
    delayLabel:SetPos(20, yPos)
    delayLabel:SetSize(150, 20)
    delayLabel:SetText("Provision Delay (s):")

    local delaySlider = vgui.Create("DNumSlider", configPanel)
    delaySlider:SetPos(180, yPos)
    delaySlider:SetSize(370, 20)
    delaySlider:SetMin(0.1)
    delaySlider:SetMax(5.0)
    delaySlider:SetDecimals(1)
    delaySlider:SetValue(0.5)
    delaySlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "AutoProvisionDelay", tostring(val))
    end
    yPos = yPos + 25

    -- Min provision amount
    local minAmountLabel = vgui.Create("DLabel", configPanel)
    minAmountLabel:SetPos(20, yPos)
    minAmountLabel:SetSize(150, 20)
    minAmountLabel:SetText("Min Provision Amount:")

    local minAmountSlider = vgui.Create("DNumSlider", configPanel)
    minAmountSlider:SetPos(180, yPos)
    minAmountSlider:SetSize(370, 20)
    minAmountSlider:SetMin(1)
    minAmountSlider:SetMax(100)
    minAmountSlider:SetDecimals(0)
    minAmountSlider:SetValue(25)
    minAmountSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "MinAutoProvisionAmount", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Max provision amount
    local maxAmountLabel = vgui.Create("DLabel", configPanel)
    maxAmountLabel:SetPos(20, yPos)
    maxAmountLabel:SetSize(150, 20)
    maxAmountLabel:SetText("Max Provision Amount:")

    local maxAmountSlider = vgui.Create("DNumSlider", configPanel)
    maxAmountSlider:SetPos(180, yPos)
    maxAmountSlider:SetSize(370, 20)
    maxAmountSlider:SetMin(100)
    maxAmountSlider:SetMax(2000)
    maxAmountSlider:SetDecimals(0)
    maxAmountSlider:SetValue(500)
    maxAmountSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "MaxAutoProvisionAmount", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Debug Options Section
    local debugLabel = vgui.Create("DLabel", configPanel)
    debugLabel:SetPos(10, yPos)
    debugLabel:SetSize(550, 25)
    debugLabel:SetText("Debug and Logging Options")
    debugLabel:SetFont("DermaDefaultBold")
    debugLabel:SetTextColor(Color(255, 100, 100))
    yPos = yPos + 30

    -- Log resource transfers
    local logTransfersCheck = vgui.Create("DCheckBoxLabel", configPanel)
    logTransfersCheck:SetPos(20, yPos)
    logTransfersCheck:SetSize(520, 20)
    logTransfersCheck:SetText("Log Resource Transfers (Debug)")
    logTransfersCheck:SetValue(false)
    logTransfersCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "LogResourceTransfers", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Log weld detection
    local logWeldCheck = vgui.Create("DCheckBoxLabel", configPanel)
    logWeldCheck:SetPos(20, yPos)
    logWeldCheck:SetSize(520, 20)
    logWeldCheck:SetText("Log Weld Detection Events (Debug)")
    logWeldCheck:SetValue(false)
    logWeldCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "LogWeldDetection", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Log hull damage
    local logHullCheck = vgui.Create("DCheckBoxLabel", configPanel)
    logHullCheck:SetPos(20, yPos)
    logHullCheck:SetSize(520, 20)
    logHullCheck:SetText("Log Hull Damage Operations (Debug)")
    logHullCheck:SetValue(false)
    logHullCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Debug", "LogHullDamage", val and "true" or "false")
    end

    return panel
end

-- Add to spawn menu
hook.Add("PopulateToolMenu", "HyperdriveConfigMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "Enhanced Hyperdrive", "hyperdrive_config", "Configuration", "", "", function(panel)
        panel:ClearControls()

        -- Add description
        panel:Help("Enhanced Hyperdrive System Configuration")
        panel:Help("Configure all aspects of the hyperdrive system including ship cores, resources, shields, and hull damage.")
        panel:Help("")

        -- Add the configuration panel
        local configPanel = CreateHyperdriveConfigPanel()
        panel:AddPanel(configPanel)
    end)

    spawnmenu.AddToolMenuOption("Utilities", "Enhanced Hyperdrive", "hyperdrive_advanced", "Advanced Settings", "", "", function(panel)
        panel:ClearControls()

        -- Add description
        panel:Help("Advanced Configuration Options")
        panel:Help("Fine-tune resource capacities, transfer rates, and debug options.")
        panel:Help("")

        -- Add the advanced configuration panel
        local advancedPanel = CreateAdvancedConfigPanel()
        panel:AddPanel(advancedPanel)
    end)

    spawnmenu.AddToolMenuOption("Utilities", "Enhanced Hyperdrive", "hyperdrive_status", "System Status", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Enhanced Hyperdrive System Status")
        panel:Help("View current system status and integration information.")
        panel:Help("")

        -- System status button
        panel:Button("View System Status", "hyperdrive_status")

        -- Resource status button
        panel:Button("View Resource Status", "hyperdrive_sb3_resources")

        -- Integration status button
        panel:Button("View Integration Status", "hyperdrive_integration_status")

        -- List integrations button
        panel:Button("List Registered Integrations", "hyperdrive_list_integrations")

        -- CAP status button
        panel:Button("View CAP Integration Status", "hyperdrive_cap_status")

        panel:Help("")
        panel:Help("Console Commands:")
        panel:Help("hyperdrive_help - Show help information")
        panel:Help("hyperdrive_status - Show system status")
        panel:Help("hyperdrive_sb3_resources - Show resource system status")
        panel:Help("hyperdrive_config_show <category> - Show configuration")
        panel:Help("hyperdrive_config_set <category> <key> <value> - Set configuration")
        panel:Help("hyperdrive_config_reset - Reset to defaults")
    end)
end)

-- Enhanced v2.2.0 configuration sections
local function AddV22ConfigSections(configPanel, yPos)
    -- Real-Time Features Section
    local realtimeLabel = vgui.Create("DLabel", configPanel)
    realtimeLabel:SetPos(10, yPos)
    realtimeLabel:SetSize(540, 25)
    realtimeLabel:SetText("Real-Time Features (v2.2.0)")
    realtimeLabel:SetFont("DermaDefaultBold")
    realtimeLabel:SetTextColor(modernTheme.realtime)
    yPos = yPos + 30

    -- Enable Real-Time HUD Updates
    local realtimeHUDCheck = vgui.Create("DCheckBoxLabel", configPanel)
    realtimeHUDCheck:SetPos(20, yPos)
    realtimeHUDCheck:SetSize(520, 20)
    realtimeHUDCheck:SetText("Enable Real-Time HUD Updates (20 FPS)")
    realtimeHUDCheck:SetValue(true)
    realtimeHUDCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_realtime", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable System Alerts
    local alertsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    alertsCheck:SetPos(20, yPos)
    alertsCheck:SetSize(520, 20)
    alertsCheck:SetText("Enable Real-Time System Alerts")
    alertsCheck:SetValue(true)
    alertsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_alerts", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Fleet Management Section
    local fleetLabel = vgui.Create("DLabel", configPanel)
    fleetLabel:SetPos(10, yPos)
    fleetLabel:SetSize(540, 25)
    fleetLabel:SetText("Fleet Management System (v2.2.0)")
    fleetLabel:SetFont("DermaDefaultBold")
    fleetLabel:SetTextColor(modernTheme.fleet)
    yPos = yPos + 30

    -- Enable Fleet Management
    local fleetCheck = vgui.Create("DCheckBoxLabel", configPanel)
    fleetCheck:SetPos(20, yPos)
    fleetCheck:SetSize(520, 20)
    fleetCheck:SetText("Enable Fleet Management UI")
    fleetCheck:SetValue(true)
    fleetCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_fleet", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Formation Flying
    local formationCheck = vgui.Create("DCheckBoxLabel", configPanel)
    formationCheck:SetPos(20, yPos)
    formationCheck:SetSize(520, 20)
    formationCheck:SetText("Enable Automatic Formation Flying")
    formationCheck:SetValue(true)
    formationCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_fleet_formation", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Stargate System Section
    local stargateLabel = vgui.Create("DLabel", configPanel)
    stargateLabel:SetPos(10, yPos)
    stargateLabel:SetSize(540, 25)
    stargateLabel:SetText("4-Stage Stargate System (v2.2.0)")
    stargateLabel:SetFont("DermaDefaultBold")
    stargateLabel:SetTextColor(modernTheme.stargate)
    yPos = yPos + 30

    -- Enable Stargate Sequence UI
    local stargateUICheck = vgui.Create("DCheckBoxLabel", configPanel)
    stargateUICheck:SetPos(20, yPos)
    stargateUICheck:SetSize(520, 20)
    stargateUICheck:SetText("Enable Stargate Sequence UI")
    stargateUICheck:SetValue(true)
    stargateUICheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_stargate", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Stage Progress Display
    local stageProgressCheck = vgui.Create("DCheckBoxLabel", configPanel)
    stageProgressCheck:SetPos(20, yPos)
    stageProgressCheck:SetSize(520, 20)
    stageProgressCheck:SetText("Enable Stage Progress Display")
    stageProgressCheck:SetValue(true)
    stageProgressCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_stargate_progress", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Admin Panel Section
    local adminLabel = vgui.Create("DLabel", configPanel)
    adminLabel:SetPos(10, yPos)
    adminLabel:SetSize(540, 25)
    adminLabel:SetText("Admin Panel System (v2.2.0)")
    adminLabel:SetFont("DermaDefaultBold")
    adminLabel:SetTextColor(modernTheme.admin)
    yPos = yPos + 30

    -- Enable Admin Panel UI
    local adminUICheck = vgui.Create("DCheckBoxLabel", configPanel)
    adminUICheck:SetPos(20, yPos)
    adminUICheck:SetSize(520, 20)
    adminUICheck:SetText("Enable Admin Panel UI (Admin Only)")
    adminUICheck:SetValue(true)
    adminUICheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_admin", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Performance Monitoring
    local perfMonCheck = vgui.Create("DCheckBoxLabel", configPanel)
    perfMonCheck:SetPos(20, yPos)
    perfMonCheck:SetSize(520, 20)
    perfMonCheck:SetText("Enable Performance Monitoring Display")
    perfMonCheck:SetValue(true)
    perfMonCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_admin_perfmon", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enhanced Visual Effects Section
    local effectsLabel = vgui.Create("DLabel", configPanel)
    effectsLabel:SetPos(10, yPos)
    effectsLabel:SetSize(540, 25)
    effectsLabel:SetText("Enhanced Visual Effects (v2.2.0)")
    effectsLabel:SetFont("DermaDefaultBold")
    effectsLabel:SetTextColor(modernTheme.accent)
    yPos = yPos + 30

    -- Enable Hover Effects
    local hoverCheck = vgui.Create("DCheckBoxLabel", configPanel)
    hoverCheck:SetPos(20, yPos)
    hoverCheck:SetSize(520, 20)
    hoverCheck:SetText("Enable UI Hover Effects")
    hoverCheck:SetValue(true)
    hoverCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_hover", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Click Effects
    local clickCheck = vgui.Create("DCheckBoxLabel", configPanel)
    clickCheck:SetPos(20, yPos)
    clickCheck:SetSize(520, 20)
    clickCheck:SetText("Enable UI Click Effects")
    clickCheck:SetValue(true)
    clickCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_click", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Enable Theme Transitions
    local transitionCheck = vgui.Create("DCheckBoxLabel", configPanel)
    transitionCheck:SetPos(20, yPos)
    transitionCheck:SetSize(520, 20)
    transitionCheck:SetText("Enable Theme Transitions")
    transitionCheck:SetValue(true)
    transitionCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_ui_transitions", val and "1" or "0")
    end
    yPos = yPos + 25

    -- Test Buttons Section
    local testLabel = vgui.Create("DLabel", configPanel)
    testLabel:SetPos(10, yPos)
    testLabel:SetSize(540, 25)
    testLabel:SetText("v2.2.0 Feature Tests")
    testLabel:SetFont("DermaDefaultBold")
    testLabel:SetTextColor(Color(255, 255, 255))
    yPos = yPos + 30

    -- Test Real-Time HUD
    local testRealtimeBtn = vgui.Create("DButton", configPanel)
    testRealtimeBtn:SetPos(20, yPos)
    testRealtimeBtn:SetSize(120, 25)
    testRealtimeBtn:SetText("Test Real-Time HUD")
    testRealtimeBtn.DoClick = function()
        if HYPERDRIVE.UI and HYPERDRIVE.UI.ShowNotification then
            HYPERDRIVE.UI.ShowNotification("Real-Time Test", "Real-time HUD system is active!", "realtime", 3)
        end
    end

    -- Test Fleet Management
    local testFleetBtn = vgui.Create("DButton", configPanel)
    testFleetBtn:SetPos(150, yPos)
    testFleetBtn:SetSize(120, 25)
    testFleetBtn:SetText("Test Fleet UI")
    testFleetBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_fleet_status")
    end

    -- Test Stargate Sequence
    local testStargateBtn = vgui.Create("DButton", configPanel)
    testStargateBtn:SetPos(280, yPos)
    testStargateBtn:SetSize(120, 25)
    testStargateBtn:SetText("Test Stargate UI")
    testStargateBtn.DoClick = function()
        if HYPERDRIVE.UI and HYPERDRIVE.UI.ShowNotification then
            HYPERDRIVE.UI.ShowNotification("Stargate Test", "4-stage sequence UI ready!", "stargate", 3)
        end
    end

    -- Test Admin Panel
    local testAdminBtn = vgui.Create("DButton", configPanel)
    testAdminBtn:SetPos(410, yPos)
    testAdminBtn:SetSize(120, 25)
    testAdminBtn:SetText("Test Admin Panel")
    testAdminBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_admin", "status")
    end

    return yPos + 35
end

print("[Hyperdrive] Enhanced Q Menu Configuration Panel v2.2.0 loaded")
