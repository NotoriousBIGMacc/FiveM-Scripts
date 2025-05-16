# QB-Timeout

A FiveM resource for QBCore servers that sends temporarily banned players to a timeout area instead of completely disconnecting them from the server. This allows administrators to temporarily restrict players while still keeping them on the server.

## Features

- Sends players with temporary bans to a designated timeout area
- Persists timeout status across player reconnects using database storage
- Admin commands to manually send/release players from timeout
- Prevents players from leaving the timeout area
- Automatically releases players when their timeout expires
- Disables combat actions, weapons, and most controls while in timeout
- Compatible with QBCore permission system (admin/mod)

## Dependencies

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Set up the database (see Database Setup section below)
4. Add `ensure qb-timeout` to your server.cfg
5. Configure the timeout and release areas in config.lua
6. Restart your server

## Database Setup

The resource will automatically create the necessary database table when it starts. However, you can also manually set up the database using one of these methods:

### Method 1: Using the SQL File

1. Locate the `database.sql` file in the resource folder
2. Execute the SQL script in your database management tool (phpMyAdmin, HeidiSQL, etc.)

### Method 2: Using the Console Command

1. Start your server with the resource installed
2. In the server console, type: `install_timeout`
3. The script will create the necessary database table

### Database Structure

The resource creates a `player_timeout` table with the following structure:

```sql
CREATE TABLE IF NOT EXISTS `player_timeout` (
  `citizenid` VARCHAR(50) PRIMARY KEY,
  `timeout_end` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_timeout_end ON player_timeout(timeout_end);
```

## Configuration

The `config.lua` file contains all configurable options:

### Timeout and Release Areas

Set the coordinates where players will be sent during timeout and where they'll be released afterward:

```lua
-- Timeout area (where banned players are sent)
Config.TimeoutArea = vector4(1639.46, 2527.04, 45.56, 165) -- Change to your desired location

-- Release area (where players are sent after timeout)
Config.ReleaseArea = vector4(1857.22, 2596.12, 45.67, 269) -- Change to your desired location
```

### Maximum Timeout Duration

Set the maximum timeout duration in minutes:

```lua
-- Maximum timeout in minutes
Config.MaxTimeoutMinutes = 2880 -- 48 hours
```

### Notification Messages

Customize the notification messages:

```lua
Config.Notifications = {
    Sent = "You have been sent to timeout.",
    Released = "You have been released from timeout.",
    Reconnected = "You cannot escape timeout by disconnecting. Your timeout continues."
}
```

## Admin Commands

The following admin commands are available to staff with admin or mod permissions:

### Send a Player to Timeout

```
/timeout [playerID] [minutes]
```

Example: `/timeout 3 60` - Sends player with ID 3 to timeout for 60 minutes

### Release a Player from Timeout

```
/release [playerID]
```

Example: `/release 3` - Releases player with ID 3 from timeout

## How It Works

1. When a player is sent to timeout, their CitizenID and timeout end time are stored in the database
2. The player is teleported to the timeout area and has most controls disabled
3. If the player disconnects and reconnects, they will be sent back to timeout until their time expires
4. When the timeout expires or an admin releases them, they are teleported to the release area

## Troubleshooting

### Player Not Being Sent to Timeout
- Ensure the player has a valid CitizenID
- Check server console for any error messages
- Verify database connection is working properly

### Database Issues
- Make sure oxmysql is properly installed and working
- Check if the player_timeout table exists in your database
- Try running the `install_timeout` command from the server console

### Timeout Area Problems
- Ensure the coordinates in config.lua are valid and accessible
- Make sure the area is properly set up (not inside objects, etc.)
- Test the coordinates by teleporting there manually

## License

This resource is licensed under the MIT License.