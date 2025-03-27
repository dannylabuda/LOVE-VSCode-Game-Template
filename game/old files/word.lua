word = Object.extend(Object)

function word:new()
	self.letters = ""
	self.rootX = 0
	self.rootY = 0
	self.orientation = 0
end

function word:update(letters, rootX, rootY, orientation)
	self.letters = letters
	self.rootX = rootX
	self.rootY = rootY
	self.orientation = orientation
end




--[[
function playTile:drawOnBoard(boardX,boardY)

	love.graphics.setColor(.5,.9,.5)
	--tostring(self.letter)
	love.graphics.print(self.letter, boardX*50+65, boardY*50+73)

end

function playTile:drawWord(wordArr, boardX, boardY)

	love.graphics.setLineWidth(3)
	love.graphics.setColor(.9,.1,.1)
	--tostring(self.letter)
	for i=1,#wordArr do
		love.graphics.print(wordArr[i].letter, boardX*50+65, boardY*50+73)
		boardX = boardX + 1
	end


end
--]]
