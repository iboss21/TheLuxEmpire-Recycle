local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('theluxempire-recycle:server:getRecyclableItems', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local items = {}
    for item, _ in pairs(Config.RecyclableItems) do
        local amount = Player.Functions.GetItemByName(item)
        if amount then
            items[item] = amount.amount
        end
    end
    cb(items)
end)

QBCore.Functions.CreateCallback('theluxempire-recycle:server:getRecycledMaterials', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    local items = {}
    for item, _ in pairs(Config.RecycledItems) do
        local amount = Player.Functions.GetItemByName(item)
        if amount then
            items[item] = amount.amount
        end
    end
    cb(items)
end)

RegisterNetEvent('theluxempire-recycle:server:recycleItems', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local recyclableItem = Config.RecyclableItems[item]
    if not recyclableItem then return end

    if Player.Functions.RemoveItem(item, amount) then
        local reward = recyclableItem.reward
        local rewardAmount = math.random(reward.amount.min, reward.amount.max) * amount
        
        local experience = Config.ExperienceSystem.enabled and Player.PlayerData.metadata.recycling_exp or 0
        local level = 1
        for lvl, data in pairs(Config.ExperienceSystem.levels) do
            if experience >= data.exp then
                level = lvl
            else
                break
            end
        end
        
        local bonus = Config.ExperienceSystem.levels[level].bonus
        rewardAmount = math.floor(rewardAmount * bonus)
        
        Player.Functions.AddItem(reward.item, rewardAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], "add", rewardAmount)
        
        if Config.ExperienceSystem.enabled then
            experience = experience + (amount * 10) -- 10 XP per recycled item
            Player.Functions.SetMetaData("recycling_exp", experience)
        end
        
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.items_recycled", {amount = amount, item = recyclableItem.label, reward = rewardAmount, rewardItem = QBCore.Shared.Items[reward.item].label}), "success")
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_items"), "error")
    end
end)

RegisterNetEvent('theluxempire-recycle:server:sellMaterials', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local recycledItem = Config.RecycledItems[item]
    if not recycledItem then return end

    if Player.Functions.RemoveItem(item, amount) then
        local price = math.random(recycledItem.price.min, recycledItem.price.max) * amount
        Player.Functions.AddMoney("cash", price)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.materials_sold", {amount = amount, item = recycledItem.label, price = price}), "success")
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_materials"), "error")
    end
end)

QBCore.Functions.CreateCallback('theluxempire-recycle:server:getExperience', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(0, 1) end

    local experience = Player.PlayerData.metadata.recycling_exp or 0
    local level = 1
    for lvl, data in pairs(Config.ExperienceSystem.levels) do
        if experience >= data.exp then
            level = lvl
        else
            break
        end
    end
    cb(experience, level)
end)

RegisterNetEvent('theluxempire-recycle:server:completeRoute', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local reward = math.random(500, 1000) -- Base reward for completing a route
    local experience = Player.PlayerData.metadata.recycling_exp or 0
    local level = 1
    for lvl, data in pairs(Config.ExperienceSystem.levels) do
        if experience >= data.exp then
            level = lvl
        else
            break
        end
    end
    
    local bonus = Config.ExperienceSystem.levels[level].bonus
    reward = math.floor(reward * bonus)
    
    Player.Functions.AddMoney("cash", reward)
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.route_completed", {reward = reward}), "success")
    
    if Config.ExperienceSystem.enabled then
        experience = experience + 100 -- 100 XP for completing a route
        Player.Functions.SetMetaData("recycling_exp", experience)
    end
end)
