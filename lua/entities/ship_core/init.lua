-- Ship Core Entity - Server v2.2.1
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH STEAM WORKSHOP
-- Mandatory ship core for Enhanced Hyperdrive System with v2.2.1 features
-- Advanced ship core with real-time monitoring, CAP integration, SB3 Steam Workshop support

print("[Ship Core] COMPLETE CODE UPDATE v2.2.1 - Ship Core Entity being updated")
print("[Ship Core] Enhanced ship core v2.2.1 with Steam Workshop integration initializing...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Safe function call wrapper to prevent errors from missing functions
local function SafeCall(func, ...)
    if func and type(func) == "function" then
        local success, result = pcall(func, ...)
        if success then
            return result
        else
            print("[Ship Core] Safe call failed: " .. tostring(result))
            return nil
        end
    end
    return nil
end

-- Safe table access wrapper
local function SafeAccess(table, ...)
    local current = table
    local keys = {...}

    for _, key in ipairs(keys) do
        if current and type(current) == "table" and current[key] then
            current = current[key]
        else
            return nil
        end
    end

    return current
end

-- Network strings for UI
util.AddNetworkString("ship_core_open_ui")
util.AddNetworkString("ship_core_update_ui")
util.AddNetworkString("ship_core_command")
util.AddNetworkString("ship_core_close_ui")
util.AddNetworkString("ship_core_name_dialog")
util.AddNetworkString("hyperdrive_play_sound")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(50, 150, 255))

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(50)
    end

    -- Initialize ship core data
    self.ship = nil
    self.lastUpdate = 0
    self.updateInterval = 2 -- Update every 2 seconds
    self.activeUIs = {} -- Track active UI sessions
    self.shipNameFile = "hyperdrive/ship_names_" .. self:EntIndex() .. ".txt"

    -- Load ship name from file
    self:LoadShipName()

    -- Initialize systems
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeSystems()
        end
    end)

    -- Initialize modern UI integration
    self.UIData = {
        lastUpdate = 0,
        updateInterval = 0.5,
        notifications = {},
        theme = "modern",
        activeTab = "overview",
        animationState = {},
        fadeAlpha = 255,
        targetAlpha = 255
    }

    -- v2.2.0 Real-Time Features
    self.FleetID = 0
    self.FleetRole = ""
    self.RealTimeMonitoring = true
    self.LastRealTimeUpdate = 0
    self.RealTimeUpdateRate = 0.05 -- 20 FPS for real-time updates
    self.PerformanceMetrics = {}
    self.SystemAlerts = {}
    self.AlertCooldowns = {} -- Track cooldowns for different alert types
    self.AlertHistory = {} -- Track alert history to prevent spam
    self.AdminAccess = false

    -- Smart update system with adaptive intervals
    self.LastEntityScan = 0
    self.EntityScanRate = 0.1 -- Base: 10 FPS for entity scanning
    self.LastResourceUpdate = 0
    self.ResourceUpdateRate = 0.2 -- Base: 5 FPS for resource calculations
    self.LastSystemCheck = 0
    self.SystemCheckRate = 0.5 -- Base: 2 FPS for system health checks
    self.LastNetworkUpdate = 0
    self.NetworkUpdateRate = 0.1 -- Base: 10 FPS for network synchronization

    -- Smart update tracking
    self.UpdatePriorities = {
        entity_scan = 1,     -- High priority
        resource_update = 2, -- Medium priority
        system_check = 3,    -- Low priority
        network_sync = 1     -- High priority
    }

    -- Adaptive update rates based on activity
    self.AdaptiveRates = {
        entity_scan = {min = 0.05, max = 1.0, current = 0.1},
        resource_update = {min = 0.1, max = 2.0, current = 0.2},
        system_check = {min = 0.25, max = 5.0, current = 0.5},
        network_sync = {min = 0.05, max = 0.5, current = 0.1}
    }

    -- Change detection for smart updates
    self.LastEntityCount = 0
    self.LastResourceState = {}
    self.LastSystemState = {}
    self.ChangeDetectionEnabled = true

    -- Performance tracking
    self.UpdatePerformance = {
        entity_scan = {total_time = 0, call_count = 0, avg_time = 0},
        resource_update = {total_time = 0, call_count = 0, avg_time = 0},
        system_check = {total_time = 0, call_count = 0, avg_time = 0},
        network_sync = {total_time = 0, call_count = 0, avg_time = 0}
    }

    -- Real-time data caches
    self.CachedAttachedEntities = {}
    self.CachedResourceData = {}
    self.CachedSystemStatus = {}
    self.CachedPerformanceData = {}

    -- Initialize v2.2.0 systems
    self:InitializeFleetManagement()
    self:InitializeRealTimeMonitoring()
    self:InitializePerformanceAnalytics()
    self:StartRealTimeUpdates()

    print("[Ship Core] Enhanced Ship Core v2.2.0 with modern UI and advanced features initialized at " .. tostring(self:GetPos()))
end

function ENT:InitializeSystems()
    -- Detect ship
    self:UpdateShipDetection()

    -- Initialize resource system first (required for other systems)
    if HYPERDRIVE.SB3Resources then
        local success = HYPERDRIVE.SB3Resources.InitializeCoreStorage(self)
        if success then
            self:SetNWBool("ResourceSystemActive", true)
            self:SetNWBool("AutoProvisionEnabled", true)
            self:SetNWBool("WeldDetectionEnabled", true)
            self:SetNWString("LastResourceActivity", "System initialized")
            print("[Ship Core] Resource system initialized")
        else
            print("[Ship Core] Resource system initialization failed")
        end
    end

    -- Initialize hull damage system
    if HYPERDRIVE.HullDamage and self.ship then
        local createFunc = SafeAccess(HYPERDRIVE.HullDamage, "CreateHullSystem")
        if createFunc then
            local hull, message = SafeCall(createFunc, self.ship, self)
            if hull then
                self:SetHullSystemActive(true)
                print("[Ship Core] Hull damage system initialized: " .. (message or "Success"))
            else
                print("[Ship Core] Hull damage system failed: " .. (message or "Unknown error"))
            end
        else
            print("[Ship Core] Hull damage CreateHullSystem function not available")
        end
    end

    -- Initialize shield system
    if HYPERDRIVE.Shields and self.ship then
        local createFunc = SafeAccess(HYPERDRIVE.Shields, "CreateShield")
        if createFunc then
            local shield, message = SafeCall(createFunc, self, self.ship)
            if shield then
                self:SetShieldSystemActive(true)
                print("[Ship Core] Shield system initialized: " .. (message or "Success"))
            else
                print("[Ship Core] Shield system failed: " .. (message or "Unknown error"))
            end
        else
            print("[Ship Core] Shield CreateShield function not available")
        end
    end

    -- Initialize CAP integration
    self:InitializeCAPIntegration()

    -- v2.2.1 Initialize new systems
    self:InitializeV221Systems()

    -- Create activation effect
    timer.Simple(1, function()
        if IsValid(self) then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetEntity(self)
            effectData:SetScale(1)
            effectData:SetMagnitude(1)
            util.Effect("ship_core_activation", effectData)

            -- Play activation sound
            if HYPERDRIVE.Sounds then
                local playFunc = SafeAccess(HYPERDRIVE.Sounds, "PlayEffect")
                if playFunc then
                    SafeCall(playFunc, "power_up", self, {
                        volume = 0.8,
                        pitch = 100,
                        soundLevel = 75
                    })
                end
            end
        end
    end)
end

-- v2.2.1 Initialize new systems
function ENT:InitializeV221Systems()
    -- Initialize flight system
    if HYPERDRIVE.Flight and self.ship then
        local flightSystem = HYPERDRIVE.Flight.GetFlightSystem(self)
        if not flightSystem then
            flightSystem = HYPERDRIVE.Flight.CreateFlightSystem(self)
        end

        if flightSystem then
            self.flightSystemInitialized = true
            self:SetNWBool("FlightSystemActive", true)
            print("[Ship Core] Flight system initialized")
        end
    end

    -- Initialize weapon systems
    if HYPERDRIVE.Weapons and self.ship then
        -- Find nearby weapons and link them
        local nearbyWeapons = ents.FindInSphere(self:GetPos(), 2000)
        local weaponCount = 0

        for _, ent in ipairs(nearbyWeapons) do
            if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") and ent.weapon then
                ent.shipCore = self
                weaponCount = weaponCount + 1
            end
        end

        if weaponCount > 0 then
            self.weaponSystemsInitialized = true
            self:SetNWBool("WeaponSystemsActive", true)
            self:SetNWInt("WeaponCount", weaponCount)
            print("[Ship Core] Weapon systems initialized - " .. weaponCount .. " weapons linked")
        end
    end

    -- Initialize ammunition system
    if HYPERDRIVE.Ammunition and self.ship then
        local storage = HYPERDRIVE.Ammunition.CreateStorage(self, 10000) -- 10kg capacity
        if storage then
            self.ammunitionSystemInitialized = true
            self:SetNWBool("AmmunitionSystemActive", true)
            print("[Ship Core] Ammunition system initialized")
        end
    end

    -- Initialize tactical AI
    if HYPERDRIVE.TacticalAI and self.ship then
        local ai = HYPERDRIVE.TacticalAI.CreateAI(self, "balanced")
        if ai then
            self.tacticalAIInitialized = true
            self:SetNWBool("TacticalAIActive", true)
            print("[Ship Core] Tactical AI initialized")
        end
    end

    -- Initialize docking system compatibility
    self.dockingSystemInitialized = true
    self:SetNWBool("DockingSystemActive", true)

    print("[Ship Core] v2.2.1 systems initialization complete")
end

-- Initialize CAP integration
function ENT:InitializeCAPIntegration()
    -- CAP integration state
    self.CAPIntegrationActive = false
    self.LastCAPUpdate = 0
    self.CAPUpdateInterval = 2.0
    self.CAPIntegration = {}

    -- Enhanced configuration
    self.Config = self.Config or {}
    self.Config.EnableCAPIntegration = true
    self.Config.PreferCAPSystems = true
    self.Config.AutoCreateCAPShields = false
    self.Config.CAPResourceIntegration = true
    self.Config.CAPEffectsEnabled = true
    self.Config.CAPShieldAutoActivation = true

    -- Initialize CAP status network variables
    self:SetNWBool("CAPIntegrationActive", false)
    self:SetNWBool("CAPShieldsDetected", false)
    self:SetNWBool("CAPEnergyDetected", false)
    self:SetNWBool("CAPResourcesDetected", false)
    self:SetNWString("CAPStatus", "Detecting...")
    self:SetNWFloat("CAPEnergyLevel", 0)
    self:SetNWInt("CAPShieldCount", 0)
    self:SetNWInt("CAPEntityCount", 0)
    self:SetNWString("CAPVersion", "Unknown")

    if not self.Config.EnableCAPIntegration then
        self:SetNWString("CAPStatus", "CAP Integration Disabled")
        return
    end

    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Available then
        self:SetNWString("CAPStatus", "CAP Not Available")
        return
    end

    self.CAPIntegrationActive = true
    self:SetNWBool("CAPIntegrationActive", true)

    -- Get CAP version info
    local detection = HYPERDRIVE.CAP.Detection
    if detection then
        self:SetNWString("CAPVersion", detection.version or "Unknown")
        self:SetNWString("CAPStatus", "CAP Integration Active - " .. detection.version)
    else
        self:SetNWString("CAPStatus", "CAP Integration Active")
    end

    -- Initialize CAP subsystems
    self.CAPIntegration = {
        shields = {},
        energySources = {},
        resources = {},
        lastShieldUpdate = 0,
        lastEnergyUpdate = 0,
        lastResourceUpdate = 0
    }

    print("[Ship Core] CAP integration initialized for core " .. self:EntIndex())
end

function ENT:Think()
    local currentTime = CurTime()

    -- Real-time entity scanning (10 FPS)
    if currentTime - self.LastEntityScan > self.EntityScanRate then
        self:RealTimeEntityScan()
        self.LastEntityScan = currentTime
    end

    -- Real-time resource calculations (5 FPS)
    if currentTime - self.LastResourceUpdate > self.ResourceUpdateRate then
        self:RealTimeResourceUpdate()
        self.LastResourceUpdate = currentTime
    end

    -- Real-time system health checks (2 FPS)
    if currentTime - self.LastSystemCheck > self.SystemCheckRate then
        self:RealTimeSystemCheck()
        self.LastSystemCheck = currentTime
    end

    -- Real-time network synchronization (10 FPS)
    if currentTime - self.LastNetworkUpdate > self.NetworkUpdateRate then
        self:RealTimeNetworkSync()
        self.LastNetworkUpdate = currentTime
    end

    -- Real-time monitoring updates (20 FPS)
    if currentTime - self.LastRealTimeUpdate > self.RealTimeUpdateRate then
        self:UpdateRealTimeData()
        self.LastRealTimeUpdate = currentTime
    end

    -- Legacy system updates (slower rate for compatibility)
    if currentTime - self.lastUpdate > self.updateInterval then
        self.lastUpdate = currentTime
        self:UpdateSystems()
        self:UpdateUI()
    end

    -- Continue real-time updates with high frequency
    self:NextThink(currentTime + 0.01) -- 100 FPS think rate for smooth real-time updates
    return true
end

function ENT:UpdateSystems()
    -- Update ship detection
    self:UpdateShipDetection()

    -- Update hull damage system
    self:UpdateHullSystem()

    -- Update shield system
    self:UpdateShieldSystem()

    -- Update resource system (Spacebuild 3 integration)
    self:UpdateResourceSystem()

    -- Update CAP integration
    self:UpdateCAPStatus()

    -- v2.2.1 Update new systems
    self:UpdateV221Systems()

    -- Update core state
    self:UpdateCoreState()
end

-- v2.2.1 Update new systems
function ENT:UpdateV221Systems()
    if not self.ship then return end

    -- Update flight system status
    if self.flightSystemInitialized and HYPERDRIVE.Flight then
        local flightSystem = HYPERDRIVE.Flight.GetFlightSystem(self)
        if flightSystem then
            local status = flightSystem:GetStatus()
            self:SetNWBool("FlightActive", status.active)
            self:SetNWFloat("FlightSpeed", status.velocity)
            self:SetNWString("FlightMode", status.flightMode)
        end
    end

    -- Update weapon systems status
    if self.weaponSystemsInitialized and HYPERDRIVE.Weapons then
        local weaponCount = 0
        local activeWeapons = 0

        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 2000)) do
            if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") and ent.weapon then
                weaponCount = weaponCount + 1
                if ent.weapon.active then
                    activeWeapons = activeWeapons + 1
                end
            end
        end

        self:SetNWInt("WeaponCount", weaponCount)
        self:SetNWInt("ActiveWeapons", activeWeapons)
    end

    -- Update ammunition system status
    if self.ammunitionSystemInitialized and HYPERDRIVE.Ammunition then
        local storage = HYPERDRIVE.Ammunition.GetStorage(self)
        if storage then
            local totalAmmo = 0
            for ammoType, amount in pairs(storage.ammunition) do
                totalAmmo = totalAmmo + amount
            end
            self:SetNWInt("TotalAmmunition", totalAmmo)
            self:SetNWFloat("AmmoCapacity", storage.capacity)
        end
    end

    -- Update tactical AI status
    if self.tacticalAIInitialized and HYPERDRIVE.TacticalAI then
        local ai = HYPERDRIVE.TacticalAI.GetAI(self)
        if ai then
            local status = ai:GetStatus()
            self:SetNWBool("TacticalAIActive", status.active)
            self:SetNWString("TacticalState", status.tacticalState)
            self:SetNWInt("ThreatCount", status.threatCount)
        end
    end
end

-- Update CAP integration status
function ENT:UpdateCAPStatus()
    if not self.CAPIntegrationActive then return end

    local currentTime = CurTime()
    if currentTime - self.LastCAPUpdate < self.CAPUpdateInterval then return end
    self.LastCAPUpdate = currentTime

    -- Get ship
    if not self.ship then return end

    local capEntityCount = 0

    -- Update CAP shield status
    if HYPERDRIVE.CAP.Shields then
        local shields = HYPERDRIVE.CAP.Shields.FindShields(self.ship)
        self.CAPIntegration.shields = shields
        self:SetNWBool("CAPShieldsDetected", #shields > 0)
        self:SetNWInt("CAPShieldCount", #shields)
        capEntityCount = capEntityCount + #shields

        if #shields > 0 then
            local shieldStatus = HYPERDRIVE.CAP.Shields.GetStatus(self, self.ship)
            if shieldStatus then
                self:SetNWFloat("ShieldStrength", shieldStatus.averageStrength or 0)
                self:SetNWBool("ShieldSystemActive", shieldStatus.activeShields > 0)
            end
        end
    end

    -- Update CAP energy status
    if HYPERDRIVE.CAP.Resources then
        local energySources = HYPERDRIVE.CAP.Resources.FindEnergySources(self.ship)
        self.CAPIntegration.energySources = energySources
        self:SetNWBool("CAPEnergyDetected", #energySources > 0)
        capEntityCount = capEntityCount + #energySources

        if #energySources > 0 then
            local totalEnergy = HYPERDRIVE.CAP.Resources.GetTotalEnergy(self.ship)
            self:SetNWFloat("CAPEnergyLevel", totalEnergy)
        end
    end

    -- Update CAP resource detection
    if self.ship.entities then
        for _, ent in ipairs(self.ship.entities) do
            if IsValid(ent) and HYPERDRIVE.CAP.GetEntityCategory then
                local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
                if category then
                    capEntityCount = capEntityCount + 1
                end
            end
        end
    end

    self:SetNWBool("CAPResourcesDetected", capEntityCount > 0)
    self:SetNWInt("CAPEntityCount", capEntityCount)
end

function ENT:UpdateShipDetection()
    if not HYPERDRIVE.ShipCore then
        self:SetShipDetected(false)
        self:SetShipType("Ship Core System Not Available")
        self:SetCoreValid(false)
        self:SetStatusMessage("Ship Core system not loaded")
        return
    end

    -- Get or create ship for this core
    local ship = HYPERDRIVE.ShipCore.GetShip(self)
    if not ship then
        -- Create ship with this core as the center
        ship = HYPERDRIVE.ShipCore.CreateShip(self)
    end

    if ship then
        -- Update ship data
        ship:Update()

        self.ship = ship
        self:SetShipDetected(true)
        self:SetShipType(ship:GetShipType())
        self:SetShipCenter(ship:GetCenter())
        self:SetFrontDirection(ship:GetFrontDirection())

        -- Validate core uniqueness
        if HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness then
            local valid, message = HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(self)
            self:SetCoreValid(valid)
            if not valid then
                self:SetStatusMessage("DUPLICATE CORE: " .. message)
                self:SetState(self.States.INVALID)
                return
            end
        end

        self:SetStatusMessage("Ship detected: " .. ship:GetShipType())
        print("[Ship Core] Ship detected: " .. ship:GetShipType() .. " with " .. #ship:GetEntities() .. " entities")
    else
        self.ship = nil
        self:SetShipDetected(false)
        self:SetShipType("No Ship")
        self:SetCoreValid(false)
        self:SetStatusMessage("Ship detection failed")
        print("[Ship Core] Failed to create or detect ship")
    end
end

function ENT:UpdateHullSystem()
    if not HYPERDRIVE.HullDamage or not self.ship then
        self:SetHullSystemActive(false)
        self:SetHullIntegrity(100)
        return
    end

    local getStatusFunc = SafeAccess(HYPERDRIVE.HullDamage, "GetHullStatus")
    if getStatusFunc then
        local hullStatus = SafeCall(getStatusFunc, self)
        if hullStatus then
            self:SetHullSystemActive(true)
            self:SetHullIntegrity(math.floor(hullStatus.integrityPercent or 100))

            -- Update status based on hull integrity
            if hullStatus.emergencyMode then
                self:SetState(self.States.EMERGENCY)
                self:SetStatusMessage("HULL EMERGENCY: " .. math.floor(hullStatus.integrityPercent) .. "%")
            elseif hullStatus.criticalMode then
                self:SetState(self.States.CRITICAL)
                self:SetStatusMessage("HULL CRITICAL: " .. math.floor(hullStatus.integrityPercent) .. "%")
            end
        else
            self:SetHullSystemActive(false)
            self:SetHullIntegrity(100)
        end
    else
        self:SetHullSystemActive(false)
        self:SetHullIntegrity(100)
    end
end

function ENT:UpdateShieldSystem()
    if not HYPERDRIVE.Shields or not self.ship then
        self:SetShieldSystemActive(false)
        self:SetShieldStrength(0)
        return
    end

    local getStatusFunc = SafeAccess(HYPERDRIVE.Shields, "GetShieldStatus")
    if getStatusFunc then
        local shieldStatus = SafeCall(getStatusFunc, self)
        if shieldStatus then
            self:SetShieldSystemActive(shieldStatus.available)
            self:SetShieldStrength(math.floor(shieldStatus.strengthPercent or 0))
        else
            self:SetShieldSystemActive(false)
            self:SetShieldStrength(0)
        end
    else
        self:SetShieldSystemActive(false)
        self:SetShieldStrength(0)
    end
end

function ENT:UpdateResourceSystem()
    -- Update Spacebuild 3 resource system if available
    if HYPERDRIVE.SB3Resources and HYPERDRIVE.SB3Resources.UpdateCoreResources then
        HYPERDRIVE.SB3Resources.UpdateCoreResources(self)
    end

    -- Update resource-related network variables
    self:UpdateResourceNetworkVars()
end

function ENT:UpdateResourceNetworkVars()
    if not HYPERDRIVE.SB3Resources then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
    if not storage then return end

    -- Update energy levels for wire outputs
    local energyAmount = HYPERDRIVE.SB3Resources.GetResourceAmount(self, "energy")
    local energyCapacity = storage.capacity.energy or 1
    local energyPercentage = (energyAmount / energyCapacity) * 100

    -- Set network variables for resource levels
    self:SetNWFloat("ResourceEnergy", energyPercentage)
    self:SetNWFloat("ResourceOxygen", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "oxygen"))
    self:SetNWFloat("ResourceCoolant", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "coolant"))
    self:SetNWFloat("ResourceFuel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "fuel"))
    self:SetNWFloat("ResourceWater", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "water"))
    self:SetNWFloat("ResourceNitrogen", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "nitrogen"))

    -- Check for emergency mode
    local emergencyMode = storage.emergencyMode and 1 or 0
    self:SetNWInt("ResourceEmergencyMode", emergencyMode)

    -- Update wire outputs if wiremod is available
    if WireLib then
        WireLib.TriggerOutput(self, "EnergyLevel", energyPercentage)
        WireLib.TriggerOutput(self, "OxygenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "oxygen"))
        WireLib.TriggerOutput(self, "CoolantLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "coolant"))
        WireLib.TriggerOutput(self, "FuelLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "fuel"))
        WireLib.TriggerOutput(self, "WaterLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "water"))
        WireLib.TriggerOutput(self, "NitrogenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "nitrogen"))
        WireLib.TriggerOutput(self, "ResourceEmergency", emergencyMode)
        WireLib.TriggerOutput(self, "ResourceSystemActive", self:GetNWBool("ResourceSystemActive", false) and 1 or 0)
        WireLib.TriggerOutput(self, "AutoProvisionEnabled", self:GetNWBool("AutoProvisionEnabled", true) and 1 or 0)
        WireLib.TriggerOutput(self, "WeldDetectionEnabled", self:GetNWBool("WeldDetectionEnabled", true) and 1 or 0)
        WireLib.TriggerOutput(self, "LastResourceActivity", self:GetNWString("LastResourceActivity", ""))

        -- Calculate total resource capacity and amount
        local totalCapacity = 0
        local totalAmount = 0
        local distributionRate = 0
        local collectionRate = 0
        for _, resourceType in ipairs({"energy", "oxygen", "coolant", "fuel", "water", "nitrogen"}) do
            totalCapacity = totalCapacity + (storage.capacity[resourceType] or 0)
            totalAmount = totalAmount + (storage.resources[resourceType] or 0)
        end
        distributionRate = storage.distributionRate or 0
        collectionRate = storage.collectionRate or 0

        WireLib.TriggerOutput(self, "TotalResourceCapacity", totalCapacity)
        WireLib.TriggerOutput(self, "TotalResourceAmount", totalAmount)
        WireLib.TriggerOutput(self, "ResourceDistributionRate", distributionRate)
        WireLib.TriggerOutput(self, "ResourceCollectionRate", collectionRate)
    end
end

function ENT:UpdateCoreState()
    if not self:GetCoreValid() then
        self:SetState(self.States.INVALID)
        return
    end

    if not self:GetShipDetected() then
        self:SetState(self.States.INACTIVE)
        self:SetStatusMessage("No ship detected")
        return
    end

    local hullIntegrity = self:GetHullIntegrity()

    if hullIntegrity < 10 then
        self:SetState(self.States.EMERGENCY)
        self:SetStatusMessage("EMERGENCY: Hull " .. hullIntegrity .. "%")
    elseif hullIntegrity < 25 then
        self:SetState(self.States.CRITICAL)
        self:SetStatusMessage("CRITICAL: Hull " .. hullIntegrity .. "%")
    else
        self:SetState(self.States.ACTIVE)
        self:SetStatusMessage("Operational")
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Get interface configuration
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or {}

    -- Check if USE key interfaces are enabled
    if not config.EnableUSEKeyInterfaces then
        if config.EnableFeedbackMessages then
            activator:ChatPrint("[Ship Core] Interface access is disabled")
        end
        return
    end

    -- Check distance
    local maxDistance = config.MaxInteractionDistance or 200
    if config.EnableDistanceChecking and self:GetPos():Distance(activator:GetPos()) > maxDistance then
        if config.EnableFeedbackMessages then
            activator:ChatPrint("[Ship Core] Too far away to access interface (max " .. maxDistance .. " units)")
        end
        return
    end

    -- Check session limits
    if config.EnableSessionTracking then
        local activeSessions = HYPERDRIVE.Interface.ActiveSessions[activator] or 0
        local maxSessions = config.MaxConcurrentSessions or 10
        if activeSessions >= maxSessions then
            if config.EnableFeedbackMessages then
                activator:ChatPrint("[Ship Core] Too many active interface sessions")
            end
            return
        end
    end

    -- Open ship core UI
    self:OpenUI(activator)

    -- Provide feedback
    if config.EnableFeedbackMessages then
        activator:ChatPrint("[Ship Core] Opening ship management interface...")
    end

    -- Track session
    if config.EnableSessionTracking then
        HYPERDRIVE.Interface.ActiveSessions[activator] = (HYPERDRIVE.Interface.ActiveSessions[activator] or 0) + 1
    end
end

function ENT:OpenUI(ply)
    if not IsValid(ply) then return end

    -- Track active UI
    self.activeUIs[ply] = true

    -- Send UI data
    net.Start("ship_core_open_ui")
    net.WriteEntity(self)
    net.WriteTable(self:GetUIData())
    net.Send(ply)

    print("[Ship Core] UI opened for " .. ply:Nick())
end

function ENT:GetUIData()
    local data = {
        -- Core information
        corePos = self:GetPos(),
        coreState = self:GetState(),
        coreStateName = self:GetStateName(),
        coreValid = self:GetCoreValid(),
        statusMessage = self:GetStatusMessage(),

        -- Ship information
        shipDetected = self:GetShipDetected(),
        shipType = self:GetShipType(),
        shipName = self:GetShipName(),
        shipCenter = self:GetShipCenter(),
        frontDirection = self:GetFrontDirection(),

        -- Hull system
        hullSystemActive = self:GetHullSystemActive(),
        hullIntegrity = self:GetHullIntegrity(),

        -- Shield system
        shieldSystemActive = self:GetShieldSystemActive(),
        shieldStrength = self:GetShieldStrength(),

        -- Resource system (Spacebuild 3)
        resourceSystemActive = HYPERDRIVE.SB3Resources ~= nil and self:GetNWBool("ResourceSystemActive", false),
        resourceEnergy = self:GetNWFloat("ResourceEnergy", 0),
        resourceOxygen = self:GetNWFloat("ResourceOxygen", 0),
        resourceCoolant = self:GetNWFloat("ResourceCoolant", 0),
        resourceFuel = self:GetNWFloat("ResourceFuel", 0),
        resourceWater = self:GetNWFloat("ResourceWater", 0),
        resourceNitrogen = self:GetNWFloat("ResourceNitrogen", 0),
        resourceEmergencyMode = self:GetNWInt("ResourceEmergencyMode", 0) == 1,

        -- Resource system settings
        autoProvisionEnabled = self:GetNWBool("AutoProvisionEnabled", true),
        weldDetectionEnabled = self:GetNWBool("WeldDetectionEnabled", true),
        lastResourceActivity = self:GetNWString("LastResourceActivity", ""),

        -- CAP integration data
        capIntegrationActive = self:GetNWBool("CAPIntegrationActive", false),
        capShieldsDetected = self:GetNWBool("CAPShieldsDetected", false),
        capEnergyDetected = self:GetNWBool("CAPEnergyDetected", false),
        capResourcesDetected = self:GetNWBool("CAPResourcesDetected", false),
        capStatus = self:GetNWString("CAPStatus", "Unknown"),
        capEnergyLevel = self:GetNWFloat("CAPEnergyLevel", 0),
        capShieldCount = self:GetNWInt("CAPShieldCount", 0),
        capEntityCount = self:GetNWInt("CAPEntityCount", 0),
        capVersion = self:GetNWString("CAPVersion", "Unknown"),

        -- Additional data
        entityCount = 0,
        playerCount = 0,
        mass = 0
    }

    -- Get detailed ship information
    if self.ship then
        -- Safe access to ship methods
        local getEntitiesFunc = SafeAccess(self.ship, "GetEntities")
        local getPlayersFunc = SafeAccess(self.ship, "GetPlayers")
        local getMassFunc = SafeAccess(self.ship, "GetMass")

        data.entityCount = getEntitiesFunc and #SafeCall(getEntitiesFunc, self.ship) or 0
        data.playerCount = getPlayersFunc and #SafeCall(getPlayersFunc, self.ship) or 0
        data.mass = getMassFunc and SafeCall(getMassFunc, self.ship) or (self.ship.mass or 0)

        -- Get hull damage details
        if HYPERDRIVE.HullDamage then
            local getStatusFunc = SafeAccess(HYPERDRIVE.HullDamage, "GetHullStatus")
            if getStatusFunc then
                local hullStatus = SafeCall(getStatusFunc, self)
                if hullStatus then
                    data.hullBreaches = hullStatus.breaches or 0
                    data.hullSystemFailures = hullStatus.systemFailures or 0
                    data.hullAutoRepair = hullStatus.autoRepairActive or false
                    data.hullCriticalMode = hullStatus.criticalMode or false
                    data.hullEmergencyMode = hullStatus.emergencyMode or false
                end
            end
        end

        -- Get shield details
        if HYPERDRIVE.Shields then
            local getStatusFunc = SafeAccess(HYPERDRIVE.Shields, "GetShieldStatus")
            if getStatusFunc then
                local shieldStatus = SafeCall(getStatusFunc, self)
                if shieldStatus then
                    data.shieldActive = shieldStatus.active or false
                    data.shieldRecharging = shieldStatus.recharging or false
                    data.shieldOverloaded = shieldStatus.overloaded or false
                    data.shieldType = shieldStatus.shieldType or "None"
                end
            end
        end
    end

    return data
end

function ENT:UpdateUI()
    if table.Count(self.activeUIs) == 0 then return end

    local data = self:GetUIData()

    for ply, _ in pairs(self.activeUIs) do
        if IsValid(ply) then
            net.Start("ship_core_update_ui")
            net.WriteTable(data)
            net.Send(ply)
        else
            self.activeUIs[ply] = nil
        end
    end
end

function ENT:CloseUI(ply)
    if IsValid(ply) then
        self.activeUIs[ply] = nil
        net.Start("ship_core_close_ui")
        net.Send(ply)

        -- Update session tracking
        local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or {}
        if config.EnableSessionTracking then
            HYPERDRIVE.Interface.ActiveSessions[ply] = math.max(0, (HYPERDRIVE.Interface.ActiveSessions[ply] or 1) - 1)
        end
    end
end

-- Handle UI commands
net.Receive("ship_core_command", function(len, ply)
    local core = net.ReadEntity()
    local command = net.ReadString()
    local data = net.ReadTable()

    if not IsValid(core) or not IsValid(ply) then return end
    if core:GetClass() ~= "ship_core" then return end

    core:HandleUICommand(ply, command, data)
end)

-- Ship name management functions
function ENT:LoadShipName()
    if file.Exists(self.shipNameFile, "DATA") then
        local nameData = file.Read(self.shipNameFile, "DATA")
        if nameData and nameData ~= "" then
            local success, result = pcall(util.JSONToTable, nameData)
            if success and result and result.shipName then
                self:SetShipName(result.shipName)
                print("[Ship Core] Loaded ship name: " .. result.shipName)
                return
            end
        end
    end

    -- Default name if no file or invalid data
    self:SetShipName("Unnamed Ship")
    print("[Ship Core] Using default ship name")
end

function ENT:SaveShipName()
    local data = {
        shipName = self:GetShipName(),
        timestamp = os.time(),
        coreIndex = self:EntIndex()
    }

    local jsonData = util.TableToJSON(data)
    if jsonData then
        file.CreateDir("hyperdrive")
        file.Write(self.shipNameFile, jsonData)
        return true
    end
    return false
end

function ENT:ValidateShipName(name)
    if not name or type(name) ~= "string" then
        return false, "Invalid name type"
    end

    -- Get configuration
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
    local maxLength = config.MaxNameLength or 32
    local minLength = config.MinNameLength or 1
    local pattern = config.NameValidationPattern or "^[%w%s%-_]+$"
    local reservedNames = config.ReservedNames or {}

    -- Remove whitespace
    name = string.Trim(name)

    -- Check length
    if string.len(name) < minLength then
        return false, "Name too short (minimum " .. minLength .. " characters)"
    end

    if string.len(name) > maxLength then
        return false, "Name too long (maximum " .. maxLength .. " characters)"
    end

    -- Check for valid characters
    if not string.match(name, pattern) then
        return false, "Invalid characters (use letters, numbers, spaces, hyphens, underscores only)"
    end

    -- Check reserved names
    local lowerName = string.lower(name)
    for _, reserved in ipairs(reservedNames) do
        if string.lower(reserved) == lowerName then
            return false, "Name '" .. name .. "' is reserved and cannot be used"
        end
    end

    -- Check uniqueness if enabled
    if config.ValidateNameUniqueness then
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetClass() == "ship_core" and ent ~= self then
                if ent.GetShipName and string.lower(ent:GetShipName()) == lowerName then
                    return false, "Ship name '" .. name .. "' is already in use"
                end
            end
        end
    end

    return true, name
end

function ENT:SetShipNameSafe(name, player)
    local valid, result = self:ValidateShipName(name)
    if valid then
        local oldName = self:GetShipName()
        self:SetShipName(result)
        self:SaveShipName()

        -- Update ship object if it exists
        if self.ship and self.ship.SetShipName then
            self.ship:SetShipName(result)
        end

        -- Register with global naming system
        if HYPERDRIVE.ShipNames and HYPERDRIVE.ShipNames.RegisterShip then
            HYPERDRIVE.ShipNames.RegisterShip(self, result)
        end

        -- Log name change if enabled
        local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
        if config.LogNameChanges then
            local playerName = IsValid(player) and player:Nick() or "System"
            print("[Ship Core] Ship renamed from '" .. oldName .. "' to '" .. result .. "' by " .. playerName)
        end

        -- Broadcast name change if enabled
        if config.BroadcastNameChanges and IsValid(player) then
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) then
                    ply:ChatPrint("[Ship Core] " .. player:Nick() .. " renamed ship '" .. oldName .. "' to '" .. result .. "'")
                end
            end
        end

        return true, result
    else
        return false, result
    end
end

function ENT:HandleUICommand(ply, command, data)
    if command == "repair_hull" then
        if HYPERDRIVE.HullDamage then
            local amount = data.amount or 25
            local success = HYPERDRIVE.HullDamage.RepairHull(self, amount)
            if success then
                ply:ChatPrint("[Ship Core] Hull repaired by " .. amount .. " points")
                -- Log repair action
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Hull repaired by " .. ply:Nick() .. " (+" .. amount .. ")", "repair", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Hull repair failed")
            end
        end

    elseif command == "activate_shields" then
        if HYPERDRIVE.Shields and self.ship then
            local success = HYPERDRIVE.Shields.ActivateShield(self, self.ship)
            if success then
                ply:ChatPrint("[Ship Core] Shields activated")

                -- Play shield engage sound
                net.Start("hyperdrive_play_sound")
                net.WriteString("Shield")
                net.WriteString("Engage")
                net.WriteEntity(self)
                net.Send(ply)

                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Shields activated by " .. ply:Nick(), "shield", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Shield activation failed")

                -- Play error sound
                net.Start("hyperdrive_play_sound")
                net.WriteString("UI")
                net.WriteString("Error")
                net.WriteEntity(self)
                net.Send(ply)
            end
        end

    elseif command == "deactivate_shields" then
        if HYPERDRIVE.Shields then
            local success = HYPERDRIVE.Shields.DeactivateShield(self)
            if success then
                ply:ChatPrint("[Ship Core] Shields deactivated")

                -- Play shield disengage sound
                net.Start("hyperdrive_play_sound")
                net.WriteString("Shield")
                net.WriteString("Disengage")
                net.WriteEntity(self)
                net.Send(ply)

                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Shields deactivated by " .. ply:Nick(), "shield", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Shield deactivation failed")

                -- Play error sound
                net.Start("hyperdrive_play_sound")
                net.WriteString("UI")
                net.WriteString("Error")
                net.WriteEntity(self)
                net.Send(ply)
            end
        end

    elseif command == "toggle_front_indicator" then
        if self.ship then
            -- Safe access to ship indicator methods
            local isVisibleFunc = SafeAccess(self.ship, "IsFrontIndicatorVisible")
            local hideFunc = SafeAccess(self.ship, "HideFrontIndicator")
            local showFunc = SafeAccess(self.ship, "ShowFrontIndicator")

            if isVisibleFunc and hideFunc and showFunc then
                local visible = SafeCall(isVisibleFunc, self.ship)
                if visible then
                    SafeCall(hideFunc, self.ship)
                    ply:ChatPrint("[Ship Core] Front indicator hidden")
                else
                    SafeCall(showFunc, self.ship)
                    ply:ChatPrint("[Ship Core] Front indicator shown")
                end

                local addLogFunc = SafeAccess(HYPERDRIVE.UI, "AddLogEntry")
                if addLogFunc then
                    SafeCall(addLogFunc, "Front indicator toggled by " .. ply:Nick(), "info", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Front indicator system not available")
            end
        end

    elseif command == "emergency_repair" then
        if HYPERDRIVE.HullDamage then
            local amount = 50 -- Emergency repair amount
            local success = HYPERDRIVE.HullDamage.RepairHull(self, amount)
            if success then
                ply:ChatPrint("[Ship Core] Emergency hull repair applied: +" .. amount .. " points")
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Emergency repair by " .. ply:Nick() .. " (+" .. amount .. ")", "emergency", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Emergency repair failed")
            end
        end

    elseif command == "hull_status" then
        if HYPERDRIVE.HullDamage then
            local hullStatus = HYPERDRIVE.HullDamage.GetHullStatus(self)
            if hullStatus then
                ply:ChatPrint("[Ship Core] Hull Status:")
                ply:ChatPrint("  Integrity: " .. string.format("%.1f", hullStatus.integrityPercent) .. "%")
                ply:ChatPrint("  Breaches: " .. (hullStatus.breaches or 0))
                ply:ChatPrint("  System Failures: " .. (hullStatus.systemFailures or 0))
                ply:ChatPrint("  Auto-Repair: " .. (hullStatus.autoRepairActive and "Active" or "Inactive"))
            else
                ply:ChatPrint("[Ship Core] Hull damage system not available")
            end
        end

    elseif command == "ship_info" then
        if self.ship then
            ply:ChatPrint("[Ship Core] Ship Information:")

            -- Safe access to ship methods
            local getTypeFunc = SafeAccess(self.ship, "GetShipType")
            local getEntitiesFunc = SafeAccess(self.ship, "GetEntities")
            local getPlayersFunc = SafeAccess(self.ship, "GetPlayers")
            local getMassFunc = SafeAccess(self.ship, "GetMass")
            local getCenterFunc = SafeAccess(self.ship, "GetCenter")

            local shipType = getTypeFunc and SafeCall(getTypeFunc, self.ship) or "Unknown"
            local entityCount = getEntitiesFunc and #SafeCall(getEntitiesFunc, self.ship) or 0
            local playerCount = getPlayersFunc and #SafeCall(getPlayersFunc, self.ship) or 0
            local mass = getMassFunc and SafeCall(getMassFunc, self.ship) or (self.ship.mass or 0)
            local center = getCenterFunc and SafeCall(getCenterFunc, self.ship) or self:GetPos()

            ply:ChatPrint("  Type: " .. shipType)
            ply:ChatPrint("  Entities: " .. entityCount)
            ply:ChatPrint("  Players: " .. playerCount)
            ply:ChatPrint("  Mass: " .. math.floor(mass))
            ply:ChatPrint("  Center: " .. math.floor(center.x) .. ", " .. math.floor(center.y) .. ", " .. math.floor(center.z))
        else
            ply:ChatPrint("[Ship Core] No ship detected")
        end

    elseif command == "set_ship_name" then
        local newName = data.name
        if newName then
            -- Check permissions if required
            local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
            if config.RequireOwnershipToRename then
                -- TODO: Add ownership check when ownership system is implemented
                -- For now, allow all players to rename
            end

            local success, result = self:SetShipNameSafe(newName, ply)
            if success then
                ply:ChatPrint("[Ship Core] Ship name changed to: " .. result)
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Ship renamed to '" .. result .. "' by " .. ply:Nick(), "info", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Name change failed: " .. result)
            end
        else
            ply:ChatPrint("[Ship Core] Invalid name provided")
        end

    elseif command == "open_name_dialog" then
        -- Send current name to client for editing
        net.Start("ship_core_name_dialog")
        net.WriteEntity(self)
        net.WriteString(self:GetShipName())
        net.Send(ply)

    elseif command == "resource_status" then
        if HYPERDRIVE.SB3Resources then
            local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
            if storage then
                ply:ChatPrint("[Ship Core] Resource Status:")
                for resourceType, amount in pairs(storage.resources) do
                    local capacity = storage.capacity[resourceType]
                    local percentage = (amount / capacity) * 100
                    local resourceConfig = HYPERDRIVE.SB3Resources.ResourceTypes[resourceType]
                    ply:ChatPrint("  " .. resourceConfig.name .. ": " .. math.floor(amount) .. "/" .. capacity .. " " .. resourceConfig.unit .. " (" .. string.format("%.1f", percentage) .. "%)")
                end
                if storage.emergencyMode then
                    ply:ChatPrint("  STATUS: EMERGENCY MODE ACTIVE")
                end
            else
                ply:ChatPrint("[Ship Core] Resource system not initialized")
            end
        else
            ply:ChatPrint("[Ship Core] Spacebuild 3 resource system not available")
        end

    elseif command == "resource_distribute" then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.DistributeResources(self)
            ply:ChatPrint("[Ship Core] Resource distribution initiated")
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Resource distribution by " .. ply:Nick(), "resource", self:EntIndex())
            end
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "resource_collect" then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.CollectResources(self)
            ply:ChatPrint("[Ship Core] Resource collection initiated")
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Resource collection by " .. ply:Nick(), "resource", self:EntIndex())
            end
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "resource_balance" then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.AutoBalanceResources(self)
            ply:ChatPrint("[Ship Core] Resource auto-balance initiated")
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Resource auto-balance by " .. ply:Nick(), "resource", self:EntIndex())
            end
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "toggle_auto_provision" then
        if HYPERDRIVE.SB3Resources then
            local currentState = self:GetNWBool("AutoProvisionEnabled", true)
            local newState = not currentState
            self:SetNWBool("AutoProvisionEnabled", newState)

            -- Update configuration if available
            if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources then
                HYPERDRIVE.EnhancedConfig.SB3Resources.EnableAutoResourceProvision = newState
            end

            local message = "Auto-provision " .. (newState and "enabled" or "disabled")
            ply:ChatPrint("[Ship Core] " .. message)
            self:SetNWString("LastResourceActivity", message)
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "toggle_weld_detection" then
        if HYPERDRIVE.SB3Resources then
            local currentState = self:GetNWBool("WeldDetectionEnabled", true)
            local newState = not currentState
            self:SetNWBool("WeldDetectionEnabled", newState)

            -- Update configuration if available
            if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources then
                HYPERDRIVE.EnhancedConfig.SB3Resources.EnableWeldDetection = newState
            end

            local message = "Weld detection " .. (newState and "enabled" or "disabled")
            ply:ChatPrint("[Ship Core] " .. message)
            self:SetNWString("LastResourceActivity", message)
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "close_ui" then
        self:CloseUI(ply)
    end
end

-- Wire input handling
function ENT:TriggerInput(iname, value)
    if iname == "DistributeResources" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.DistributeResources(self)
        end
    elseif iname == "CollectResources" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.CollectResources(self)
        end
    elseif iname == "BalanceResources" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.AutoBalanceResources(self)
        end
    elseif iname == "SetEnergyCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "energy", value)
        end
    elseif iname == "SetOxygenCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "oxygen", value)
        end
    elseif iname == "SetCoolantCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "coolant", value)
        end
    elseif iname == "SetFuelCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "fuel", value)
        end
    elseif iname == "SetWaterCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "water", value)
        end
    elseif iname == "SetNitrogenCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "nitrogen", value)
        end
    elseif iname == "ToggleAutoProvision" and value > 0 then
        local currentState = self:GetNWBool("AutoProvisionEnabled", true)
        self:SetNWBool("AutoProvisionEnabled", not currentState)
        self:SetNWString("LastResourceActivity", "Auto-provision " .. (not currentState and "enabled" or "disabled"))
    elseif iname == "ToggleWeldDetection" and value > 0 then
        local currentState = self:GetNWBool("WeldDetectionEnabled", true)
        self:SetNWBool("WeldDetectionEnabled", not currentState)
        self:SetNWString("LastResourceActivity", "Weld detection " .. (not currentState and "enabled" or "disabled"))
    elseif iname == "EmergencyResourceShutdown" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.EmergencyShutdown(self)
            self:SetNWString("LastResourceActivity", "Emergency shutdown activated")
        end
    elseif iname == "RepairHull" and value > 0 then
        if HYPERDRIVE.HullDamage then
            HYPERDRIVE.HullDamage.RepairHull(self, 25)
        end
    elseif iname == "ActivateShields" and value > 0 then
        if HYPERDRIVE.Shields and self.ship then
            HYPERDRIVE.Shields.ManualActivate(self, self.ship)
        end
    elseif iname == "DeactivateShields" and value > 0 then
        if HYPERDRIVE.Shields and self.ship then
            HYPERDRIVE.Shields.ManualDeactivate(self, self.ship)
        end
    end

    -- Update wire outputs after input processing
    if WireLib then
        self:UpdateWireOutputs()
    end
end

-- v2.2.0 New initialization functions
function ENT:InitializeFleetManagement()
    -- Initialize fleet management capabilities
    self.FleetID = 0
    self.FleetRole = ""
    self.FleetData = {}

    -- Set up fleet network variables
    self:SetNWInt("FleetID", 0)
    self:SetNWString("FleetRole", "")
    self:SetNWBool("FleetCapable", true)

    print("[Ship Core] Fleet management initialized")
end

function ENT:InitializeRealTimeMonitoring()
    -- Initialize real-time monitoring system
    self.RealTimeMonitoring = true
    self.LastRealTimeUpdate = 0
    self.RealTimeUpdateRate = 0.05 -- 20 FPS
    self.SystemAlerts = {}

    -- Set up real-time network variables
    self:SetNWBool("RealTimeMonitoring", true)
    self:SetNWFloat("LastUpdate", CurTime())
    self:SetNWString("SystemStatus", "Operational")

    print("[Ship Core] Real-time monitoring initialized")
end

-- Start real-time update system
function ENT:StartRealTimeUpdates()
    -- Initialize all real-time timers
    self.LastEntityScan = CurTime()
    self.LastResourceUpdate = CurTime()
    self.LastSystemCheck = CurTime()
    self.LastNetworkUpdate = CurTime()
    self.LastRealTimeUpdate = CurTime()

    print("[Ship Core] Real-time update system started")
end

-- Real-time entity scanning
function ENT:RealTimeEntityScan()
    if not self.ship then return end

    -- Scan for attached entities
    local entities = self.ship:GetEntities()
    local entityCount = #entities

    -- Cache entity data for performance
    self.CachedAttachedEntities = {
        count = entityCount,
        entities = entities,
        lastScan = CurTime(),
        hyperdriveEngines = 0,
        shieldGenerators = 0,
        capEntities = 0,
        sb3Entities = 0
    }

    -- Count specific entity types
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local class = ent:GetClass()
            if string.find(class, "hyperdrive") then
                self.CachedAttachedEntities.hyperdriveEngines = self.CachedAttachedEntities.hyperdriveEngines + 1
            elseif string.find(class, "shield") then
                self.CachedAttachedEntities.shieldGenerators = self.CachedAttachedEntities.shieldGenerators + 1
            elseif HYPERDRIVE.CAP and HYPERDRIVE.CAP.GetEntityCategory and HYPERDRIVE.CAP.GetEntityCategory(class) then
                self.CachedAttachedEntities.capEntities = self.CachedAttachedEntities.capEntities + 1
            elseif string.find(class, "sb3_") or string.find(class, "spacebuild") then
                self.CachedAttachedEntities.sb3Entities = self.CachedAttachedEntities.sb3Entities + 1
            end
        end
    end

    -- Update network variables
    self:SetNWInt("AttachedEntityCount", entityCount)
    self:SetNWInt("HyperdriveEngineCount", self.CachedAttachedEntities.hyperdriveEngines)
    self:SetNWInt("ShieldGeneratorCount", self.CachedAttachedEntities.shieldGenerators)
    self:SetNWInt("CAPEntityCount", self.CachedAttachedEntities.capEntities)
    self:SetNWInt("SB3EntityCount", self.CachedAttachedEntities.sb3Entities)
end

-- Real-time resource calculations
function ENT:RealTimeResourceUpdate()
    if not HYPERDRIVE.SB3Resources then
        -- Initialize default resource data when SB3Resources not available
        self.CachedResourceData = {
            energy = 0,
            oxygen = 0,
            coolant = 0,
            fuel = 0,
            water = 0,
            nitrogen = 0,
            maxEnergy = 1000,
            maxOxygen = 100,
            maxCoolant = 200,
            maxFuel = 300,
            maxWater = 150,
            maxNitrogen = 80,
            distributionRate = 0,
            collectionRate = 0,
            emergencyMode = false,
            lastUpdate = CurTime()
        }
        return
    end

    -- Update resource system
    HYPERDRIVE.SB3Resources.UpdateCoreResources(self)

    -- Cache resource data
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
    if storage then
        self.CachedResourceData = {
            energy = storage.resources.energy or 0,
            oxygen = storage.resources.oxygen or 0,
            coolant = storage.resources.coolant or 0,
            fuel = storage.resources.fuel or 0,
            water = storage.resources.water or 0,
            nitrogen = storage.resources.nitrogen or 0,
            maxEnergy = storage.capacity.energy or 1000,
            maxOxygen = storage.capacity.oxygen or 100,
            maxCoolant = storage.capacity.coolant or 200,
            maxFuel = storage.capacity.fuel or 300,
            maxWater = storage.capacity.water or 150,
            maxNitrogen = storage.capacity.nitrogen or 80,
            distributionRate = storage.distributionRate or 0,
            collectionRate = storage.collectionRate or 0,
            emergencyMode = storage.emergencyMode or false,
            lastUpdate = CurTime()
        }

        -- Calculate percentages
        local energyPercent = (self.CachedResourceData.energy / self.CachedResourceData.maxEnergy) * 100
        local oxygenPercent = (self.CachedResourceData.oxygen / self.CachedResourceData.maxOxygen) * 100
        local coolantPercent = (self.CachedResourceData.coolant / self.CachedResourceData.maxCoolant) * 100

        -- Update network variables with real-time data
        self:SetNWFloat("ResourceEnergy", energyPercent)
        self:SetNWFloat("ResourceOxygen", oxygenPercent)
        self:SetNWFloat("ResourceCoolant", coolantPercent)
        self:SetNWFloat("ResourceFuel", (self.CachedResourceData.fuel / self.CachedResourceData.maxFuel) * 100)
        self:SetNWFloat("ResourceWater", (self.CachedResourceData.water / self.CachedResourceData.maxWater) * 100)
        self:SetNWFloat("ResourceNitrogen", (self.CachedResourceData.nitrogen / self.CachedResourceData.maxNitrogen) * 100)
        self:SetNWFloat("ResourceDistributionRate", self.CachedResourceData.distributionRate)
        self:SetNWFloat("ResourceCollectionRate", self.CachedResourceData.collectionRate)
        self:SetNWBool("ResourceEmergencyMode", self.CachedResourceData.emergencyMode)
    else
        -- Initialize default resource data when storage not available
        self.CachedResourceData = {
            energy = 0,
            oxygen = 0,
            coolant = 0,
            fuel = 0,
            water = 0,
            nitrogen = 0,
            maxEnergy = 1000,
            maxOxygen = 100,
            maxCoolant = 200,
            maxFuel = 300,
            maxWater = 150,
            maxNitrogen = 80,
            distributionRate = 0,
            collectionRate = 0,
            emergencyMode = false,
            lastUpdate = CurTime()
        }
    end
end

-- Real-time system health checks
function ENT:RealTimeSystemCheck()
    local currentTime = CurTime()

    -- Smart update scheduler with performance tracking
    self:SmartUpdateScheduler(currentTime)

    self.LastRealTimeUpdate = currentTime
end

function ENT:SmartUpdateScheduler(currentTime)
    -- Priority-based update scheduling
    local updates = {
        {name = "entity_scan", func = self.SmartEntityScan, priority = self.UpdatePriorities.entity_scan, lastVar = "LastEntityScan"},
        {name = "resource_update", func = self.SmartResourceUpdate, priority = self.UpdatePriorities.resource_update, lastVar = "LastResourceUpdate"},
        {name = "system_check", func = self.SmartSystemCheck, priority = self.UpdatePriorities.system_check, lastVar = "LastSystemCheck"},
        {name = "network_sync", func = self.SmartNetworkSync, priority = self.UpdatePriorities.network_sync, lastVar = "LastNetworkSync"}
    }

    -- Sort by priority (lower number = higher priority)
    table.sort(updates, function(a, b) return a.priority < b.priority end)

    -- Execute updates based on adaptive timing
    for _, update in ipairs(updates) do
        local lastUpdate = self[update.lastVar] or 0
        local updateRate = self.AdaptiveRates[update.name].current

        if currentTime - lastUpdate >= updateRate then
            local startTime = SysTime()

            -- Execute update function
            update.func(self, currentTime)

            -- Track performance
            local executionTime = SysTime() - startTime
            self:TrackUpdatePerformance(update.name, executionTime)

            -- Update timing
            self[update.lastVar] = currentTime

            -- Adapt update rate based on performance
            self:AdaptUpdateRate(update.name, executionTime)
        end
    end
end

function ENT:SmartEntityScan(currentTime)
    -- Only scan if entities might have changed
    if not self:ShouldScanEntities() then
        return
    end

    local oldCount = self.LastEntityCount
    self:RealTimeEntityScan()
    local newCount = self.CachedAttachedEntities.count or 0

    -- Detect significant changes
    if math.abs(newCount - oldCount) > 0 then
        self.LastEntityCount = newCount
        -- Force other systems to update when entities change
        self:InvalidateSystemCaches()
        print("[Ship Core] Smart scan: Entity count changed from " .. oldCount .. " to " .. newCount)
    end
end

function ENT:SmartResourceUpdate(currentTime)
    -- Only update resources if there are changes or critical conditions
    if not self:ShouldUpdateResources() then
        return
    end

    local oldState = table.Copy(self.LastResourceState)
    self:RealTimeResourceUpdate()

    -- Check for significant resource changes
    local newState = self:GetResourceState()
    if self:HasSignificantResourceChange(oldState, newState) then
        self.LastResourceState = newState
        print("[Ship Core] Smart update: Resource state changed")
    end
end

function ENT:SmartSystemCheck(currentTime)
    -- Only check systems if conditions warrant it
    if not self:ShouldCheckSystems() then
        return
    end

    local oldState = table.Copy(self.LastSystemState)

    -- Cache system status
    self.CachedSystemStatus = {
        shipDetected = self:GetShipDetected(),
        coreValid = self:GetCoreValid(),
        hullIntegrity = self:GetHullIntegrity(),
        shieldStrength = self:GetShieldStrength(),
        systemState = self:GetState(),
        lastCheck = currentTime
    }

    -- Update ship detection
    self:UpdateShipDetection()

    -- Update hull system
    self:UpdateHullSystem()

    -- Update shield system
    self:UpdateShieldSystem()

    -- Update CAP integration
    self:UpdateCAPStatus()

    -- Update core state
    self:UpdateCoreState()

    local newState = self:GetSystemState()
    if self:HasSignificantSystemChange(oldState, newState) then
        self.LastSystemState = newState
        print("[Ship Core] Smart check: System state changed")
    end
end

function ENT:SmartNetworkSync(currentTime)
    -- Only sync network variables when there are changes
    if not self:ShouldSyncNetwork() then
        return
    end

    -- Update real-time data and network synchronization
    self:UpdateRealTimeData()
    self:RealTimeNetworkSync()
end

-- Smart update helper functions
function ENT:ShouldScanEntities()
    -- Scan if we haven't scanned recently or if there might be changes
    local timeSinceLastScan = CurTime() - (self.LastEntityScan or 0)

    -- Always scan if it's been too long
    if timeSinceLastScan > 5.0 then
        return true
    end

    -- Scan if ship state changed
    if self.ship and self.ship.entitiesChanged then
        self.ship.entitiesChanged = false
        return true
    end

    -- Scan if we detect potential changes (players nearby, etc.)
    local nearbyPlayers = #ents.FindInSphere(self:GetPos(), 500)
    if nearbyPlayers > 0 and timeSinceLastScan > 1.0 then
        return true
    end

    return false
end

function ENT:ShouldUpdateResources()
    -- Update if critical conditions exist
    local energyLevel = self:GetNWFloat("EnergyLevel", 100)
    if energyLevel < 25 then
        return true
    end

    -- Update if emergency mode
    if self:GetNWBool("ResourceEmergencyMode", false) then
        return true
    end

    -- Update if enough time has passed
    local timeSinceLastUpdate = CurTime() - (self.LastResourceUpdate or 0)
    return timeSinceLastUpdate > 1.0
end

function ENT:ShouldCheckSystems()
    -- Check if system state might have changed
    local currentState = self:GetState()
    if currentState ~= (self.LastSystemState.state or 0) then
        return true
    end

    -- Check if hull integrity is low
    local hullIntegrity = self:GetHullIntegrity()
    if hullIntegrity < 50 then
        return true
    end

    -- Check if enough time has passed
    local timeSinceLastCheck = CurTime() - (self.LastSystemCheck or 0)
    return timeSinceLastCheck > 2.0
end

function ENT:ShouldSyncNetwork()
    -- Always sync if there are active UI sessions
    if table.Count(self.activeUIs) > 0 then
        return true
    end

    -- Sync if enough time has passed
    local timeSinceLastSync = CurTime() - (self.LastNetworkSync or 0)
    return timeSinceLastSync > 0.5
end

function ENT:InvalidateSystemCaches()
    -- Force all systems to update on next check
    self.LastResourceUpdate = 0
    self.LastSystemCheck = 0
    self.LastNetworkSync = 0
end

function ENT:GetResourceState()
    return {
        energy = self:GetNWFloat("EnergyLevel", 100),
        oxygen = self:GetNWFloat("OxygenLevel", 100),
        emergency = self:GetNWBool("ResourceEmergencyMode", false)
    }
end

function ENT:GetSystemState()
    return {
        state = self:GetState(),
        hull = self:GetHullIntegrity(),
        shields = self:GetShieldStrength(),
        detected = self:GetShipDetected(),
        valid = self:GetCoreValid()
    }
end

function ENT:HasSignificantResourceChange(oldState, newState)
    if not oldState or not newState then return true end

    -- Check for significant energy change (>5%)
    if math.abs((oldState.energy or 0) - (newState.energy or 0)) > 5 then
        return true
    end

    -- Check for significant oxygen change (>5%)
    if math.abs((oldState.oxygen or 0) - (newState.oxygen or 0)) > 5 then
        return true
    end

    -- Check for emergency mode change
    if (oldState.emergency or false) ~= (newState.emergency or false) then
        return true
    end

    return false
end

function ENT:HasSignificantSystemChange(oldState, newState)
    if not oldState or not newState then return true end

    -- Check for state change
    if (oldState.state or 0) ~= (newState.state or 0) then
        return true
    end

    -- Check for significant hull change (>2%)
    if math.abs((oldState.hull or 100) - (newState.hull or 100)) > 2 then
        return true
    end

    -- Check for significant shield change (>5%)
    if math.abs((oldState.shields or 0) - (newState.shields or 0)) > 5 then
        return true
    end

    -- Check for detection/validity changes
    if (oldState.detected or false) ~= (newState.detected or false) then
        return true
    end

    if (oldState.valid or false) ~= (newState.valid or false) then
        return true
    end

    return false
end

function ENT:TrackUpdatePerformance(updateName, executionTime)
    local perf = self.UpdatePerformance[updateName]
    if perf then
        perf.total_time = perf.total_time + executionTime
        perf.call_count = perf.call_count + 1
        perf.avg_time = perf.total_time / perf.call_count
    end
end

function ENT:AdaptUpdateRate(updateName, executionTime)
    local rates = self.AdaptiveRates[updateName]
    if not rates then return end

    -- Adapt rate based on execution time
    if executionTime > 0.01 then -- If taking more than 10ms
        -- Slow down updates
        rates.current = math.min(rates.max, rates.current * 1.1)
    elseif executionTime < 0.001 then -- If very fast
        -- Speed up updates
        rates.current = math.max(rates.min, rates.current * 0.9)
    end

    -- Update the actual rate variables
    if updateName == "entity_scan" then
        self.EntityScanRate = rates.current
    elseif updateName == "resource_update" then
        self.ResourceUpdateRate = rates.current
    elseif updateName == "system_check" then
        self.SystemCheckRate = rates.current
    elseif updateName == "network_sync" then
        self.NetworkSyncRate = rates.current
    end
end

-- Real-time network synchronization
function ENT:RealTimeNetworkSync()
    -- Update performance metrics
    if self.PerformanceMetrics then
        local uptime = CurTime() - self.PerformanceMetrics.systemUptime
        self:SetNWFloat("SystemUptime", uptime)
        self:SetNWInt("TotalOperations", self.PerformanceMetrics.totalOperations or 0)
        self:SetNWFloat("AverageHullIntegrity", self.PerformanceMetrics.averageHullIntegrity or 100)
        self:SetNWFloat("EnergyEfficiency", self.PerformanceMetrics.energyEfficiency or 1.0)
    end

    -- Update fleet information
    self:SetNWInt("FleetID", self.FleetID or 0)
    self:SetNWString("FleetRole", self.FleetRole or "")

    -- Update alert count
    self:SetNWInt("AlertCount", #self.SystemAlerts)

    -- Update last update timestamp
    self:SetNWFloat("LastUpdate", CurTime())
end

function ENT:InitializePerformanceAnalytics()
    -- Initialize performance analytics
    self.PerformanceMetrics = {
        systemUptime = CurTime(),
        totalOperations = 0,
        averageHullIntegrity = 100,
        energyEfficiency = 1.0,
        lastMaintenanceTime = CurTime(),
        operationalHours = 0
    }

    -- Set up performance network variables
    self:SetNWFloat("SystemUptime", CurTime())
    self:SetNWInt("TotalOperations", 0)
    self:SetNWFloat("AverageHullIntegrity", 100)
    self:SetNWFloat("EnergyEfficiency", 1.0)

    print("[Ship Core] Performance analytics initialized")
end

function ENT:UpdateRealTimeData()
    -- Update real-time monitoring data
    local currentTime = CurTime()

    -- Update system status based on current state
    local status = "Operational"
    local state = self:GetState()

    if state == self.States.INACTIVE then
        status = "Offline"
    elseif state == self.States.CHARGING then
        status = "Charging"
    elseif state == self.States.COOLDOWN then
        status = "Cooldown"
    elseif state == self.States.EMERGENCY then
        status = "Emergency"
    elseif state == self.States.CRITICAL then
        status = "Critical"
    elseif state == self.States.INVALID then
        status = "Invalid"
    end

    self:SetNWString("SystemStatus", status)
    self:SetNWFloat("LastUpdate", currentTime)

    -- Update performance metrics in real-time
    if self.PerformanceMetrics then
        local uptime = currentTime - self.PerformanceMetrics.systemUptime
        self:SetNWFloat("SystemUptime", uptime)

        -- Update operational hours
        self.PerformanceMetrics.operationalHours = uptime / 3600

        -- Update total operations counter
        self.PerformanceMetrics.totalOperations = (self.PerformanceMetrics.totalOperations or 0) + 1

        -- Update average hull integrity
        local currentHull = self:GetHullIntegrity()
        local avgHull = self.PerformanceMetrics.averageHullIntegrity or 100
        self.PerformanceMetrics.averageHullIntegrity = (avgHull + currentHull) / 2

        -- Calculate energy efficiency based on resource usage
        if self.CachedResourceData and self.CachedResourceData.energy and self.CachedResourceData.maxEnergy and self.CachedResourceData.maxEnergy > 0 then
            local energyPercent = (self.CachedResourceData.energy / self.CachedResourceData.maxEnergy) * 100
            local efficiency = math.min(1.0, energyPercent / 100)
            self.PerformanceMetrics.energyEfficiency = efficiency
        else
            -- Default efficiency when no resource data available
            self.PerformanceMetrics.energyEfficiency = 1.0
        end
    end

    -- Update real-time entity counts
    if self.CachedAttachedEntities then
        self:SetNWInt("AttachedEntityCount", self.CachedAttachedEntities.count or 0)
        self:SetNWInt("HyperdriveEngineCount", self.CachedAttachedEntities.hyperdriveEngines or 0)
        self:SetNWInt("ShieldGeneratorCount", self.CachedAttachedEntities.shieldGenerators or 0)
    end

    -- Update real-time resource status
    if self.CachedResourceData then
        -- Safe energy calculation with nil checks
        local energyPercent = 0
        if self.CachedResourceData.energy and self.CachedResourceData.maxEnergy and self.CachedResourceData.maxEnergy > 0 then
            energyPercent = (self.CachedResourceData.energy / self.CachedResourceData.maxEnergy) * 100
        end

        -- Safe oxygen calculation with nil checks
        local oxygenPercent = 0
        if self.CachedResourceData.oxygen and self.CachedResourceData.maxOxygen and self.CachedResourceData.maxOxygen > 0 then
            oxygenPercent = (self.CachedResourceData.oxygen / self.CachedResourceData.maxOxygen) * 100
        end

        self:SetNWFloat("EnergyLevel", energyPercent)
        self:SetNWFloat("OxygenLevel", oxygenPercent)
        self:SetNWBool("ResourceEmergencyMode", self.CachedResourceData.emergencyMode or false)
    else
        -- Default values when no cached data available
        self:SetNWFloat("EnergyLevel", 0)
        self:SetNWFloat("OxygenLevel", 0)
        self:SetNWBool("ResourceEmergencyMode", false)
    end

    -- Update real-time system health
    if self.CachedSystemStatus then
        self:SetNWBool("ShipDetected", self.CachedSystemStatus.shipDetected or false)
        self:SetNWBool("CoreValid", self.CachedSystemStatus.coreValid or false)
        self:SetNWFloat("HullIntegrity", self.CachedSystemStatus.hullIntegrity or 100)
        self:SetNWFloat("ShieldStrength", self.CachedSystemStatus.shieldStrength or 0)
    end

    -- Check for system alerts in real-time
    self:CheckSystemAlerts()

    self.LastRealTimeUpdate = currentTime
end

function ENT:CheckSystemAlerts()
    -- Check for various system alerts with throttling
    local currentTime = CurTime()
    local alerts = {}

    -- Alert cooldown settings (in seconds)
    local alertCooldowns = {
        emergency = 30,  -- 30 seconds between emergency alerts
        critical = 15,   -- 15 seconds between critical alerts
        warning = 10     -- 10 seconds between warning alerts
    }

    -- Helper function to check if alert should be sent
    local function ShouldSendAlert(alertKey, alertType)
        local lastSent = self.AlertCooldowns[alertKey] or 0
        local cooldown = alertCooldowns[alertType] or 5
        return (currentTime - lastSent) >= cooldown
    end

    -- Helper function to add throttled alert
    local function AddThrottledAlert(alertKey, alertType, message)
        table.insert(alerts, {type = alertType, message = message, key = alertKey})

        -- Only send notification if cooldown has passed
        if ShouldSendAlert(alertKey, alertType) then
            self.AlertCooldowns[alertKey] = currentTime

            -- Send notification
            local alertMessage = "Ship Core Alert: " .. message

            if alertType == "emergency" or alertType == "critical" then
                -- Try multiple notification methods
                -- Method 1: HYPERDRIVE Admin system
                if HYPERDRIVE.Admin and HYPERDRIVE.Admin.NotifyAdmins then
                    HYPERDRIVE.Admin.NotifyAdmins(alertMessage, "error")
                -- Method 2: ULib admin notification
                elseif ULib and ULib.tsayError then
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() then
                            ULib.tsayError(ply, alertMessage, true)
                        end
                    end
                -- Method 3: Basic admin notification
                else
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:IsAdmin() then
                            ply:ChatPrint("[HYPERDRIVE ALERT] " .. alertMessage)
                        end
                    end
                end

                -- Log to console (but only once per cooldown)
                print("[Ship Core Alert] " .. alertMessage)
            end
        end
    end

    -- Hull integrity alerts
    local hullIntegrity = self:GetNWFloat("HullIntegrity", 100)
    if hullIntegrity < 10 then
        AddThrottledAlert("hull_critical", "emergency", "HULL BREACH CRITICAL")
    elseif hullIntegrity < 25 then
        AddThrottledAlert("hull_damage", "critical", "Hull damage critical")
    elseif hullIntegrity < 50 then
        AddThrottledAlert("hull_warning", "warning", "Hull damage detected")
    end

    -- Energy alerts
    local energyLevel = self:GetNWFloat("EnergyLevel", 100)
    if energyLevel < 10 then
        AddThrottledAlert("energy_critical", "critical", "Energy critically low")
    elseif energyLevel < 25 then
        AddThrottledAlert("energy_low", "warning", "Energy low")
    end

    -- System state alerts
    local state = self:GetNWInt("State", 0)
    if state == 4 then -- EMERGENCY
        AddThrottledAlert("system_emergency", "emergency", "SYSTEM EMERGENCY")
    elseif state == 0 then -- OFFLINE
        AddThrottledAlert("system_offline", "warning", "System offline")
    end

    -- Update alerts
    self.SystemAlerts = alerts
    self:SetNWInt("AlertCount", #alerts)

    -- Clean up old cooldowns (older than 5 minutes)
    for alertKey, lastTime in pairs(self.AlertCooldowns) do
        if (currentTime - lastTime) > 300 then
            self.AlertCooldowns[alertKey] = nil
        end
    end
end

function ENT:OnRemove()
    -- Clean up timers
    timer.Remove("shipcore_realtime_" .. self:EntIndex())

    -- Leave fleet if in one
    if self.FleetID and self.FleetID > 0 then
        if HYPERDRIVE.Fleet then
            local fleet = HYPERDRIVE.Fleet.ActiveFleets[self.FleetID]
            if fleet then
                fleet:RemoveShip(self)
            end
        end
    end

    -- Close all active UIs
    for ply, _ in pairs(self.activeUIs) do
        if IsValid(ply) then
            self:CloseUI(ply)
        end
    end

    -- Unregister from ship naming system
    if HYPERDRIVE.ShipNames and HYPERDRIVE.ShipNames.UnregisterShip then
        HYPERDRIVE.ShipNames.UnregisterShip(self)
    end

    -- Clean up ship detection
    if HYPERDRIVE.ShipCore then
        HYPERDRIVE.ShipCore.RemoveShip(self)
    end

    -- Clean up resource storage
    if HYPERDRIVE.SB3Resources then
        local coreId = self:EntIndex()
        HYPERDRIVE.SB3Resources.CoreStorage[coreId] = nil
    end

    -- Clean up v2.2.1 systems
    self:CleanupV221Systems()

    -- Support undo system
    if self.UndoID then
        undo.ReplaceEntity(self.UndoID, NULL)
    end

    print("[Ship Core] Ship core v2.2.1 removed")
end

-- Clean up v2.2.1 systems
function ENT:CleanupV221Systems()
    -- Clean up flight system
    if self.flightSystemInitialized and HYPERDRIVE.Flight then
        HYPERDRIVE.Flight.RemoveFlightSystem(self)
    end

    -- Clean up weapon systems
    if self.weaponSystemsInitialized then
        -- Unlink weapons
        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 2000)) do
            if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") and ent.weapon then
                ent.shipCore = nil
            end
        end
    end

    -- Clean up ammunition system
    if self.ammunitionSystemInitialized and HYPERDRIVE.Ammunition then
        HYPERDRIVE.Ammunition.RemoveStorage(self)
    end

    -- Clean up tactical AI
    if self.tacticalAIInitialized and HYPERDRIVE.TacticalAI then
        HYPERDRIVE.TacticalAI.RemoveAI(self)
    end

    print("[Ship Core] v2.2.1 systems cleaned up")
end
