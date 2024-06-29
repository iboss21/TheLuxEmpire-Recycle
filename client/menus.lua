local QBCore = exports['qb-core']:GetCoreObject()

function OpenRecyclingShop()
    QBCore.Functions.TriggerCallback('theluxempire-recycle:server:getRecycledMaterials', function(items)
        local shopMenu = {
            {
                header = Lang:t("menu.sell_recycled"),
                isMenuHeader = true
            }
        }
        for item, amount in pairs(items) do
            table.insert(shopMenu, {
                header = Config.RecycledItems[item].label,
                txt = Lang:t("menu.sell_amount", {amount = amount}),
                params = {
                    event = "theluxempire-recycle:client:sellMaterial",
                    args = {
                        item = item,
                        max = amount
                    }
                }
            })
        end
        table.insert(shopMenu, {
            header = Lang:t("menu.close"),
            params = {
                event = "qb-menu:client:closeMenu"
            }
        })
        exports['qb-menu']:openMenu(shopMenu)
    end)
end

RegisterNetEvent('theluxempire-recycle:client:sellMaterial', function(data)
    local input = lib.inputDialog(Lang:t("menu.sell_material", {material = Config.RecycledItems[data.item].label}), {
        {type = 'number', label = Lang:t("menu.amount"), description = Lang:t("menu.max_amount", {max = data.max}), required = true, min = 1, max = data.max}
    })
    if input then
        TriggerServerEvent('theluxempire-recycle:server:sellMaterials', data.item, input[1])
    end
end)

function OpenExperienceMenu()
    QBCore.Functions.TriggerCallback('theluxempire-recycle:server:getExperience', function(exp, level)
        local nextLevel = Config.ExperienceSystem.levels[level + 1]
        local expMenu = {
            {
                header = Lang:t("menu.experience_info"),
                isMenuHeader = true
            },
            {
                header = Lang:t("menu.current_level", {level = level}),
                txt = Lang:t("menu.current_exp", {exp = exp, next = nextLevel and nextLevel.exp or Lang:t("menu.max_level")})
            },
            {
                header = Lang:t("menu.current_bonus", {bonus = (Config.ExperienceSystem.levels[level].bonus * 100 - 100)}),
                txt = Lang:t("menu.bonus_explanation")
            },
            {
                header = Lang:t("menu.close"),
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
        }
        exports['qb-menu']:openMenu(expMenu)
    end)
end

RegisterNetEvent('theluxempire-recycle:client:openExperienceMenu', function()
    OpenExperienceMenu()
end)
