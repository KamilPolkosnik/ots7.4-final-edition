Crafting.alchemist = {
    -- Rings (enabled only).
    {
        id = 2357,
        name = "ring of the unforgiving master",
        alchemyType = "rings",
        level = 90,
        cost = 1500000,
        count = 1,
        materials = {
            {id = 2209, count = 25}, -- club ring
            {id = 2207, count = 25}, -- sword ring
            {id = 2208, count = 25}, -- axe ring
            {id = 7954, count = 25}, -- distance ring
            {id = 2123, count = 1}, -- ring of the sky
            {id = 1986, count = 10} -- red tome
        }
    },
    {
        id = 7089,
        name = "regeneration ring",
        alchemyType = "rings",
        level = 58,
        cost = 1500000,
        count = 1,
        materials = {
            {id = 2168, count = 50}, -- life ring
            {id = 2214, count = 25}, -- ring of healing
            {id = 2123, count = 1}, -- ring of the sky
            {id = 2074, count = 10}, -- panpipes
            {id = 2804, count = 10} -- shadow herb
        }
    },
    {
        id = 7088,
        name = "regeneration amulet",
        alchemyType = "rings",
        level = 62,
        cost = 1500000,
        count = 1,
        materials = {
            {id = 2171, count = 10}, -- platinum amulet
            {id = 2661, count = 25}, -- scarf
            {id = 1986, count = 10}, -- red tome
            {id = 1948, count = 10}, -- parchment
            {id = 2151, count = 10}, -- talon
            {id = 2159, count = 10} -- scarab coin
        }
    },

    -- Ammunition.
    {
        id = 2545,
        name = "poison arrow",
        alchemyType = "ammunition",
        level = 20,
        cost = 0,
        count = 1,
        materials = {
            {id = 2544, count = 2} -- arrow
        }
    },
    {
        id = 2546,
        name = "burst arrow",
        alchemyType = "ammunition",
        level = 35,
        cost = 0,
        count = 10,
        materials = {
            {id = 2544, count = 10}, -- arrow
            {id = 2301, count = 1} -- fire field rune
        }
    },
    {
        id = 2547,
        name = "power bolt",
        alchemyType = "ammunition",
        level = 45,
        cost = 0,
        count = 1,
        materials = {
            {id = 2543, count = 28} -- bolt
        }
    },
    {
        id = 5971,
        name = "infernal bolt",
        alchemyType = "ammunition",
        level = 70,
        cost = 0,
        count = 1,
        materials = {
            {id = 2547, count = 10} -- power bolt
        }
    }
}
