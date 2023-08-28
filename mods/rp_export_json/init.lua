-- r_place/mods/rp_export_json/init.lua
-- Export area to JSON
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

local S = minetest.get_translator("rp_export_json")
local color_map = {}
for hex, _ in pairs(rp_nodes.colors) do
    color_map[minetest.get_content_id("rp_nodes:color_" .. hex)] = tonumber(hex, 16)
end

local function save(callback)
    minetest.log("action","[rp_export_json] Staring saving to JSON")
    local VM = VoxelManip()
    local minp, maxp = VM:read_from_map(
        {x=rp_core.area[1][1],y=1,z=rp_core.area[1][2]},
        {x=rp_core.area[2][1],y=1,z=rp_core.area[2][2]}
    )
    local data = VM:get_data()

    ---@diagnostic disable-next-line: redefined-local
    minetest.handle_async(function(color_map, area, data, minp, maxp)
        local json_data = {}
        json_data.x_axis = (area[2][1] - area[1][1] + 1)
        json_data.z_axis = (area[2][2] - area[1][2] + 1)
        json_data.map = {}
        local VA = VoxelArea(minp, maxp)
        for z = area[2][2], area[1][2], -1 do
            local x_data = {}
            for x = area[2][1], area[1][1], -1 do
                local i = VA:index(x,1,z)
                local id = data[i]
                x_data[#x_data+1] = color_map[id] or 0
            end
            json_data.map[#json_data.map+1] = x_data
        end
        
        local json = minetest.write_json(json_data)
        local WP = minetest.get_worldpath()
        minetest.safe_file_write(WP .. "/r_place.json", json)
    end, function(...)
        minetest.log("action","[rp_export_json] Done saving to JSON")
        if callback then
            callback(...)
        end
    end, color_map, rp_core.area, data, minp, maxp)
end

local function loop()
    save(function()
        minetest.after(60, save)
    end)
end

minetest.after(1,loop)

minetest.register_chatcommand("json_force_export", {
    description = S("Forcely start export to JSON job"),
    privs = {server = true},
    func = function(name, param)
        save()
        return true, minetest.colorize("orange", S("Job started."))
    end
})