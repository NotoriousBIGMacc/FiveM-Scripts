-- Add harness column to player_vehicles table if it doesn't exist
ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS `harness` BOOLEAN NULL DEFAULT NULL;

-- Insert harness item into items table if using QBCore
INSERT INTO `items` (`name`, `label`, `weight`, `type`, `unique`, `useable`, `image`, `shouldClose`, `combinable`, `description`, `created`) 
VALUES ('harness', 'Racing Harness', 1, 'item', false, true, 'harness.png', true, NULL, 'Racing harness for improved safety during high-speed driving', NULL)
ON DUPLICATE KEY UPDATE `useable` = true, `description` = 'Racing harness for improved safety during high-speed driving';

-- If you're using qb-inventory with metadata, you can add this to set default uses
-- This is optional and depends on your inventory system
-- UPDATE `items` SET `metadata` = '{"uses":20}' WHERE `name` = 'harness';