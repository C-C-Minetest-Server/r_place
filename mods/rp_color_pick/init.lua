-- r_place/mods/rp_color_pick/init.lua
-- Color picker
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

local S = minetest.get_translator("rp_color_pick")

local function play_suish_pop(pname)
    minetest.sound_play({
        name = "rp_color_pick_suish_pop",
        fade = 0,
        gain = 0.7,
    }, {
        to_player = pname,
    }, true)
end

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    if not puncher:is_player() then return end
    local pname = puncher:get_player_name()
    local nname = node.name
    local old_wield = puncher:get_wielded_item()
    if old_wield:get_name() == nname then return end
    local inv = puncher:get_inventory()
    if inv:contains_item("main",nname) then
        local def = minetest.registered_nodes[nname]
        if def then
            inv:set_stack(puncher:get_wield_list(),puncher:get_wield_index(),ItemStack())
            local new_equip = inv:remove_item("main",nname)

            puncher:set_wielded_item(new_equip)
            inv:add_item("main", old_wield)

            play_suish_pop(pname)
            minetest.chat_send_player(pname, minetest.colorize("orange", S("Picked @1",def.description)))
        end
    end
end)