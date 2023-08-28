-- r_place/mods/rp_mapgen_nodes/init.lua
-- Map generation nodes of Place
--[[
    Copyright (C) 2023  1F616EMO

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
    USA
]]

minetest.register_node("rp_mapgen_nodes:transparent_ground", {
    description = "(Hack!) Transparent Ground",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    pointable = false,
    diggable = false,
    is_ground_content = true,
    damage_per_second = math.huge,
})

minetest.register_node("rp_mapgen_nodes:noplace", {
    description = "(Hack!) Place blocker",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    pointable = false,
    diggable = false,
    walkable = true,
    is_ground_content = true,
})

minetest.register_node("rp_mapgen_nodes:border", {
    description = "(Hack!) Area Border",
    tiles = {"rp_nodes_base.png^[colorize:#000000:255"},
    pointable = true,
    diggable = false,
    is_ground_content = false,
    damage_per_second = math.huge,
})

-- Black
minetest.register_alias("rp_mapgen_nodes:default_fill","rp_nodes:color_222222")
