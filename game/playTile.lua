playTile = Object.extend(Object)
require "word"
require "gameTile"


function playTile:new(letter, special, x, y)
	self.letter = ""
	self.special =""
	self.x = x
	self.y = y
end

function playTile:update(letter, special, x, y)
	self.letter = letter
	self.special = special
	self.x = x
	self.y = y
end

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

function playTile:drawWordNew(word, currGameTiles)

	local tempGameTiles = currGameTiles

	love.graphics.setLineWidth(3)
	love.graphics.setColor(.9,.1,.1)
	wordArr = {}
	for i=1,#word.letters do
		wordArr[i] = string.sub(word.letters,i,i)
	end
	--tostring(self.letter)
	tempX = word.rootX
	tempY = word.rootY
	--print(word.letters .. " x: " .. word.rootX .. " y: " .. word.rootY)
	
	for i=1,#wordArr do
		love.graphics.print(wordArr[i], tempX*50+65, tempY*50+73)

		if(word.orientation == 0) then
			tempX = tempX + 1
		end
		if(word.orientation == 1) then
			tempY = tempY + 1
		end

		if tempX < 13 and tempY < 13 then
			local tempGameTile = gameTile()
			tempGameTile:update("none", false, wordArr[i])

			if tempX == 7 and tempY == 7 then tempGameTile:update("root", false, wordArr[i]) end
			--print(tempGameTile.letter)
			tempGameTiles[tempX][tempY] = tempGameTile
			--print(tempGameTiles[tempX][tempY].letter)
		end


	end

	--return updated gametiles with letters

	return tempGameTiles


end
