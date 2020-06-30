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

local function getPrepareParentSkill(skillId)
    local func = OdinScoundrelOverhaul.ComboSkills.OnPrepareHit[skillId]
    if func ~= nil then
        return skillId
    else
        local using = Ext.StatGetAttribute(skillId, "Using")
        if using ~= nil then
            return using
        end
    end
    return ""
end

local function isStealthed(character)
    if HasActiveStatus(character, "INVISIBLE") == 1 or HasActiveStatus(character, "SNEAKING") == 1 then
        return 1
    end
end

Ext.NewQuery(getSkillEntryName, "OBSCO_LUA_GetSkillEntryName", "[in](STRING)_ProtoId, [out](STRING)_SkillId")
Ext.NewQuery(hasScoundrelSkills, "OBSCO_LUA_HasScoundrelSkills", "[in](CHARACTERGUID)_Character, [out](INTEGER)_Result");
Ext.NewQuery(isScoundrelSkill, "OBSCO_LUA_IsScoundrelSkill", "[in](STRING)_SkillId, [out](INTEGER)_Result");
Ext.NewQuery(getPrepareParentSkill, "OBSCO_LUA_Skill_GetPrepareParentSkill", "[in](STRING)_SkillId, [out](STRING)_ParentSkillId");
Ext.NewQuery(isStealthed, "OBSCO_LUA_IsStealthed", "[in](CHARACTERGUID)_Character, [out](INTEGER)_Result");