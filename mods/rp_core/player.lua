-- r_place/mods/rp_core/player.lua
-- Player spawnpoint and hand
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

function minetest.get_spawn_level(x,z)
    return 10
end

local list_nodes = {}
for name, def in pairs(minetest.registered_nodes) do
    if def.groups and def.groups.rp_nodes == 1 then
        list_nodes[#list_nodes + 1] = ItemStack(name)
    end
end

local inventory_formspec = table.concat({
    "size[8,4]",
    "list[current_player;main;0,0;8,4;]"
}, "")

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()

    -- Spawnpoint
    local spawn_pos = {
        x = (rp_core.area[1][1] + rp_core.area[2][1]) / 2,
        y = 10,
        z = (rp_core.area[1][2] + rp_core.area[2][2]) / 2
    }
    player:set_pos(spawn_pos)

    -- Fly
    local privs = minetest.get_player_privs(name)
    privs.fly = true
    minetest.set_player_privs(name,privs)

    -- Initial items
    local inv = player:get_inventory()
    inv:set_list("main",list_nodes)

    -- Formspec
    player:set_inventory_formspec(inventory_formspec)
end)

minetest.register_item(":", {
    type = "none",
    range = 15.0,
})