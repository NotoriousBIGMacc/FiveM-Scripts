Config = {}

-- Timeout area (where banned players are sent)
Config.TimeoutArea = vector4(1639.46, 2527.04, 45.56, 165) -- Example coords

-- Release area (where players are sent after timeout)
Config.ReleaseArea = vector4(1857.22, 2596.12, 45.67, 269) -- Example coords

-- Maximum timeout in minutes (change as needed)
Config.MaxTimeoutMinutes = 2880 -- 48 hours

Config.Notifications = {
    Sent = "You have been sent to timeout.",
    Released = "You have been released from timeout.",
    Reconnected = "You cannot escape timeout by disconnecting. Your timeout continues."
}
