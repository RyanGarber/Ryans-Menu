function stats_get_hash(key, character_specific)
    if not character_specific then return MISC.GET_HASH_KEY(key) end
    local character = STATS.STAT_GET_INT(MISC.GET_HASH_KEY("MPPLY_LAST_MP_CHAR"))
    return MISC.GET_HASH_KEY("MP" .. character .. "_" .. key)
end

function stats_set_office_money(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 crate of Special Cargo to sell before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell that cargo.", function()
        STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BUY_COMPLETE", true), 1000, true)
        STATS.STAT_SET_INT(stats_get_hash("LIFETIME_SELL_COMPLETE", true), 1000, true)
        STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BUY_UNDERTAKEN", true), 1000, true)
        STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BUY_UNDERTAKEN", true), 1000, true)
        STATS.STAT_SET_INT(stats_get_hash("LIFETIME_CONTRA_EARNINGS", true), amount, true)

        basics_show_text_message(Colors.Purple, "CEO Office Money", "Done! Switch sessions and start a Special Cargo sale to apply your changes.")
    end)
end

function stats_set_mc_clutter(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 unit of stock to sell, in every business, before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell all of those, one by one.", function()
        for i=0, 5 do
            STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BKR_SELL_EARNINGS" .. i), amount, true)
            if i == 0 then i = "" end
            STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BIKER_BUY_COMPLET" .. i, true), 1000, true)
            STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BIKER_BUY_UNDERTA" .. i, true), 1000, true)
            STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BIKER_SELL_COMPLET" .. i, true), 1000, true)
            STATS.STAT_SET_INT(stats_get_hash("LIFETIME_BIKER_SELL_UNDERTA" .. i, true), 1000, true)
        end

        basics_show_text_message(Colors.Purple, "M.C. Clubhouse Clutter", "Done! Switch sessions and start a sale in every business to apply changes.")
    end)
end

function stats_get_kills()
    kills = memory.alloc_int()
    STATS.STAT_GET_INT(stats_get_hash("MPPLY_KILLS_PLAYERS", false), kills, -1)
    return memory.read_int(kills)
end
function stats_set_kills(kills)
    STATS.STAT_SET_INT(stats_get_hash("MPPLY_KILLS_PLAYERS", false), kills, true)
end

function stats_get_deaths()
    deaths = memory.alloc_int()
    STATS.STAT_GET_INT(stats_get_hash("MPPLY_DEATHS_PLAYER", false), deaths, -1)
    return memory.read_int(deaths)
end
function stats_set_deaths(deaths)
    STATS.STAT_SET_INT(stats_get_hash("MPPLY_DEATHS_PLAYER", false), deaths, true)
end