OdinScoundrelOverhaul.ComboPoints = {
    OdinSCO_COMBO_1 = 1,
    OdinSCO_COMBO_2 = 2,
    OdinSCO_COMBO_3 = 3
}

OdinScoundrelOverhaul.ActivatedComboPoints = {
    OdinSCO_USE_COMBO_1 = 1,
    OdinSCO_USE_COMBO_2 = 2,
    OdinSCO_USE_COMBO_3 = 3
}

local function refreshDeadlyFlourish(character)
    Ext.Print("refreshDeadlyFlourish: STARTED")
    local slot = NRD_SkillBarFindSkill(character, "Shout_OdinSCO_DeadlyFlourish")
    if slot ~= nil then
        Ext.Print("refreshDeadlyFlourish: SkillBarFindSkill finished")
        -- NRD_SkillBarClear(character, slot)
        -- Ext.Print("refreshDeadlyFlourish: SkillBarClear finished")
        -- Osi.DB_OBSCO_Flicker_DeadlyFlourish(character, slot)
        NRD_SkillSetCooldown(character, "Shout_OdinSCO_DeadlyFlourish", 6.0)
        Ext.Print("refreshDeadlyFlourish: SkillSetCooldown finished")
        Osi.ProcObjectTimer(character, "ODINSCO_FLICKER_DEADLYFLOURISH", 25)
    end
end

function incrementComboPoints(character, points)
    Ext.Print("incrementComboPoints")
    if CharacterHasSkill(character, "Shout_OdinSCO_DeadlyFlourish") == 1 and CharacterIsInCombat(character) == 1 then
        if IsSkillActive(character, "Shout_OdinSCO_DeadlyFlourish") then
            local newAmount = getComboPoints(character) + points
            if newAmount == 1 then
                ApplyStatus(character, "OdinSCO_COMBO_1", -1.0, 1, character)
            elseif newAmount == 2 then
                ApplyStatus(character, "OdinSCO_COMBO_2", -1.0, 1, character)
            elseif newAmount >= 3 then
                newAmount = 3
                if HasActiveStatus(character, "OdinSCO_COMBO_3") == 0 then
                    ApplyStatus(character, "OdinSCO_COMBO_3", -1.0, 1, character)
                    SetTag(character, "ODINSCO_COMBO_READY")
                    refreshDeadlyFlourish(character) --TOOD: Try removing this - might work as intended outside of the engine?
                end
            end
        end
    end
end

local function enterCombatComboBonus(character)
    if CharacterHasSkill(character, "Shout_OdinSCO_DeadlyFlourish") == 1 then
        local scoundrelPoints = CharacterGetAbility(character, "RogueLore")
        if scoundrelPoints >= 5 and scoundrelPoints < 10 then
            incrementComboPoints(character, 1)
        elseif scoundrelPoints >= 10 then
            incrementComboPoints(character, 2)
        end
    end
end

-- -- Transforms skills as the player moves through combo tiers
-- local function setComboTierSkills(character, points, prevPoints)
--     for a, comboSkill in pairs(OdinScoundrelOverhaul.ComboSkills) do
--         local newSkill = comboSkill[points]
--         if newSkill ~= nil then
--             local prevSkill = comboSkill[prevPoints]
--             -- if points == 0 then
--             --     prevSkill = comboSkill[prevPoints]
--             -- end
--             if CharacterHasSkill(character, prevSkill) == 1 then
--                 local skillIsLearned = NRD_SkillGetInt(character, prevSkill, "IsLearned")
--                 Ext.Print("skillIsLearned: "..skillIsLearned.." prevSkill: "..prevSkill)
--                 local isActivated = NRD_SkillGetInt(character, prevSkill, "IsActivated")
--                 Ext.Print("skillIsLearned: "..isActivated.." prevSkill: "..prevSkill)
--                 local zeroMemory = NRD_SkillGetInt(character, prevSkill, "ZeroMemory")
--                 Ext.Print("skillIsLearned: "..zeroMemory.." prevSkill: "..prevSkill)
--                 if skillIsLearned == 1 and prevSkill ~= newSkill then
--                     local prevSlot = NRD_SkillBarFindSkill(character, prevSkill)
--                     local prevCD = NRD_SkillGetCooldown(character, prevSkill)
                    
--                     CharacterRemoveSkill(character, prevSkill)
--                     CharacterAddSkill(character, newSkill, 0)
--                     NRD_SkillBarSetSkill(character, prevSlot, newSkill)
--                     NRD_SkillSetCooldown(character, newSkill, prevCD)
--                 end
--             end
--         end
--     end
-- end

local function activateComboPoints(character)
    local comboPointsCount = getComboPoints(character)
    local isComboActivated = HasActiveStatus(character, "OdinSCO_USE_COMBO_3")
    if comboPointsCount == 3 and isComboActivated == 0  then
        ApplyStatus(character, "OdinSCO_USE_COMBO_3", -1.0, 1, character)
        CharacterStatusText(character, "<font color='#C9AA58'>Combo</font> Activated</font>")
    elseif comboPointsCount == 3 then
        RemoveStatus(character, "OdinSCO_USE_COMBO_3")
        CharacterStatusText(character, "<font color='#C9AA58'>Combo</font> Deactivated</font>")
    end
end

function getComboPoints(character)
    local comboPointsCount = 0
    for status, value in pairs(OdinScoundrelOverhaul.ComboPoints) do
        if HasActiveStatus(character, status) == 1 then
            comboPointsCount = value
        end
    end
    return comboPointsCount
end

function getActivatedComboPoints(character)
    local activatedComboPointsCount = 0
    for status, value in pairs(OdinScoundrelOverhaul.ActivatedComboPoints) do
        if HasActiveStatus(character, status) == 1 then
            activatedComboPointsCount = value
        end
    end
    return activatedComboPointsCount
end

function consumeComboPoints(character)
    RemoveStatus(character, "OdinSCO_COMBO_3")
    RemoveStatus(character, "OdinSCO_COMBO_2")
    RemoveStatus(character, "OdinSCO_COMBO_1")

    RemoveStatus(character, "OdinSCO_USE_COMBO_3")
    RemoveStatus(character, "OdinSCO_USE_COMBO_2")
    RemoveStatus(character, "OdinSCO_USE_COMBO_1")

    ClearTag(character, "ODINSCO_COMBO_READY")
    refreshDeadlyFlourish(character) --TOOD: Try removing this - might work as intended outside of the engine?
end

-- function consumeComboPoints(character, activatedComboPoints, comboToAdd)
--     local activatedComboPointsCount = getActivatedComboPoints(character)
--     local comboPointsStatus = nil
--     for status, value in pairs(OdinScoundrelOverhaul.ComboPoints) do
--         if HasActiveStatus(character, status) == 1 then
--             comboPointsStatus = status
--         end
--     end
--     local activatedCombo = nil
--     for status, value in pairs(OdinScoundrelOverhaul.ActivatedComboPoints) do
--         if value == activatedComboPoints then
--             activatedCombo = status
--         end
--     end
--     if comboPointsStatus ~= nil and activatedCombo ~= nil then
--         local comboPointsToRemove = OdinScoundrelOverhaul.ActivatedComboPoints[activatedCombo]
--         local comboPointsCount = OdinScoundrelOverhaul.ComboPoints[comboPointsStatus]
--         local newComboPointsCount = comboPointsCount - comboPointsToRemove

--         RemoveStatus(character, "OdinSCO_COMBO_3")
--         RemoveStatus(character, "OdinSCO_COMBO_2")
--         RemoveStatus(character, "OdinSCO_COMBO_1")

--         RemoveStatus(character, "OdinSCO_USE_COMBO_3")
--         RemoveStatus(character, "OdinSCO_USE_COMBO_2")
--         RemoveStatus(character, "OdinSCO_USE_COMBO_1")

--         if comboToAdd > 0 then
--             newComboPointsCount = newComboPointsCount + comboToAdd
--         end

--         incrementComboPoints(character, newComboPointsCount)
--         -- Ext.Print("Setting comboTier to: "..newComboPointsCount.." with "..activatedComboPointsCount)
--         -- setComboTierSkills(character, newComboPointsCount, activatedComboPointsCount)
--     else
--         -- setComboTierSkills(character, 0, 0)
--     end
-- end

-- function checkAddedSkill(character, skillId)
--     Ext.Print("Check added skill entered")

--     if NRD_SkillGetInt(character, skillId, "IsLearned") == 0 then
--         Ext.Print("I think dis is a weapon skill: "..skillId)
--     end

--     if NRD_SkillGetInt(character, skillId, "ZeroMemory") == 1 then
--         Ext.Print("ZERO MEM")
--     end


--     local comboSkillMatch = OdinScoundrelOverhaul.ComboSkills[skillId]
--     if comboSkillMatch ~= nil then
--         for tier, skill in pairs(comboSkillMatch) do
--             if CharacterHasSkill(character, skill) == 1 then
--                 Ext.Print("aaaah")
--                 local skillIsLearned = NRD_SkillGetInt(character, skill, "IsLearned")
--                 if skillIsLearned == 1 then
--                     Ext.Print("abc")
--                     CharacterRemoveSkill(character, skillId)
--                 end
--             end
--         end
--     end
-- end

Ext.NewCall(incrementComboPoints, "OBSCO_LUA_IncrementComboPoints", "(CHARACTERGUID)_Character, (INTEGER)_PointsToAdd");
Ext.NewCall(activateComboPoints, "OBSCO_LUA_ActivateComboPoints", "(CHARACTERGUID)_Character");
Ext.NewCall(consumeComboPoints, "OBSCO_LUA_ConsumeComboPoints", "(CHARACTERGUID)_Character");
Ext.NewCall(enterCombatComboBonus, "OBSCO_LUA_EnterCombatComboPoints", "(CHARACTERGUID)_Character");
-- Ext.NewCall(checkAddedSkill, "OBSCO_LUA_CheckAddedSkill", "(CHARACTERGUID)_Character, (STRING)_SkillId");