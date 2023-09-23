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
local WP = minetest.get_worldpath()

local function save()
    minetest.log("action","[rp_export_json] Staring saving to JSON")
    local json_data = {}

    json_data.x_axis = (rp_core.area[2][1] - rp_core.area[1][1] + 1)
    json_data.z_axis = (rp_core.area[2][2] - rp_core.area[1][2] + 1)
    json_data.map = {{}}

    local curr_map_row_id = 1
    for x in rp_export.get_area_iterator(rp_core.area[1], rp_core.area[2], false) do
        if #json_data.map[curr_map_row_id] >= json_data.x_axis then
            curr_map_row_id = curr_map_row_id + 1
            json_data.map[curr_map_row_id] = {}
        end
        local curr_map_row = json_data.map[curr_map_row_id]
        curr_map_row[#curr_map_row + 1] = x.color or 0x000000
    end

    local json = minetest.write_json(json_data)
    minetest.safe_file_write(WP .. "/r_place.json", json)
end

rp_utils.every_n_seconds(60, save)

minetest.register_chatcommand("json_force_export", {
    description = S("Forcely start export to JSON job"),
    privs = {server = true},
    func = function(name, param)
        save()
        return true, minetest.colorize("orange", S("Job started."))
    end
})