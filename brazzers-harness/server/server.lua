local QBCore = exports['qb-core']:GetCoreObject()

-- Register harness as usable item
QBCore.Functions.CreateUseableItem('harness', function(source, item)
    TriggerClientEvent('brazzers-harness:client:attachHarness', source, item)
end)

-- Helper: Get real plate if using fake plates
local function getRealPlate(plate)
    if Config.BrazzersFakePlate then
        local fake = exports['brazzers-fakeplates']:getPlateFromFakePlate(plate)
        if fake then plate = fake end
        Wait(100)
    end
    return plate
end

-- Check if vehicle is owned
local function isVehicleOwned(plate)
    plate = getRealPlate(plate)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    return result ~= nil
end

-- Check if harness installed on vehicle
local function hasHarness(plate)
    plate = getRealPlate(plate)
    local result = MySQL.scalar.await('SELECT harness FROM player_vehicles WHERE plate = ?', {plate})
    return result == 1 or result == true
end

-- Attach harness request
RegisterNetEvent('brazzers-harness:server:attachHarness', function(plate, ItemData)
    local src = source
    plate = getRealPlate(plate)
    if not isVehicleOwned(plate) then
        return TriggerClientEvent('seatbelt:client:UseHarness', src, ItemData, true)
    end
    if Config.UninstallHarnessWithItem and hasHarness(plate) then
        return TriggerClientEvent('brazzers-harness:client:installHarness', src, plate, 'uninstall')
    end
    TriggerClientEvent('brazzers-harness:client:installHarness', src, plate, 'install')
end)

-- Install or uninstall harness
RegisterNetEvent('brazzers-harness:server:installHarness', function(plate, action)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not plate or not action then return end
    plate = getRealPlate(plate)

    if action == 'install' then
        Player.Functions.RemoveItem('harness', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['harness'], 'remove')
        MySQL.update('UPDATE player_vehicles SET harness = ? WHERE plate = ?', {true, plate})
        TriggerClientEvent('QBCore:Notify', src, "Harness installed!", 'success')
    elseif action == 'uninstall' then
        if not hasHarness(plate) then
            return TriggerClientEvent('QBCore:Notify', src, "No harness installed.", 'error')
        end
        Player.Functions.AddItem('harness', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['harness'], 'add')
        MySQL.update('UPDATE player_vehicles SET harness = ? WHERE plate = ?', {nil, plate})
        TriggerClientEvent('QBCore:Notify', src, "Harness uninstalled!", 'success')
    end
end)

-- Toggle belt/harness logic
RegisterNetEvent('brazzers-harness:server:toggleBelt', function(plate, ItemData)
    local src = source
    plate = getRealPlate(plate)
    if not hasHarness(plate) then
        return TriggerClientEvent('seatbelt:client:UseSeatbelt', src)
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local harnessItem = Player.Functions.GetItemByName('harness')
    if harnessItem then
        TriggerClientEvent('seatbelt:client:UseHarness', src, harnessItem, false)
    else
        -- Dummy item data for installed harness without item
        local dummyItemData = {
            name = 'harness',
            info = { uses = 20 }
        }
        TriggerClientEvent('seatbelt:client:UseHarness', src, dummyItemData, false)
    end
end)

-- Decrement harness uses on equip
RegisterNetEvent('equip:harness', function(ItemData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not ItemData or not ItemData.info or not ItemData.info.uses then return end

    local uses = ItemData.info.uses - 1
    if uses <= 0 then
        Player.Functions.RemoveItem(ItemData.name, 1, ItemData.slot)
    else
        Player.Functions.SetItemInfo(ItemData.slot, 'uses', uses)
    end
end)

-- Handle harness damage
RegisterNetEvent('seatbelt:DoHarnessDamage', function(hp, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.slot then return end

    if hp <= 0 then
        Player.Functions.RemoveItem('harness', 1, data.slot)
    else
        Player.Functions.SetItemInfo(data.slot, 'uses', hp)
    end
end)

-- Callback to check harness on vehicle
QBCore.Functions.CreateCallback('brazzers-harness:server:checkHarness', function(source, cb, plate)
    plate = getRealPlate(plate)
    local result = MySQL.scalar.await('SELECT harness FROM player_vehicles WHERE plate = ?', {plate})
    cb(result == 1 or result == true)
end)

-- Admin: Give harness
RegisterNetEvent('brazzers-harness:server:giveHarness', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.Functions.GetPermission('admin') then return end
    Player.Functions.AddItem('harness', 1, nil, {uses = 20})
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['harness'], 'add')
    TriggerClientEvent('QBCore:Notify', src, "Harness received!", 'success')
end)

-- Admin: Force install harness on vehicle
RegisterNetEvent('brazzers-harness:server:forceInstall', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.Functions.GetPermission('admin') then return end
    plate = getRealPlate(plate)
    MySQL.update('UPDATE player_vehicles SET harness = ? WHERE plate = ?', {true, plate})
    TriggerClientEvent('QBCore:Notify', src, "Harness force-installed on " .. plate, 'success')
end)
