gameTile = Object.extend(Object)

function gameTile:new()
	self.special = " "
	self.isEmpty = true
	self.letter = " "
end

function gameTile:update(special, isEmpty, letter)
	self.special = special
	self.isEmpty = isEmpty
	self.letter = letter
end

function gameTile:setLetter(letter)
	self.letter = letter
end

function gameTile:draw(currentTiles)
	for i=1,13 do
		for j=1,13 do
			love.graphics.setLineWidth(1)
			love.graphics.setColor(.224,.209,.209)
			love.graphics.rectangle("fill", i*50+55, j*50+55, 40, 40)
			love.graphics.setColor(.5,.9,.5)
			love.graphics.print(tostring(currentTiles[i][j].special), i*50+59, j*50+53)
		end
	end

function gameTile:getSpecial()
	result = ""
	if (self.special == nil) then
		result = "Nil"
		return result
		end
	if not (self.special == nil) then
		return tostring(self.special)
	end
end

end
