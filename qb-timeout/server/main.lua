local QBCore = exports['qb-core']:GetCoreObject()
local timeoutList = {}

-- Ensure database table exists when resource starts
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS player_timeout (
            citizenid VARCHAR(50) PRIMARY KEY,
            timeout_end INT NOT NULL
        )
    ]], {})
    
    -- Load active timeouts from database
    MySQL.Async.fetchAll('SELECT * FROM player_timeout WHERE timeout_end > ?', {os.time()}, function(results)
        if results and #results > 0 then
            for _, data in ipairs(results) do
                timeoutList[data.citizenid] = data.timeout_end
            end
            print('Loaded ' .. #results .. ' active timeouts from database')
        end
    end)
    
    -- Clean up expired timeouts
    MySQL.Async.execute('DELETE FROM player_timeout WHERE timeout_end <= ?', {os.time()})
end)

-- Save timeout to database
local function saveTimeoutToDatabase(citizenid, endTime)
    MySQL.Async.execute('REPLACE INTO player_timeout (citizenid, timeout_end) VALUES (?, ?)', 
        {citizenid, endTime})
end

-- Remove timeout from database
local function removeTimeoutFromDatabase(citizenid)
    MySQL.Async.execute('DELETE FROM player_timeout WHERE citizenid = ?', {citizenid})
end

-- Timeout Command Logic
local function sendToTimeout(source, args)
    local playerId = tonumber(args[1])
    local minutes = tonumber(args[2])
    local maxMinutes = Config.MaxTimeoutMinutes
    
    if not playerId or not minutes then
        TriggerClientEvent('QBCore:Notify', source, "Invalid arguments.", "error")
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(playerId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, "Player not found.", "error")
        return
    end
    
    local citizenid = targetPlayer.PlayerData.citizenid

    if minutes > maxMinutes then
        minutes = maxMinutes
        TriggerClientEvent('QBCore:Notify', source, "Timeout capped at " .. maxMinutes .. " minutes.", "error")
    end

    if minutes < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Timeout must be at least 1 minute.", "error")
        return
    end

    local duration = minutes * 60
    local endTime = os.time() + duration
    
    -- Store in memory (both by source and citizenid for quick lookups)
    timeoutList[playerId] = endTime
    timeoutList[citizenid] = endTime
    
    -- Store by citizenid in database for persistence
    saveTimeoutToDatabase(citizenid, endTime)
    
    TriggerClientEvent('qb-timeout:client:EnterTimeout', playerId, duration)
    TriggerClientEvent('QBCore:Notify', source, "Player sent to timeout for " .. minutes .. " minutes.", "success")
end

-- Release Command Logic
local function releaseFromTimeout(source, args)
    local playerId = tonumber(args[1])
    local targetPlayer = QBCore.Functions.GetPlayer(playerId)
    
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, "Player not found.", "error")
        return
    end
    
    local citizenid = targetPlayer.PlayerData.citizenid
    
    if timeoutList[playerId] or timeoutList[citizenid] then
        -- Clear from memory
        timeoutList[playerId] = nil
        timeoutList[citizenid] = nil
        
        -- Clear from database
        removeTimeoutFromDatabase(citizenid)
        
        TriggerClientEvent('qb-timeout:client:ReleaseFromTimeout', playerId)
        TriggerClientEvent('QBCore:Notify', source, "Player released from timeout.", "success")
    else
        -- Double-check database in case it's not in memory
        MySQL.Async.fetchScalar('SELECT timeout_end FROM player_timeout WHERE citizenid = ?', {citizenid}, function(result)
            if result and tonumber(result) > os.time() then
                -- Found in database but not in memory
                removeTimeoutFromDatabase(citizenid)
                TriggerClientEvent('qb-timeout:client:ReleaseFromTimeout', playerId)
                TriggerClientEvent('QBCore:Notify', source, "Player released from timeout.", "success")
            else
                TriggerClientEvent('QBCore:Notify', source, "Player is not in timeout.", "error")
            end
        end)
    end
end

-- Register /timeout for admin
QBCore.Commands.Add("timeout", "Send player to timeout (box)", {
    {name="id", help="Player ID"},
    {name="time", help="Minutes (max " .. Config.MaxTimeoutMinutes .. ")"}
}, true, sendToTimeout, "admin")

-- Register /timeout for mod
QBCore.Commands.Add("timeout", "Send player to timeout (box)", {
    {name="id", help="Player ID"},
    {name="time", help="Minutes (max " .. Config.MaxTimeoutMinutes .. ")"}
}, true, sendToTimeout, "mod")

-- Register /release for admin
QBCore.Commands.Add("release", "Release player from timeout", {
    {name="id", help="Player ID"}
}, true, releaseFromTimeout, "admin")

-- Register /release for mod
QBCore.Commands.Add("release", "Release player from timeout", {
    {name="id", help="Player ID"}
}, true, releaseFromTimeout, "mod")

-- Check timeout status when a player loads in
RegisterNetEvent('qb-timeout:server:CheckTimeoutStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- First check memory cache by citizenid (more reliable than source)
    local endTime = timeoutList[citizenid]
    
    -- If not in memory, check database
    if not endTime then
        MySQL.Async.fetchScalar('SELECT timeout_end FROM player_timeout WHERE citizenid = ?', {citizenid}, function(result)
            if result and tonumber(result) > os.time() then
                local duration = tonumber(result) - os.time()
                -- Add to memory cache (both by source and citizenid)
                timeoutList[src] = tonumber(result)
                timeoutList[citizenid] = tonumber(result)
                TriggerClientEvent('qb-timeout:client:EnterTimeout', src, duration)
            end
        end)
    elseif os.time() < endTime then
        local duration = endTime - os.time()
        -- Update source in memory cache
        timeoutList[src] = endTime
        TriggerClientEvent('qb-timeout:client:EnterTimeout', src, duration)
    end
end)

-- Allow client to request release after timer expires
RegisterNetEvent('qb-timeout:server:ReleaseMe', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    if timeoutList[src] or timeoutList[citizenid] then
        -- Clear from memory
        timeoutList[src] = nil
        timeoutList[citizenid] = nil
        
        -- Clear from database
        removeTimeoutFromDatabase(citizenid)
        
        TriggerClientEvent('qb-timeout:client:ReleaseFromTimeout', src)
    end
end)

-- Handle player disconnection
AddEventHandler('playerDropped', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local citizenid = Player.PlayerData.citizenid
        
        if timeoutList[src] or timeoutList[citizenid] then
            -- Player is in timeout and disconnected
            -- We don't need to do anything as the timeout is already saved in the database
            -- Just remove source from memory cache (keep citizenid for faster lookups)
            timeoutList[src] = nil
            
            -- Log the disconnect attempt if you want
            print(Player.PlayerData.name .. " (CitizenID: " .. citizenid .. ") disconnected while in timeout")
        end
    end
end)
