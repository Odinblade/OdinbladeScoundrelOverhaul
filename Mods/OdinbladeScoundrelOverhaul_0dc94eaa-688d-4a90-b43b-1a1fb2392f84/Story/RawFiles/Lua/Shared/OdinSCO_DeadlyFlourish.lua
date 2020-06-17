local function hasScoundrelSkills(character)
    return 1
end

Ext.NewQuery(hasScoundrelSkills, "OBSCO_LUA_HasScoundrelSkills", "[in](CHARACTERGUID)_Character, [out](INTEGER)_Result");