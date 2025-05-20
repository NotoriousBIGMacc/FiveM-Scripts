# Racing Harness Script Fixes

The following issues were identified and fixed in the racing harness script:

## 1. Fixed Logical Error in validateClass Function

The original code used `or` operators which would always return true:
```lua
if class ~= 8 or class ~= 13 or class ~= 14 then return plate end
```

Changed to use `and` operators for correct logic:
```lua
if class ~= 8 and class ~= 13 and class ~= 14 then return plate end
```

## 2. Fixed hasHarness Function

The original function was returning `true` if a result existed, but it should return the actual harness value:
```lua
local function hasHarness(plate)
    -- code...
    local result = MySQL.scalar.await('SELECT harness FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return true
    end
end
```

Changed to return the actual result:
```lua
local function hasHarness(plate)
    -- code...
    local result = MySQL.scalar.await('SELECT harness FROM player_vehicles WHERE plate = ?', {plate})
    return result
end
```

## 3. Fixed NULL References in SQL Queries

Changed `NULL` (which is not valid in Lua) to `nil`:
```lua
MySQL.update('UPDATE player_vehicles set harness = ? WHERE plate = ?',{nil, plate})
```

## 4. Enhanced toggleBelt Event

Improved the toggleBelt event to properly handle harness data and create dummy data if needed:
```lua
RegisterNetEvent('brazzers-harness:server:toggleBelt', function(plate, ItemData)
    local src = source
    if not src then return end
    
    local hasHarnessInstalled = hasHarness(plate)
    if not hasHarnessInstalled then 
        return TriggerClientEvent('seatbelt:client:UseSeatbelt', src) 
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local harnessItem = Player.Functions.GetItemByName(Config.Harness)
    if harnessItem then
        TriggerClientEvent('seatbelt:client:UseHarness', src, harnessItem, false)
    else
        -- Create a dummy item data if player doesn't have the item but vehicle has harness installed
        local dummyItemData = {
            name = Config.Harness,
            info = {
                uses = 20
            }
        }
        TriggerClientEvent('seatbelt:client:UseHarness', src, dummyItemData, false)
    end
end)
```

## 5. Added Item Use Registration

Added the missing item use registration to the client.lua file:
```lua
QBCore.Functions.CreateUseableItem(Config.Harness, function(source, item)
    TriggerEvent('brazzers-harness:client:attachHarness', item)
end)
```

## 6. Added Missing Event Handlers

Added event handlers for 'equip:harness' and 'seatbelt:DoHarnessDamage' events:
```lua
-- Handle harness equip event
RegisterNetEvent('equip:harness', function(ItemData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Update item uses if needed
    if ItemData and ItemData.info and ItemData.info.uses then
        local uses = ItemData.info.uses - 1
        if uses <= 0 then
            Player.Functions.RemoveItem(ItemData.name, 1, ItemData.slot)
        else
            Player.Functions.SetItemInfo(ItemData.slot, 'uses', uses)
        end
    end
end)

-- Handle harness damage event
RegisterNetEvent('seatbelt:DoHarnessDamage', function(hp, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if data and data.slot then
        if hp <= 0 then
            Player.Functions.RemoveItem(Config.Harness, 1, data.slot)
        else
            Player.Functions.SetItemInfo(data.slot, 'uses', hp)
        end
    end
end)
```

## 7. Enhanced Database Schema

Updated the db.sql file to include proper SQL commands for adding the harness column and item:
```sql
-- Add harness column to player_vehicles table if it doesn't exist
ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS `harness` BOOLEAN NULL DEFAULT NULL;

-- Insert harness item into items table if using QBCore
INSERT INTO `items` (`name`, `label`, `weight`, `type`, `unique`, `useable`, `image`, `shouldClose`, `combinable`, `description`, `created`) 
VALUES ('harness', 'Racing Harness', 1, 'item', false, true, 'harness.png', true, NULL, 'Racing harness for improved safety during high-speed driving', NULL)
ON DUPLICATE KEY UPDATE `useable` = true, `description` = 'Racing harness for improved safety during high-speed driving';
```

## Installation Instructions

1. Run the SQL commands in `db.sql` to update your database
2. Make sure you have the harness.png image in your inventory images folder
3. Follow the instructions in the README.md file for integrating with qb-smallresources
4. Restart your server or resource

These fixes should resolve the issues with the racing harness script and make it fully functional.