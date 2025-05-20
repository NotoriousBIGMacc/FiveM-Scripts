-- Debug script for Racing Harness
-- This file helps with debugging the harness system

local QBCore = exports[Config.Core]:GetCoreObject()
local debugMode = false

-- Toggle debug mode
RegisterCommand('harness_debug', function()
    if not QBCore.Functions.GetPlayerData().metadata.isadmin then
        QBCore.Functions.Notify(Lang:t("error.no_permission"), 'error')
        return
    end
    
    debugMode = not debugMode
    QBCore.Functions.Notify(Lang:t(debugMode and "info.debug_enabled" or "info.debug_disabled"), 'primary')
    
    if debugMode then
        CreateThread(function()
            while debugMode do
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle ~= 0 then
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    local class = GetVehicleClass(vehicle)
                    
                    -- Draw debug info on screen
                    SetTextFont(4)
                    SetTextProportional(1)
                    SetTextScale(0.5, 0.5)
                    SetTextColour(255, 255, 255, 255)
                    SetTextDropshadow(0, 0, 0, 0, 255)
                    SetTextEdge(2, 0, 0, 0, 150)
                    SetTextDropShadow()
                    SetTextOutline()
                    
                    BeginTextCommandDisplayText("STRING")
                    AddTextComponentSubstringPlayerName("~b~Harness Debug~w~\nPlate: " .. plate .. "\nVehicle Class: " .. class)
                    EndTextCommandDisplayText(0.01, 0.01)
                    
                    -- Check if vehicle has harness installed
                    QBCore.Functions.TriggerCallback('brazzers-harness:server:checkHarness', function(hasHarness)
                        BeginTextCommandDisplayText("STRING")
                        AddTextComponentSubstringPlayerName("Harness Installed: " .. (hasHarness and "~g~Yes" or "~r~No"))
                        EndTextCommandDisplayText(0.01, 0.07)
                    end, plate)
                end
                Wait(500)
            end
        end)
    end
end, false)

-- Command to give yourself a harness item (admin only)
RegisterCommand('give_harness', function()
    if not QBCore.Functions.GetPlayerData().metadata.isadmin then
        QBCore.Functions.Notify(Lang:t("error.no_permission"), 'error')
        return
    end
    
    TriggerServerEvent('brazzers-harness:server:giveHarness')
end, false)

-- Command to force install harness on current vehicle (admin only)
RegisterCommand('force_harness', function()
    if not QBCore.Functions.GetPlayerData().metadata.isadmin then
        QBCore.Functions.Notify(Lang:t("error.no_permission"), 'error')
        return
    end
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        QBCore.Functions.Notify(Lang:t("error.not_in_vehicle"), 'error')
        return
    end
    
    local plate = QBCore.Functions.GetPlate(vehicle)
    TriggerServerEvent('brazzers-harness:server:forceInstall', plate)
end, false)

-- Help text for debug commands
TriggerEvent('chat:addSuggestion', '/harness_debug', 'Toggle harness debug mode (Admin Only)')
TriggerEvent('chat:addSuggestion', '/give_harness', 'Give yourself a racing harness (Admin Only)')
TriggerEvent('chat:addSuggestion', '/force_harness', 'Force install harness on current vehicle (Admin Only)')