-- r_place/mods/rp_snapshot/init.lua
-- User interface of rp_export for taking snapshots
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

local S = minetest.get_translator("rp_snapshot")
rp_snapshot = {}
rp_snapshot.snapshots = {}

local function delete_snapshot(name, i)
    if not rp_snapshot.snapshots[name] then return end
    rp_snapshot.snapshots[name][i] = nil
end

function rp_snapshot.save_snapshot(name, data, minp, maxp)
    if not rp_snapshot.snapshots[name] then
        rp_snapshot.snapshots[name] = {}
    end
    local i
    local t = 0
    repeat
        i = math.random(1000)
        t = t + 1
    until (rp_snapshot.snapshots[name][i] == nil) or t > 100
    if not i then
        return nil
    end
    local after = minetest.after(30, delete_snapshot, name, i) -- 5 minutes
    data.after = after
    data.minp, data.maxp = minp, maxp
    data.time = os.time()
    rp_snapshot.snapshots[name][i] = data
    return i
end

function rp_snapshot.get_snapshot(name, i)
    if not rp_snapshot.snapshots[name] then return end
    return rp_snapshot.snapshots[name][i]
end

function rp_snapshot.delete_snapshot(name, i)
    if not rp_snapshot.snapshots[name] then return false  end
    if not rp_snapshot.snapshots[name][i] then return false end
    rp_snapshot.snapshots[name][i].after:cancel()
    rp_snapshot.snapshots[name][i] = nil
    return true
end

function rp_snapshot.delete_snapshots_by_name(name)
    if not rp_snapshot.snapshots[name] then return end
    for k, v in pairs(rp_snapshot.snapshots[name]) do
        v.after:cancel()
    end
    rp_snapshot.snapshots[name] = nil
end

local selecting = {}

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    if not puncher:is_player() then return end
    local name = puncher:get_player_name()
    if selecting[name] then
        if not rp_core.in_area(pos) then
            minetest.chat_send_player(name,
                minetest.colorize("orange", S("Invalid position selected.")))
            return
        end
        selecting[name][#selecting[name] + 1] = {pos.x, pos.z}
        minetest.chat_send_player(name,
            minetest.colorize("orange", S("Got (@1, @2)", pos.x, pos.z)))
        if #selecting[name] == 2 then
            local minp, maxp = rp_utils.sort_2d(selecting[name][1], selecting[name][2])
            local data = rp_export.get_area(minp, maxp, true)
            local id = rp_snapshot.save_snapshot(name, data, minp, maxp)
            if id then
                minetest.chat_send_player(name,
                    minetest.colorize("orange", S("Snapshot saved. ID: @1", id)))
                minetest.chat_send_player(name,
                    minetest.colorize("orange", S("The snapshot will be alive for 5 minutes or until you leave.")))
            else
                minetest.chat_send_player(name,
                    minetest.colorize("orange",
                        S("Snapshot saving failed. Please try again, or delete some snapshots.")))
            end
            selecting[name]  = nil
        end
    end
end)

minetest.register_chatcommand("ss", {
    description = S("Start taking snapshot of map"),
    func = function(name, param)
        selecting[name] = {}
        return true, minetest.colorize("orange", S("Select two corners by punching them."))
    end
})

minetest.register_chatcommand("ss_cancel", {
    description = S("Stop taking snapshot of map"),
    func = function(name, param)
        selecting[name] = nil
        return true, minetest.colorize("orange", S("Snapshot taking cancled."))
    end
})

minetest.register_chatcommand("ss_list", {
    description = S("List snapshots"),
    func = function(name, param)
        if not rp_snapshot.snapshots[name] then
            return false, minetest.colorize("orange", S("You have not created any snapshots yet."))
        end
        local ss_data = {}
        for k, v in pairs(rp_snapshot.snapshots[name]) do
            ss_data[#ss_data+1] = {
                id = k,
                minp = v.minp,
                maxp = v.maxp,
                time = v.time
            }
        end
        if #ss_data == 0 then
            return false, minetest.colorize("orange", S("You have not created any snapshots yet."))
        end
        local rtn = {}
        rtn[#rtn+1] = S("--- List of snapshots ---")
        for _, v in ipairs(ss_data) do
            rtn[#rtn+1] = string.format("%d: (%d, %d) to (%d, %d) (%s)",
                v.id,
                v.minp[1], v.minp[2],
                v.maxp[1], v.maxp[2],
                os.date('%m/%d/%Y %H:%M:%S %z', v.time)
            )
        end
        rtn[#rtn+1] = S("--- List of snapshots END ---")
        return true, table.concat(rtn,"\n")
    end
})

minetest.register_chatcommand("ss_del", {
    description = S("Delete snapshots"),
    param = S("<snapshot id>"),
    func = function(name, param)
        local id = tonumber(param)
        if not id then
            return false, minetest.colorize("orange", S("Please enter a valid ID."))
        end
        local status = rp_snapshot.delete_snapshot(name, id)
        if status then
            return true, minetest.colorize("orange", S("Successfully deleted snapshot @1.", id))
        else
            return false, minetest.colorize("orange", S("Snapshot @1 not found.", id))
        end
    end
})

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    rp_snapshot.delete_snapshots_by_name(name)
    selecting[name] = nil
end)

