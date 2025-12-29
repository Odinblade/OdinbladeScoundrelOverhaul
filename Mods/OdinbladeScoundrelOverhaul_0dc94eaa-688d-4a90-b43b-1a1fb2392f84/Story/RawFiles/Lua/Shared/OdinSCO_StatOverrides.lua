Ext.Require("Shared/OdinSCO_SharedData.lua")

-- Credit: LaughingLeader and Norbyte for base of this function
function OverrideStats()
    local total_changes = 0
    local total_stats = 0
    local debug_print = false

    for statname,overrides in pairs(OdinScoundrelOverhaul.StatOverrides) do
        for property,value in pairs(overrides) do
            if debug_print then print("[OdinSCO:Bootstrap.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. value .."\"") end
            local stat = Ext.Stats.Get(statname)
            if property == "SkillCustomDescription" or property == "SkillCustomDescription_Extra" then
                Ext.Stats.AddCustomDescription(statname, "SkillProperties", value)
                if debug_print then print("[OdinSCO:Bootstrap.lua] Custom description set: " .. statname .. " (".. property ..") = \"".. value .."\"") end
            else 
                Ext.Stats.SetAttribute(statname, property, value)
                if debug_print then print("[OdinSCO:Bootstrap.lua] Stat attribute overwritten: " .. statname .. " (".. property ..") = \"".. value .."\"") end
            end
            total_changes = total_changes + 1
        end
        total_stats = total_stats + 1
    end

    print("[OdinSCO:Bootstrap.lua] Changed ("..tostring(total_changes)..") properties in ("..tostring(total_stats)..") stats.")
end