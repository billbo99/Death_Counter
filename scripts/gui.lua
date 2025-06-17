local Utils = require("scripts.utils")

local mod_gui = require("mod-gui")
local Gui = {}

function Gui.DestroyGui(player)
    local gui_top = player.gui.top["DeathCounterIcon"]
    local gui_main = player.gui.left["DeathCounterMain"]

    if gui_top ~= nil then
        gui_top.destroy()
    end
    if gui_main ~= nil then
        gui_main.destroy()
    end
end

function Gui.CreateTopGui(player)
    local button_flow = mod_gui.get_button_flow(player)
    local button = button_flow.DeathCounterMainButton
    if not button then
        button =
            button_flow.add {
                type = "sprite-button",
                name = "DeathCounterMainButton",
                sprite = "DeathCounter",
                style = mod_gui.button_style
            }
    end
    return button
end

function Gui.OnGuiClosed(e)
    if not e.element then return end
    if e.element and e.element.get_mod() ~= "Death_Counter" then return end
    local player = game.get_player(e.player_index)
    player.opened = nil
    player.gui.left["DeathCounterMain"].destroy()
end

function Gui.CreateMainGui(player)
    if player.gui.left["DeathCounterMain"] then
        player.gui.left["DeathCounterMain"].destroy()
        player.opened = nil
    end

    if storage.causes and Utils.TableSize(storage.causes) > 0 then
        local DeathCounterMain = player.gui.left.add({ type = "frame", name = "DeathCounterMain", direction = "vertical" })
        player.opened = DeathCounterMain
        DeathCounterMain.style.minimal_height = 10
        DeathCounterMain.style.minimal_width = 10

        DeathCounterMain.add({ type = "label", caption = "Death Counter", style = "frame_title" })

        local headers = Utils.sortedKeys(storage.causes)
        local column_count = 2 + #headers
        local f = DeathCounterMain.add({ type = "table", style = "bordered_table", column_count = column_count })

        f.add({ type = "label", caption = "Player", style = "bold_label" })
        f.add({ type = "label", caption = "Total", style = "bold_label" })
        for _, header in pairs(headers) do
            if header == "Suicide" then
                f.add({ type = "label", caption = "Suicide" })
            elseif header == "Unknown" then
                f.add({ type = "label", caption = "Unknown" })
            elseif Utils.starts_with(header, "player") then
                local killer = Utils.split(header, "/")[2]
                f.add({ type = "sprite", sprite = "entity.character", tooltip = killer })
            else
                if helpers.is_valid_sprite_path(string.format("entity.%s", header)) then
                    f.add({ type = "sprite", sprite = string.format("entity.%s", header), tooltip = { "entity-name." .. header } })
                else
                    f.add({ type = "sprite", sprite = "utility.questionmark", tooltip = header })
                end
            end
        end

        local death_counts = {}
        for player_name, _ in pairs(storage.players) do
            if not death_counts[player_name] then
                death_counts[player_name] = 0
            end
            for cause, _ in pairs(storage.players[player_name].DeathCount) do
                death_counts[player_name] = death_counts[player_name] + storage.players[player_name].DeathCount[cause]
            end
        end

        local rank = Utils.sortedKeys(death_counts)
        for _, player_name in pairs(rank) do
            f.add({ type = "label", caption = player_name })
            f.add({ type = "label", caption = death_counts[player_name] })
            for _, header in pairs(headers) do
                if storage.players[player_name]["DeathCount"][header] then
                    f.add({ type = "label", caption = storage.players[player_name]["DeathCount"][header] })
                else
                    f.add({ type = "label", caption = "" })
                end
            end
        end
    end
end

function Gui.onGuiClick(event)
    local player = game.players[event.player_index]
    local element = event.element.name

    if element == "DeathCounterMainButton" then
        if player.gui.left["DeathCounterMain"] then
            player.gui.left["DeathCounterMain"].destroy()
        else
            Gui.CreateMainGui(player)
        end
    end
end

return Gui
