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

Options = {
	list = {
		{'mode', "NORMAL", {"NORMAL", "TRIPLE", "MODE-D"}},
		{'draw_symbol', DRAW_SYMBOL, {true, false}},
	},
	selectedOption = 1,
}

function Options:new(canvas, input)
	local o = clone(self)
	o.canvas = canvas
	o.input = input
	for i = 1,#o.list do
		o[o.list[i][1]] = o.list[i][2]
	end
	return o
end

function Options:draw()
	love.graphics.setCanvas(self.canvas)
		love.graphics.clear(0,0,0,255)
		love.graphics.setColor(255,255,255)
		
		local fHeight = font:getHeight()
		local y = self.canvas:getHeight()/2 - fHeight*(#self.list+0.5)/2
		local x = self.canvas:getWidth()/2
		
		for i = 1,#self.list do
			local keyw = font:getWidth(self.list[i][1])
			local valuew = font:getWidth(tostring(self.list[i][2]))
			love.graphics.print(
				self.list[i][1],
				x, y,
				0,
				1, 1,
				keyw+16, 0
			)
			love.graphics.setColor(255,200,0)
			love.graphics.print(
				tostring(self.list[i][2]),
				x, y,
				0,
				1, 1,
				-16, 0
			)
			love.graphics.setColor(255,255,255)
			if i == self.selectedOption then
				love.graphics.rectangle(
					"line",
					x - keyw-32, y-16,
					keyw+valuew+64,
					fHeight+32,
					2, 2
				)
			end
			y = y+font:getHeight()+32
		end
		
	love.graphics.setCanvas()
end

function Options:run()
	local stop = false
	local offset = 0
	local actions = {
		[LEFT ] = function() 
			self:moveValue(self.selectedOption, -1)
		end,
		[RIGHT] = function() 
			self:moveValue(self.selectedOption, 1)
		end,
		[UP   ] = function() 
			offset = offset - 1
		end,
		[DOWN ] = function() 
			offset = offset + 1
		end,
		[A    ] = function()
			stop = true
			--self:moveValue(self.selectedOption, 1)
		end,
		[B    ] = function()
			stop = true
		end,
		[START] = function()
			stop = true
		end,
	}
	self.input:useInput(function(key) actions[key]() end)

	self.selectedOption = (self.selectedOption+offset-1)%#self.list + 1
	
	return stop
end

function Options:moveValue(listIndex, offset)
	local option = self.list[listIndex]
	local current = 0
	for i = 1,#option[3] do
		if option[3][i] == option[2] then
			current = i
			break
		end
	end
	if current == 0 then
		option[2] = option[3][1]
	else
		current = (current+offset-1)%#option[3] + 1
		option[2] = option[3][current]
	end
	self[option[1]] = option[2]
end