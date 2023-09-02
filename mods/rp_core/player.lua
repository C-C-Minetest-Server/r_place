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

local S = minetest.get_translator("rp_core")

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

local function check_pos(pos)
    pos = vector.copy(pos)
    local altered = false
    if pos.y <= 1 then
        pos.y = 5
        altered = true
    elseif pos.y > 105 then
        pos.y = 100
        altered = true
    end
    if pos.x < (rp_core.area[1][1] - 10) then
        pos.x = rp_core.area[1][1] - 5
        altered = true
    elseif pos.x > (rp_core.area[2][1] + 10) then
        pos.x = rp_core.area[2][1] + 5
        altered = true
    end
    if pos.y < (rp_core.area[1][2] - 10) then
        pos.y = rp_core.area[1][2] - 5
        altered = true
    elseif pos.y > (rp_core.area[2][2] + 10) then
        pos.y = rp_core.area[2][2] + 5
        altered = true
    end
    return pos, altered
end

local spawnpoint = minetest.settings:get("static_spawnpoint")
if spawnpoint and spawnpoint ~= "" then
    spawnpoint = vector.from_string(spawnpoint)
    spawnpoint = check_pos(spawnpoint)
end
if not(spawnpoint and spawnpoint ~= "") then
    spawnpoint = {
        x = (rp_core.area[1][1] + rp_core.area[2][1]) / 2,
        y = 10,
        z = (rp_core.area[1][2] + rp_core.area[2][2]) / 2
    }
end

minetest.register_chatcommand("spawn", {
    description = S("Go back to spawnpoint"),
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false end
        player:set_pos(spawnpoint)
        return true, S("Teleported back to spawn.")
    end
})

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()

    -- Spawnpoint
    player:set_pos(spawnpoint)

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

rp_utils.every_n_seconds(5, function()
    for _, player in pairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        local npos, altered = check_pos(pos)

        if altered then
            local name = player:get_player_name()
            minetest.chat_send_player(name, minetest.get_color_escape_sequence("orange") ..
                S("How about we explore the area ahead of us later?"))
            player:set_pos(npos)
        end
    end
end)

minetest.override_item("", {
    range = 15.0,
})