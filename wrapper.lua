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

require ".anitext"
require ".menu"
require ".options"
require ".highscores"

local LOSE_WAIT_TOTAL = LOSE_ANIM_SPEED*LOSE_ANIM_END_WAIT+10

Wrapper = {}

function Wrapper:new(canvas, input)
	local o = clone(self)
	o.canvas = canvas
	o.input = input
	
	o.mainMenu = Menu:new(canvas, {
		"New Game",
		"Highscores",
		"Stats",
		"Options",
		"Quit"
	})
	
	o.options = Options:new()
	
	o.current = function(dt) o:executeMainMenu() end
	o.drawing = function() o:drawMainMenu() end
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

function Wrapper:executeMainMenu()
	actions = {
		[1] = function()		--New Game
			self:createGame()
		end,
		[2] = function()		-- Highscores
			
		end,
		[3] = function()		-- Stats
		
		end,
		[4] = function()		-- Options
		
		end,
		[5] = function()		-- Quit
			quit()
		end,
	}
	local action = self.mainMenu:run(self.input)
	if action > 0 then
		actions[action]()
	end
end

function Wrapper:drawMainMenu()
	love.graphics.setCanvas(self.canvas)
		love.graphics.clear(0,0,0,255)
		self.mainMenu:draw()
	love.graphics.setCanvas()
end

function Wrapper:createGame()
	local gameCanvas = 
		love.graphics.newCanvas(600, 1000)
	local game = Game:new(gameCanvas,self.input,self.options)

	local scoreText = AniText:new()
	local levelText = AniText:new()
	
	self.current = function(dt)
		game:update(dt)
		scoreText:update(dt)
		levelText:update(dt)
		if game.lost and game.lostAnim >= LOSE_WAIT_TOTAL then
			self:startHighScore(game.score)
		end
	end
	self.drawing = function() 
		game:draw()
		love.graphics.setCanvas(self.canvas)
			love.graphics.clear(0x00,0x00,0x00,000)
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(GAMEBACKGROUND)
			love.graphics.draw(MODEIMAGE[self.options.mode])
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
			scoreText:draw(game.score, 781, 437)
			levelText:draw(game.level, 784, 780)
			
		love.graphics.setCanvas()
	end
	self.playing = true
end

function Wrapper:startHighScore(score)
	self.playing = false
	local index = HighscoreList:addScore(score)
	local displayer = HighscoreDisplayer:new(self.input,index)
	self.current = function(dt)
		if displayer:run(dt) then
			self.current = function(dt) self:executeMainMenu() end
			self.drawing = function() self:drawMainMenu() end
		end
	end

	self.drawing = function()
		displayer:draw(self.canvas)
	end
end
