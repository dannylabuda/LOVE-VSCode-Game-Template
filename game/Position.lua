Position = Object.extend(Object)

--this should work
function Position:new(row,col)
	self.row = row
	self.col = col
end

function Position:update(row,col)
	self.row = row
	self.col = col
	return self
end

function Position:GetRow()
	return self.row
end

function Position:GetCol()
	return self.col
end

function Position:Print()
	return self.row .. " " .. self.col
end
