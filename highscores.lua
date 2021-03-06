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
require ".helperfunctions"

HighscoreList = {
}

HighscoreDisplayer = {
	index = 0.5,
	highlight = nil,
	byLevel = false,
}

function writeScore(file, score)
	if file:tell() > 0 then
		file:write("\n")
	end
	file:write(tostring(score[1]))
	file:write("\t")
	file:write(tostring(score[2]))
end

function LoadList(mode)
	local dirty = false
	local f = love.filesystem.newFile(mode..".hs","r")
	local t = {}
		
	if f then
		for line in f:lines() do
			local numbers = split(line,"\t")
			if #numbers == 2 then
				local n1, n2 = tonumber(numbers[1]), tonumber(numbers[2])
				if n1 ~= nil or n2 ~= nil then
					local index = #t+1
					t[index] = {index = index}
					t[index][1] = tonumber(n1)
					t[index][2] = tonumber(n2)	
				else
					dirty = true
				end
			else
				dirty = true
			end
		end
	end
	
	if dirty then
		local f = love.filesystem.newFile(mode..".hs","w")
		if f then
			for i=1,#t do
				writeScore(f,i)
			end
			f:close()
		end
	end

	return t
end

for i=1,#MODES do
	HighscoreList[MODES[i]] = LoadList(MODES[i])
end

function HighscoreList:addScore(score, mode)
	score.index = #self[mode]+1
	self[mode][score.index] = score

	local f = love.filesystem.newFile(mode..".hs","a")
	if f then
		writeScore(f,score)
		f:close()
	end
end

function HighscoreDisplayer:new(input, mode, score)
	local o = clone(self)
	o.input = input


	o.list = clone(HighscoreList[mode])
	o:sort()

	if score then
		o.highlight = score.index
		o:setIndex(score.index)
		return o
	end
	return o
end

function HighscoreDisplayer:sort()
	if self.byLevel then
		table.sort(self.list, function (a,b)
			if a[2] == b[2] then
				return a[1]>b[1]
			end
			return a[2]>b[2]
		end)
	else
		table.sort(self.list, function (a,b)
			if a[1] == b[1] then
				return a[2]>b[2]
			end
			return a[1]>b[1]
		end)
	end
end

function HighscoreDisplayer:setIndex(index)
	for i=1,#self.list do
		if self.list[i].index==index then
			self.index = i-5
			return
		end
	end
end

function HighscoreDisplayer:run(dt)
	local dy = 0.
	local stop = false

	local actions = {
		[LEFT ] = function() 
			if self.byLevel then
				self.byLevel = false
				self:sort()
				if self.highlight then
					self:setIndex(self.highlight)
				end
			end
		end,
		[RIGHT] = function()
			if not self.byLevel then
				self.byLevel = true
				self:sort()
				if self.highlight then
					self:setIndex(self.highlight)
				end
			end
		end,
		[UP   ] = function() end,
		[DOWN ] = function() end,
		[A    ] = function()
			self.byLevel = not self.byLevel
			self:sort()
			if self.highlight then
				self:setIndex(self.highlight)
			end
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
		dy = dy-dt*HIGHSCORE_SCROLL_SPEED
	end
	if self.input:isDown(DOWN) then
		dy = dy+dt*HIGHSCORE_SCROLL_SPEED
	end
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
				if self.list[index].index == self.highlight then
					love.graphics.setColor(255,220,0,255)
				else
					love.graphics.setColor(255,255,255,255)
				end
				love.graphics.print(
					self.list[index][1],
					w/4, y,
					0,
					1, 1,
					font:getWidth(self.list[index][1])/2, fHeight/2
				)
				love.graphics.print(
					self.list[index][2],
					3*w/4, y,
					0,
					1, 1,
					font:getWidth(self.list[index][2])/2, fHeight/2
				)
			end
		end
	love.graphics.setCanvas()
end
