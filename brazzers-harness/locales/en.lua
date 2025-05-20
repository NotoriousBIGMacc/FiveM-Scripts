local Translations = {
    error = {
        not_in_vehicle = 'You must be in a vehicle to install a harness',
        wrong_class = 'You cannot install a harness in this type of vehicle',
        canceled_installation = 'Canceled installation',
        already_installed = 'You already have a harness installed',
        no_harness = 'This vehicle doesn\'t even have a harness',
        not_owned = 'You can only install a harness in a vehicle you own',
        no_permission = 'You do not have permission to use this command',
    },
    success = {
        installed = 'Racing harness installed successfully',
        uninstalled = 'Racing harness removed successfully',
        harness_received = 'You received a racing harness',
        harness_toggled = 'Racing harness toggled',
    },
    info = {
        installing = 'Installing racing harness...',
        uninstalling = 'Removing racing harness...',
        debug_enabled = 'Harness debug mode enabled',
        debug_disabled = 'Harness debug mode disabled',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
