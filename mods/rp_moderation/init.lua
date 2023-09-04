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
local function do_confirm(name, action, func, cancel)
    confirm_queue[name] = {func, cancel}
    return true, minetest.colorize("orange",
        S("Are you sure you want to @1? Type /mod_y to confirm, or /mod_n to cancel.",action))
end

local get_pos_queue = {}
local function do_get_pos_confirm(name, action, how_many, func)
    get_pos_queue[name] = {
        pos = {},
        func = func,
        how_many = how_many,
        action = action
    }
    return true, minetest.colorize("orange",
        S("Select @1 coordinates by punching nodes, " ..
          "/mod_here to set it to your position, or /mod_n to cancel.", how_many))
end

local pos_particlespawner = {}
local function pos_spawn_particlespawners(name, pos1, pos2)
    pos1, pos2 = vector.sort(pos1, pos2)
    pos1 = vector.offset(pos1, -0.4, 0.6, -0.4)
    pos2 = vector.offset(pos2, 0.4, 0.6, 0.4)
    local sides = {
        {
            (pos2.x - pos1.x + 1),
            vector.new(pos1.x, 1.6, pos1.z),
            vector.new(pos2.x, 1.6, pos1.z),
        },
        {
            (pos2.x - pos1.x + 1),
            vector.new(pos1.x, 1.6, pos2.z),
            vector.new(pos2.x, 1.6, pos2.z),
        },
        {
            (pos2.z - pos1.z + 1),
            vector.new(pos1.x, 1.6, pos1.z),
            vector.new(pos1.x, 1.6, pos2.z)
        },
        {
            (pos2.z - pos1.z + 1),
            vector.new(pos2.x, 1.6, pos1.z),
            vector.new(pos2.x, 1.6, pos2.z)
        }
    }
    local particles = {}
    for _, data in ipairs(sides) do
        particles[#particles+1] = minetest.add_particlespawner({
            amount = data[1] * 10,
            time = 0,
            minpos = data[2],
            maxpos = data[3],
            minacc = {x=0, y=-10, z=0},
            maxacc = {x=0, y=-13, z=0},
            minexptime = 1,
            maxexptime = 1,
            minsize = 0,
            maxsize = 0,
            collisiondetection = false,
            glow = 3,
            node = {name = "rp_mapgen_nodes:border"},
            playername = name,
        })
        particles[#particles+1] = minetest.add_particlespawner({
            amount = data[1] * 10,
            time = 0,
            minpos = data[2],
            maxpos = data[3],
            minacc = {x=0, y=-10, z=0},
            maxacc = {x=0, y=-13, z=0},
            minexptime = 1,
            maxexptime = 1,
            minsize = 0,
            maxsize = 0,
            collisiondetection = false,
            glow = 3,
            node = {name = "rp_nodes:color_FFFFFF"},
            playername = name,
        })
    end
    pos_particlespawner[name] = particles
end

local function get_pos_do_confirm(name)
    local entry = get_pos_queue[name]
    get_pos_queue[name] = nil
    if pos_particlespawner[name] then
        for _, id in ipairs(pos_particlespawner[name]) do
            minetest.delete_particlespawner(id)
        end
        pos_particlespawner[name] = nil
    end
    confirm_queue[name] = {function()
        if pos_particlespawner[name] then
            for _, id in ipairs(pos_particlespawner[name]) do
                minetest.delete_particlespawner(id)
            end
            pos_particlespawner[name] = nil
        end
        return entry.func(entry.pos)
    end, function()
        if pos_particlespawner[name] then
            for _, id in ipairs(pos_particlespawner[name]) do
                minetest.delete_particlespawner(id)
            end
            pos_particlespawner[name] = nil
        end
    end}
    if entry.how_many == 2 then
        pos_spawn_particlespawners(name, entry.pos[1], entry.pos[2])
    end
end

minetest.register_chatcommand("mod_y", {
    description = S("Confirm moderation action"),
    func = function(name, param)
        if confirm_queue[name] then
            local func = confirm_queue[name][1]
            confirm_queue[name] = nil
            return func()
        end
        return false, minetest.colorize("orange", S("No queued job."))
    end
})

minetest.register_chatcommand("mod_n", {
    description = S("Cancel moderation action"),
    func = function(name, param)
        if confirm_queue[name] or get_pos_queue[name] then
            if confirm_queue[name] and confirm_queue[name][2] then
                confirm_queue[name][2]()
            end
            confirm_queue[name] = nil
            get_pos_queue[name] = nil
            return true, minetest.colorize("orange", S("Job cancled."))
        end
        return false, minetest.colorize("orange", S("No queued job."))
    end
})

minetest.register_chatcommand("mod_here", {
    description = S("Pick the current position"),
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false end -- e.g. from IRC
        if get_pos_queue[name] then
            local entry = get_pos_queue[name]
            local pos = vector.round(player:get_pos())
            pos.y = 1
            if not rp_core.in_area(pos) then
                return false, minetest.colorize("orange", S("Invalid position selected."))
            else
                minetest.chat_send_player(name, minetest.colorize("orange",
                    S("Got position: @1", vector.to_string(pos))))
                entry.pos[#entry.pos+1] = vector.copy(pos)
                if #entry.pos >= entry.how_many then
                    local action = entry.action
                    if type(action) == "function" then
                        action = action(entry.pos)
                    end
                    get_pos_do_confirm(name)
                    return true, minetest.colorize("orange",
                        S("Are you sure you want to @1? Type /mod_y to confirm, or /mod_n to cancel.", action))
                end
                return true
            end
        end
        return false, minetest.colorize("orange", S("No queued job."))
    end
})

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    confirm_queue[name] = nil
    get_pos_queue[name] = nil
    if pos_particlespawner[name] then
        for _, id in ipairs(pos_particlespawner[name]) do
            minetest.delete_particlespawner(id)
        end
        pos_particlespawner[name] = nil
    end
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    if not puncher:is_player() then return end
    local name = puncher:get_player_name()
    if get_pos_queue[name] then
        local entry = get_pos_queue[name]
        if not rp_core.in_area(pos) then
            minetest.chat_send_player(name, minetest.colorize("orange",
                S("Invalid position selected.")))
        else
            minetest.chat_send_player(name, minetest.colorize("orange",
                S("Got position: @1", vector.to_string(pos))))
            entry.pos[#entry.pos+1] = vector.copy(pos)
            if #entry.pos >= entry.how_many then
                local action = entry.action
                if type(action) == "function" then
                    action = action(entry.pos)
                end
                get_pos_do_confirm(name)
                minetest.chat_send_player(name, minetest.colorize("orange",
                    S("Are you sure you want to @1? Type /mod_y to confirm, or /mod_n to cancel.", action)))
            end
        end
    end
end)

minetest.register_chatcommand("mod_rm_player", {
    description = S("Remove all nodes placed by a player"),
    params = S("<player name>"),
    privs = {ban = true},
    func = function(name, param)
        if param == "" then
            return false, minetest.colorize("orange", S("Player name can't be blank."))
        end
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
                local minp, maxp = VM:read_from_map({
                    {
                        x = rp_core.area[1][1],
                        y = 1,
                        z = rp_core.area[1][2]
                    }, {
                        x = rp_core.area[2][1],
                        y = 1,
                        z = rp_core.area[2][2]
                    }})
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

minetest.register_chatcommand("mod_rm_range", {
    description = S("Remove nodes within a range"),
    privs = {server = true},
    func = function(name, param)
        return do_get_pos_confirm(name,
            function(pos_list)
                return S("remove nodes within the range @1 to @2",
                    vector.to_string(pos_list[1]),
                    vector.to_string(pos_list[2]))
            end, 2, function(pos_list)
                -- local minp, maxp = vector.sort(pos_list[1], pos_list[2])
                -- for x = minp.x, maxp.x do
                --     for z = minp.z, maxp.z do
                --         local pos = vector.new(x,1,z)
                --         minetest.set_node(pos, {name = "rp_mapgen_nodes:default_fill"})
                --     end
                -- end
                for pos in rp_utils.vector_range(pos_list[1], pos_list[2]) do
                    minetest.set_node(pos, {name = "rp_mapgen_nodes:default_fill"})
                end
                return true, minetest.colorize("orange", S("Removed nodes in range."))
            end)
    end
})

minetest.register_chatcommand("mod_set_color", {
    description = S("Replace nodes within a range to a specific color"),
    privs = {server = true},
    func = function(name, param)
        param = string.upper(param)
        if param == "LIST" or param == "" then
            local rstr = {"--- " .. S("List of node colors") .. " ---"}
            for hex, nname in pairs(rp_nodes.colors) do
                rstr[#rstr+1] = hex .. ": " .. nname
            end
            rstr[#rstr+1] = "--- " .. S("List end") .. " ---"
            return true, table.concat(rstr, "\n")
        end
        if not rp_nodes.colors[param] then
            return false, S("Color node \"@1\" not found. Try /mod_set_color list",param)
        end
        local nodename = "rp_nodes:color_" .. param
        return do_get_pos_confirm(name,
            function(pos_list)
                return S("replace nodes within the range @1 to @2 by @3",
                    vector.to_string(pos_list[1]),
                    vector.to_string(pos_list[2]),
                    minetest.registered_nodes[nodename].description)
            end, 2, function(pos_list)
                local minp, maxp = vector.sort(pos_list[1], pos_list[2])
                for x = minp.x, maxp.x do
                    for z = minp.z, maxp.z do
                        local pos = vector.new(x,1,z)
                        minetest.set_node(pos, {name = nodename})
                    end
                end
                return true, minetest.colorize("orange", S("Replaced nodes in range."))
            end)
    end
})