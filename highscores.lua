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

HighscoreList = {
	sorted = false,
}

function HighscoreList:addScore(score)
	self[#self] = score
	self.sorted = false
end

function HighscoreList:sort()
	--Slow, switch out later
	if not self.sorted
		for i=1,#self do
			for j=i+1,#self do
				if self[i]<self[j] then
					self[i],self[j] = self[j],self[i]
				end
			end
		end
		self.sorted = true;
	end
end
