Ryan.Audio = {
    PlayFromEntity = function(entity, sound_group, sound_name)
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound_name, entity, sound_group, true, true)
    end,

    PlayAtCoords = function(coords, sound_group, sound_name, range)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, sound_name, coords.x, coords.y, coords.z, sound_group, true, range, true)
    end,
    
    PlayOnAllPlayers = function(sound_group, sound_name)
        for _, player_id in pairs(players.list()) do
            Ryan.Audio.PlayFromEntity(Ryan.Player.Get(player_id).ped_id, sound_group, sound_name)
        end
    end
}