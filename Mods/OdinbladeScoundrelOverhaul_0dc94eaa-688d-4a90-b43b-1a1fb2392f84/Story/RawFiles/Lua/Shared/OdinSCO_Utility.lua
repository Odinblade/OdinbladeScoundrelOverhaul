-- Credit: LaughingLeader
local function getSkillEntryName(skill)
    local skillId = string.gsub(skill, "_%-?%d+$", "")
    return skillId
end

local function hasScoundrelSkills(character)
    local result = 0
    for k, skillId in pairs(OdinScoundrelOverhaul.ScoundrelSkills) do
        if IsSkillActive(character, skillId) == 1 then
            result = 1
            break
        end
    end
    return result
end

local function isScoundrelSkill(inSkillId)
    local result = 0
    for k, skillId in pairs(OdinScoundrelOverhaul.ScoundrelSkills) do
        if inSkillId == skillId then
            result = 1
            break
        end
    end
    return result
end

Ext.NewQuery(getSkillEntryName, "OBSCO_LUA_GetSkillEntryName", "[in](STRING)_ProtoId, [out](STRING)_SkillId")
Ext.NewQuery(hasScoundrelSkills, "OBSCO_LUA_HasScoundrelSkills", "[in](CHARACTERGUID)_Character, [out](INTEGER)_Result");
Ext.NewQuery(isScoundrelSkill, "OBSCO_LUA_IsScoundrelSkill", "[in](STRING)_SkillId, [out](INTEGER)_Result");