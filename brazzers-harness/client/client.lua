local QBCore = exports['qb-core']:GetCoreObject()
local seatbeltOn = false
local harnessOn = false
local harnessHp = 20
local harnessData = {}

-- Ejection/crash logic variables (unchanged)
local handbrake, sleep, newVehBodyHealth, currVehBodyHealth, frameBodyChange = 0, 0, 0, 0, 0
local lastFrameVehSpeed, lastFrameVehSpeed2, thisFrameVehSpeed, tick = 0, 0, 0, 0
local damageDone, modifierDensity, lastVeh, veloc = false, true, nil, nil

local function ejectFromVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(1)
    SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(ped, veloc.x * 4, veloc.y * 4, veloc.z * 4)
    local ejectSpeed = math.ceil(GetEntitySpeed(ped) * 8)
    if GetEntityHealth(ped) - ejectSpeed > 0 then
        SetEntityHealth(ped, GetEntityHealth(ped) - ejectSpeed)
    elseif GetEntityHealth(ped) ~= 0 then
        SetEntityHealth(ped, 0)
    end
end

local function toggleSeatbelt()
    seatbeltOn = not seatbeltOn
    if seatbeltOn then harnessOn = false end
    SeatBeltLoop()
    QBCore.Functions.Notify(seatbeltOn and "Seatbelt fastened!" or "Seatbelt unfastened!", seatbeltOn and "success" or "error")
    TriggerEvent("seatbelt:client:ToggleSeatbelt", seatbeltOn)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5.0, seatbeltOn and "carbuckle" or "carunbuckle", 0.25)
end

local function toggleHarnessWithBar()
    QBCore.Functions.Progressbar("harness_toggle", harnessOn and "Taking Off Harness" or "Putting On Harness", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        harnessOn = not harnessOn
        if harnessOn then seatbeltOn = false end
        SeatBeltLoop()
        QBCore.Functions.Notify(harnessOn and "Harness engaged!" or "Harness disengaged!", harnessOn and "success" or "error")
        TriggerEvent("seatbelt:client:ToggleSeatbelt", harnessOn)
    end)
end

function SeatBeltLoop()
    CreateThread(function()
        while true do
            if seatbeltOn or harnessOn then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)
            end
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                seatbeltOn = false
                harnessOn = false
                TriggerEvent("seatbelt:client:ToggleSeatbelt", false)
                break
            end
            if not seatbeltOn and not harnessOn then break end
            Wait(0)
        end
    end)
end

exports("HasHarness", function() return harnessOn end)

RegisterNetEvent('QBCore:Client:EnteredVehicle', function()
    local ped = PlayerPedId()
    while IsPedInAnyVehicle(ped, false) do
        Wait(0)
        local currVehicle = GetVehiclePedIsIn(ped, false)
        if currVehicle and currVehicle ~= false and currVehicle ~= 0 then
            SetPedHelmet(ped, false)
            lastVeh = GetVehiclePedIsIn(ped, false)
            if GetVehicleEngineHealth(currVehicle) < 0.0 then
                SetVehicleEngineHealth(currVehicle, 0.0)
            end
            if (GetVehicleHandbrake(currVehicle) or (GetVehicleSteeringAngle(currVehicle)) > 25.0 or (GetVehicleSteeringAngle(currVehicle)) < -25.0) then
                if handbrake == 0 then
                    handbrake = 100
                else
                    handbrake = 100
                end
            end

            thisFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
            currVehBodyHealth = GetVehicleBodyHealth(currVehicle)
            if currVehBodyHealth == 1000 and frameBodyChange ~= 0 then
                frameBodyChange = 0
            end
            if frameBodyChange ~= 0 then
                if lastFrameVehSpeed > 110 and thisFrameVehSpeed < (lastFrameVehSpeed * 0.75) and not damageDone then
                    if frameBodyChange > 18.0 then
                        if not seatbeltOn and not IsThisModelABike(currVehicle) then
                            if math.random(math.ceil(lastFrameVehSpeed)) > 60 then
                                if not harnessOn then
                                    ejectFromVehicle()
                                else
                                    harnessHp = harnessHp - 1
                                    TriggerServerEvent('seatbelt:DoHarnessDamage', harnessHp, harnessData)
                                end
                            end
                        elseif (seatbeltOn or harnessOn) and not IsThisModelABike(currVehicle) then
                            if lastFrameVehSpeed > 150 then
                                if math.random(math.ceil(lastFrameVehSpeed)) > 150 then
                                    if not harnessOn then
                                        ejectFromVehicle()
                                    else
                                        harnessHp = harnessHp - 1
                                        TriggerServerEvent('seatbelt:DoHarnessDamage', harnessHp, harnessData)
                                    end
                                end
                            end
                        end
                    else
                        if not seatbeltOn and not IsThisModelABike(currVehicle) then
                            if math.random(math.ceil(lastFrameVehSpeed)) > 60 then
                                if not harnessOn then
                                    ejectFromVehicle()
                                else
                                    harnessHp = harnessHp - 1
                                    TriggerServerEvent('seatbelt:DoHarnessDamage', harnessHp, harnessData)
                                end
                            end
                        elseif (seatbeltOn or harnessOn) and not IsThisModelABike(currVehicle) then
                            if lastFrameVehSpeed > 120 then
                                if math.random(math.ceil(lastFrameVehSpeed)) > 200 then
                                    if not harnessOn then
                                        ejectFromVehicle()
                                    else
                                        harnessHp = harnessHp - 1
                                        TriggerServerEvent('seatbelt:DoHarnessDamage', harnessHp, harnessData)
                                    end
                                end
                            end
                        end
                    end
                    damageDone = true
                    SetVehicleEngineOn(currVehicle, false, true, true)
                end
                if currVehBodyHealth < 350.0 and not damageDone then
                    damageDone = true
                    SetVehicleEngineOn(currVehicle, false, true, true)
                    Wait(1000)
                end
            end
            if lastFrameVehSpeed < 100 then
                Wait(100)
                tick = 0
            end
            frameBodyChange = newVehBodyHealth - currVehBodyHealth
            if tick > 0 then
                tick = tick - 1
                if tick == 1 then
                    lastFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
                end
            else
                if damageDone then
                    damageDone = false
                    frameBodyChange = 0
                    lastFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
                end
                lastFrameVehSpeed2 = GetEntitySpeed(currVehicle) * 3.6
                if lastFrameVehSpeed2 > lastFrameVehSpeed then
                    lastFrameVehSpeed = GetEntitySpeed(currVehicle) * 3.6
                end
                if lastFrameVehSpeed2 < lastFrameVehSpeed then
                    tick = 25
                end
            end
            if tick < 0 then
                tick = 0
            end
            newVehBodyHealth = GetVehicleBodyHealth(currVehicle)
            if not modifierDensity then
                modifierDensity = true
            end
            veloc = GetEntityVelocity(currVehicle)
        else
            if lastVeh then
                SetPedHelmet(ped, true)
                Wait(200)
                newVehBodyHealth = GetVehicleBodyHealth(lastVeh)
                if not damageDone and newVehBodyHealth < currVehBodyHealth then
                    damageDone = true
                    SetVehicleEngineOn(lastVeh, false, true, true)
                    Wait(1000)
                end
                lastVeh = nil
            end
            lastFrameVehSpeed2 = 0
            lastFrameVehSpeed = 0
            newVehBodyHealth = 0
            currVehBodyHealth = 0
            frameBodyChange = 0
            Wait(2000)
            break
        end
    end
end)

RegisterNetEvent('seatbelt:client:UseHarness', function(ItemData, updateInfo)
    local ped = PlayerPedId()
    local inveh = IsPedInAnyVehicle(ped, false)
    local class = GetVehicleClass(GetVehiclePedIsUsing(ped))
    if inveh and class ~= 8 and class ~= 13 and class ~= 14 then
        if not harnessOn then
            LocalPlayer.state:set("inv_busy", true, true)
            QBCore.Functions.Progressbar("harness_equip", "Attaching Race Harness", 5000, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                LocalPlayer.state:set("inv_busy", false, true)
                harnessOn = true
                seatbeltOn = false
                SeatBeltLoop()
                QBCore.Functions.Notify("Harness engaged!", "success")
                TriggerEvent("seatbelt:client:ToggleSeatbelt", true)
                if updateInfo then TriggerServerEvent('equip:harness', ItemData) end
                if updateInfo then
                    harnessHp = ItemData.info.uses
                    harnessData = ItemData
                    TriggerEvent('hud:client:UpdateHarness', harnessHp)
                end
            end)
        else
            harnessOn = false
            QBCore.Functions.Notify("Harness disengaged!", "error")
            TriggerEvent("seatbelt:client:ToggleSeatbelt", false)
        end
    else
        QBCore.Functions.Notify('You\'re not in a car.', 'error')
    end
end)

RegisterCommand('toggleseatbelt', function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) or IsPauseMenuActive() then return end
    local class = GetVehicleClass(GetVehiclePedIsUsing(PlayerPedId()))
    if class == 8 or class == 13 or class == 14 then return end
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local plate = QBCore.Functions.GetPlate(vehicle)
    QBCore.Functions.TriggerCallback('brazzers-harness:server:checkHarness', function(hasHarness)
        if hasHarness then
            toggleHarnessWithBar()
        else
            toggleSeatbelt()
        end
    end, plate)
end, false)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt/Harness', 'keyboard', 'B')
