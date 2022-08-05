local player_data = require("scripts.player-data")
local Gui = require("scripts.gui")

---@class Smarts
local Smarts = {}

function Smarts.init_glolbal()
    global.players = global.players or {}
    global.causes = global.causes or {}

    if game.active_mods["space-exploration"] then
        local respawned_event = remote.call("space-exploration", "get_on_player_respawned_event")
        script.on_event(respawned_event, Smarts.on_player_died)
    end
end

function Smarts.on_configuration_changed()
    Smarts.init_glolbal()
end

function Smarts.on_init()
    Smarts.init_glolbal()

    for i, _ in pairs(game.players) do
        player_data.init(i)
        Gui.CreateTopGui(game.players[i])
    end
end

function Smarts.on_player_created(e)
    player_data.init(e.player_index)
    Gui.CreateTopGui(game.players[e.player_index])
end

function Smarts.on_player_joined_game(e)
    Gui.DestroyGui(game.players[e.player_index])
    Gui.CreateTopGui(game.players[e.player_index])
end

function Smarts.on_gui_click(e)
    local mod = e.element.get_mod()
    if mod == nil or mod ~= "Death_Counter" then
        return
    end

    Gui.onGuiClick(e)
end

function Smarts.on_player_died(e)
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

    if (settings.global["DeathCounter_Summary"] and settings.global["DeathCounter_Summary"].value) or (settings.global["DeathCounter_PerPlayer"] and settings.global["DeathCounter_PerPlayer"].value) then
        local _summary = {}
        for _player, data in pairs(global.players) do
            local _total = 0
            if data.DeathCount then
                for _cause, _count in pairs(data.DeathCount) do
                    _total = _total + _count
                end
            end
            _summary[_player] = _total
        end

        local _keys = {}
        for k, _ in pairs(_summary) do table.insert(_keys, k) end
        table.sort(_keys)

        local _target = e.player_index -- player location
        if game.is_multiplayer() then
            _target = 0 -- server location
        end

        if settings.global["DeathCounter_Summary"] and settings.global["DeathCounter_Summary"].value then
            game.write_file("DeathCounter_kill_summary.csv", "player,count\n", false, _target)
        end
        for _, k in ipairs(_keys) do
            if settings.global["DeathCounter_Summary"] and settings.global["DeathCounter_Summary"].value then
                game.write_file("DeathCounter_kill_summary.csv", k .. "," .. _summary[k] .. "\n", true, _target)
            end
            if settings.global["DeathCounter_PerPlayer"] and settings.global["DeathCounter_PerPlayer"].value then
                game.write_file(k .. ".csv", _summary[k] .. "\n", false, _target)
            end
        end
    end
end

function Smarts.space_exploration_respawn(e)
    print(serpent.block(e))
end

return Smarts
