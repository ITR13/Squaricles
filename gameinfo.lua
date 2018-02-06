GameInfoDisplayer = {}

function GameInfoDisplayer:new(game,mode)
	local o = clone(self)
	o.game = game
	o.scoreText = AniText:new()
	o.levelText = AniText:new()
	o.mode = mode

	return o
end

function GameInfoDisplayer:draw()
	self:drawBackground()
	self:drawPreviews()
	self:drawSpecial()
	self:drawText()
end

function GameInfoDisplayer:drawBackground()
	love.graphics.clear(0x00,0x00,0x00,000)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(GAMEBACKGROUND)
	love.graphics.draw(MODEIMAGE[self.mode])
end

function GameInfoDisplayer:drawPreviews()
	for p=1,#PREVIEWS do
		setColor("background")
		preview = PREVIEWS[p]
		love.graphics.rectangle('fill',unpack(preview))
		piece = self.game.pieces[p]
		w,h = preview[3]/2,preview[4]/2
		for i=1,2 do
			for j=1,2 do
				x,y = preview[1]+(2-j)*w,preview[2]+(2-i)*h
				setColor(piece.shape[i][j])
				love.graphics.rectangle('fill',
					x+PREVIEW_INDENT[i][j][1],
					y+PREVIEW_INDENT[i][j][2],
					w-PREVIEW_INDENT[i][j][3],
					h-PREVIEW_INDENT[i][j][4]
				)
			end
		end
	end
end

function GameInfoDisplayer:drawSpecial()
	love.graphics.setColor(COLORS["special-back"])
	love.graphics.rectangle('fill',unpack(SPECIAL_POS))
	love.graphics.setColor(COLORS["special"])
	love.graphics.rectangle(
		'fill',
		SPECIAL_POS[1],
		SPECIAL_POS[2],
		SPECIAL_POS[3]*self.game.special/REMOVE_COLOR_COST,
		SPECIAL_POS[4]
	)
	love.graphics.draw(
		SPECIALIMAGE,
		SPECIAL_POS[1],
		SPECIAL_POS[2]
	)
end

function GameInfoDisplayer:drawText()
	love.graphics.setColor(255,255,255)
	self.scoreText:draw(self.game.score, 781, 437)
	self.levelText:draw(self.game.level, 784, 780)
end

function GameInfoDisplayer:update(dt)
	self.scoreText:update(dt)
	self.levelText:update(dt)
end
