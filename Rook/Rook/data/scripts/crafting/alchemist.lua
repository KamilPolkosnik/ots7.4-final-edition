Crafting.alchemist = {
    -- Timed rings (base forms).
    {
        id = 2165,
        name = "stealth ring",
        alchemyType = "rings",
        level = 35,
        cost = 3000,
        count = 1,
        materials = {
            {id = 2230, count = 10}
        }
    },
    {
        id = 2166,
        name = "power ring",
        alchemyType = "rings",
        level = 40,
        cost = 500,
        count = 1,
        materials = {}
    },
    {
        id = 2167,
        name = "energy ring",
        alchemyType = "rings",
        level = 45,
        cost = 100,
        count = 1,
        materials = {
            {id = 2006, count = 10}
        }
    },
    {
        id = 2168,
        name = "life ring",
        alchemyType = "rings",
        level = 45,
        cost = 500,
        count = 1,
        materials = {
            {id = 2177, count = 1}
        }
    },
    {
        id = 2169,
        name = "time ring",
        alchemyType = "rings",
        level = 35,
        cost = 3000,
        count = 1,
        materials = {
            {id = 2230, count = 10}
        }
    },
    {
        id = 2207,
        name = "sword ring",
        alchemyType = "rings",
        level = 50,
        cost = 0,
        count = 1,
        materials = {
            {id = 2166, count = 1},
            {id = 2376, count = 1}
        }
    },
    {
        id = 2208,
        name = "axe ring",
        alchemyType = "rings",
        level = 50,
        cost = 0,
        count = 1,
        materials = {
            {id = 2166, count = 1},
            {id = 2386, count = 1}
        }
    },
    {
        id = 2209,
        name = "club ring",
        alchemyType = "rings",
        level = 50,
        cost = 0,
        count = 1,
        materials = {
            {id = 2166, count = 1},
            {id = 2398, count = 1}
        }
    },
    {
        id = 7954,
        name = "distance ring",
        alchemyType = "rings",
        level = 50,
        cost = 0,
        count = 1,
        materials = {
            {id = 2166, count = 1},
            {id = 2455, count = 1}
        }
    },
    {
        id = 2213,
        name = "dwarven ring",
        alchemyType = "rings",
        level = 55,
        cost = 100,
        count = 1,
        materials = {
            {id = 2525, count = 1}
        }
    },
    {
        id = 2214,
        name = "ring of healing",
        alchemyType = "rings",
        level = 55,
        cost = 0,
        count = 1,
        materials = {
            {id = 2168, count = 3}
        }
    },
    {
        id = 2357,
        name = "ring of the unforgiving master",
        alchemyType = "rings",
        level = 90,
        cost = 45000,
        count = 1,
        materials = {
            {id = 2209, count = 5},
            {id = 2207, count = 5},
            {id = 2208, count = 5},
            {id = 2166, count = 1},
            {id = 7954, count = 5},
            {id = 2123, count = 1}
        }
    },
    {
        id = 7089,
        name = "regeneration ring",
        alchemyType = "rings",
        level = 58,
        cost = 10000,
        count = 1,
        materials = {
            {id = 2214, count = 10},
            {id = 2123, count = 1}
        }
    },
    {
        id = 7088,
        name = "regeneration amulet",
        alchemyType = "rings",
        level = 62,
        cost = 10000,
        count = 1,
        materials = {
            {id = 2214, count = 10},
            {id = 2123, count = 1}
        }
    },

    -- Ammunition.
    {
        id = 2544,
        name = "arrow",
        alchemyType = "ammunition",
        level = 8,
        cost = 0,
        count = 50,
        materials = {
            {id = 2229, count = 10}
        },
        recipes = {
            {
                cost = 0,
                materials = {
                    {id = 2229, count = 10}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2230, count = 50}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2543, count = 100}
                }
            }
        }
    },
    {
        id = 2543,
        name = "bolt",
        alchemyType = "ammunition",
        level = 12,
        cost = 0,
        count = 50,
        materials = {
            {id = 2229, count = 12}
        },
        recipes = {
            {
                cost = 0,
                materials = {
                    {id = 2229, count = 12}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2230, count = 60}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2544, count = 120}
                }
            }
        }
    },
    {
        id = 2545,
        name = "poison arrow",
        alchemyType = "ammunition",
        level = 20,
        cost = 500,
        count = 50,
        materials = {
            {id = 2544, count = 100}
        },
        recipes = {
            {
                cost = 500,
                materials = {
                    {id = 2544, count = 100}
                }
            },
            {
                cost = 500,
                materials = {
                    {id = 2543, count = 100}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2544, count = 50},
                    {id = 2229, count = 10}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2544, count = 50},
                    {id = 2230, count = 50}
                }
            }
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
            {id = 2544, count = 100},
            {id = 2304, count = 1}
        },
        recipes = {
            {
                cost = 0,
                materials = {
                    {id = 2544, count = 100},
                    {id = 2304, count = 1}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2544, count = 100},
                    {id = 2305, count = 2}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2544, count = 100},
                    {id = 2311, count = 10}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2311, count = 20}
                }
            },
            {
                cost = 0,
                materials = {
                    {id = 2305, count = 4}
                }
            }
        }
    },
    {
        id = 2547,
        name = "power bolt",
        alchemyType = "ammunition",
        level = 45,
        cost = 100,
        count = 1,
        materials = {
            {id = 2543, count = 100}
        },
        recipes = {
            {
                cost = 100,
                materials = {
                    {id = 2543, count = 100}
                }
            },
            {
                cost = 100,
                materials = {
                    {id = 2311, count = 2}
                }
            }
        }
    },
    {
        id = 5971,
        name = "infernal bolt",
        alchemyType = "ammunition",
        level = 70,
        cost = 500,
        count = 1,
        materials = {
            {id = 2547, count = 10}
        },
        recipes = {
            {
                cost = 500,
                materials = {
                    {id = 2547, count = 10}
                }
            },
            {
                cost = 500,
                materials = {
                    {id = 2311, count = 5}
                }
            }
        }
    }
}
