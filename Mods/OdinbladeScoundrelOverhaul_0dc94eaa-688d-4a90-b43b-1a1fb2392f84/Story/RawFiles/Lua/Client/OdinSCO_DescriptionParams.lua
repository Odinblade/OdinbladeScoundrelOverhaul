Ext.Require("Shared/OdinSCO_SharedData.lua")

-- Listeners
local function OdinSCO_SkillGetDescriptionParam(skill, character, isFromItem, param)
    if param == "OdinSCO_TT_Test" then
        Ext.Print("Lemonade")
        for leftSkill, rightSkill in pairs(OdinScoundrelOverhaul.StanceSkills) do
            Ext.Print("A")
            if leftSkill == skill.Name then
                Ext.Print("B")
                local cd = NRD_SkillGetCooldown(character, skill.Name)
                -- local cd = Game.Math.IsRangedWeapon(character.MainWeapon)
                return cd
                -- -- local cdEntries = getSkillCooldownsDB(character, rightSkill)
                -- local cdEntries = Osi.DB_OdinSCO_SkillCooldown:Get(character, rightSkill, nil)
                -- if #cdEntries > 0 then
                --     Ext.Print("Ba")
                --     for i, entry in pairs(cdEntries) do
                --         return entry[3]
                --     end
                -- end
            elseif rightSkill == skill.Name then
                Ext.Print("C")
                local cdEntries = Osi.DB_OdinSCO_SkillCooldown:Get(character, leftSkill, nil)
                if #cdEntries > 0 then
                    for i, entry in pairs(cdEntries) do
                        return entry[3]
                    end
                end
            end
        end
    end


    -- local damageParam = HuntsmanOverhaul.DamageParams[param]
    -- if damageParam ~= nil then
    --     local isGrenade = HuntsmanOverhaul.Grenades[skill.Name]
    --     if isGrenade ~= nil then
    --         local status, result = xpcall(GetGrenadeBoostVal, debug.traceback, character, skill)
    --         return result
    --     end
    --     if skill.Requirement == "RangedWeapon" then
    --         local result = OdinHUN_BeginEACheck(skill, character)
    --         return result
    --     end
    -- else
    --     local tooltipDamageParam = HuntsmanOverhaul.TooltipStatuses[param]
    --     if tooltipDamageParam ~= nil then
    --         tooltipDamageParam = Ext.GetStat(tooltipDamageParam, nil)
    --         local result = OdinHUN_BeginEACheck(tooltipDamageParam, character)
    --         return result
    --     end
    -- end
end

Ext.RegisterListener("SkillGetDescriptionParam", OdinSCO_SkillGetDescriptionParam)
Ext.Print("[OdinSCO_DescriptionParams.lua] Registered listener SkillGetDescriptionParam.")
