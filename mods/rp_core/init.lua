-- r_place/mods/rp_core/init.lua
-- Handle area and node placement
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

rp_core = {}

function rp_core.log(lvl,msg)
    return minetest.log(lvl,"[rp_core] " .. msg)
end

local MP = minetest.get_modpath("rp_core")

local scripts = {
    "mapgen",
    "border",
    "player",
    "placement"
}

for _,n in ipairs(scripts) do
    dofile(MP .. "/" .. n .. ".lua")
end

