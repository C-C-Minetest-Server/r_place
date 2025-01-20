-- r_place/mods/rp_core/mapgen.lua
-- Handle area generation
-- With code from langton/mods/lg_mapgen/init.lua
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

minetest.set_mapgen_setting("mgname", "singlenode", true)

local ID_GROUND = minetest.get_content_id("rp_mapgen_nodes:transparent_ground")

minetest.register_on_generated(function(minp,maxp,seed)
	if minp.y > 0 or maxp.y < 0 then return end
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local y = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			data[area:index(x,y,z)] = ID_GROUND
		end
	end

	vm:set_data(data)
    vm:set_lighting({day = 15, night = 15})
	vm:calc_lighting()
	vm:write_to_map(data)
end)