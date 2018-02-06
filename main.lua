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

local WIDTH = 1920.0/2
local HEIGHT = 1200.0
local rescaleNextFrame = false

font = love.graphics.newFont("font/Play-Bold.ttf",60)
love.graphics.setFont(font)

function love.load()
	initRandom()
	love.window.setMode(
		0,
		0,
		{resizable = true, centered = true}
	)

	love.window.setTitle("Squaricles")
	
	leftCanvas =  love.graphics.newCanvas(WIDTH, HEIGHT)
	--rightCanvas = love.graphics.newCanvas(WIDTH, HEIGHT)
		
	wrappers = {
		Wrapper:new(leftCanvas, QWEASD),
		--Wrapper:new(rightCanvas, ARROWS),
	}
	rescaleNextFrame = true
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
	local w = love.graphics.getWidth()/#wrappers
	local h = love.graphics.getHeight()

	if rescaleNextFrame then
		w, h = w/1920, h/1200
		rescaleNextFrame = false
	 	if w<h then
			love.window.setMode(
				w*WIDTH,
				w*HEIGHT,
				{resizable = true, centered = true}
			)
			w = w*WIDTH
			h = w*HEIGHT
		else
			love.window.setMode(
				h*WIDTH,
				h*HEIGHT,
				{resizable = true, centered = true}
			)
			w = h*WIDTH
			h = h*HEIGHT
		end
	end

	for i=1,#wrappers do
		wrappers[i]:draw()
	end
	
	love.graphics.setCanvas()
	love.graphics.clear(0x00,0x00,0x00,000)
	love.graphics.setColor(255,255,255,255)
	
	local mult = 1
	
	if w/WIDTH < h/HEIGHT then
		mult = w/WIDTH
	else
		mult = h/HEIGHT
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
