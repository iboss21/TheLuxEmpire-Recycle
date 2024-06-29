local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isRecycling = false
local currentRoute = nil
local currentWaypoint = 1
local recyclingTruck = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

CreateThread(function()
    for _, center in pairs(Config.RecyclingCenters) do
        local blip = AddBlipForCoord(center.ped.coords.x, center.ped.coords.y, center.ped.coords.z)
        SetBlipSprite(blip, center.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, center.blip.scale)
        SetBlipColour(blip, center.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(center.name)
        EndTextCommandSetBlipName(blip)

        local ped = CreatePed(4, GetHashKey(center.ped.model), center.ped.coords.x, center.ped.coords.y, center.ped.coords.z - 1.0, center.ped.coords.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "theluxempire-recycle:client:openMenu",
                    icon = "fas fa-recycle",
                    label = "Recycle Items",
                },
                {
                    type = "client",
                    event = "theluxempire-recycle:client:startRoute",
                    icon = "fas fa-truck",
                    label = "Start Recycling Route",
                },
            },
            distance = 2.0
        })
    end
end)

RegisterNetEvent('theluxempire-recycle:client:openMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = "Recycling Center",
            isMenuHeader = true
        },
        {
            header = "Recycle Items",
            txt = "Turn in your recyclable items",
            params = {
                event = "theluxempire-recycle:client:recycleItems"
            }
        },
        {
            header = "Sell Recycled Materials",
            txt = "Sell your processed materials",
            params = {
                event = "theluxempire-recycle:client:sellMaterials"
            }
        },
        {
            header = "Check Experience",
            txt = "View your recycling experience",
            params = {
                event = "theluxempire-recycle:client:checkExperience"
            }
        }
    })
end)

RegisterNetEvent('theluxempire-recycle:client:recycleItems', function()
    QBCore.Functions.TriggerCallback('theluxempire-recycle:server:getRecyclableItems', function(items)
        local options = {}
        for item, amount in pairs(items) do
            table.insert(options, {
                title = Config.RecyclableItems[item].label,
                description = "You have " .. amount,
                onSelect = function()
                    local input = lib.inputDialog('Recycle ' .. Config.RecyclableItems[item].label, {
                        {type = 'number', label = 'Amount', description = 'How many do you want to recycle?', required = true, min = 1, max = amount}
                    })
                    if input then
                        TriggerServerEvent('theluxempire-recycle:server:recycleItems', item, input[1])
                    end
                end
            })
        end
        lib.registerContext({
            id = 'recycle_items_menu',
            title = 'Recycle Items',
            options = options
        })
        lib.showContext('recycle_items_menu')
    end)
end)

RegisterNetEvent('theluxempire-recycle:client:sellMaterials', function()
    QBCore.Functions.TriggerCallback('theluxempire-recycle:server:getRecycledMaterials', function(items)
        local options = {}
        for item, amount in pairs(items) do
            table.insert(options, {
                title = Config.RecycledItems[item].label,
                description = "You have " .. amount,
                onSelect = function()
                    local input = lib.inputDialog('Sell ' .. Config.RecycledItems[item].label, {
                        {type = 'number', label = 'Amount', description = 'How many do you want to sell?', required = true, min = 1, max = amount}
                    })
                    if input then
                        TriggerServerEvent('theluxempire-recycle:server:sellMaterials', item, input[1])
                    end
                end
            })
        end
        lib.registerContext({
            id = 'sell_materials_menu',
            title = 'Sell Recycled Materials',
            options = options
        })
        lib.showContext('sell_materials_menu')
    end)
end)

RegisterNetEvent('theluxempire-recycle:client:checkExperience', function()
    QBCore.Functions.TriggerCallback('theluxempire-recycle:server:getExperience', function(exp, level)
        local nextLevel = Config.ExperienceSystem.levels[level + 1]
        local progress = nextLevel and math.floor((exp / nextLevel.exp) * 100) or 100
        lib.registerContext({
            id = 'experience_menu',
            title = 'Recycling Experience',
            options = {
                {
                    title = 'Current Level: ' .. level,
                    description = 'Experience: ' .. exp .. ' / ' .. (nextLevel and nextLevel.exp or 'Max'),
                    progress = progress
                },
                {
                    title = 'Current Bonus: ' .. (Config.ExperienceSystem.levels[level].bonus * 100 - 100) .. '%',
                    description = 'Your recycling efficiency bonus'
                }
            }
        })
        lib.showContext('experience_menu')
    end)
end)

RegisterNetEvent('theluxempire-recycle:client:startRoute', function()
    if recyclingTruck then
        QBCore.Functions.Notify('You already have a recycling truck out!', 'error')
        return
    end

    local routes = {}
    for i, route in ipairs(Config.RecyclingRoutes) do
        table.insert(routes, {
            title = route.name,
            onSelect = function()
                SpawnRecyclingTruck(i)
            end
        })
    end

    lib.registerContext({
        id = 'route_selection_menu',
        title = 'Select Recycling Route',
        options = routes
    })
    lib.showContext('route_selection_menu')
end)

function SpawnRecyclingTruck(routeIndex)
    local coords = Config.RecyclingTruck.spawnLocation
    QBCore.Functions.SpawnVehicle(Config.RecyclingTruck.model, function(vehicle)
        recyclingTruck = vehicle
        SetVehicleNumberPlateText(vehicle, "RECYCLE"..tostring(math.random(1000, 9999)))
        SetEntityHeading(vehicle, coords.w)
        exports['LegacyFuel']:SetFuel(vehicle, 100.0)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        SetVehicleEngineOn(vehicle, true, true)
    end, coords, true)
    
    currentRoute = routeIndex
    currentWaypoint = 1
    CreateRouteBlip()
end

function CreateRouteBlip()
    if DoesBlipExist(currentBlip) then RemoveBlip(currentBlip) end
    local coords = Config.RecyclingRoutes[currentRoute].waypoints[currentWaypoint]
    currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(currentBlip, 1)
    SetBlipDisplay(currentBlip, 4)
    SetBlipScale(currentBlip, 0.8)
    SetBlipColour(currentBlip, 5)
    SetBlipRoute(currentBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Recycling Waypoint")
    EndTextCommandSetBlipName(currentBlip)
end

CreateThread(function()
    while true do
        Wait(1000)
        if currentRoute and recyclingTruck then
            local coords = GetEntityCoords(recyclingTruck)
            local waypointCoords = Config.RecyclingRoutes[currentRoute].waypoints[currentWaypoint]
            local distance = #(coords - waypointCoords)
            
            if distance < 5.0 then
                currentWaypoint = currentWaypoint + 1
                if currentWaypoint > #Config.RecyclingRoutes[currentRoute].waypoints then
                    QBCore.Functions.Notify('Route completed! Return to the recycling center.', 'success')
                    RemoveBlip(currentBlip)
                    currentRoute = nil
                    currentWaypoint = 1
                    TriggerServerEvent('theluxempire-recycle:server:completeRoute')
                else
                    CreateRouteBlip()
                    QBCore.Functions.Notify('Reached waypoint! Proceeding to next location.', 'success')
                end
            end
        end
    end
end)
