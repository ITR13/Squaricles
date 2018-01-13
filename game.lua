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

function Game:new(canvas, input, level)
	local pieces = {}
	for i=0,#PREVIEWS do
		pieces[i] = randomSquindice(DEFAULT_AMOUNT_OF_COLORS)
	end
	pieces[0].y = pieces[0].y + 1
	
	local o = {
		canvas =		canvas,
		input =			input,
		pieces =		pieces,
		board =			Board:new(),
		width =			canvas:getWidth(),
		height =		canvas:getHeight(),
		colors =		DEFAULT_AMOUNT_OF_COLORS,
		gravity =		DEFAULT_GRAVITY * math.pow(0.8, level),
		level =			level,
		timer =			4,
		restTimer =		0,
		placedPiece =	false,
		squares = 		{timer = 0},
		
		pause = 		false,
		pauseTimer = 	0.,
		
		clears = 		0,
		score = 		0,
	}
	
	for k,v in pairs(clone(self)) do o[k] = v end

	o:checkGhost()
	
	return o
end

function Game:draw()
	love.graphics.setCanvas(self.canvas)
		local w,h = self.width/self.board.width,self.height/self.board.height
		love.graphics.clear(COLORS["background"])
		if not (self.pause or self.pauseTimer > 0) then		
			self:drawBoard(w,h)
			self:drawSquares(w,h)
			if self.ghost then self:drawPiece(self.pieces[0],w,h,true) end
			self:drawPiece(self.pieces[0],w,h)
		end
	love.graphics.setCanvas()
end

function Game:drawBoard(w,h)
	for i=1,self.board.height do
		local y = (i-1)*h + 4
		for j=1,self.board.width do 
			local x = (j-1)*w + 4
			setColor(self.board[i][j])
			love.graphics.rectangle('fill',x,y,w-8,h-8)
			if self.board[i][j]>0 and DRAW_SYMBOL then
				setColor(self.board[i][j],false,true)
				love.graphics.polygon(
					'fill',
					polyregular(
						self.board[i][j]%3+3,
						x+w/2,y+h/2,
						w*1/3,h*1/3
					)
				)
			end
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

function Game:drawPiece(piece, w,h, ghost)
	local x0,y0 = piece.x,piece.y
	if y0<1 then return end
	
	for j=1,2 do
		local y0 = y0
		if ghost then
			while self.board[y0+1][x0-j+1] == 0 do y0 = y0+1 end
			if piece.shape[1][j] ==0 then
				y0 = y0+1
			end
		end
		for i=1,2 do
			local x,y = (x0-j)*w,(y0-i)*h
			local c = piece.shape[i][j]
			if c ~= 0 then
				setColor("outline",ghost)
				love.graphics.rectangle(
					'fill',
					x-4,y-4,
					w+8,h+8
				)
				setColor(c,ghost)
				love.graphics.rectangle(
					'fill',
					x+4,y+4,
					w-8,h-8
				)
				if DRAW_SYMBOL then
					setColor(c,ghost,true)
					love.graphics.polygon(
						'fill',
						polyregular(
							c%3+3,
							x+w/2,y+h/2,
							w*1/3,h*1/3
						)
					)
				end
			end
		end
	end
	local x,y = (x0-1)*w,(y0-1)*h
	
	if not ghost then
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle('fill',x-16,y-4,32,8)
		love.graphics.rectangle('fill',x-4,y-16,8,32)
	end
end

function Game:update(dt)
	if self.pause or self.pauseTimer > 0 then
		self.pauseTimer = self.pauseTimer - dt
		self.input:useInput(function(key) 
			self:togglePause()
		end)
		return
	end
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
		self.board:gravBoard()
		self.squares = self.board:findSquares()
		if #self.squares>0 then
			self:addScore(self.squares)
			self:addClear()
		end
		self.squares.timer = 0
	end
end

function Game:checkGravity(dt)
	if self.pieces[0]:isBlocked(0,1,self.board) then
		self.restTimer = self.restTimer + dt
		if self.restTimer >= REST_TIME then
			self:place()
		end
	else
		if self.gravity>0 then
			self.timer = self.timer - dt
			while self.timer <= 0 do
				self:movePiece(0,1)
				self.timer = self.timer + self.gravity
			end
		else
			while self:movePiece(0,1) do end
		end
	end
end

function Game:place()
	local piece = self.pieces[0]
	local x0,y0 = piece.x,piece.y

	self.lost = true
	for i=1,2 do
		for j=1,2 do
			local c = piece.shape[i][j]
			if c ~= 0 then
				self.board[y0-i+1][x0-j+1] = c
				if y0-i+1>0 then
					self.lost = false
				elseif self.board[1][x0-j+1] == 0 then
					self.lost = false
				end
			end
		end
	end
	self.placedPiece = true
	
	for i=1,#self.pieces do
		self.pieces[i-1] = self.pieces[i]
	end
	self.pieces[#self.pieces] = randomSquindice(self.colors)
	
	self.restTimer = 0
	self.timer = IDLE_TIME
	self:checkGhost()
end

function Game:parseInput(key)
	actions = {
		[UP   ] = function() 
			return self:hardDrop() 
		end,
		[DOWN ] = function() 
			return self:movePiece(0,1)
		end,
		[LEFT ] = function()
			return self:movePiece(-1,0)
		end,
		[RIGHT] = function() 
			return self:movePiece(1,0)
		end,
		[A    ] = function()
			return self.pieces[0]:doRotate(true,self.board)
		end,
		[B    ] = function() 
			return self.pieces[0]:doRotate(false,self.board) 
		end,
		[START] = function()
			return self:togglePause()
		end,
	}	
	return actions[key]()
end

function Game:hardDrop()
	while self:movePiece(0,1) do end
	self:place()
	return true
end

function Game:movePiece(dx, dy)
	local piece = self.pieces[0]

	if piece:isBlocked(dx,dy,self.board) then
		local shape = piece.shape
		if dy == 1 and shape[1][1]==0 and shape[1][2]==0 then
			shape[1], shape[2] = shape[2], shape[1]
			piece.y = piece.y-1
		end
		if dx == -1 and shape[1][1]==0 and shape[2][1]==0 then
			shape[1][1], shape[1][2] = shape[1][2], shape[1][1]
			shape[2][1], shape[2][2] = shape[2][2], shape[2][1]
			piece.x = piece.x-1
		elseif dx == 1 and shape[1][2]==0 and shape[2][2]==0 then
			shape[1][1], shape[1][2] = shape[1][2], shape[1][1]
			shape[2][1], shape[2][2] = shape[2][2], shape[2][1]
			piece.x = piece.x+1
		end
		return false
	end
	piece.x = piece.x + dx
	piece.y = piece.y + dy
	
	self:checkGhost()
	return true
end

function Game:addScore(squares)
	for i=1,#squares do
		self.score = self.score + squares[i].size*100
	end
	if #self.squares>2 then
		self.score = self.score + (#self.squares-2)*50
	elseif self.squares==2 then
		self.score = self.score + 25
	end
end

local lLimit = {
	{08,10},
	{16,10},
	{23,10},
	{44,10},
	{55,10},
	{75,10}
}

function Game:addClear()
	self.clears = self.clears + 1
	local levelUp = self.clears%20
	for i=1,#lLimit do 
		if self.level<lLimit[i][1] then
			levelUp = self.clears%lLimit[i][2]==0
			break
		end
	end
	
	if levelUp then
		self.level = self.level + 1
		local danger = self.level
		
		if danger > 160 then
			danger = -1
			self.colors = 6
		elseif danger > 110 then
			danger = danger-110
			danger = danger/2
			self.colors = 6
		
		elseif danger > 90 then
			danger = -1
			self.colors = 5
		elseif danger > 70 then
			danger = danger-70
			self.colors = 5
			
		elseif danger > 50 then
			danger = -1
			self.colors = 4
		elseif danger > 40 then
			danger = danger-40
			danger = danger*2
			self.colors = 4
		
		elseif danger > 25 then
			danger = -1
			self.colors = 3
		else
			self.colors = 3
		end
		
		if danger < 0 then
			self.gravity = 0
		else
			self.gravity = DEFAULT_GRAVITY * math.pow(0.8, danger)
		end
	end
end

function Game:checkGhost()
	if self.pieces[0]:isBlocked(0,2,self.board) then
		self.ghost = false
	else
		self.ghost = true
	end
end

function Game:togglePause()
	self.pause = not self.pause
	self.pauseTimer = 0
end