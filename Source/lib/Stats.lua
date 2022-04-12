function stats_set_office_money(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 crate of Special Cargo to sell before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell that cargo.", function()
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_COMPLETE"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_SELL_COMPLETE"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_UNDERTAKEN"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BUY_UNDERTAKEN"), 1000, true)
        STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_CONTRA_EARNINGS"), amount, true)

        basics_show_text_message(Colors.Purple, "CEO Office Money", "Done! Switch sessions and start a Special Cargo sale to apply your changes.")
    end)
end

function stats_set_mc_clutter(command, click_type, amount)
    menu.show_warning(command, click_type, "Make sure you have at least 1 unit of stock to sell, in every business, before proceeding.\n\nIf you do, press Proceed, then switch sessions and sell all of those, one by one.", function()
        for i=0, 5 do
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("LIFETIME_BKR_SELL_EARNINGS" .. i), amount, true)
            if i == 0 then i = "" end
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_BUY_COMPLET" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_BUY_UNDERTA" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_SELL_COMPLET" .. i), 1000, true)
            STATS.STAT_SET_INT(MISC.GET_HASH_KEY("MP0_LIFETIME_BIKER_SELL_UNDERTA" .. i), 1000, true)
        end

        basics_show_text_message(Colors.Purple, "M.C. Clubhouse Clutter", "Done! Switch sessions and start a sale in every business to apply changes.")
    end)
end