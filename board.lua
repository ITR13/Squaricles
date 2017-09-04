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

Board = {width = 6, height = 12}

for y=-1,Board.height+2 do
	Board[y] = {}
	for x=-1,Board.width+2 do
		if y<1 or x<1 or x>Board.width then
			Board[y][x] = -1
		else
			Board[y][x] = 0
		end
	end
end

function Board:new()
	local o = clone(self)
	return o
end

function Board:findSquares()
	local squares = {}
	for size=math.min(self.width,self.height),1,-1 do
		for y=1,self.height-size do
			for x=1,self.width-size do
				if self:isSquare(x,y,size) then
					squares[#squares+1] = {x=x,y=y,size=size}
				end
			end
		end
	end
	return squares
end

function Board:isSquare(x,y,size)
	local color = self[y][x]
	if color < 1 then
		return false
	end
	local dx, dy = size,0
	for i=1,4 do
		if self[y+dy][x+dx] ~= color then
			return false
		end
		dx,dy = dy,size-dx
	end
	return true
end

function Board:gravBoard()
	for x=1,self.width do
		local distance = 0
		for y=1,self.height do
			if self[y][x]==0 then
				distance = distance+1
			elseif distance ~= 0 then
				self[y-distance][x] = self[y][x]
				self[y][x] = 0
			end
		end
	end
end

function Board:removeSquares(squares)
	for i=1,#squares do
		local x,y = squares[i].x,squares[i].y
		local dx,dy = 0,squares[i].size
		for j=1,4 do
			self[y+dy][x+dx] = 0
			dx,dy = dy,squares[i].size-dx
		end
	end
end

