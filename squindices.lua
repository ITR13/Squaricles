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
require ".board"

Squindice = {x=Board.width/2+1,y=0,
			shape = {{-1,-1},{-1,-1}}, color = 0}

function Squindice:new(o, colors)
	o = o or {}
	for k,v in pairs(clone(self)) do o[k] = o[k] or v end

	if colors ~= nil then
		for x=1,2 do
			for y=1,2 do
				if o.shape[x][y] ~=0 then
					o.shape[x][y] = math.random(colors)
				end
			end
		end
	end
	return o
end

function Squindice:isBlocked(dx,dy,board)
	local x,y = self.x+dx,self.y+dy
	for i =0,1 do
		for j=0,1 do
			if board[y-i][x-j]~=0 and self.shape[i+1][j+1] ~= 0 then
				return true
			end
		end
	end
	return false
end

function Squindice:rotate(clockwise)
	local prev = -1
	local x,y = 1,1
	for i=0,4 do
		local nextprev = self.shape[x][y]
		if prev~=-1 then
			self.shape[x][y] = prev
		end
		prev = nextprev
		if clockwise then
			x,y = 3-y,x
		else
			x,y = y,3-x
		end
	end
	
	if not ENABLE_SPINJUMPING then
		if self.shape[1][1]==0 and self.shape[1][2] == 0 then
			self.shape[1], self.shape[2] = self.shape[2], self.shape[1]
			return true
		end
	end
	return false
end

function Squindice:doRotate(clockwise, board)
	local fell = self:rotate(clockwise)
	if self:isBlocked(0,0,board) then
		if ENABLE_SPINJUMPING and not self:isBlocked(0,-1,board) then
			self.y = self.y-1
			return true
		end
	
		if fell then
			self.shape[1],self.shape[2] = self.shape[2],self.shape[1]
		end
		self:rotate(not clockwise)
		return false
	end
	return true
end

Simple =	Squindice:new({ shape={{-1,-1},{-0,-0}} })
Diagonal =	Squindice:new({ shape={{-1,-0},{-0,-1}} })
CournerL =	Squindice:new({ shape={{-1,-1},{-1,-0}} })
CournerR =	Squindice:new({ shape={{-1,-1},{-0,-1}} })

Chances = {
	{SIMPLE_CHANCE,		Simple},
	{DIAGONAL_CHANCE,	Diagonal},
	{COURNER_CHANCE,	CournerL},
	{COURNER_CHANCE,	CournerR},
}
TOTALCHANCE = 0
for i=1,#Chances do
	TOTALCHANCE = TOTALCHANCE+Chances[i][1]
end

function randomSquindice(colors)
	local r = math.random(TOTALCHANCE)
	for i=1,#Chances do
		if r<=Chances[i][1] then
			return Chances[i][2]:new(nil,colors)
		end
		r = r-Chances[i][1]
	end
end
