-- QB-Timeout Installation Script
-- This script will create the necessary database table for the timeout system

local QBCore = exports['qb-core']:GetCoreObject()

-- Ensure this only runs on the server
if not IsDuplicityVersion() then return end

-- Print header
print('^2=======================================================^7')
print('^2QB-Timeout - Database Installation^7')
print('^2=======================================================^7')

-- Create the database table
MySQL.ready(function()
    print('^3Creating database table...^7')
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `player_timeout` (
          `citizenid` VARCHAR(50) PRIMARY KEY,
          `timeout_end` INT NOT NULL,
          `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        
        CREATE INDEX IF NOT EXISTS idx_timeout_end ON player_timeout(timeout_end);
    ]], {}, function(rowsChanged)
        print('^2Database table created successfully!^7')
        print('^3You can now use the timeout system.^7')
        
        -- Check if there are any existing timeouts
        MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM player_timeout WHERE timeout_end > ?', {os.time()}, function(result)
            if result and result[1] and result[1].count > 0 then
                print('^3Found ' .. result[1].count .. ' active timeouts in the database.^7')
            else
                print('^3No active timeouts found in the database.^7')
            end
            
            print('^2=======================================================^7')
            print('^2Installation complete! You can now restart your server.^7')
            print('^2=======================================================^7')
        end)
    end)
end)

-- Add a command to run the installation manually
RegisterCommand('install_timeout', function(source, args)
    if source == 0 then -- Only allow from console
        print('^3Running installation script...^7')
        TriggerEvent('qb-timeout:server:InstallDatabase')
    end
end, true)

-- Register an event to trigger the installation
RegisterNetEvent('qb-timeout:server:InstallDatabase', function()
    MySQL.ready(function()
        print('^3Creating database table...^7')
        
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS `player_timeout` (
              `citizenid` VARCHAR(50) PRIMARY KEY,
              `timeout_end` INT NOT NULL,
              `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            
            CREATE INDEX IF NOT EXISTS idx_timeout_end ON player_timeout(timeout_end);
        ]], {}, function(rowsChanged)
            print('^2Database table created successfully!^7')
        end)
    end)
end)

-- Run the installation when the resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Trigger the installation
    TriggerEvent('qb-timeout:server:InstallDatabase')
end)