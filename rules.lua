--[[
    Squaricles
    Copyright (C) 2017  ITR

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>
]]--

COLORS = {
	["outline"] = {255,255,255},
	["background"] = {0x54,0x4B,0x3D},
	[-1] = {0,0,0}, --"this should not happen",
	[0] = {0xBA,0xAB,0x68},
	{0x54,0x66,0x39},
	{0x7A,0xDF,0xBB},
	{0xFA,0x79,0x21},
	{0x28,0x0F,0x15},
	{0xE8,0xE8,0xE8},
	{0x42,0x3B,0x0B},
}

ENABLE_SPINJUMPING = true
DEFAULT_AMOUNT_OF_COLORS = 6


SIMPLE_CHANCE = 79
DIAGONAL_CHANCE = 5
COURNER_CHANCE = 8


REST_TIME = 3.0
IDLE_TIME = 0.25
SQUARE_REMOVAL_TIME = 0.2


--[[ Backgrounds ]]--
GAMEBACKGROUND = love.graphics.newImage("img/Game.png")
PREVIEWS = {
	{14,13,166,163},
	{193,32,131,128},
	{334,32,131,128},
	{476,32,131,128},
}

PREVIEW_INDENT = {
	{{2,2,8,8},{6,2,8,8}},
	{{2,6,8,8},{6,6,8,8}},
}