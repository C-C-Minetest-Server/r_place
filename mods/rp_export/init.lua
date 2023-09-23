-- r_place/mods/rp_export/init.lua
-- Export map nodes into machine-readable form
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

rp_export = {}

local MP = minetest.get_modpath("rp_export")
dofile(MP .. "/iterator.lua")

function rp_export.get_area(minp, maxp, get_placer)
    local rtn = {}
    for x in rp_export.get_area_iterator(minp, maxp, get_placer) do
        rtn[#rtn + 1] = x
    end
    rtn.len_x = maxp[1] - minp[1] + 1
    rtn.len_z = maxp[2] - minp[2] + 1
    return rtn
end

function rp_export.encode_png(minp, maxp)
    local data = {}
    for x in rp_export.get_area_iterator(minp, maxp, false) do
        local color = x.color
        if not color then
            color = 0x000000
        end
        data[data + 1] = color
    end
    local width = maxp[1] - minp[1] + 1
    local height = maxp[2] - minp[2] + 1
    return minetest.encode_png(width, height, data)
end

