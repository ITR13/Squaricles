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
require ".stats"
require ".gameinfo"

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
	
	o.options = Options:new(canvas, input)
	
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
			self:startGame()
		end,
		[2] = function()		-- Highscores

		end,
		[3] = function()		-- Stats
			self:startStats()
		end,
		[4] = function()		-- Options
			self:startOptions()
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

function Wrapper:startGame()
	local gameCanvas = 
		love.graphics.newCanvas(600, 1000)
	local game = Game:new(gameCanvas,self.input,self.options)
	local gameInfoDisplayer = GameInfoDisplayer:new(game,self.options.mode)
	self.current = function(dt)
		game:update(dt)
		gameInfoDisplayer:update(dt)
		if game.lost and game.lostAnim >= LOSE_WAIT_TOTAL then
			self:startHighScore({game.score,game.level})
		end
	end
	self.drawing = function() 
		game:draw()
		love.graphics.setCanvas(self.canvas)
			gameInfoDisplayer:draw()
			love.graphics.draw(gameCanvas,10,190)
		love.graphics.setCanvas()
	end
	self.playing = true
end

function Wrapper:startOptions()
	self.playing = false
	self.current = function(dt)
		if self.options:run() then
			self.current = function(dt) self:executeMainMenu() end
			self.drawing = function() self:drawMainMenu() end
		end
	end
	self.drawing = function()
		self.options:draw()
	end
end

function Wrapper:startHighScore(score)
	self.playing = false
	HighscoreList:addScore(score,self.options.mode)
	local displayer = HighscoreDisplayer:new(
						self.input,
						self.options.mode,
						score
					)
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

function Wrapper:startStats()
	self.playing = false
	local viewer = StatViewer:new(self.canvas,self.input)
	self.current = function(dt)
		if viewer:run(dt) then
			self.current = function(dt) self:executeMainMenu() end
			self.drawing = function() self:drawMainMenu() end
		end
	end
	self.drawing = function()
		viewer:draw()
	end
end
