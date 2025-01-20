-- r_place/mods/rp_utils/init.lua
-- Utility functions
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

rp_utils = {}

function rp_utils.every_n_seconds(delay, func)
    local function loop()
        func()
        minetest.after(delay, loop)
    end
    minetest.after(1,loop)
end

do
    local function iter(state)
        local pos1, pos2 = state.pos1, state.pos2
        local rtn = nil
        if state.pointer then
            local pointer = state.pointer
            rtn = vector.copy(pointer)
            pointer.x = pointer.x + 1
            if pointer.x > pos2.x then
                pointer.x = pos1.x
                pointer.y = pointer.y + 1
                if pointer.y > pos2.y then
                    pointer.y = pos1.y
                    pointer.z = pointer.z + 1
                    if pointer.z > pos2.z then
                        state.pointer = nil
                    end
                end
            end
        end
        return rtn
    end

    function rp_utils.vector_range(pos1, pos2)
        pos1, pos2 = vector.sort(pos1, pos2)
        local state = {
            pos1 = pos1, pos2 = pos2,
            pointer = vector.copy(pos1)
        }
        return iter, state
    end
end

function rp_utils.sort(num1, num2)
    if num1 > num2 then
        return num1, num2
    end
    return num2, num1
end

function rp_utils.sort_2d(pos1, pos2)
    local minx, maxx = rp_utils.sort(pos1[1], pos2[1])
    local minz, maxz = rp_utils.sort(pos1[2], pos2[2])
    return {minx, minz}, {maxx, maxz}
end