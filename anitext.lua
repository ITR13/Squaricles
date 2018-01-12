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

AniText = {
	value = nil,
	angularSpeed = 1.,
	angularDist = math.pi/8,
	
	jumps = 2,
	jumpHeight = .5,
	jumpSpeed = 1.5,
	
	isJumping = 0,
	cJump = 0.
}


function AniText:new(other)
	other = other or {}
	local o = clone(self)
	for k,v in pairs(other) do o[k] = v end
	o.time = math.random()*math.pi*2
	return o
end

function AniText:update(dt)
	if self.cJump == 0 then
		if self.isJumping>0 then
			self.isJumping = self.isJumping - 1
			self.cJump = dt*self.jumpSpeed
			self.time = math.random(2)*math.pi
			if self.angularSpeed < 0.4 then
				self.angularSpeed = 0.4
			else
				self.angularSpeed = self.angularSpeed
								  * ( math.random()*0.4 + 0.8 ) 
			end
		else
			self.time = self.time + dt*self.angularSpeed
		end
	else
		self.cJump = self.cJump + dt*self.jumpSpeed
		if self.cJump > 1 then
			if self.isJumping > 0 then
				self.cJump = self.cJump - 1
				self.isJumping = self.isJumping-1
			else
				self.cJump = 0
			end
		end
	end
end

function AniText:draw(value, x, y)
	if self.value ~= value then
		self.isJumping = self.isJumping + self.jumps
		self.value = value
	end
	
	local h = font:getHeight()
	local w = font:getWidth(value)
	y = y + self:getJumpHeight(self.cJump)*h

	love.graphics.setColor(255,255,255)
	love.graphics.print(
		value,
		x, y,
		math.sin(self.time)*self.angularDist,
		1, 1,
		w/2, h/2
	)
end

function AniText:getJumpHeight(x)
	if x < 0 or x > 0.8 then 
		return 0
	elseif x < 0.51282 then
		x = 1.95*x - 1
	else
		x = x-0.51282+0.285714
		x = 3.5*x-1
	end
	return (x*x-1)*self.jumpHeight
end
