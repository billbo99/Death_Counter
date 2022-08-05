local Smarts = require("smarts")

script.on_init(Smarts.on_init)
script.on_configuration_changed(Smarts.on_configuration_changed)
script.on_event(defines.events.on_player_created, Smarts.on_player_created)
script.on_event(defines.events.on_player_joined_game, Smarts.on_player_joined_game)
script.on_event(defines.events.on_gui_click, Smarts.on_gui_click)
script.on_event(defines.events.on_player_died, Smarts.on_player_died)
