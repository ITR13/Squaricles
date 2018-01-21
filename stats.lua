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

Stats = { values = {} }

StatViewer = {
	stats = Stats,
	y = 0
}

function Stats:max(key, value)
	if Stats.values[key] and Stats.values[key]>=value then
		return
	end
	Stats.values[key] = value
end

function Stats:min(key, value)
	if Stats.values[key] and Stats.values[key]<=value then
		return
	end
	Stats.values[key] = value
end

function Stats:add(key)
	if Stats.values[key] then
		Stats.values[key] = Stats.values[key]+1
	else
		Stats.values[key] = 1
	end
end

Stats:add("Opened Game")

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
		for k,v in pairs(self.stats.values) do
			love.graphics.print(
				k,
				0, y,
				0,
				1, 1,
				0, 0
			)
			love.graphics.print(
				v,
				w, y,
				0,
				1, 1,
				font:getWidth(v), 0
			)
			y = y + fHeight
		end
	love.graphics.setCanvas()
end
