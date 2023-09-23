-- r_place/mods/rp_export/iterator.lua
-- rp_export iterator
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

-- minp and max are {x,z}; y = 1

local node_map = {}
local color_map_name = {}
for hex, _ in pairs(rp_nodes.colors) do
    local name = "rp_nodes:color_" .. hex
    local num = tonumber(hex, 16)
    node_map[minetest.get_content_id(name)] = name
    color_map_name[name] = num
end

local function iterator_vmip(state)
    state.curr_x = state.curr_x + 1
    if state.curr_x > state.maxp[1] then
        state.curr_x = state.minp[1]
        state.curr_z = state.curr_z + 1
        if state.curr_z > state.maxp[2] then
            return nil
        end
    end
    minetest.log("verbose", string.format("[rp_export -> iterator_vmip] Working on %d %d",state.curr_x,state.curr_z))
    local i = state.va:index(state.curr_x,1,state.curr_z)
    local name = node_map[state.vm_data[i]]
    return {
        color = color_map_name[name],
        name = name,
    }
end

local function iterator_api(state)
    state.curr_x = state.curr_x + 1
    if state.curr_x > state.maxp[1] then
        state.curr_x = state.minp[1]
        state.curr_z = state.curr_z + 1
        if state.curr_z > state.maxp[2] then
            return nil
        end
    end
    minetest.log("verbose", string.format("[rp_export -> iterator_api] Working on %d %d",state.curr_x,state.curr_z))
    local pos = vector.new(state.curr_x, 1, state.curr_z)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)
    return {
        color = color_map_name[node.name],
        placer = meta:get_string("placer"),
        name = node.name,
    }
end

function rp_export.get_area_iterator(minp, maxp, get_placer)
    -- If we are not wanting to get placer, we use the less expensive Voxelmanip
    -- But if we do, iterate through blocks using the high-level APIs.
    local state = {
        minp = minp, maxp = maxp,
        curr_x = minp[1] - 1, curr_z = minp[2]
    }
    minetest.log("verbose", string.format("[rp_export] Start working on %d %d to %d %d",
        minp[1],minp[2],maxp[1],maxp[2]))
    if get_placer then
        minetest.log("verbose", "[rp_export] Using API getter")
        return iterator_api, state
    else
        minetest.log("verbose", "[rp_export] Using VoxelManip getter")
        local VM = VoxelManip()
        local vminp, vmaxp = VM:read_from_map(
            {x=minp[1],y=1,z=minp[2]},
            {x=maxp[1],y=1,z=maxp[2]}
        )
        local data = VM:get_data()
        state.va = VoxelArea(vminp, vmaxp)
        state.vm_data = data
        return iterator_vmip, state
    end
end