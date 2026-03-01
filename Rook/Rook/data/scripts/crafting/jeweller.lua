Crafting.jeweller = {
    -- Temporary random recipes for upgrade-system items.
    {
        id = 7870,
        name = "upgrade crystal",
        level = 15,
        cost = 5000,
        count = 1,
        materials = {
            {id = 2148, count = 5000}, -- gold coin
            {id = 2149, count = 2}, -- small emerald
            {id = 2147, count = 2} -- small ruby
        }
    },
    {
        id = 7871,
        name = "enchant crystal",
        level = 20,
        cost = 9000,
        count = 1,
        materials = {
            {id = 7870, count = 2}, -- upgrade crystal
            {id = 2146, count = 2}, -- small sapphire
            {id = 2144, count = 1} -- black pearl
        }
    },
    {
        id = 7872,
        name = "alter crystal",
        level = 25,
        cost = 12000,
        count = 1,
        materials = {
            {id = 7871, count = 1}, -- enchant crystal
            {id = 2145, count = 2}, -- small diamond
            {id = 2147, count = 1} -- small ruby
        }
    },
    {
        id = 7873,
        name = "cleanse crystal",
        level = 30,
        cost = 14000,
        count = 1,
        materials = {
            {id = 7872, count = 1}, -- alter crystal
            {id = 2146, count = 2}, -- small sapphire
            {id = 2149, count = 2} -- small emerald
        }
    },
    {
        id = 7874,
        name = "fortune crystal",
        level = 35,
        cost = 18000,
        count = 1,
        materials = {
            {id = 7871, count = 2}, -- enchant crystal
            {id = 2154, count = 1}, -- yellow gem
            {id = 2074, count = 2} -- panpipes
        }
    },
    {
        id = 7875,
        name = "faith crystal",
        level = 40,
        cost = 22000,
        count = 1,
        materials = {
            {id = 7874, count = 1}, -- fortune crystal
            {id = 2193, count = 2}, -- ankh
            {id = 2145, count = 2} -- small diamond
        }
    },
    {
        id = 7876,
        name = "mind crystal",
        level = 50,
        cost = 35000,
        count = 1,
        materials = {
            {id = 7875, count = 1}, -- faith crystal
            {id = 6437, count = 3}, -- soul orb
            {id = 2348, count = 2}, -- ancient rune
            {id = 2349, count = 2} -- blue note
        }
    },
    {
        id = 7877,
        name = "limitless crystal",
        level = 55,
        cost = 45000,
        count = 1,
        materials = {
            {id = 7876, count = 1}, -- mind crystal
            {id = 7874, count = 2}, -- fortune crystal
            {id = 3956, count = 4}, -- elephant tusk
            {id = 2745, count = 10} -- blue rose
        }
    },
    {
        id = 7878,
        name = "mirrored crystal",
        level = 60,
        cost = 50000,
        count = 1,
        materials = {
            {id = 7876, count = 1}, -- mind crystal
            {id = 7875, count = 1}, -- faith crystal
            {id = 2145, count = 5}, -- small diamond
            {id = 2146, count = 5}, -- small sapphire
            {id = 2147, count = 5} -- small ruby
        }
    },
    {
        id = 7879,
        name = "void crystal",
        level = 65,
        cost = 60000,
        count = 1,
        materials = {
            {id = 7878, count = 1}, -- mirrored crystal
            {id = 6437, count = 5}, -- soul orb
            {id = 3955, count = 3}, -- voodoo doll
            {id = 2804, count = 20} -- shadow herb
        }
    },
    {
        id = 7881,
        name = "upgrade catalyst",
        level = 45,
        cost = 25000,
        count = 1,
        materials = {
            {id = 7870, count = 2}, -- upgrade crystal
            {id = 7874, count = 1}, -- fortune crystal
            {id = 2151, count = 10} -- talon
        }
    },
    {
        id = 7882,
        name = "crystal extractor",
        level = 35,
        cost = 16000,
        count = 1,
        materials = {
            {id = 7870, count = 1}, -- upgrade crystal
            {id = 7881, count = 1}, -- upgrade catalyst
            {id = 2148, count = 10000} -- gold coin
        }
    },
    {
        id = 7883,
        name = "crystal fossil",
        level = 30,
        cost = 9000,
        count = 1,
        materials = {
            {id = 2159, count = 15}, -- scarab coin
            {id = 2348, count = 2}, -- ancient rune
            {id = 2349, count = 2}, -- blue note
            {id = 2148, count = 3000} -- gold coin
        }
    },
    {
        id = 7893,
        name = "rarity crystal",
        level = 55,
        cost = 70000,
        count = 1,
        materials = {
            {id = 7878, count = 1}, -- mirrored crystal
            {id = 7879, count = 1}, -- void crystal
            {id = 6437, count = 8}, -- soul orb
            {id = 2154, count = 4}, -- yellow gem
            {id = 2145, count = 6} -- small diamond
        }
    },
    {
        id = 7894,
        name = "tier crystal",
        level = 60,
        cost = 85000,
        count = 1,
        materials = {
            {id = 7893, count = 1}, -- rarity crystal
            {id = 7877, count = 1}, -- limitless crystal
            {id = 2348, count = 5}, -- ancient rune
            {id = 3956, count = 6}, -- elephant tusk
            {id = 2148, count = 25000} -- gold coin
        }
    },
    {
        id = 7953,
        name = "identification scroll",
        level = 20,
        cost = 8000,
        count = 1,
        materials = {
            {id = 1967, count = 5}, -- parchment
            {id = 7870, count = 1}, -- upgrade crystal
            {id = 2148, count = 5000} -- gold coin
        }
    }
}
