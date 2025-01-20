-- r_place/mods/rp_analysis/init.lua
-- Do analysis on nodes
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

local S = minetest.get_translator("rp_analysis")

rp_analysis = {}

rp_analysis.CACHE_TTL = 60
rp_analysis.renewed_time = 0
rp_analysis.cache = {}
rp_analysis.renew_cache = function()
    local cache = {
        by_player = {}, -- "" == Unknown
        by_color = {},
    }
    for x in rp_export.get_area_iterator(rp_core.area[1], rp_core.area[2], true) do
        local name = x.name
        local placer = x.placer
        if name then
            cache.by_color[name] = (cache.by_color[name] or 0) + 1
        end
        cache.by_player[placer] = (cache.by_player[placer] or 0) + 1
    end
    rp_analysis.cache = cache
    rp_analysis.renewed_time = os.time()
end

rp_analysis.get_cache = function()
    if os.time() - rp_analysis.renewed_time > rp_analysis.CACHE_TTL then
        rp_analysis.renew_cache()
    end
    return rp_analysis.cache
end

minetest.register_chatcommand("anal_force_update", {
    description = S("Force update analysis cache"),
    privs = {server = true},
    func = function(name, param)
        rp_analysis.renew_cache()
        return true, S("Done.")
    end
})

minetest.register_chatcommand("anal_player", {
    description = S("Get per-player analysis"),
    func = function(name, param)
        local cache = rp_analysis.get_cache()
        local rstr = "--- " .. S("Per-player analysis") .. " ---\n"
        for pname, count in pairs(cache.by_player) do
            if pname == "" then
                pname = S("Unknown")
            end
            local percent = (count / rp_core.area_size) * 100
            rstr = rstr .. string.format("%s: %d (%.1d%%)", pname, count, percent) .. "\n"
        end
        rstr = rstr .. S("Total: @1",rp_core.area_size) .. "\n"
        rstr = rstr .. "--- " .. S("List end") .. " ---"
        return true, rstr
    end
})


minetest.register_chatcommand("anal_color", {
    description = S("Get per-color analysis"),
    func = function(name, param)
        local cache = rp_analysis.get_cache()
        local rstr = "--- " .. S("Per-color analysis") .. " ---\n"
        for nname, count in pairs(cache.by_color) do
            local def = minetest.registered_nodes[nname]
            if def then
                local percent = (count / rp_core.area_size) * 100
                rstr = rstr .. string.format("%s: %d (%.1d%%)", def.description, count, percent) .. "\n"
            end
        end
        rstr = rstr .. S("Total: @1",rp_core.area_size) .. "\n"
        rstr = rstr .. "--- " .. S("List end") .. " ---"
        return true, rstr
    end
})