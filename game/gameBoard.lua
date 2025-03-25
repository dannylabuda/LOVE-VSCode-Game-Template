gameBoard = Object.extend(Object)

function gameBoard:new(newX,newY)
    self.X = newX
	self.Y = newY
end

function gameBoard:update(x,y)
    self.X = x
	self.Y = y
end

function gameBoard:draw()
	love.graphics.setColor(94,66,34)
	love.graphics.print("Game Board", 100,75)
	for i=1,13 do
		for j=1,13 do
			love.graphics.setLineWidth(3)
			love.graphics.setColor(.94,.66,.34)
			love.graphics.rectangle("line", i*50+50, j*50+50, 50, 50)
		end
	end

end
