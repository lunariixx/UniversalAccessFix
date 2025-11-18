Version = "1.0.8"
UniversalTags = {"id_medical", "id_medic", "id_medicaldoctor", "id_surgeon",
                 "id_engineer", "id_mechanic", "id_security",
                 "id_captain",  "id_assistant",
                 "id_command", "id_allaccess"}

Timer.Wait(function()
    local header = "\n/// Running Universal Access Mod v" .. Version .. " ///\n"
    local line = string.rep("-", #header + 4)
    print(line .. "\n" .. header .. line)
end, 1)

function makeIDUniversal(instance, _)
    local success, err = pcall(function()
        if instance == nil or instance.Item == nil then
            error("Instance or instance.Item is nil")
        end

        local item = instance.Item
        local updatedTags = {}

        for _, tag in ipairs(UniversalTags) do
            if not item.HasTag(tag) then
                item.AddTag(tag)
                table.insert(updatedTags, tag)
            end
        end

        if #updatedTags > 0 then
            if SERVER then
                Timer.Wait(function()
                    if item and not item.Removed then
                        Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(
                            item.SerializableProperties[Identifier("Tags")], item))
                        print("[UniversalAccessMod] Updated ID card '" .. tostring(item.Prefab.Identifier) ..
                                  "' with tags: " .. table.concat(updatedTags, ", "))
                    end
                end, 1000)
            else
                print("[UniversalAccessMod] Updated ID card '" .. tostring(item.Prefab.Identifier) ..
                          "' (client, no sync)")
            end
        end

    end)

    if not success then
        print("[UniversalAccessMod][ERROR] Failed to update ID card: " .. tostring(err))
    end
end

Hook.Patch("Barotrauma.Items.Components.IdCard", "OnItemLoaded", makeIDUniversal, Hook.HookMethodType.After)
Hook.Patch("Barotrauma.Items.Components.IdCard", "Initialize", makeIDUniversal, Hook.HookMethodType.After)
