-- r_place/mods/rp_initial_message/init.lua
-- Send message when a player joins
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

local S = minetest.get_translator("rp_initial_message")

local function C(msg)
    return minetest.colorize("orange", msg)
end

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()

    minetest.chat_send_player(name, C(S("Welcome to rPlace Minetest Server!")))
    minetest.chat_send_player(name, C(S("Here, you can place pixels to form pictures!")))
    minetest.chat_send_player(name, C(S("All colors are in your inventory; Press `I` to put them onto the hotbar.")))
end)