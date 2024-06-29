Config = Config or {}

Config.Debug = false

Config.RecyclingCenters = {
    {
        name = "Main Recycling Center",
        blip = {
            sprite = 365,
            color = 2,
            scale = 0.8,
        },
        ped = {
            model = "s_m_y_garbage",
            coords = vector4(746.82, -1400.21, 26.57, 248.0),
        },
        dropoff = vector3(746.82, -1400.21, 26.57),
    },
    -- Add more recycling centers here
}

Config.RecyclableItems = {
    ["bottle"] = {
        label = "Glass Bottle",
        reward = {
            item = "recycled_glass",
            amount = {min = 1, max = 3}
        }
    },
    ["can"] = {
        label = "Aluminum Can",
        reward = {
            item = "recycled_metal",
            amount = {min = 1, max = 2}
        }
    },
    ["paper"] = {
        label = "Paper",
        reward = {
            item = "recycled_paper",
            amount = {min = 1, max = 4}
        }
    },
    ["plastic"] = {
        label = "Plastic",
        reward = {
            item = "recycled_plastic",
            amount = {min = 1, max = 3}
        }
    },
}

Config.ProcessingTime = 5000 -- milliseconds

Config.RecycledItems = {
    ["recycled_glass"] = {
        label = "Recycled Glass",
        price = {min = 40, max = 60}
    },
    ["recycled_metal"] = {
        label = "Recycled Metal",
        price = {min = 65, max = 85}
    },
    ["recycled_paper"] = {
        label = "Recycled Paper",
        price = {min = 30, max = 50}
    },
    ["recycled_plastic"] = {
        label = "Recycled Plastic",
        price = {min = 50, max = 70}
    },
}

Config.RecyclingTruck = {
    model = "trash",
    spawnLocation = vector4(742.09, -1398.73, 26.55, 248.0),
}

Config.RecyclingRoutes = {
    {
        name = "Downtown Route",
        waypoints = {
            vector3(233.07, -802.24, 30.56),
            vector3(-255.13, -983.14, 31.22),
            vector3(-590.32, -892.51, 25.93),
            -- Add more waypoints
        }
    },
    -- Add more routes
}

Config.ExperienceSystem = {
    enabled = true,
    levels = {
        [1] = {exp = 0, bonus = 1.0},
        [2] = {exp = 1000, bonus = 1.1},
        [3] = {exp = 2500, bonus = 1.2},
        [4] = {exp = 5000, bonus = 1.3},
        [5] = {exp = 10000, bonus = 1.5},
    }
}

-- discord
-- Discord Webhook
Config.DiscordWebhook = {
    enabled = true,
    url = "YOUR_DISCORD_WEBHOOK_URL_HERE",
}
