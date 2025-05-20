# Racing Harness Troubleshooting Guide

If you're experiencing issues with the racing harness system, this guide will help you diagnose and fix common problems.

## Common Issues and Solutions

### 1. Harness Item Not Working

**Symptoms:**
- Using the harness item does nothing
- No notification appears when using the harness

**Possible Causes:**
- Item is not properly registered as usable
- Event handlers are not properly set up

**Solutions:**
1. Check if the harness item is properly registered in your items table:
   ```sql
   SELECT * FROM items WHERE name = 'harness';
   ```

2. Make sure the item is set as usable (useable = 1)
   ```sql
   UPDATE items SET useable = 1 WHERE name = 'harness';
   ```

3. Verify that the item use event is properly registered in qb-smallresources/server/main.lua:
   ```lua
   QBCore.Functions.CreateUseableItem("harness", function(source, item)
       TriggerClientEvent('brazzers-harness:client:attachHarness', source, item)
   end)
   ```

### 2. Cannot Install Harness in Vehicle

**Symptoms:**
- You get an error message when trying to install the harness
- The installation progress bar appears but nothing happens afterward

**Possible Causes:**
- Vehicle class check is failing
- Database column is missing or has the wrong type
- Vehicle is not owned by a player

**Solutions:**
1. Check if the vehicle is owned by a player (must be in player_vehicles table)

2. Verify that the harness column exists in your player_vehicles table:
   ```sql
   SHOW COLUMNS FROM player_vehicles LIKE 'harness';
   ```

3. If the column doesn't exist, add it:
   ```sql
   ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS `harness` BOOLEAN NULL DEFAULT NULL;
   ```

4. Check the vehicle class - harnesses can only be installed in regular vehicles (not motorcycles, bicycles, or boats)

### 3. Harness Not Working After Installation

**Symptoms:**
- Harness is installed but doesn't provide protection
- Pressing the seatbelt key (B) doesn't activate the harness

**Possible Causes:**
- Integration with qb-smallresources is not complete
- Event handlers are not properly set up

**Solutions:**
1. Make sure you've replaced the toggleseatbelt command in qb-smallresources/client/seatbelt.lua:
   ```lua
   RegisterCommand('toggleseatbelt', function()
       if not IsPedInAnyVehicle(PlayerPedId(), false) or IsPauseMenuActive() then return end
       local class = GetVehicleClass(GetVehiclePedIsUsing(PlayerPedId()))
       if class == 8 or class == 13 or class == 14 then return end
       local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
       local plate = QBCore.Functions.GetPlate(vehicle)

       TriggerServerEvent('brazzers-harness:server:toggleBelt', plate)
   end, false)

   RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')
   ```

2. Make sure you've replaced the seatbelt:client:UseHarness event in qb-smallresources/client/seatbelt.lua:
   ```lua
   RegisterNetEvent('seatbelt:client:UseHarness', function(ItemData, updateInfo) -- On Item Use (registered server side)
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
                   ToggleHarness()
                   if updateInfo then TriggerServerEvent('equip:harness', ItemData) end
               end)
               if updateInfo then
                   harnessHp = ItemData.info.uses
                   harnessData = ItemData
                   TriggerEvent('hud:client:UpdateHarness', harnessHp)
               end
           else
               harnessOn = false
               ToggleSeatbelt()
           end
       else
           QBCore.Functions.Notify('You\'re not in a car.', 'error')
       end
   end)
   ```

3. Restart both qb-smallresources and brazzers-harness resources

### 4. Database Errors

**Symptoms:**
- Server console shows SQL errors
- Harness functionality is inconsistent

**Possible Causes:**
- Database schema is incorrect
- SQL queries are failing

**Solutions:**
1. Check for SQL errors in your server console

2. Verify that your database has the correct schema:
   ```sql
   SHOW COLUMNS FROM player_vehicles;
   ```

3. Make sure the harness column is of type BOOLEAN or TINYINT(1):
   ```sql
   ALTER TABLE player_vehicles MODIFY COLUMN harness BOOLEAN NULL DEFAULT NULL;
   ```

### 5. Debug Mode

If you're still having issues, you can use the built-in debug commands to help diagnose problems:

1. `/harness_debug` - Toggle debug mode to see information about the current vehicle and harness status
2. `/give_harness` - Give yourself a harness item (admin only)
3. `/force_harness` - Force install a harness on the current vehicle (admin only)

## Still Having Issues?

If you're still experiencing problems after trying these solutions, please:

1. Check your server console for any error messages
2. Verify that all required resources are running
3. Make sure you've followed all installation steps in the README.md file
4. Try reinstalling the resource from scratch

For additional support, join the Brazzers Development Discord: https://discord.gg/J7EH9f9Bp3