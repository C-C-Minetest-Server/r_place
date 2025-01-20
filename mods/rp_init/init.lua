-- r_place/mods/rp_init/init.lua
-- Scripts that shall be run before any other mods
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

-- This mod contains scripts that nust be executed before everything happen.
-- This mod must be standalone, i.e. NOT depending on any other mods.
-- Other mods in rPlace SHOULD depend on this mod.

-- Set random seed
math.randomseed(os.time())

minetest.log("[rp_init] Init done")