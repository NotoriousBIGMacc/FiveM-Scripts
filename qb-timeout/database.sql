-- qb-timeout database setup
-- Run this script to create the necessary table for the timeout system

CREATE TABLE IF NOT EXISTS `player_timeout` (
  `citizenid` VARCHAR(50) PRIMARY KEY,
  `timeout_end` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_timeout_end ON player_timeout(timeout_end);

-- Example query to view active timeouts
-- SELECT * FROM player_timeout WHERE timeout_end > UNIX_TIMESTAMP();

-- Example query to clear all timeouts (use with caution)
-- DELETE FROM player_timeout;