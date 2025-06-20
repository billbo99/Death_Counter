local player_data = {}

function player_data.init(player_index)
    local player_name = game.get_player(player_index).name
    if not storage.players[player_name] then
        storage.players[player_name] = { DeathCount = {} }
    else
        if not storage.players[player_name].DeathCount then
            storage.players[player_name].DeathCount = {}
        end
    end
end

return player_data
