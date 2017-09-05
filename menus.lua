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

Wrapper = {}

function Wrapper:new(canvas, input, color)
	local o = clone(self)
	o.canvas = canvas
	o.input = input
	o.current = function(dt) o:mainMenu() end
	o.drawing = function() o:drawMainMenu() end
	o.color = color
	return o
end

function Wrapper:draw()
	if self.drawing then
		self.drawing()
	end
end

function Wrapper:update(dt)
	if self.current then
		self.current(dt)
	end
end

function Wrapper:mainMenu()
	self.input:useInput(function(key)
		actions = {
			[A] = function()
				local game = Game:new(self.canvas,self.input,2)
				self.current = function(dt)
					game:update(dt)
					if game.lost then
						self.current = function(dt) self:mainMenu() end
						self.drawing = function() self:drawMainMenu() end
						self.playing = false
					end
				end
				self.drawing = function() game:draw() end
				self.playing = true
			end,
			[B] = function()
				-- Highscores
			end,
			[LEFT] = function()
				-- Stats
			end,
			[RIGHT] = function()
				quit()
			end,
			[UP]= function() end,
			[DOWN]= function() end,
		}
		
		actions[key]()
	end)
end

function Wrapper:drawMainMenu()
	love.graphics.setCanvas(self.canvas)
		love.graphics.clear(self.color)
	love.graphics.setCanvas()
end