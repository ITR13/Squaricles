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
			[A] = function()		--New Game
				self:createGame()
			end,
			[B] = function()		-- Highscores
				
			end,
			[LEFT] = function()		-- Stats
			
			end,
			[RIGHT] = function()	-- Quit
				--quit()
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

function Wrapper:createGame()
	local gameCanvas = 
		love.graphics.newCanvas(600, 1000)
	local game = Game:new(gameCanvas,self.input,0)

	self.current = function(dt)
		game:update(dt)
		if game.lost then
			self.current = function(dt) self:mainMenu() end
			self.drawing = function() self:drawMainMenu() end
			self.playing = false
		end
	end
	self.drawing = function() 
		game:draw()
		love.graphics.setCanvas(self.canvas)
			love.graphics.clear(0x00,0x00,0x00,000)
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(GAMEBACKGROUND)
			love.graphics.draw(gameCanvas,10,190)
			
			for p=1,#PREVIEWS do
				setColor("background")
				preview = PREVIEWS[p]
				love.graphics.rectangle('fill',unpack(preview))
				piece = game.pieces[p]
				w,h = preview[3]/2,preview[4]/2
				for i=1,2 do
					for j=1,2 do
						x,y = preview[1]+(2-j)*w,preview[2]+(2-i)*h
						setColor(piece.shape[i][j])
						love.graphics.rectangle('fill',
							x+PREVIEW_INDENT[i][j][1],
							y+PREVIEW_INDENT[i][j][2],
							w-PREVIEW_INDENT[i][j][3],
							h-PREVIEW_INDENT[i][j][4]
						)
					end
				end
			end
			
			love.graphics.setColor(255,255,255)
			love.graphics.print(
				game.score,
				781 - font:getWidth(game.score)/2,
				437 - font:getHeight()/2,
				0
			)
			love.graphics.print(
				game.level,
				784 - font:getWidth(game.score)/2,
				780 - font:getHeight()/2,
				0
			)
			
		love.graphics.setCanvas()
	end
	self.playing = true
end
