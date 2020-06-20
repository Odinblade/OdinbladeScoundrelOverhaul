local function SessionLoading()
    Ext.Print("[OdinSCO:BootstrapServer.lua] Session is loading.")
end

Ext.Require("Shared/OdinSCO_Utility.lua")
Ext.Require("Server/OdinSCO_ComboSkills.lua")
Ext.Require("Server/OdinSCO_CooldownManager.lua")

Ext.Require("Shared/OdinSCO_ComboPoints.lua")

local ModuleLoading = function ()
    Ext.Print("[OdinSCO:BootstrapServer.lua] Module is loading.")
    -- Osi.DB_OdinSCO_SkillCooldown("NULL_00000000-0000-0000-0000-000000000000", "", 0.0)
    OverrideStats()
end

Ext.RegisterListener("ModuleLoading", ModuleLoading)
Ext.RegisterListener("SessionLoading", SessionLoading)