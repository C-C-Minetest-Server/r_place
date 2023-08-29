-- r_place/mods/rp_moderation/init.lua
-- Moderation tools
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

local S = minetest.get_translator("rp_moderation")

local confirm_queue = {}
local function do_confirm(name, action, func)
    confirm_queue[name] = func
    return true, minetest.colorize("orange",
        S("Are you sure you want to @1? Type /mod_y to confirm, or /mod_n to cancel.",action))
end

minetest.register_chatcommand("mod_y", {
    description = S("Confirm moderation action"),
    func = function(name, param)
        if confirm_queue[name] then
            local func = confirm_queue[name]
            confirm_queue[name] = nil
            return func()
        end
        return false, minetest.colorize("orange", S("No queued job."))
    end
})

minetest.register_chatcommand("mod_n", {
    description = S("Cancel moderation action"),
    func = function(name, param)
        if confirm_queue[name] then
            confirm_queue[name] = nil
            return true, minetest.colorize("orange", S("Job cancled."))
        end
        return false, minetest.colorize("orange", S("No queued job."))
    end
})

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    confirm_queue[name] = nil
end)

minetest.register_chatcommand("mod_rm_player", {
    description = S("Remove all nodes placed by a player"),
    params = S("<player name>"),
    privs = {ban = true},
    func = function(name, param)
        return do_confirm(name, S("erase all nodes placed by @1",param), function()
            local count = 0
            for x = rp_core.area[1][1], rp_core.area[2][1] do
                for z = rp_core.area[1][2], rp_core.area[2][2] do
                    local pos = vector.new(x,1,z)

                    local meta = minetest.get_meta(pos)
                    local m_pname = meta:get_string("placer")
                    if m_pname == param then
                        minetest.set_node(pos, {name = "rp_mapgen_nodes:default_fill"})
                        count = count + 1
                    end
                end
            end
            local percent = string.format("%.1d",(count / rp_core.area_size) * 100)
            return true, minetest.colorize("orange", S("Erased @1 (@2%) nodes.",count,percent))
        end)
    end
})

do
    local CONTENT_IGNORE = minetest.CONTENT_IGNORE
    local CONTENT_FILL   = minetest.get_content_id("rp_mapgen_nodes:default_fill")

    minetest.register_chatcommand("mod_reset",{
        description = S("Reset the area"),
        privs = {server = true},
        func = function(name,param)
            return do_confirm(name, S("erase the entire map"), function()
                local VM = VoxelManip()
                local minp, maxp = VM:read_from_map(
                    {
                        x = rp_core.area[1][1],
                        y = 1,
                        z = rp_core.area[1][2]
                    }, {
                        x = rp_core.area[2][1],
                        y = 1,
                        z = rp_core.area[2][2]
                    })
                local VA = VoxelArea(minp, maxp)
                local data = {}
                for i in VA:iterp(minp, maxp) do
                    local pos = VA:position(i)
                    if rp_core.in_area(pos) then
                        data[i] = CONTENT_FILL
                    else
                        data[i] = CONTENT_IGNORE
                    end
                end

                VM:set_data(data)
                VM:write_to_map()

                for x = rp_core.area[1][1], rp_core.area[2][1] do
                    for z = rp_core.area[1][2], rp_core.area[2][2] do
                        minetest.get_meta({x=x,y=1,z=z}):from_table({})
                    end
                end

                minetest.after(0,minetest.fix_light,minp,maxp)
                return true, minetest.colorize("orange", S("Map reset done."))
            end)
        end
    })
end