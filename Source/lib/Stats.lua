function stats_hash(stat_type, stat_name)
    local prefix = nil
    if stat_type == Stats.Global then prefix = "MPPLY"
    else prefix = "MP" .. stats_get_int(stats_hash(MPPLY, "LAST_MP_CHAR")) end
    return util.joaat(prefix .. "_" .. stat_name)
end

function stats_get_int(key)
    local value = memory.alloc_int()
    STATS.STAT_GET_INT(key, value, -1)
    return memory.read_int(value)
end

function stats_set_int(key, value)
    STATS.STAT_SET_INT(key, value, true)
end

function stats_set_office_money(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 crate of Special Cargo to sell before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell that cargo.", function()
        stats_set_int(stats_hash(Stats.Character, "LIFETIME_CONTRA_EARNINGS"), amount)

        stats_set_int(stats_hash(Stats.Character, "LIFETIME_BUY_COMPLETE"), 1000)
        stats_set_int(stats_hash(Stats.Character, "LIFETIME_SELL_COMPLETE"), 1000)
        stats_set_int(stats_hash(Stats.Character, "LIFETIME_BUY_UNDERTAKEN"), 1000)
        stats_set_int(stats_hash(Stats.Character, "LIFETIME_BUY_UNDERTAKEN"), 1000)

        basics_show_text_message(Color.Purple, "CEO Office Money", "Done! Switch sessions and start a Special Cargo sale to apply your changes.")
    end)
end

function stats_set_mc_clutter(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 unit of stock to sell, in every business, before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell all of those, one by one.", function()
        for i=0, 5 do
            stats_set_int(stats_hash(Stats.Character, "LIFETIME_BKR_SELL_EARNINGS" .. i), amount)

            if i == 0 then i = "" end
            stats_set_int(stats_hash(Stats.Character, "LIFETIME_BIKER_BUY_COMPLET" .. i), 1000)
            stats_set_int(stats_hash(Stats.Character, "LIFETIME_BIKER_BUY_UNDERTA" .. i), 1000)
            stats_set_int(stats_hash(Stats.Character, "LIFETIME_BIKER_SELL_COMPLET" .. i), 1000)
            stats_set_int(stats_hash(Stats.Character, "LIFETIME_BIKER_SELL_UNDERTA" .. i), 1000)
        end

        basics_show_text_message(Color.Purple, "M.C. Clubhouse Clutter", "Done! Switch sessions and start a sale in every business to apply changes.")
    end)
end

function stats_get_kills()
    return stats_get_int(stats_hash(Stats.Global, "KILLS_PLAYERS"))
end

function stats_set_kills(kills)
    stats_set_int(stats_hash(Stats.Global, "KILLS_PLAYERS"), kills)
    stats_set_int(stats_hash(Stats.Character, "KILLS_PLAYERS"), kills)
end

function stats_get_deaths()
    return stats_get_int(stats_hash(Stats.Global, "DEATHS_PLAYER"))
end

function stats_set_deaths(deaths)
    stats_set_int(stats_hash(Stats.Global, "DEATHS_PLAYER"), deaths)
    stats_set_int(stats_hash(Stats.Character, "DEATHS_PLAYER"), deaths)
end