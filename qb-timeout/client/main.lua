local QBCore = exports['qb-core']:GetCoreObject()
local isInTimeout = false
local timeoutEndTime = 0

local disabledControls = {
    1, 2, 24, 25, 37, 44, 45, 58, 140, 141, 142, 143, 257, 263, 264,
    268, 269, 270, 271, 288, 289, 170, 73, 75, 23, 74, 59, 71, 72, 92, 106
}

RegisterNetEvent('qb-timeout:client:EnterTimeout', function(duration)
    local wasInTimeout = isInTimeout
    isInTimeout = true
    timeoutEndTime = GetGameTimer() + (duration * 1000)
    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.TimeoutArea.x, Config.TimeoutArea.y, Config.TimeoutArea.z, false, false, false, false)
    SetEntityHeading(ped, Config.TimeoutArea.w)
    
    -- Show different notification if player reconnected during timeout
    if wasInTimeout then
        QBCore.Functions.Notify(Config.Notifications.Reconnected, 'error', 10000)
    else
        QBCore.Functions.Notify(Config.Notifications.Sent, 'error', 10000)
    end
    
    Citizen.CreateThread(function()
        while isInTimeout do
            for _, control in ipairs(disabledControls) do
                DisableControlAction(0, control, true)
            end
            RemoveAllPedWeapons(ped, true)
            if IsPedInAnyVehicle(ped, false) then
                TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)
            end
            SetPedCanRagdoll(ped, false)
            DisableControlAction(0, 22, true) -- Jump
            
            -- Force player back to timeout area if they somehow move away
            local playerCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - vector3(Config.TimeoutArea.x, Config.TimeoutArea.y, Config.TimeoutArea.z))
            if distance > 10.0 then
                SetEntityCoords(ped, Config.TimeoutArea.x, Config.TimeoutArea.y, Config.TimeoutArea.z, false, false, false, false)
                SetEntityHeading(ped, Config.TimeoutArea.w)
            end
            
            if GetGameTimer() >= timeoutEndTime then
                TriggerServerEvent('qb-timeout:server:ReleaseMe')
                break
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('qb-timeout:client:ReleaseFromTimeout', function()
    if isInTimeout then
        isInTimeout = false
        local ped = PlayerPedId()
        SetEntityCoords(ped, Config.ReleaseArea.x, Config.ReleaseArea.y, Config.ReleaseArea.z, false, false, false, false)
        SetEntityHeading(ped, Config.ReleaseArea.w)
        QBCore.Functions.Notify(Config.Notifications.Released, 'success', 5000)
        SetPedCanRagdoll(ped, true)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qb-timeout:server:CheckTimeoutStatus')
end)
