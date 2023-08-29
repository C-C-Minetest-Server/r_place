-- r_place/mods/rp_core/placement.lua
-- Handle node placement and area protection
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

local deny = {}
local deny_clear = {}
local delay_hud = {}

rp_core.time_delay = tonumber(minetest.settings:get("r_place.delay") or "5") or 5
rp_core.wear_show_delay = minetest.settings:get_bool("r_place.wear_show_delay", false)
local time_delay = rp_core.time_delay

local S = minetest.get_translator("rp_core")

minetest.register_privilege("no_delay", {
    description = S("Disable build delay"),
    give_to_singleplayer = false,
})

do
    local old_is_protected = minetest.is_protected
    function minetest.is_protected(pos, name)
        if deny[name] and (os.time() - deny[name] <= time_delay) then
            return true
        elseif not rp_core.in_area(pos) then
            return true
        end
        return old_is_protected(pos, name)
    end
end

local function hud_loop()
    local now = os.time()
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local text = ""
        if deny[name] then
            local time_left = time_delay + (deny[name] - now)
            text = S("@1 seconds left", time_left)
        end
        if not delay_hud[name] then
            delay_hud[name] = player:hud_add({
                hud_elem_type = "text",
                position      = {x = 1, y = 0},
                scale         = {x = 100, y = 100},
                text          = text,
                number        = 0xFFFFFF,
                offset        = {x = -6, y = 25},
                alignment     = {x = -1, y = 3}
            })
        else
            player:hud_change(delay_hud[name], "text", text)
        end
    end
    minetest.after(0.5,hud_loop)
end
minetest.after(0,hud_loop)


minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    if not placer:is_player() then return true end
    local name = placer:get_player_name()

    local meta = minetest.get_meta(pos)
    meta:mark_as_private("placer") -- For performance
    meta:set_string("placer",name)
    meta:set_string("infotext",S("Placed by: @1",name))

    if deny_clear[name] then
        deny_clear[name]:cancel()
    end
    if minetest.check_player_privs(name, {no_delay = true}) then
        return true
    end
    deny[name] = os.time()
    deny_clear[name] = minetest.after(time_delay, function()
        deny[name] = nil
        deny_clear[name] = nil
    end)
    return true
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    deny[name] = nil
    delay_hud[name] = nil
    if deny_clear[name] then
        deny_clear[name]:cancel()
        deny_clear[name] = nil
    end
end)

