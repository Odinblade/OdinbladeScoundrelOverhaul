Ext.Require("Server/OdinSCO_ComboSkills.lua")
Ext.Require("Shared/OdinSCO_Utility.lua")
Ext.Require("Shared/OdinSCO_ComboPoints.lua")
Ext.Require("Shared/OdinSCO_SharedData.lua")

Ext.Events.SessionLoading:Subscribe(function (e)
    print("[OdinSCO:BootstrapServer.lua] Session is loading.")
end)

Ext.Events.StatsLoaded:Subscribe(function (e)
    print("[OdinSCO:BootstrapServer.lua] StatsLoaded is loading.")
end)
