Ext.Require("Shared/OdinSCO_SharedData.lua")

local function testFunc(msg)
    Ext.Print("[OdinSCO:BootstrapServer.lua] testFunc started")
    Ext.Print(msg)
end

-- function getSkillCooldownsDB(character, skill)
--     local cdEntries = Osi.DB_OdinSCO_SkillCooldown:Get(character, rightSkill, nil)
--     return cdEntries
-- end

local function decreaseCooldowns(character)
    Ext.Print("[OdinSCO:BootstrapServer.lua] decreaseCooldowns started")
    local cdEntries = Osi.DB_OdinSCO_SkillCooldown:Get(character, nil, nil)
    if #cdEntries > 0 then
        for i, entry in pairs(cdEntries) do
            local prevCD = entry[3]
            Ext.Print("TEMP: "..entry[2].." is: "..entry[3])
            local newCD = prevCD - 6.0
            if newCD >= 0.0 then
                Osi.DB_OdinSCO_SkillCooldown:Delete(character, entry[2], entry[3])
                Osi.DB_OdinSCO_SkillCooldown(character, entry[2], newCD)
            end

            -- If the skill will be off cooldown next turn, let the user know it's ready!
            if prevCD == 6.0 then
                local skillStat = Ext.GetStat(entry[2])
                if skillStat.Cooldown > 1 then
                    if CharacterHasSkill(character, entry[2]) == 0 then
                        if CharacterIsInCombat(character) == 1 then
                            Ext.Print("SKILL_READY: "..entry[2]..": "..entry[3])
                            CharacterStatusText(character, "SKILL READY: "..skillStat.DisplayName)
                        end
                    end
                end
            end
        end
    end
    -- Ext.Print("[OdinSCO:BootstrapServer.lua] decreaseCooldowns finished")
end



local function applyCooldown(character, skill)
    -- Ext.Print("[OdinSCO:BootstrapServer.lua] applyCooldown started")
    local cdEntries = Osi.DB_OdinSCO_SkillCooldown:Get(character, skill, nil)

    -- Row for char/skill does not exist - make one!
    if #cdEntries > 0 then
        for i, entry in pairs(cdEntries) do
            NRD_SkillSetCooldown(character, skill, entry[3])
        end
    else
        Osi.DB_OdinSCO_SkillCooldown(character, skill, 0.0)
    end
    -- Ext.Print("[OdinSCO:BootstrapServer.lua] applyCooldown finished")
end

local function performSkillSwap(character, oldSkill, newSkill)
    local slot = NRD_SkillBarFindSkill(character, oldSkill)

    local oldCD = NRD_SkillGetCooldown(character, oldSkill)

    Osi.DB_OdinSCO_SkillCooldown:Delete(character, oldSkill, nil)
    local inCombat = CharacterIsInCombat(character)
    if inCombat == 1 then
        Osi.DB_OdinSCO_SkillCooldown(character, oldSkill, oldCD)
    else 
        Osi.DB_OdinSCO_SkillCooldown(character, oldSkill, 0.0)
    end
    
    CharacterRemoveSkill(character, oldSkill)
    NRD_SkillBarSetSkill(character, slot, newSkill)
    CharacterAddSkill(character, newSkill, 0)

    if inCombat == 1 then
        applyCooldown(character, newSkill)
    end

    -- Ext.Print("[OdinSCO:BootstrapServer.lua] performSkillSwap: Finished swapping: "..oldSkill.." with "..newSkill)
end

local function beginStanceSwap(character)
    local stanceEntries = Osi.DB_OdinSCO_CurrentStance:Get(character, nil)
    local stance

    if #stanceEntries > 0 then
        for i, entry in pairs(stanceEntries) do
            stance = entry[2]
        end
    end

    for leftSkill, rightSkill in pairs(OdinScoundrelOverhaul.StanceSkills) do
        local hasLeft = CharacterHasSkill(character, leftSkill)
        local hasRight = CharacterHasSkill(character, rightSkill)
        if stance == 0 and hasLeft == 1 then
            -- Ext.Print("[OdinSCO:BootstrapServer.lua] beginStanceSwap: Begin swapping: "..leftSkill.." with "..rightSkill)
            performSkillSwap(character, leftSkill, rightSkill)
        elseif stance == 1 and hasRight == 1 then
            -- Ext.Print("[OdinSCO:BootstrapServer.lua] beginStanceSwap: Begin swapping: "..rightSkill.." with "..leftSkill)
            performSkillSwap(character, rightSkill, leftSkill)
        end
    end

    if stance == 0 then
        stance = 1
    elseif stance == 1 then
        stance = 0
    end

    --Change the recorded stance now that the character has swapped
    Osi.DB_OdinSCO_CurrentStance:Delete(character, nil)
    Osi.DB_OdinSCO_CurrentStance(character, stance)
end

Ext.NewCall(testFunc, "OBSCO_LUA_TestFunc", "(STRING)_Msg");
-- Ext.NewCall(transformSkill, "OBSCO_LUA_TransformSkill", "(CHARACTERGUID)_Character, (STRING)_leftSkillRef, (STRING)_rightSkillRef");
Ext.NewCall(beginStanceSwap, "OBSCO_LUA_BeginStanceSwap", "(CHARACTERGUID)_Character");
Ext.NewCall(decreaseCooldowns, "OBSCO_LUA_DecreaseCooldowns", "(CHARACTERGUID)_Character");