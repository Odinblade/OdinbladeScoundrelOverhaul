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
    if not Ext.Entity.GetCharacter(character).IsPlayer then
        return
    end

    if not CharacterHasSkill(character, "Shout_OdinSCO_DeadlyFlourish") then
        return
    end

    local slot = NRD_SkillBarFindSkill(character, "Shout_OdinSCO_DeadlyFlourish")
    if slot ~= nil then
        NRD_SkillSetCooldown(character, "Shout_OdinSCO_DeadlyFlourish", 6.0)
        Osi.ProcObjectTimer(character, "ODINSCO_FLICKER_DEADLYFLOURISH", 100)
    end
end

function incrementComboPoints(character, points)
    local isPlayer = Ext.Entity.GetCharacter(character).IsPlayer
    
    if (CharacterHasSkill(character, "Shout_OdinSCO_DeadlyFlourish") == 1 or not isPlayer) and CharacterIsInCombat(character) == 1 then
        local newAmount = getComboPoints(character) + points
        if newAmount == 1 then
            ApplyStatus(character, "OdinSCO_COMBO_1", -1.0, 1, character)
        elseif newAmount == 2 then
            ApplyStatus(character, "OdinSCO_COMBO_2", -1.0, 1, character)
        elseif newAmount >= 3 then
            if HasActiveStatus(character, "OdinSCO_COMBO_3") == 0 then
                ApplyStatus(character, "OdinSCO_COMBO_3", -1.0, 1, character)
                SetTag(character, "ODINSCO_COMBO_READY")
                refreshDeadlyFlourish(character)
            end
        end
    end
end

local function enterCombatComboBonus(character)
    if CharacterHasSkill(character, "Shout_OdinSCO_DeadlyFlourish") == 1 or not Ext.Entity.GetCharacter(character).IsPlayer then
        local scoundrelPoints = CharacterGetAbility(character, "RogueLore")
        if scoundrelPoints >= 5 and scoundrelPoints < 10 then
            incrementComboPoints(character, 1)
        elseif scoundrelPoints >= 10 then
            incrementComboPoints(character, 2)
        end
    end
end

function activateComboPoints(character)
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
    refreshDeadlyFlourish(character)
end

Ext.NewCall(incrementComboPoints, "OBSCO_LUA_IncrementComboPoints", "(CHARACTERGUID)_Character, (INTEGER)_PointsToAdd");
Ext.NewCall(activateComboPoints, "OBSCO_LUA_ActivateComboPoints", "(CHARACTERGUID)_Character");
Ext.NewCall(consumeComboPoints, "OBSCO_LUA_ConsumeComboPoints", "(CHARACTERGUID)_Character");
Ext.NewCall(enterCombatComboBonus, "OBSCO_LUA_EnterCombatComboPoints", "(CHARACTERGUID)_Character");