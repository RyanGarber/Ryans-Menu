Ryan.Audio = {}

-- Play a sound locally in 2D.
Ryan.Audio.Play = function(sound_group, sound_name)
    AUDIO.PLAY_SOUND_FRONTEND(-1, sound_name, sound_group)
end

-- Play a sound coming from an entity in 3D.
Ryan.Audio.PlayFromEntity = function(entity, sound_group, sound_name)
    AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound_name, entity, sound_group, true, true)
end

-- Play a sound coming from a position in 3D.
Ryan.Audio.PlayAtCoords = function(coords, sound_group, sound_name, range)
    AUDIO.PLAY_SOUND_FROM_COORD(-1, sound_name, coords.x, coords.y, coords.z, sound_group, true, range, true)
end

-- Play a sound on all players at once.
Ryan.Audio.PlayOnAllPlayers = function(sound_group, sound_name)
    for _, player_id in pairs(players.list()) do
        Ryan.Audio.PlayFromEntity(Ryan.Player.Get(player_id).ped_id, sound_group, sound_name)
    end
end

-- Play the button-press sound effect.
Ryan.Audio.SelectSound = function()
    Ryan.Audio.Play("HUD_FRONTEND_MP_SOUNDSET", "SELECT")
end

-- Play the button-press sound effect when a value changes.
Ryan.Audio.SelectSoundToggle = function(value, state, key)
    if value[key] == true and state[key] ~= true then
        Ryan.Audio.SelectSound()
        state[key] = true
    elseif value[key] ~= true and state[key] == true then
        Ryan.Audio.SelectSound()
        state[key] = nil
    end
end