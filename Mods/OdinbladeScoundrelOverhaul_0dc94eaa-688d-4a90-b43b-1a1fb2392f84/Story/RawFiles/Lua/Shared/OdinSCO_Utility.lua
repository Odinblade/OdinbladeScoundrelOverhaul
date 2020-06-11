-- Credit: LaughingLeader
local function GetSkillEntryName(skill)
    local skillId = string.gsub(skill, "_%-?%d+$", "")
    return skillId
end

Ext.NewQuery(GetSkillEntryName, "OBSCO_LUA_GetSkillEntryName", "[in](STRING)_ProtoId, [out](STRING)_SkillId")