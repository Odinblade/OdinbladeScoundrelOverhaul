Game.Tooltip.Register.Skill(function (_, skill, tooltip)
    local customProperty = OdinScoundrelOverhaul.UISkillProperties[skill]
    if customProperty ~= nil then
        local skillProperties = tooltip:GetElement("SkillProperties")
        if skillProperties ~= nil then
            -- Insert customProperty to pre-existing SkillProperties entry
            table.insert(skillProperties.Properties, 1, {
                Label = customProperty,
                Warning = ""
            })
        else
            -- Insert SkillProperties element as it doesn't exist
            tooltip:AppendElement({
                Properties = {{
                    Label = customProperty,
                    Warning = ""
                }},
                Resistances = {},
                Type = "SkillProperties"
            })
        end
    end
end)