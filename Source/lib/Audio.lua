function audio_play_from_entity(entity, sound_group, sound_name)
    AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound_name, entity, sound_group, true, true)
end

function audio_play_at_coords(coords, sound_group, sound_name, range)
    AUDIO.PLAY_SOUND_FROM_COORD(-1, sound_name, coords.x, coords.y, coords.z, sound_group, true, range, true)
end

function audio_play_on_all_players(sound_group, sound_name)
    for _, player_id in pairs(players.list()) do
        audio_play_from_entity(player_get_ped(player_id), sound_group, sound_name)
    end
end