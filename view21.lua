

function on_shot_registered(shot)
    if shot.manual then return end
    local p = entities.get_entity(shot.target)
    local n = p:get_player_info()
    print(string.format("Fired at: %s | HC: %i | ED: %i | AD: %i | Result: %s | BT: %i | SP: %s | Roll SP: %s | Mismatched: %s",
    n.name, shot.hitchance, shot.client_damage, shot.server_damage, shot.result, shot.backtrack, shot.secure, shot.very_secure, shot.client_hitgroup ~= shot.server_hitgroup))

end