local QBCore = exports['qb-core']:GetCoreObject()

-- Useable harness item triggers client event
QBCore.Functions.CreateUseableItem('harness', function(source, item)
    TriggerClientEvent('seatbelt:client:UseHarness', source, item, true)
end)

-- Install harness (persistent, DB)
RegisterNetEvent('equip:harness', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not plate then return end

    -- Save harness to DB
    MySQL.update('UPDATE player_vehicles SET harness = ? WHERE plate = ?', {true, plate})

    -- Remove harness item from inventory
    Player.Functions.RemoveItem('harness', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['harness'], 'remove')
    TriggerClientEvent('QBCore:Notify', src, "Harness installed!", 'success')
end)

-- Callback: check if harness is installed on vehicle
QBCore.Functions.CreateCallback('brazzers-harness:server:checkHarness', function(source, cb, plate)
    local result = MySQL.scalar.await('SELECT harness FROM player_vehicles WHERE plate = ?', {plate})
    cb(result == 1 or result == true)
end)
