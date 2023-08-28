-- r_place/mods/rp_core/commands.lua
-- Handle chatcommands
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

do
    local CONTENT_IGNORE = minetest.CONTENT_IGNORE
    local CONTENT_FILL   = minetest.get_content_id("rp_mapgen_nodes:default_fill")

    minetest.register_chatcommand("reset",{
        description = S("Reset the area"),
        privs = {server = true},
        func = function(name,param)
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
            return true, S("Map reset done.")
        end
    })
end