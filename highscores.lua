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

require ".rules"

HighscoreList = {
	sorted = false,
}

HighscoreDisplayer = {
	list = HighscoreList,
	index = 5,
	highlight = nil,
}

function HighscoreList:addScore(score)
	self[#self+1] = score
	self.sorted = false
	self:sort()
	for i=1,#self do
		if self[i] <= score then
			return i
		end
	end
	return nil
end

function HighscoreList:sort()
	--Slow, switch out later
	if not self.sorted then
		for i=1,#self do
			for j=i+1,#self do
				if self[i]<self[j] then
					self[i],self[j] = self[j],self[i]
				end
			end
		end
		self.sorted = true;
	end
end

function HighscoreDisplayer:new(input, index)
	local o = clone(self)
	o.input = input
	o.index = (index or o.index) - 5.
	o.highlight = index
	return o
end

function HighscoreDisplayer:run(dt)
	local dy = 0.
	local stop = false

	local actions = {
		[LEFT ] = function() end,
		[RIGHT] = function() end,
		[UP   ] = function() 
			dy = dy-dt*HIGHSCORE_SCROLL_SPEED
		end,
		[DOWN ] = function() 
			dy = dy-dt*HIGHSCORE_SCROLL_SPEED
		end,
		[A    ] = function()
			stop = true
		end,
		[B    ] = function()
			stop = true
		end,
		[START] = function()
			run = true
		end,
	}
	self.input:useInput(function(key) actions[key]() end)
	self.index = self.index+dy
	return stop
end

function HighscoreDisplayer:draw(canvas)
	love.graphics.setCanvas(canvas)
		love.graphics.clear(0,0,0,255)
		local w,h = canvas:getDimensions()
		local fHeight = font:getHeight()
		local elements = h/fHeight + 1
		for i = 0,elements do
			local y = i*fHeight+self.index%1
			local index = math.floor(self.index+i)

			if index > 0 and index <= #self.list then
				if index == self.highlight then
					love.graphics.setColor(255,220,0,255)
				else
					love.graphics.setColor(255,255,255,255)
				end
				love.graphics.print(
					self.list[index],
					w/2, y,
					0,
					1, 1,
					font:getWidth(self.list[index])/2, fHeight/2
				)
			end
		end
	love.graphics.setCanvas()
end
