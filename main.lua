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
HEIGHT = 1200 * 4/5		--/ 2

font = love.graphics.newFont("font/Play-Bold.ttf",60)
love.graphics.setFont(font)

function love.load()
	initRandom()
	love.window.setMode( WIDTH, HEIGHT, {resizable = true, centered = true})
	love.window.setTitle("Squaricles")
	
	leftCanvas =  love.graphics.newCanvas(1920/2, 1200)
	--rightCanvas = love.graphics.newCanvas(1920/2, 1200)
		
	wrappers = {
		Wrapper:new(leftCanvas, QWEASD, {255,0,0}),
		--Wrapper:new(rightCanvas, ARROWS, {0,255,0}),
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
	
	local w = love.graphics.getWidth()/#wrappers
	local h = love.graphics.getHeight()
	local mult = 1
	
	if w/(1920/2) < h/(1200/1) then
		mult = w/(1920/2)
	else
		mult = h/(1200/1)
	end
	
	
	for i=1,#wrappers do
		love.graphics.draw(
			wrappers[i].canvas, 
			(w-(1920/2)*mult)/2 + (i-1)*w, 
			(h-(1200/1)*mult)/2, 
			0,
			mult, mult, 
			0, 0
		)
	end
	
	if DEBUGONSCREEN then
		love.graphics.setColor(255,255,255,255)
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

function setColor(colorindex, makeghost, inverted)
	local c = {}
	if inverted then
		for i=1,3 do
			c[i] = 255-COLORS[colorindex][i]
		end
	else
		for i=1,3 do
			c[i] = COLORS[colorindex][i]
		end
	end
	if makeghost then 
		c[4] = 127
	else
		c[4] = 255	
	end
	love.graphics.setColor(c)
end