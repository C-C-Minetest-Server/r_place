-- r_place/mods/rp_nodes/init.lua
-- Nodes for Place
-- With code from parkour/mods/pkr_nodes/init.lua
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

rp_nodes = {}

local S = minetest.get_translator("rp_nodes")
rp_nodes.colors = { -- https://lospec.com/palette-list/r-place
    ["FFFFFF"] = S("White"),
    ["E4E4E4"] = S("Light grey"),
    ["888888"] = S("Dark grey"),
    ["222222"] = S("Black"),

    ["FFA7D1"] = S("Pink"),
    ["E50000"] = S("Red"),
    ["E59500"] = S("Orange"),
    ["A06A42"] = S("Brown"),

    ["E5D900"] = S("Yellow"),
    ["94E044"] = S("Light green"),
    ["02BE01"] = S("Green"),
    ["00D3DD"] = S("Cyan"),

    ["0083C7"] = S("Light blue"),
    ["0000EA"] = S("Blue"),
    ["CF6EE4"] = S("Dark pink"),
    ["820080"] = S("Magenta"),
}

local function on_place(itemstack, placer, pointed_thing)
    local iname = itemstack:get_name()
    local pnode = minetest.get_node(pointed_thing.under)
    local pname = pnode.name
    if iname ~= pname then
        return minetest.item_place(itemstack, placer, pointed_thing)
    end
    return itemstack, nil
end

for hex, name in pairs(rp_nodes.colors) do
    local alpha = ":200"
    if hex == "222222" then
        alpha = ":245"
    elseif hex == "FFFFFF" then
        alpha = ":80"
    end
    minetest.register_node("rp_nodes:color_" .. hex, {
        description = S("@1 building block", name),
        tiles = {"rp_nodes_base.png^[colorize:#" .. hex .. alpha},
        groups = {rp_nodes = 1},
        buildable_to = true,
        is_ground_content = false,
        node_placement_prediction = "",
        on_place = on_place,
        paramtype = "light",
        light_source = minetest.LIGHT_MAX,
    })
end