local function SessionLoading()
    Ext.Print("[OdinSCO:BootstrapClient.lua] Session is loading.")
end

-- Ext.Require("Client/OdinSCO_DescriptionParams.lua")

local ModuleLoading = function ()
    Ext.Print("[OdinSCO:BootstrapClient.lua] Module is loading.")
    -- OverrideStats()
end

Ext.RegisterListener("ModuleLoading", ModuleLoading)
Ext.RegisterListener("SessionLoading", SessionLoading)