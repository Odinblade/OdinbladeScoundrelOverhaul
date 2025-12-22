Ext.Require("Shared/OdinSCO_SharedData.lua")
Ext.Require("Shared/OdinSCO_ComboPoints.lua")
Ext.Require("Shared/OdinSCO_Utility.lua")

-- Auto use combo on Scoundrel skills for enemies
--- @param character EsvCharacter
Ext.Osiris.RegisterListener("CharacterUsedSkill", 4, "before", function (character, skill, skillType, skillElement)
    if getComboPoints(character) == 3 and
    Ext.Entity.GetCharacter(character).IsPlayer == false and
    isScoundrelSkill(skill) then
        activateComboPoints(character)
    end
end)

local function multiplyDamage(target, hithandle, multiplier)
    for k,type in pairs(OdinScoundrelOverhaul.DamageTypes) do
        local damage = NRD_HitStatusGetDamage(target, hithandle, type)
        if damage ~= 0 then
            damage = damage * multiplier
            NRD_HitStatusClearDamage(target, hithandle, type)
            NRD_HitStatusAddDamage(target, hithandle, type, damage)
        end
    end
end

local function convertHitToElementalDamage(character, target, damage, hithandle)

    local newDamageType = OdinScoundrelOverhaul.ElementalDamageTypes[math.random(#OdinScoundrelOverhaul.ElementalDamageTypes)]
    local newResistance = NRD_CharacterGetComputedStat(target, newDamageType.."Resistance", 0)

    for resistanceType, damageType in pairs(OdinScoundrelOverhaul.ResistanceParams) do
        local resistanceStat = NRD_CharacterGetComputedStat(target, resistanceType, 0)
        if resistanceStat < newResistance then
            newDamageType = damageType
            newResistance = resistanceStat
        elseif resistanceStat == newResistance then
            local result = math.random(100)
            if result < 50 then
                newDamageType = damageType
                newResistance = resistanceStat
            end
        end
    end
    NRD_HitClearAllDamage(hithandle)
    NRD_HitAddDamage(hithandle, newDamageType, damage)
    return newDamageType
end

local function skillShadowStep(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_APPLY_SHADOWSTEP_BONUS") == 1 then
        multiplyDamage(target, hithandle, 1.2)
    end
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then 
        consumeComboPoints(character)
        Osi.OBSCO_QueueStatusApply(character, "INVISIBLE", character, 6.0, 0, 500)
    end
    if didHit == 1 then
        Osi.ProcObjectTimerCancel(character, "OdinSCO_INCREMENT_COMBO_DELAYED")
        Osi.ProcObjectTimer(character, "OdinSCO_INCREMENT_COMBO_DELAYED", 1250)
    end
    Osi.ProcObjectTimerCancel(character, "OdinSCO_SHADOWSTEP_RETURN")
    Osi.ProcObjectTimer(character, "OdinSCO_SHADOWSTEP_RETURN", 1000)
end

local function skillVault(character,  target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then 
        consumeComboPoints(character)
        multiplyDamage(target, hithandle, 1.25)

        local newCD = NRD_SkillGetCooldown(character, "MultiStrike_Vault") - 6.0
        if newCD > 0.0 then
            Osi.OBSCO_QueueCooldownOverride(character, "MultiStrike_Vault", newCD)
        else
            Osi.OBSCO_QueueCooldownOverride(character, "MultiStrike_Vault", 0.0)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillChloroform(character, target, hithandle)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)
        
        NRD_HitStatusClearAllDamage(target, hithandle)

        local x, y, z = GetPosition(target)
        NRD_ProjectilePrepareLaunch();
        NRD_ProjectileSetString("SkillId", "Projectile_OdinSCO_Chloroform_Combo");
        NRD_ProjectileSetVector3("SourcePosition", x, y+1, z);
        NRD_ProjectileSetVector3("TargetPosition", x, y, z);
        NRD_ProjectileSetGuidString("Caster", character);
        NRD_ProjectileSetGuidString("Target", target);
        NRD_ProjectileLaunch();
    end
end

local function skillFanOfKnives(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then    
        consumeComboPoints(character)
        Osi.ProcObjectTimerCancel(character, "OdinSCO_FANOFKNIVES_ANIM")
        Osi.ProcObjectTimer(character, "OdinSCO_FANOFKNIVES_ANIM", 1000)
    end
    if didHit == 1 then
        Osi.ProcObjectTimerCancel(character, "OdinSCO_INCREMENT_COMBO_DELAYED")
        Osi.ProcObjectTimer(character, "OdinSCO_INCREMENT_COMBO_DELAYED", 1250)
    end
end

local function skillThrowingKnife(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then    
        consumeComboPoints(character)
        NRD_HitStatusClearAllDamage(target, hithandle)

        local x, y, z = GetPosition(target)
        NRD_ProjectilePrepareLaunch();
        NRD_ProjectileSetString("SkillId", "Projectile_OdinSCO_ThrowingKnife_Combo");
        NRD_ProjectileSetVector3("SourcePosition", x, y+1, z);
        NRD_ProjectileSetVector3("TargetPosition", x, y, z);
        NRD_ProjectileSetGuidString("Caster", character);
        NRD_ProjectileSetGuidString("Target", target);
        NRD_ProjectileLaunch();
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillShadowSlash(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if didHit == 1 then
        Osi.ProcObjectTimerCancel(character, "OdinSCO_INCREMENT_COMBO_DELAYED")
        Osi.ProcObjectTimer(character, "OdinSCO_INCREMENT_COMBO_DELAYED", 1250)
    end
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then  
        consumeComboPoints(character)
    end
    if HasActiveStatus(character, "OdinSCO_APPLY_SHADOWSLASH_BONUS") == 1 then
        multiplyDamage(target, hithandle, 1.2)
    end
    Osi.ProcObjectTimerCancel(character, "OdinSCO_COMBO_INVIS_CLEANUP")
    Osi.ProcObjectTimer(character, "OdinSCO_COMBO_INVIS_CLEANUP", 900)
end

local function skillSinisterStrike(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        local damageType = NRD_StatusGetString(target, hithandle, "DamageType")

        for k,type in pairs(OdinScoundrelOverhaul.ElementalDamageBonus) do
            if k == damageType then
                Osi.OBSCO_QueueStatusApply(target, type, character, 6.0, 0, 10)
            end
        end

        local newCD = NRD_SkillGetCooldown(character, "Target_OdinSCO_SinisterStrike") - 6.0
        if newCD > 0.0 then
            Osi.OBSCO_QueueCooldownOverride(character, "Target_OdinSCO_SinisterStrike", newCD)
        else
            Osi.OBSCO_QueueCooldownOverride(character, "Target_OdinSCO_SinisterStrike", 0.0)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillSinisterStrike_Prep(character, target, damage, hithandle)
    RemoveStatus(character, "OdinSCO_PREPHIT_SINISTERSTRIKE")
    convertHitToElementalDamage(character, target, damage, hithandle)
end

local function skillCorruptedBlade(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        Osi.OBSCO_QueueStatusApply(target, "POISONED", character, 12.0, 0, 10)
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillFatality(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then  
        consumeComboPoints(character)
        multiplyDamage(target, hithandle, 2.0)
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
    Osi.ProcObjectTimerCancel(character, "OdinSCO_COMBO_INVIS_CLEANUP")
    Osi.ProcObjectTimer(character, "OdinSCO_COMBO_INVIS_CLEANUP", 900)
end

local function skillGagOrder(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        if didHit == 1 then
            Osi.OBSCO_QueueStatusApply(target, "MUTED", character, 12.0, 0, 10)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillGagOrder_Prep(character, target, damage, hithandle)
    RemoveStatus(character, "OdinSCO_PREPHIT_GAGORDER")
    convertHitToElementalDamage(character, target, damage, hithandle)
end


local function skillKneeBreaker(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        if didHit == 1 then
            Osi.OBSCO_QueueDamageOnMoveApply(target, "DAMAGE_ON_MOVE", character, 12.0, 0.525)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillSerratedEdge(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        if GetStatusTurns(target, "BLEEDING") ~= nil then
            multiplyDamage(target, hithandle, 1.25)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillMisdirection(character, target, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)

        TeleportToPosition(target, x, y, z, "", 0, 1)
        SetOnStage(target, 1)

        PlayEffect(target, "OdinSCO_Impact_01");
        PlayEffect(target, "RS3_FX_Skills_Void_Netherswap_Reappear_01");
        
        PlayEffect(character, "OdinSCO_Impact_01");
        PlayEffect(character, "RS3_FX_Skills_Void_Netherswap_Reappear_01");
    end
end

local function skillSleepingArms(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        if didHit == 1 then
            Osi.OBSCO_QueueStatusApply(target, "OdinSCO_STRUGGLE", character, 12.0, 0, 10)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillCrawlingInfestation(character, target)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        RemoveStatus(target, "OdinSCO_CRAWLINGINFESTATION")
    end
end

local function skillTerrifyingCruelty(character, target, hithandle)
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        if didHit == 1 then
            Osi.OBSCO_QueueStatusApply(target, "OdinSCO_CRUELTY", character, 12.0, 0, 10)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillTerrifyingCruelty_Prep(character, target, damage, hithandle)
    RemoveStatus(character, "OdinSCO_PREPHIT_TERRIFYINGCRUELTY")
    convertHitToElementalDamage(character, target, damage, hithandle)
end

local function skillCloakAndDagger(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)
        ApplyStatus(character, "INVISIBLE", 6.0, 0, character)
    end
end

local function skillLaunchBomber(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)

        Osi.OBSCO_QueueCooldownOverride(character, "Projectile_LaunchBomber", 0.0)
    end
end

local function skillFirecracker(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)

        local ox, oy, oz = GetPosition(character)
        NRD_ProjectilePrepareLaunch();
        NRD_ProjectileSetString("SkillId", "Projectile_OdinSCO_Firecracker_Combo");
        NRD_ProjectileSetVector3("SourcePosition", x, y+1, z);
        NRD_ProjectileSetVector3("TargetPosition", x, y, z);
        NRD_ProjectileSetGuidString("Caster", character);
        NRD_ProjectileLaunch();
    end
end

local function skillFindersKeepers(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)

        local newCD = NRD_SkillGetCooldown(character, "Target_OdinSCO_FindersKeepers") - 18.0
        if newCD > 0.0 then
            Osi.OBSCO_QueueCooldownOverride(character, "Target_OdinSCO_FindersKeepers", newCD)
        else
            Osi.OBSCO_QueueCooldownOverride(character, "Target_OdinSCO_FindersKeepers", 0.0)
        end
    end
end

local function skillAdrenaline(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        ApplyStatus(character, "OdinSCO_ADRENALINE_COMBO", 6.0, 0, character)
    end
    incrementComboPoints(character, 1)
end

local function skillOutmaneuver(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then 
        consumeComboPoints(character)
        ApplyStatus(character, "OdinSCO_OUTMANEUVER_COMBO", 6.0, 1, character)
    end
end

local function skillSlipIntoShadows(character, x, y, z)
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        ApplyStatus(character, "HASTED", 6.0, 0, character)
    end
end

-- Initiate region
local function skillOnHit(character, target, hithandle, protoId)
    local skillId = getSkillEntryName(protoId)
    local using = Ext.StatGetAttribute(skillId, "Using")
    if using ~= nil then
        skillId = using
    end
    
    local func = OdinScoundrelOverhaul.ComboSkills.OnHit[skillId]
    if func~= nil then
        func(character, target, hithandle)
    elseif skillId ~= '' then
        local using = Ext.StatGetAttribute(skillId, "Using")
        if using ~= nil then
            func = OdinScoundrelOverhaul.ComboSkills.OnHit[using]
            if func~= nil then
                func(character, target, hithandle)
            end
        end
    end
end

local function skillOnPrepareHit(character, target, damage, hithandle, skillId)
    local using = Ext.StatGetAttribute(skillId, "Using")
    if using ~= nil then
        skillId = using
    end

    local func = OdinScoundrelOverhaul.ComboSkills.OnPrepareHit[skillId]
    if func~= nil then
        func(character, target, damage, hithandle)
    end
end

local function skillAtPos(character, x, y, z, skillId)
    local using = Ext.StatGetAttribute(skillId, "Using")
    if using ~= nil then
        skillId = using
    end

    local func = OdinScoundrelOverhaul.ComboSkills.AtPos[skillId]
    if func~= nil then
        func(character, x, y, z)
    end
end

OdinScoundrelOverhaul.ComboSkills.OnHit = {
    MultiStrike_OdinSCO_ShadowStep = skillShadowStep,
    MultiStrike_Vault = skillVault,
    Projectile_Chloroform = skillChloroform,
    Projectile_FanOfKnives = skillFanOfKnives,
    Projectile_ThrowingKnife = skillThrowingKnife,
    Shout_OdinSCO_ShadowSlash = skillShadowSlash,
    Target_CorruptedBlade = skillCorruptedBlade,
    Target_Fatality = skillFatality,
    Target_GagOrder = skillGagOrder,
    Target_KneeBreaker = skillKneeBreaker,
    Target_SerratedEdge = skillSerratedEdge,
    Target_SleepingArms = skillSleepingArms,
    Target_OdinSCO_SinisterStrike = skillSinisterStrike,
    Target_TerrifyingCruelty = skillTerrifyingCruelty
}

OdinScoundrelOverhaul.ComboSkills.OnPrepareHit = {
    Target_GagOrder = skillGagOrder_Prep,
    Target_OdinSCO_SinisterStrike = skillSinisterStrike_Prep,
    Target_TerrifyingCruelty = skillTerrifyingCruelty_Prep
}

OdinScoundrelOverhaul.ComboSkills.AtPos = {
    Jump_CloakAndDagger = skillCloakAndDagger,
    Projectile_LaunchBomber = skillLaunchBomber,
    Projectile_OdinSCO_Firecracker = skillFirecracker,
    Shout_Adrenaline = skillAdrenaline,
    Shout_OdinSCO_Outmaneuver = skillOutmaneuver,
    Shout_OdinSCO_SlipIntoShadows = skillSlipIntoShadows
}

Ext.NewCall(skillOnHit, "OBSCO_LUA_Skill_OnHit", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle, (STRING)_SkillId")
Ext.NewCall(skillOnPrepareHit, "OBSCO_LUA_Skill_OnPrepareHit", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER)_Damage, (INTEGER64)_HitHandle, (STRING)_SkillId")
Ext.NewCall(skillAtPos, "OBSCO_LUA_Skill_AtPos", "(GUIDSTRING)_Character, (REAL)_X, (REAL)_Y, (REAL)_Z, (STRING)_SkillId")

-- SPECIAL PROCESSING
Ext.NewCall(skillCrawlingInfestation, "OBSCO_Lua_Skill_CrawlingInfestation", "(GUIDSTRING)_Character, (GUIDSTRING)_Target")
Ext.NewCall(skillMisdirection, "OBSCO_Lua_Skill_Misdirection", "(GUIDSTRING)_Caster, (GUIDSTRING)_Clone, (REAL)_X, (REAL)_Y, (REAL)_Z")
Ext.NewCall(skillSinisterStrike, "OBSCO_Lua_Skill_SinisterStrike", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle")
Ext.NewCall(skillFindersKeepers, "OBSCO_Lua_Skill_FindersKeepers", "(GUIDSTRING)_Character")