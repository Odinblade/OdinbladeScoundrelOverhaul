Ext.Require("Client/OdinSCO_UI_Tooltip.lua")
Ext.Require("Shared/OdinSCO_SharedData.lua")

Ext.Events.SessionLoading:Subscribe(function (e)
    print("[OdinSCO:BootstrapClient.lua] Session is loading.")
end)

Ext.Events.StatsLoaded:Subscribe(function (e)
    print("[OdinSCO:BootstrapClient.lua] StatsLoaded is loading.")
end)
