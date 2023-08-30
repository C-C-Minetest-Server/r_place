-- r_place/mods/rp_random_messages/init.lua
-- Random messages
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

local S = minetest.get_translator("rp_random_messages")

local random_messages = {
    S("Punch an existing color node to put it onto your hand."),
    S("You will have to wait for @1 seconds before placing down another node.", rp_core.time_delay),
    S("You are allowed to cover up other's works, but try not to do that if you can find empty spaces."),
    S("Rightclick a pixel to replace it with the color on your hand."),
    S("Use /anal_player to see per-player node placement count.")
}

random_messages_api.from_table(random_messages)

