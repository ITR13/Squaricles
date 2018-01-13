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

Menu = {
	elements = {},
	maxWidth = 0.,
	spacing = 4,
	selectedOption = 1
}

function Menu:new(canvas, elements)
	local o = clone(self)
	o.elements = elements or o.elements
	o.canvas = canvas
	for i = 1,#o.elements do
		local w = font:getWidth(o.elements[i])
		if w > o.maxWidth then
			o.maxWidth = w
		end
	end
	return o
end

function Menu:draw()
	local w, h = self.canvas:getDimensions()
	local dy = #self.elements*(font:getHeight()+self.spacing)
	local y = h/2 - dy/2
		
	love.graphics.setColor(63,63,63,255)
	love.graphics.rectangle(
		"fill", 
		w/2 - self.maxWidth/2 - 16,
		h/2 - dy/2 - 8,
		self.maxWidth + 32,
		dy + 16,
		20,
		20
	)
	
	love.graphics.setLineWidth(4)
	love.graphics.setColor(255,255,255,255)
	for i = 1,#self.elements do
		local dx, dy = font:getWidth(self.elements[i]), font:getHeight()
	
		love.graphics.print(
			self.elements[i],
			w/2, y,
			0,
			1, 1,
			dx/2, 0
		)
		if i == self.selectedOption then
			love.graphics.rectangle(
				"line", 
				w/2 - dx/2 - 8,
				y + self.spacing/2,
				dx + 16, dy+self.spacing,
				2, 2
			)
		end
		
		y = y + font:getHeight() + self.spacing
	end
	love.graphics.setLineWidth(1)
end

function Menu:run(input)
	local run = false
	local offset = 0
	local stop = false

	local actions = {
		[A] = function()
			run = true
		end,
		[B] = function()
			stop = true
		end,
		[LEFT] = function() end,
		[RIGHT] = function() end,
		[UP]= function() 
			offset = offset + 1
		end,
		[DOWN]= function() 
			offset = offset - 1
		end,
	}
	input:useInput(function(key) actions[key]() end)

	self.selectedOption = (self.selectedOption+offset-1)%#self.elements + 1
	if run then
		return self.selectedOption
	elseif stop then
		return #self.elements
	end
	return 0
end