require("mod-gui")

local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")
local Gui = require("scripts.gui")

script.on_init(
    function()
        global_data.init()
        for i, _ in pairs(game.players) do
            player_data.init(i)
            Gui.CreateTopGui(game.players[i])
        end
    end
)

script.on_load(
    function()
    end
)

script.on_event(
    defines.events.on_player_created,
    function(e)
        player_data.init(e.player_index)
        Gui.CreateTopGui(game.players[e.player_index])
    end
)

script.on_event(
    defines.events.on_player_joined_game,
    function(e)
        Gui.DestroyGui(game.players[e.player_index])
        Gui.CreateTopGui(game.players[e.player_index])
    end
)

script.on_event(
    defines.events.on_gui_click,
    function(e)
        local mod = e.element.get_mod()
        if mod == nil or mod ~= "Death_Counter" then
            return
        end

        Gui.onGuiClick(e)
    end
)

script.on_event(
    defines.events.on_player_died,
    function(e)
        local PlayerName = game.get_player(e.player_index).name
        local player_table = global.players[PlayerName]

        Gui.DestroyGui(game.players[e.player_index])

        local cause = "Unknown"
        if e.cause then
            cause = e.cause.name
        end

        if cause == "character" then
            if e.cause.player and e.cause.player.name then
                if e.cause.player.name == PlayerName then
                    cause = "Suicide"
                else
                    cause = "player/" .. e.cause.player.name
                end
            end
        end

        if not player_table.DeathCount[cause] then
            player_table.DeathCount[cause] = 1
        else
            player_table.DeathCount[cause] = player_table.DeathCount[cause] + 1
        end

        if not global.causes[cause] then
            global.causes[cause] = 1
        else
            global.causes[cause] = global.causes[cause] + 1
        end
    end
)
