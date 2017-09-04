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

require ".helperfunctions"
require ".board"
require ".input"

Game = {}

function Game:new(canvas, input, gravity)
	--local width, height = canvas.getWidth(), canvas:getHeight()
	
	local pieces = {}
	for i=1,6 do
		pieces[i] = randomSquindice(DEFAULT_AMOUNT_OF_COLORS)
	end
	pieces[1].y = pieces[1].y - 1
	
	local o = {
		canvas = canvas,
		input = input,
		pieces = pieces,
		board = Board:new(),
		width = canvas:getWidth(),
		height = canvas:getHeight(),
		colors = DEFAULT_AMOUNT_OF_COLORS,
		gravity = gravity,
		timer = 4,
		restTimer = 0,
		placedPiece = false,
		squares = {timer = 0},
		
		clears = 0,
		score = 0,
	}
	
	for k,v in pairs(clone(self)) do o[k] = v end
	
	return o
end

function Game:draw()
	love.graphics.setCanvas(self.canvas)
		local w,h = self.width/self.board.width,self.height/self.board.height
		love.graphics.clear(COLORS["background"])
		self:drawBoard(w,h)
		self:drawSquares(w,h)
		self:drawPiece(w,h)
	love.graphics.setCanvas()
end

function Game:drawBoard(w,h)
	for i=1,self.board.height do
		local y = (i-1)*h + 4
		for j=1,self.board.width do 
			local x = (j-1)*w + 4
			love.graphics.setColor(COLORS[self.board[i][j]])
			love.graphics.rectangle('fill',x,y,w-8,h-8)
		end
	end
end

function Game:drawSquares(w,h)
	local alpha = 255*self.squares.timer/SQUARE_REMOVAL_TIME
	for k=1,#self.squares do
		love.graphics.setColor(255,255,255,alpha)
		local square = self.squares[k]
		
		local x0,y0 = square.x,square.y
		local dx,dy = 0,square.size
		for j=1,4 do
			local x,y = (x0+dx-1)*w+4,(y0+dy-1)*h+4
			love.graphics.rectangle('fill',x,y,w-8,h-8)
			dx,dy = dy,square.size-dx
		end
	end
end

function Game:drawPiece(w,h)
	local piece = self.pieces[1]
	local x0,y0 = piece.x,piece.y
	for i=1,2 do
		for j=1,2 do
			local x,y = (x0+j-2)*w,(y0+i-2)*h
			local c = piece.shape[i][j]
			if c ~= 0 then
				love.graphics.setColor(COLORS["outline"])
				love.graphics.rectangle(
					'fill',
					x-4,y-4,
					w+8,h+8
				)
				love.graphics.setColor(COLORS[c])
				love.graphics.rectangle(
					'fill',
					x+4,y+4,
					w-8,h-8
				)
			end
		end
	end
	local x,y = x0*w,y0*h
		
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle('fill',x-16,y-4,32,8)
	love.graphics.rectangle('fill',x-4,y-16,8,32)
end

function Game:update(dt)
	if self.lost then
		return
	elseif #self.squares ~= 0 then
		self:squareRemovalUpdate(dt)
	else
		self:playUpdate(dt)
	end
end

function Game:squareRemovalUpdate(dt)
	self.input:useInput(function(key)
		if key~=UP and self:parseInput(key) then
			self.restTimer = 0
		end
	end)
	
	self.squares.timer = self.squares.timer + dt
	if self.squares.timer >= SQUARE_REMOVAL_TIME then
		local newTime = self.squares.timer - SQUARE_REMOVAL_TIME
		self.board:removeSquares(self.squares)
		self.board:gravBoard()
		self.squares = self.board:findSquares()
		self.squares.timer = newTime
	end
end

function Game:playUpdate(dt)
	self:checkGravity(dt)
	self.input:useInput(function(key)
		if self:parseInput(key) then
			self.restTimer = 0
		end
	end)
	
	if self.placedPiece then
		self.placedPiece = false
		self:addClear()
		self.board:gravBoard()
		self.squares = self.board:findSquares()
		self.squares.timer = 0
	end
end

function Game:checkGravity(dt)
	if self.pieces[1]:isBlocked(0,-1,self.board) then
		self.restTimer = self.restTimer + dt
		if self.restTimer >= REST_TIME then
			self:place()
		end
	else
		if self.gravity>0 then
			self.timer = self.timer - dt
			while self.timer <= 0 do
				self:movePiece(0,-1)
				self.timer = self.timer + self.gravity
			end
		else
			while self:movePiece(0,-1) do end
		end
	end
end

function Game:place()
	local piece = self.pieces[1]
	local x0,y0 = piece.x,piece.y

	for i=1,2 do
		for j=1,2 do
			local c = piece.shape[i][j]
			if c ~= 0 then
				self.board[y0+i-1][x0+j-1] = c
			end
		end
	end
	self.placedPiece = true
	
	for i=2,#self.pieces do
		self.pieces[i-1] = self.pieces[i]
	end
	self.pieces[#self.pieces] = randomSquindice(self.colors)
	
	local piece = self.pieces[1]
	if piece:isBlocked(0,0,self.board) then
		self.lost = true
	end
	
	self.restTimer = 0
	self.timer = IDLE_TIME
end

function Game:parseInput(key)
	actions = {
		[UP] = function() return self:hardDrop() end,
		[DOWN] = function() return self:movePiece(0,-1) end,
		[LEFT] = function() return self:movePiece(-1,0) end,
		[RIGHT] = function() return self:movePiece(1,0) end,
		[A] = function() return self.pieces[1]:doRotate(false,self.board) end,
		[B] = function() return self.pieces[1]:doRotate(true,self.board) end,
	}	
	return actions[key]()
end

function Game:hardDrop()
	while self:movePiece(0,-1) do end
	self:place()
	return true
end

function Game:movePiece(dx, dy)
	local piece = self.pieces[1]

	if piece:isBlocked(dx,dy,self.board) then
		local shape = piece.shape
		if dy == -1 and shape[2][1]==0 and shape[2][2]==0 then
			shape[1], shape[2] = shape[2], shape[1]
			piece.y = piece.y+1
		end
		if dx == 1 and shape[1][1]==0 and shape[2][1]==0 then
			shape[1][1], shape[1][2] = shape[1][2],shape[1][1]
			shape[2][1], shape[2][2] = shape[2][2],shape[2][1]
			piece.x = piece.x+1
		elseif dx == -1 and shape[1][2]==0 and shape[2][2]==0 then
			shape[1][1], shape[1][2] = shape[1][2],shape[1][1]
			shape[2][1], shape[2][2] = shape[2][2],shape[2][1]
			piece.x = piece.x-1
		end
		return false
	end
	piece.x = piece.x + dx
	piece.y = piece.y + dy
	return true
end

function Game:addScore(squares)
	for i=1,#squares do
		game.score = game.score + squares[i].size
	end
end

function Game:addClear()
	self.clears = self.clears + 1
	if self.clears>250 then
		self.gravity = 0
	elseif self.clears%10==0 then
		self.gravity = self.gravity * 0.8
	end
end