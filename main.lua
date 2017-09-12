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
require ".input"
require ".squindices"
require ".board"
require ".game"
require ".wrapper"

WIDTH = 1920 * 4/5 		/ 2
HEIGHT = 1200 * 4/5		/ 2

function love.load()
	initRandom()
	love.window.setMode( WIDTH, HEIGHT, {resizable = true, centered = true})
	love.window.setTitle("Squaricles")
	
	leftCanvas =  love.graphics.newCanvas(1920/2, 1200)
	rightCanvas = love.graphics.newCanvas(1920/2, 1200)
		
	wrappers = {
		Wrapper:new(leftCanvas, QWEASD, {255,0,0}),
		Wrapper:new(rightCanvas, ARROWS, {0,255,0}),
	}
end

function quit(force)
	if force then
		love.event.quit()
		return
	end

	for i=1,#wrappers do
		if wrappers[i].playing then
			return
		end
	end
	love.event.quit()
end

function love.draw()
	for i=1,#wrappers do
		wrappers[i]:draw()
	end
	
	love.graphics.setCanvas()
	love.graphics.clear(0x00,0x00,0x00,000)
	love.graphics.setColor(255,255,255,255)
	
	w = love.graphics.getWidth()/#wrappers
	h = love.graphics.getHeight()
	
	for i=1,#wrappers do
		love.graphics.draw(wrappers[i].canvas, (i-1)*w, 0, 0,
			w/(1920/2), h/(1200), 0, 0)
	end
	
	if DEBUGONSCREEN then
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(DEBUGONSCREEN)
	end
end

function love.update(dt)
	for i=1,#wrappers do
		wrappers[i]:update(dt)
	end
end

function initRandom()
	math.randomseed(os.time())
	for i=0,10 do 
		math.random()
	end
end

function setColor(colorindex, makeghost)
	local c = COLORS[colorindex]
	if makeghost then 
		c[4] = 127
	else
		c[4] = 255	
	end
	love.graphics.setColor(c)
end