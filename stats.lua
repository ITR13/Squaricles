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

Stats = {
	[0] = 1,
	[2] = 2,
	[5] = 3,
	["hi"] = 5,
	["b"] = 6,
	["lol"] = "nice",
}

StatViewer = {
	stats = Stats,
	y = 0
}

function StatViewer:new(canvas, input)
	local o = clone(self)
	o.canvas = canvas
	o.input = input
	return o
end

function StatViewer:run(dt)
	local stop = false
	local actions = {
		[LEFT ] = function() end,
		[RIGHT] = function() end,
		[UP   ] = function() end,
		[DOWN ] = function() end,
		[A    ] = function()
			stop = true
		end,
		[B    ] = function()
			stop = true
		end,
		[START] = function()
			stop = true
		end,
	}
	self.input:useInput(function(key) actions[key]() end)
	if self.input:isDown(UP) then
		self.y = self.y+dt*HIGHSCORE_SCROLL_SPEED*font:getHeight()
	end
	if self.input:isDown(DOWN) then
		self.y = self.y-dt*HIGHSCORE_SCROLL_SPEED*font:getHeight()
	end
	return stop
end

function StatViewer:draw()
	love.graphics.setCanvas(self.canvas)
		love.graphics.clear(0,0,0,255)
		local w,h = self.canvas:getDimensions()
		local fHeight = font:getHeight()
		local y = self.y
		love.graphics.setColor(255,255,255,255)
		for k,v in pairs(self.stats) do
			love.graphics.print(
				k,
				w/4, y,
				0,
				1, 1,
				font:getWidth(k)/2, 0
			)
			love.graphics.print(
				v,
				3*w/4, y,
				0,
				1, 1,
				font:getWidth(v)/2, 0
			)
			y = y + fHeight
		end
	love.graphics.setCanvas()
end
