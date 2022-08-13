Ryan.Stats = {
    Type = {
        Global = 1,
        Character = 2
    },

    GetHash = function(stat_type, stat_name)
        local prefix = nil
        if stat_type == Ryan.Stats.Type.Global then prefix = "MPPLY"
        else prefix = "MP" .. Ryan.Stats.GetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Global, "LAST_MP_CHAR")) end
        return util.joaat(prefix .. "_" .. stat_name)
    end,

    GetInteger = function(key)
        local value = memory.alloc_int()
        STATS.STAT_GET_INT(key, value, -1)
        return memory.read_int(value)
    end,

    SetInteger = function(key, value)
        STATS.STAT_SET_INT(key, value, true)
    end,

    -- Specific Stats --
    SetOfficeMoney = function(command, click_type, amount)
        menu.show_warning(command, click_type, "Make sure you have at least 1 crate of Special Cargo to sell before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell that cargo.", function()
            Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_CONTRA_EARNINGS"), amount)
    
            Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BUY_COMPLETE"), 1000)
            Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_SELL_COMPLETE"), 1000)
            Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BUY_UNDERTAKEN"), 1000)
            Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BUY_UNDERTAKEN"), 1000)
    
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "CEO Office Money", "Done! Switch sessions and start a Special Cargo sale to apply your changes.")
        end)
    end,

    SetMCClutter = function(command, click_type, amount)
        menu.show_warning(command, click_type, "Make sure you have at least 1 unit of stock to sell, in every business, before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell all of those, one by one.", function()
            for i = 0, 5 do
                Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BKR_SELL_EARNINGS" .. i), amount)
    
                if i == 0 then i = "" end
                Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BIKER_BUY_COMPLET" .. i), 1000)
                Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BIKER_BUY_UNDERTA" .. i), 1000)
                Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BIKER_SELL_COMPLET" .. i), 1000)
                Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "LIFETIME_BIKER_SELL_UNDERTA" .. i), 1000)
            end
    
            Ryan.Basics.ShowTextMessage(Ryan.Globals.BackgroundColors.Purple, "M.C. Clubhouse Clutter", "Done! Switch sessions and start a sale in every business to apply changes.")
        end)
    end,

    GetKills = function()
        return Ryan.Stats.GetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Global, "KILLS_PLAYERS"))
    end,

    GetDeaths = function()
        return Ryan.Stats.GetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Global, "DEATHS_PLAYER"))
    end,

    SetKills = function(kills)
        Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Global, "KILLS_PLAYERS"), kills)
        Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "KILLS_PLAYERS"), kills)
    end,

    SetDeaths = function(deaths)
        Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Global, "DEATHS_PLAYER"), deaths)
        Ryan.Stats.SetInteger(Ryan.Stats.GetHash(Ryan.Stats.Type.Character, "DEATHS_PLAYER"), deaths)
    end
}