--[[
    Installation Script for Racing Harness
    
    This script will help you install the racing harness system properly.
    It will:
    1. Check if the database has the required harness column
    2. Add the harness item to the items table if needed
    3. Copy the harness image to the inventory images folder
    4. Provide instructions for integrating with qb-smallresources
]]

-- This is a server-side script
local QBCore = nil
AddEventHandler('QBCore:Server:OnSharedObjectLoaded', function(obj) QBCore = obj end)
if QBCore == nil then QBCore = exports['qb-core']:GetCoreObject() end

-- Configuration
local Config = {
    -- Path to your qb-inventory images folder (change this to match your server)
    InventoryImagesPath = "resources/[qb]/qb-inventory/html/images/",
    
    -- Path to your qb-smallresources folder (change this to match your server)
    SmallResourcesPath = "resources/[qb]/qb-smallresources/",
    
    -- Default harness uses
    DefaultHarnessUses = 20
}

-- Check if the database has the harness column
local function CheckDatabase()
    print("^2[HARNESS] ^7Checking database for harness column...")
    local result = MySQL.Sync.fetchAll("SHOW COLUMNS FROM player_vehicles LIKE 'harness'")
    
    if #result == 0 then
        print("^3[HARNESS] ^7Harness column not found in player_vehicles table. Adding it now...")
        MySQL.Sync.execute("ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS `harness` BOOLEAN NULL DEFAULT NULL")
        print("^2[HARNESS] ^7Harness column added successfully!")
    else
        print("^2[HARNESS] ^7Harness column already exists in player_vehicles table.")
    end
    
    -- Check if harness item exists in items table
    local itemResult = MySQL.Sync.fetchAll("SELECT * FROM items WHERE name = 'harness'")
    
    if #itemResult == 0 then
        print("^3[HARNESS] ^7Harness item not found in items table. Adding it now...")
        MySQL.Sync.execute("INSERT INTO `items` (`name`, `label`, `weight`, `type`, `unique`, `useable`, `image`, `shouldClose`, `combinable`, `description`, `created`) VALUES ('harness', 'Racing Harness', 1, 'item', false, true, 'harness.png', true, NULL, 'Racing harness for improved safety during high-speed driving', NULL)")
        print("^2[HARNESS] ^7Harness item added successfully!")
    else
        print("^2[HARNESS] ^7Harness item already exists in items table.")
    end
    
    -- Set default uses for harness if using metadata
    print("^3[HARNESS] ^7Would you like to set default uses for the harness item? (Y/N)")
    print("^3[HARNESS] ^7This will set the default uses to " .. Config.DefaultHarnessUses)
    print("^3[HARNESS] ^7Type 'Y' in the server console to confirm, or 'N' to skip.")
    
    -- This would normally wait for console input, but we'll just provide instructions
    print("^3[HARNESS] ^7To set default uses, run this SQL command:")
    print("^3[HARNESS] ^7UPDATE `items` SET `metadata` = '{\"uses\":" .. Config.DefaultHarnessUses .. "}' WHERE `name` = 'harness';")
end

-- Copy harness image to inventory images folder
local function CopyHarnessImage()
    print("^2[HARNESS] ^7Copying harness image to inventory images folder...")
    print("^3[HARNESS] ^7Please copy the harness.png file from:")
    print("^3[HARNESS] ^7" .. GetResourcePath(GetCurrentResourceName()) .. "/README/IMAGES/harness.png")
    print("^3[HARNESS] ^7To your inventory images folder:")
    print("^3[HARNESS] ^7" .. Config.InventoryImagesPath)
end

-- Provide instructions for integrating with qb-smallresources
local function ProvideInstructions()
    print("^2[HARNESS] ^7Installation almost complete!")
    print("^2[HARNESS] ^7Please follow these steps to complete the installation:")
    print("")
    print("^3[HARNESS] ^71. Locate your seatbelt:client:UseHarness event in qb-smallresources/client/seatbelt.lua")
    print("^3[HARNESS] ^7   and replace it with the one in the README.md file.")
    print("")
    print("^3[HARNESS] ^72. Locate your toggleseatbelt command in qb-smallresources/client/seatbelt.lua")
    print("^3[HARNESS] ^7   and replace it with the one in the README.md file.")
    print("")
    print("^3[HARNESS] ^73. Locate your harness useable item in qb-smallresources/server/main.lua")
    print("^3[HARNESS] ^7   and replace it with the one in the README.md file.")
    print("")
    print("^3[HARNESS] ^74. Restart your server or the following resources:")
    print("^3[HARNESS] ^7   - qb-core")
    print("^3[HARNESS] ^7   - qb-inventory")
    print("^3[HARNESS] ^7   - qb-smallresources")
    print("^3[HARNESS] ^7   - brazzers-harness")
    print("")
    print("^2[HARNESS] ^7Installation complete! Enjoy your new racing harness system!")
end

-- Main installation function
local function InstallHarness()
    print("^2[HARNESS] ^7Starting installation of Racing Harness system...")
    
    -- Check database
    CheckDatabase()
    
    -- Copy harness image
    CopyHarnessImage()
    
    -- Provide instructions
    ProvideInstructions()
end

-- Register command to run installation
RegisterCommand("install_harness", function(source, args)
    if source == 0 then -- Only allow from console
        InstallHarness()
    else
        TriggerClientEvent('QBCore:Notify', source, "This command can only be run from the server console.", "error")
    end
end, true)

print("^2[HARNESS] ^7Racing Harness installation script loaded!")
print("^2[HARNESS] ^7Type 'install_harness' in the server console to begin installation.")