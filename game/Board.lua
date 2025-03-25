Board = Object.extend(Object)

require "Position"

--this should work
function Board:new()
	self.size = 0
	self.tiles = {}
end

function Board:update(size)
	self.size = size
	self.tiles = {}

	for i=1,size do
		local row = {}
		for j=1,size do
			table.insert(row, "None")
		end
		table.insert(self.tiles,row)
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
	--print("isempty")
	--print(pos:Print())
	return self:InBounds(pos) and self:GetTile(pos) == "None"
end

function Board:IsFilled(pos)
	--print("isfilled")
	--print(pos:Print())
	return self:InBounds(pos) and self:GetTile(pos) ~= "None"
end

function Board:Copy()
	result = Board()
	bSize = self.size
	result = Board:update(bSize)
	local positionsTable = self:All_Positions()
	for i=1,#positionsTable do
		result:SetTile(positionsTable[i], self:GetTile(positionsTable[i]))
	end
	return result
end

function SampleBoard()
	local result = Board:New(13)
	local tempPos = Position()
	tempPos:New(7,7)
	result:SetTile(tempPos, 'f')
	tempPos:New(8,7)
	result:SetTile(tempPos, 'o')
	tempPos:New(9,7)
	result:SetTile(tempPos, 'r')
	return result
end
