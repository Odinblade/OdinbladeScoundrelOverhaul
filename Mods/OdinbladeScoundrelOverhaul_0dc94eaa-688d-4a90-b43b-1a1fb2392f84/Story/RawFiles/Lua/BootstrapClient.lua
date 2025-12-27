Ext.Require("Shared/OdinSCO_StatOverrides.lua")

Ext.Events.SessionLoading:Subscribe(function (e)
    print("[OdinSCO:BootstrapClient.lua] Session is loading.")
end)

Ext.Events.StatsLoaded:Subscribe(function (e)
    print("[OdinSCO:BootstrapClient.lua] StatsLoaded is loading.")
    OverrideStats()
end)
