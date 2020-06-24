Ext.Require("Shared/OdinSCO_SharedData.lua")
Ext.Require("Shared/OdinSCO_ComboPoints.lua")

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

local function convertHitToElementalDamage(target, damage, hithandle)
    local newType = OdinScoundrelOverhaul.ElementalDamageTypes[math.random(#OdinScoundrelOverhaul.ElementalDamageTypes)]
    -- for k,type in pairs(OdinScoundrelOverhaul.DamageTypes) do
        -- local damage = NRD_HitStatusGetDamage(target, hithandle, type)
        if damage ~= 0 then
            -- NRD_HitStatusClearDamage(target, hithandle, type)
            NRD_HitClearAllDamage(hithandle)
            NRD_HitAddDamage(hithandle, newType, damage)
        end
        -- hithandle.DamageList:ConvertDamageType(newType)
    -- end
    return newType
end

-- SOME RULES
-- Each skill MUST call consumeComboPoints in one way or another.

local function skillShadowStep(character, target, hithandle)
    Ext.Print("skillShadowStep started")
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    -- local rows = Osi.DB_OBSCO_ShadowStep_Stealth:Get(character)
    -- if rows ~= nil then
    if HasActiveStatus(character, "OdinSCO_APPLY_SHADOWSTEP_BONUS") == 1 then
        NRD_DebugLog("skillShadowStep stealth multiplier applied")
        multiplyDamage(target, hithandle, 1.2)
    end
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then 
        consumeComboPoints(character)
        Osi.OBSCO_QueueStatusApply(character, "INVISIBLE", character, 6.0, 0, 500)
    end
    if didHit == 1 then
        -- incrementComboPoints(character, 1)
        Osi.ProcObjectTimerCancel(character, "OdinSCO_INCREMENT_COMBO_DELAYED")
        Osi.ProcObjectTimer(character, "OdinSCO_INCREMENT_COMBO_DELAYED", 1250)
    end
    Osi.ProcObjectTimerCancel(character, "OdinSCO_SHADOWSTEP_RETURN")
    Osi.ProcObjectTimer(character, "OdinSCO_SHADOWSTEP_RETURN", 1000)
end

local function skillVault(character,  target, hithandle)
    Ext.Print("skillVault started")
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
    Ext.Print("skillChloroform started")
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
    Ext.Print("skillFanOfKnives started")
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
    Ext.Print("skillThrowingKnife started")
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
    Ext.Print("skillShadowSlash started")
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then  
        consumeComboPoints(character)
        multiplyDamage(target, hithandle, 1.2)
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
    Osi.ProcObjectTimerCancel(character, "OdinSCO_COMBO_INVIS_CLEANUP")
    Osi.ProcObjectTimer(character, "OdinSCO_COMBO_INVIS_CLEANUP", 900)
end

local function skillSinisterStrike(character, target, hithandle)
    Ext.Print("skillSinisterStrike started")
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
    Ext.Print("skillSinisterStrike_Prep started")
    RemoveStatus(character, "OdinSCO_PREPHIT_SINISTERSTRIKE")
    convertHitToElementalDamage(target, damage, hithandle)
end

local function skillCorruptedBlade(character, target, hithandle)
    Ext.Print("skillCorruptedBlade started")
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
    Ext.Print("skillFatality started")
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
    Ext.Print("skillGagOrder started")
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
    Ext.Print("skillGagOrder_Prep started")
    RemoveStatus(character, "OdinSCO_PREPHIT_GAGORDER")
    convertHitToElementalDamage(target, damage, hithandle)
end


local function skillKneeBreaker(character, target, hithandle)
    Ext.Print("skillKneeBreaker started")
    local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        if didHit == 1 then
            Osi.OBSCO_QueueDamageOnMoveApply(target, "DAMAGE_ON_MOVE", character, 12.0, 0.375)
        end
    end
    if didHit == 1 then
        incrementComboPoints(character, 1)
    end
end

local function skillSerratedEdge(character, target, hithandle)
    Ext.Print("skillSerratedEdge started")
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
    Ext.Print("skillMisdirection started")
    -- local didHit = NRD_StatusGetInt(target, hithandle, "Hit")
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
    Ext.Print("skillSleepingArms started")
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
    Ext.Print("skillCrawlingInfestation started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        RemoveStatus(target, "OdinSCO_CRAWLINGINFESTATION")
    end
end

local function skillTerrifyingCruelty(character, target, hithandle)
    Ext.Print("skillTerrifyingCruelty started")
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
    Ext.Print("skillTerrifyingCruelty_Prep started")
    RemoveStatus(character, "OdinSCO_PREPHIT_TERRIFYINGCRUELTY")
    convertHitToElementalDamage(target, damage, hithandle)  
end

local function skillCloakAndDagger(character, x, y, z)
    Ext.Print("skillCloakAndDagger started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)
        ApplyStatus(character, "INVISIBLE", 6.0, 0, character)

        local newCD = NRD_SkillGetCooldown(character, "Jump_CloakAndDagger") - 12.0
        if newCD > 0.0 then
            Osi.OBSCO_QueueCooldownOverride(character, "Jump_CloakAndDagger", newCD)
        else
            Osi.OBSCO_QueueCooldownOverride(character, "Jump_CloakAndDagger", 0.0)
        end
    end
end

local function skillLaunchBomber(character, x, y, z)
    Ext.Print("skillLaunchBomber started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)

        local newCD = NRD_SkillGetCooldown(character, "Projectile_LaunchBomber") - 18.0
        if newCD > 0.0 then
            Osi.OBSCO_QueueCooldownOverride(character, "Projectile_LaunchBomber", newCD)
        else
            Osi.OBSCO_QueueCooldownOverride(character, "Projectile_LaunchBomber", 0.0)
        end
    end
end

local function skillFirecracker(character, x, y, z)
    Ext.Print("skillFirecracker started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then
        consumeComboPoints(character)

        local ox, oy, oz = GetPosition(character)
        Ext.Print("Projectile Launched for Firecracker!")
        NRD_ProjectilePrepareLaunch();
        NRD_ProjectileSetString("SkillId", "Projectile_OdinSCO_Firecracker_Combo");
        NRD_ProjectileSetVector3("SourcePosition", ox, oy+1, oz);
        NRD_ProjectileSetVector3("TargetPosition", x, y, z);
        NRD_ProjectileSetGuidString("Caster", character);
        NRD_ProjectileLaunch();
    end
end

local function skillFindersKeepers(character, x, y, z)
    Ext.Print("skillFindersKeepers started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)

        local newCD = NRD_SkillGetCooldown(character, "Target_OdinSCO_FindersKeepers") - 30.0
        if newCD > 0.0 then
            Osi.OBSCO_QueueCooldownOverride(character, "Target_OdinSCO_FindersKeepers", newCD)
        else
            Osi.OBSCO_QueueCooldownOverride(character, "Target_OdinSCO_FindersKeepers", 0.0)
        end
    end
end

local function skillAdrenaline(character, x, y, z)
    Ext.Print("skillAdrenaline started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        ApplyStatus(character, "OdinSCO_ADRENALINE_COMBO", 6.0, 0, character)

        -- local newCD = NRD_SkillGetCooldown(character, "Shout_Adrenaline") - 6.0
        -- if newCD > 0.0 then
        --     Osi.OBSCO_QueueCooldownOverride(character, "Shout_Adrenaline", newCD)
        -- else
        --     Osi.OBSCO_QueueCooldownOverride(character, "Shout_Adrenaline", 0.0)
        -- end
    end
    incrementComboPoints(character, 1)
end

local function skillPlayOfTheGame(character, x, y, z)
    Ext.Print("skillPlayOfTheGame started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        ApplyStatus(character, "OdinSCO_PLAYOFTHEGAME_COMBO", 6.0, 0, character)
    else
        -- ApplyStatus(character, "OdinSCO_PLAYOFTHEGAME", 6.0, 0, character)
        incrementComboPoints(character, 2)
    end
end

local function skillSlipIntoShadows(character, x, y, z)
    Ext.Print("skillSlipIntoShadows started")
    if HasActiveStatus(character, "OdinSCO_USE_COMBO_3") == 1 then   
        consumeComboPoints(character)
        ApplyStatus(character, "HASTED", 6.0, 0, character)
    end
    incrementComboPoints(character, 1)
end

-- Initiate region
local function skillOnHit(character, target, hithandle, skillId)
    -- Ext.Print(skillId)
    local func = OdinScoundrelOverhaul.ComboSkills.OnHit[skillId]
    if func~= nil then
        func(character, target, hithandle)
    else
        Ext.Print("Checking using field...")
        local using = Ext.StatGetAttribute(skillId, "Using")
        if using ~= nil then
            Ext.Print("Using: "..using)
            func = OdinScoundrelOverhaul.ComboSkills.OnHit[using]
            if func~= nil then
                func(character, target, hithandle)
            end
        end
    end
end

local function skillOnPrepareHit(character, target, damage, hithandle, skillId)
    local func = OdinScoundrelOverhaul.ComboSkills.OnPrepareHit[skillId]
    if func~= nil then
        func(character, target, damage, hithandle)
    end
end

local function skillAtPos(character, x, y, z, skillId)
    -- Ext.Print(skillId)
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
    Target_OdinSCO_FindersKeepers = skillFindersKeepers,
    Shout_Adrenaline = skillAdrenaline,
    Shout_OdinSCO_PlayOfTheGame = skillPlayOfTheGame,
    Shout_OdinSCO_SlipIntoShadows = skillSlipIntoShadows
}

-- Ext.RegisterListener("BeforeCharacterApplyDamage", BeforeCharacterApplyDamage)

Ext.NewCall(skillOnHit, "OBSCO_LUA_Skill_OnHit", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle, (STRING)_SkillId")
Ext.NewCall(skillOnPrepareHit, "OBSCO_LUA_Skill_OnPrepareHit", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER)_Damage, (INTEGER64)_HitHandle, (STRING)_SkillId")
Ext.NewCall(skillAtPos, "OBSCO_LUA_Skill_AtPos", "(GUIDSTRING)_Character, (REAL)_X, (REAL)_Y, (REAL)_Z, (STRING)_SkillId")
-- Ext.NewCall(isSkillScoundrelPrepare, "OBSCO_LUA_Skill_IsSkillScoundrelPrepare", "(STRING)_SkillId")


-- SPECIAL PROCESSING
Ext.NewCall(skillCrawlingInfestation, "OBSCO_Lua_Skill_CrawlingInfestation", "(GUIDSTRING)_Character, (GUIDSTRING)_Target")
Ext.NewCall(skillMisdirection, "OBSCO_Lua_Skill_Misdirection", "(GUIDSTRING)_Caster, (GUIDSTRING)_Clone, (REAL)_X, (REAL)_Y, (REAL)_Z")
Ext.NewCall(skillSinisterStrike, "OBSCO_Lua_Skill_SinisterStrike", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle")