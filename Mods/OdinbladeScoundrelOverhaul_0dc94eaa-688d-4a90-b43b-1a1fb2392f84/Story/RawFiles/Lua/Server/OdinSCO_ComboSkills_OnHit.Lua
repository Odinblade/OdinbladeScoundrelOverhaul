Ext.Require("Shared/OdinSCO_SharedData.lua")
Ext.Require("Shared/OdinSCO_ComboPoints.lua")

-- SOME RULES
-- Each skill MUST call consumeComboPoints in one way or another.

local function multiplyDamage(target, hithandle, multiplier)
    for k,type in pairs(OdinScoundrelOverhaul.DamageTypes) do
        local damage = NRD_HitStatusGetDamage(target, hithandle, type)
        -- local damage2 = NRD_HitGetDamage(hithandle, "Physical")
        Ext.Print("Starting damage: "..damage)
        -- Ext.Print("Starting damage2: "..damage2)
        damage = damage * multiplier
        NRD_HitStatusClearDamage(target, hithandle, type)
        NRD_HitStatusAddDamage(target, hithandle, type, damage)
        Ext.Print("Ending damage: "..damage)
    end
end

local function skillThrowingKnife(character, target, hithandle)
    if HasActiveStatus(character, "INVISIBLE") then
        Ext.Print("Char is INVISIBLE")
    end
    Ext.Print("SkillThrowingKnife started")
    local activatedComboPoints = getActivatedComboPoints(character)
    Ext.Print(activatedComboPoints)
    if activatedComboPoints ~= 0 then    
        consumeComboPoints(character, activatedComboPoints, 0)
        
        if activatedComboPoints >= 2 then
            ApplyStatus(target, "BLEEDING", 6.0, 0, character)
            -- local damage = NRD_HitStatusGetDamage(target, hithandle, "Physical")
            -- damage = damage*1.125
            -- NRD_HitStatusClearDamage(target, hithandle, "Physical")
            -- NRD_HitStatusAddDamage(target, hithandle, "Physical", damage)
            -- Ext.Print("DAMAGE BUMP")
        end
        if activatedComboPoints == 3 then
            NRD_HitStatusClearAllDamage(target, hithandle)
            -- NRD_SkillSetCooldown(character, "Projectile_ThrowingKnife", 0.0)
            local x, y, z = GetPosition(target)
            NRD_ProjectilePrepareLaunch();
            NRD_ProjectileSetString("SkillId", "Projectile_OdinSCO_ThrowingKnife_C3");
            NRD_ProjectileSetVector3("SourcePosition", x, y+1, z);
            NRD_ProjectileSetVector3("TargetPosition", x, y, z);
            NRD_ProjectileSetGuidString("Caster", character);
            NRD_ProjectileSetGuidString("Target", target);
            NRD_ProjectileLaunch();
        end
    end
end

local function skillVault(character, target, hithandle)
    Ext.Print("SkillVault started")
    local activatedComboPoints = getActivatedComboPoints(character)
    Ext.Print(activatedComboPoints)
    if activatedComboPoints ~= 0 then
        consumeComboPoints(character, activatedComboPoints, 0)
        -- if activatedComboPoints >= 2 then
        --     ApplyStatus(target, "REGENERATION", 6.0, 0, character)
        -- end
        if activatedComboPoints == 3 then
            -- hithandle.DamageList:Multiply(1.5)
            multiplyDamage(target, hithandle, 1.25)
            -- for k,type in pairs(OdinScoundrelOverhaul.DamageTypes) do
            --     local damage = NRD_HitStatusGetDamage(target, hithandle, type)
            --     -- local damage2 = NRD_HitGetDamage(hithandle, "Physical")
            --     Ext.Print("Starting damage: "..damage)
            --     -- Ext.Print("Starting damage2: "..damage2)
            --     damage = damage * 1.25
            --     NRD_HitStatusClearDamage(target, hithandle, type)
            --     NRD_HitStatusAddDamage(target, hithandle, type, damage)
            --     Ext.Print("Ending damage: "..damage)
            -- end
        end
    end
end

local function skillPrepareVault(character, target, hithandle)
    Ext.Print("SkillPrepareVault started")
    local activatedComboPoints = getActivatedComboPoints(character)
    Ext.Print(activatedComboPoints)
    if activatedComboPoints ~= 0 then
        if activatedComboPoints == 3 then
            local invis = HasActiveStatus(character, "INVISIBLE")
            Ext.Print(invis)
        end
    end
end

local function skillOnHit(character, target, hithandle, skillId)
    Ext.Print(skillId)
    local func = OdinScoundrelOverhaul.ComboSkills.OnHit[skillId]
    if func~= nil then
        func(character, target, hithandle)
    end
end

local function skillOnPrepareHit(character, target, hithandle, skillId)
    Ext.Print(skillId)
    local func = OdinScoundrelOverhaul.ComboSkills.OnPrepareHit[skillId]
    if func~= nil then
        func(character, target, hithandle)
    end
end

OdinScoundrelOverhaul.ComboSkills.OnHit = {
    Projectile_ThrowingKnife = skillThrowingKnife,
    MultiStrike_Vault = skillVault
}

OdinScoundrelOverhaul.ComboSkills.OnPrepareHit = {
    -- Projectile_ThrowingKnife = skillThrowingKnife,
    MultiStrike_Vault = skillPrepareVault
}

-- OBSCO_LUA_Skill_OnPrepareHit
-- Ext.NewCall(skillThrowingKnife, "OBSCO_LUA_Skill_ThrowingKnife", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle");
-- Ext.NewCall(setComboTierSkills, "OBSCO_LUA_SetComboTierSkills", "(GUIDSTRING)_Character, (INTEGER)_Tier")
Ext.NewCall(skillOnHit, "OBSCO_LUA_Skill_OnHit", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle, (STRING)_SkillId")
Ext.NewCall(skillOnPrepareHit, "OBSCO_LUA_Skill_OnPrepareHit", "(GUIDSTRING)_Character, (GUIDSTRING)_Target, (INTEGER64)_HitHandle, (STRING)_SkillId")