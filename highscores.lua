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
	self[#self] = score
	self.sorted = false
	self:sort()
	for i=5,#self do
		if self[i] >= score then
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

