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

require ".helperfunctions"

UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4
A = 5
B = 6
START = 7

Input = {queue = {}, keys = {}}

function love.keypressed( key, scancode, isrepeat)
	for i=1,#Inputs do
		local keys = Inputs[i].keys
		for j=1,#keys do
			if keys[j]==key then
				Inputs[i].queue[#Inputs[i].queue+1] = j
			end
		end
	end
end

function Input:useInput(func)
	if func ~= nil then
		for i=1,#self.queue do
			success = func(self.queue[i]) or success
		end
	end
	for i in pairs(self.queue) do self.queue[i] = nil end
end

QWEASD = clone(Input)
QWEASD.keys[UP] = "w"
QWEASD.keys[DOWN] = "s"
QWEASD.keys[LEFT] = "a"
QWEASD.keys[RIGHT] = "d"
QWEASD.keys[A] = "q"
QWEASD.keys[B] = "e"
QWEASD.keys[START] = "space"

ARROWS = clone(Input)
ARROWS.queue = QWEASD.queue
ARROWS.keys[UP] = "up"
ARROWS.keys[DOWN] = "down"
ARROWS.keys[LEFT] = "left"
ARROWS.keys[RIGHT] = "right"
ARROWS.keys[A] = "rshift"
ARROWS.keys[B] = "rctrl"
ARROWS.keys[START] = "return"


Inputs = {QWEASD, ARROWS}

