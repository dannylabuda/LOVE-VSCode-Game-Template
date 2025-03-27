Board = Object.extend(Object)

--this should work
function Board:new()
	self.size = 0
	self.tiles = {}
end

function Board:update(size)
	self.size = size
	self.tiles = {}

	for i=1,size do
		self.tiles[i] = {}
		for j=1,size do
			self.tiles[i][j] = "*"
		end
	end
	return self
end

function Board:Print()
	print("Table Size: " .. self.size)
	for i=1,#self.tiles do
		local row = ""
		for j=1,#self.tiles do
			row = row .. " | " .. self.tiles[i][j]
		end
		print(row)
	end
end

--prob wont work
function Board:All_Positions()
	local result = {}
	for r=1,self.size do
		for c=1, self.size do
			--local newPos = Position()
			local newPos = {r,c}
			table.insert(result, newPos)
		end
	end
	return result
end

function Board:GetTile(pos)
	local row = pos[1]
	local col = pos[2]
	return self.tiles[row][col]
end

function Board:SetTile(pos,tile)
	local row = pos[1]
	local col = pos[2]
	self.tiles[row][col] = tile
end

function Board:InBounds(pos)
	local row = pos[1]
	local col = pos[2]
	if row >= 1 and row < self.size and col >= 1 and col < self.size then return true
	else return false
	end
end

--returns true if the tile is in bounds and has "none"
function Board:IsEmpty(pos)
	return self:InBounds(pos) and self:GetTile(pos) == "*"
end

function Board:IsFilled(pos)
	return self:InBounds(pos) and self:GetTile(pos) ~= "*"
end

function Board:BoardEmpty()
    for row = 1, self.size do
        for col = 1, self.size do
            if self:GetTile({row, col}) and self:GetTile({row, col}) ~= "*" then
                return false  -- Found at least one placed tile, board isn't empty
            end
        end
    end
    return true  -- No tiles found, board is empty
end

function Board:Equals(otherBoard)

	-- Quick check: Are we comparing to the same object?
	if self == otherBoard then
		print("Comparing the same object")
		return true
	end
	-- Quick size check
	if self.size ~= otherBoard.size then
		print("Wrong size!")
		return false
	end

	self:Print()
	otherBoard:Print()

-- Compare all tiles
	print("Comparing tiles...")
	for i = 1, self.size do
		for j = 1, self.size do
			local tile1 = self:GetTile{i,j}
			local tile2 = otherBoard:GetTile{i,j}
			--uncomment this next line to see each individual check
			--print(string.format("Comparing [%d,%d]: %s vs %s", i, j, tile1, tile2))

			if tile1 ~= tile2 then
				print(string.format("Mismatch at [%d,%d]: %s vs %s", i, j, tile1, tile2))
				return false
			end
		end
	end

	-- If all checks passed, boards are identical
	return true
end

function Board:Copy()
	local result = Board()
	result.size = self.size
	result.tiles = {}
	for i=1, self.size do
		result.tiles[i] = {}
		for j=1, self.size do
			result.tiles[i][j] = self.tiles[i][j]
		end
	end
	return result
end
