local Translations = {
    error = {
        not_enough_items = "You don't have enough items to recycle",
        not_enough_materials = "You don't have enough materials to sell",
    },
    success = {
        items_recycled = "You recycled %{amount} %{item} and received %{reward} %{rewardItem}",
        materials_sold = "You sold %{amount} %{item} for $%{price}",
        route_completed = "Route completed! You earned $%{reward}",
    },
    info = {
        recycling_center = "Recycling Center",
        recycling_items = "Recycling items...",
        selling_materials = "Selling materials...",
    },
    menu = {
        recycle_items = "Recycle Items",
        sell_recycled = "Sell Recycled Materials",
        check_experience = "Check Experience",
        start_route = "Start Recycling Route",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
