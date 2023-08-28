-- r_place/mods/rp_core/mapgen.lua
-- Handle border generation
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

local function v(x,z)
    return vector.new(x,1,z)
end

local WP = minetest.get_worldpath()
local NEW_BORDER
-- ^%s*%(%s*([^%s,]+)%s*[,%s]%s*([^%s,]+)%s*[,%s]?%s*%)()
do
    local BORDER_POS1_SETTINGS = minetest.settings:get("r_place.area_pos1") or "(30,30)"
    local BORDER_POS2_SETTINGS = minetest.settings:get("r_place.area_pos2") or "(-30,-30)"

    local BORDER_POS1x, BORDER_POS1z = string.match(
        BORDER_POS1_SETTINGS,
        "^%s*%(%s*([^%s,]+)%s*[,%s]%s*([^%s,]+)%s*[,%s]?%s*%)()"
    )
    local BORDER_POS2x, BORDER_POS2z = string.match(
        BORDER_POS2_SETTINGS,
        "^%s*%(%s*([^%s,]+)%s*[,%s]%s*([^%s,]+)%s*[,%s]?%s*%)()"
    )

    BORDER_POS1x, BORDER_POS1z = tonumber(BORDER_POS1x), tonumber(BORDER_POS1z)
    BORDER_POS2x, BORDER_POS2z = tonumber(BORDER_POS2x), tonumber(BORDER_POS2z)

    if not (BORDER_POS1x and BORDER_POS1z and BORDER_POS2x and BORDER_POS2z) then
        error("[rp_core] Please pass valid coordinates into r_place.area_pos{1,2}!")
    end

    NEW_BORDER = {
        {
            BORDER_POS1x <  BORDER_POS2x and BORDER_POS1x or BORDER_POS2x,
            BORDER_POS1z <  BORDER_POS2z and BORDER_POS1z or BORDER_POS2z
        }, {
            BORDER_POS1x >= BORDER_POS2x and BORDER_POS1x or BORDER_POS2x,
            BORDER_POS1z >= BORDER_POS2z and BORDER_POS1z or BORDER_POS2z
        }
    }
end

rp_core.area = NEW_BORDER

minetest.after(0,function()
    do -- Clear old barrier and remove out-of-range nodes
        local CACHE_PATH = WP .. "/" .. "rp_core_border_cache"
        local CACHE_READ = io.open(CACHE_PATH, "r")
        if CACHE_READ then
            local OLD_BORDER = minetest.deserialize(CACHE_READ:read("*a"))
            if OLD_BORDER
            and (OLD_BORDER[1][1] ~= NEW_BORDER[1][1]
            or OLD_BORDER[1][2] ~= NEW_BORDER[1][2]
            or OLD_BORDER[2][1] ~= NEW_BORDER[2][1]
            or OLD_BORDER[2][2] ~= NEW_BORDER[2][2]) then
                -- Not equal
                rp_core.log("action","Removing old area barriers...")
                local remove_queue = {}

                -- Remove building nodes
                for x = OLD_BORDER[1][1], OLD_BORDER[2][1], 1 do
                    for z = OLD_BORDER[1][2], OLD_BORDER[2][2], 1 do
                        if x < NEW_BORDER[1][1]
                        or x > NEW_BORDER[2][1]
                        or z < NEW_BORDER[1][2]
                        or z > NEW_BORDER[2][2] then
                            table.insert(remove_queue,{x,z})
                        end
                    end
                end

                -- Remove old border
                for x = OLD_BORDER[1][1] - 1, OLD_BORDER[2][1] + 1, 1 do
                    table.insert(remove_queue,{x,OLD_BORDER[1][2] - 1})
                    table.insert(remove_queue,{x,OLD_BORDER[2][2] + 1})
                end
                for z = OLD_BORDER[1][2] - 1, OLD_BORDER[2][2] + 1, 1 do
                    table.insert(remove_queue,{OLD_BORDER[1][1] - 1,z})
                    table.insert(remove_queue,{OLD_BORDER[2][1] + 1,z})
                end

                local VM = VoxelManip()
                local pmin, pmax = VM:read_from_map(
                    v(OLD_BORDER[1][1] - 1,OLD_BORDER[1][2] - 1),
                    v(OLD_BORDER[2][1] + 1,OLD_BORDER[2][2] + 1)
                )
                local data = VM:get_data()
                local VA = VoxelArea(pmin,pmax)

                for _,pos in pairs(remove_queue) do
                    local vm_i = VA:index(pos[1],1,pos[2])
                    data[vm_i] = minetest.CONTENT_AIR
                end

                VM:set_data(data)
                VM:calc_lighting()
                VM:write_to_map()

                minetest.after(1,minetest.fix_light,pmin,pmax)
            end
            CACHE_READ:close()
        end
        -- Write back to cache
        local CACHE_WRITE = io.open(CACHE_PATH, "w")
        if CACHE_WRITE then
            CACHE_WRITE:write(minetest.serialize(NEW_BORDER))
            CACHE_WRITE:close()
        end
    end

    do -- Construct area
        rp_core.log("action","Constructing area")
        local CONTENT_BORDER = minetest.get_content_id("rp_mapgen_nodes:border")
        local CONTENT_FILL   = minetest.get_content_id("rp_mapgen_nodes:default_fill")
        local CONTENT_AIR    = minetest.CONTENT_AIR
        local CONTENT_IGNORE = minetest.CONTENT_IGNORE

        local VM = VoxelManip()
        local pmin, pmax = VM:read_from_map(
            v(NEW_BORDER[1][1] - 1,NEW_BORDER[1][2] - 1),
            v(NEW_BORDER[2][1] + 1,NEW_BORDER[2][2] + 1)
        )
        local data = VM:get_data()
        local VA = VoxelArea(pmin,pmax)

        for vm_i, d in ipairs(data) do
            local pos = VA:position(vm_i)
            local x,y,z = pos.x, pos.y, pos.z
            if y ~= 1
            or x < NEW_BORDER[1][1] - 1
            or x > NEW_BORDER[2][1] + 1
            or z < NEW_BORDER[1][2] - 1
            or z > NEW_BORDER[2][2] + 1 then
                data[vm_i] = CONTENT_IGNORE
            elseif x == NEW_BORDER[1][1] - 1
            or x == NEW_BORDER[2][1] + 1
            or z == NEW_BORDER[1][2] - 1
            or z == NEW_BORDER[2][2] + 1 then
                data[vm_i] = CONTENT_BORDER
            elseif d == CONTENT_AIR
            or d == CONTENT_IGNORE
            or d == CONTENT_BORDER then
                data[vm_i] = CONTENT_FILL
            else
                data[vm_i] = CONTENT_IGNORE
            end
        end

        VM:set_data(data)
        VM:write_to_map()

        minetest.after(1,minetest.fix_light,pmin,pmax)
    end
end)

function rp_core.in_area(pos)
    local x, y, z = pos.x, pos.y, pos.z
    if y ~= 1
    or x < rp_core.area[1][1]
    or x > rp_core.area[2][1]
    or z < rp_core.area[1][2]
    or z > rp_core.area[2][2] then
        return false
    end
    return true
end