Solver = Object.extend(Object)

require "NewTrie"
require "Board"
require "Position"

--REMEMBER TO PASS TRIE
function Solver:new(dictionary,board,rack)
	self.trie = dictionary
	self.board = board
	self.rack = rack
	self.cross_check_results = "None"
	self.direction = "None"
end

function Solver:update(dictionary,board,rack)
	self.trie = dictionary
	self.board = board
	self.rack = rack
	self.cross_check_results = "None"
	self.direction = "None"

	return self
end

function Solver:before(pos)
	local row = pos:GetRow()
	local col = pos:GetCol()
	local tempPos = Position()
	--print("before row: " .. row .. " column: " .. col)

	if self.direction == "across" then

		tempPos = tempPos:update(row, col-1)
		--print("before1..." ..tempPos:Print())
		return tempPos

	elseif self.direction == "down" then
		tempPos = tempPos:update(row-1, col)
		--print("before2..." .. tempPos:Print())
		return tempPos
	end
end

function Solver:after(pos)
	local row = pos:GetRow()
	local col = pos:GetCol()
	local tempPos = Position()

	if self.direction == "across" then
		return tempPos:update(row, col+1)
	else
		return tempPos:update(row+1, col)
	end
end

function Solver:beforeCross(pos)
	local row = pos:GetRow()
	local col = pos:GetCol()
	local tempPos = Position()

	if self.direction == "across" then
		return tempPos:update(row-1, col)
	else
		return tempPos:update(row, col-1)
	end
end

function Solver:afterCross(pos)
	local row = pos:GetRow()
	local col = pos:GetCol()
	local tempPos = Position()

	if self.direction == "across" then
		return tempPos:update(row+1, col)
	else
		return tempPos:update(row, col+1)
	end
end

function Solver:legalMove(word,lastPos)
	print("Found word: " .. word)
	--this may fail, might have to clean up these funcs
	local board_if_played = self.board:Copy()

	local playPos = lastPos

	local wordIdx = #word - 1

	while wordIdx >=1 do
		board_if_played:SetTile(playPos,word[wordIdx])
		wordIdx = wordIdx - 1
		playPos = self:before(playPos)
	end
	print("board if played: " .. board_if_played:Print())
end

function Solver:crossCheck()

	local result = {}
	local legal_here = {}

	for i,pos in pairs(self.board:All_Positions()) do
		if self.board:IsFilled(pos) then
			goto continue
		end
		local letters_before = ""
		local scan_pos = pos

		while self.board:IsFilled(self:beforeCross(scan_pos)) do
			scan_pos = self:beforeCross(scan_pos)
			letters_before = self.board:GetTile(scan_pos) .. letters_before
		end
		local letters_after = ""
		scan_pos = pos
		while self.board:IsFilled(self:afterCross(scan_pos)) do
			scan_pos = self:afterCross(scan_pos)
			letters_after = letters_after .. self.board:GetTile(scan_pos)
		end
		--can change to array if this doesnt work properly
		if #letters_before == 0 and #letters_after == 0 then
			legal_here = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
		else
			legal_here = {}
			local letters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
			for i,letter in pairs(letters) do
				local word_formed = letters_before .. letter .. letters_after
				if self.trie:search(word_formed) then
					table.insert(legal_here,letter)
				end				
			end
		end
		result[pos] = legal_here
		::continue::
	end
	return result
end

function Solver:findAnchors()
	local anchors = {}
	for i,pos in pairs(self.board:All_Positions()) do
		local empty = self.board:IsEmpty(pos)
		--print("findAnchors")
		--print(self:before(pos))
		--before returns nil
		local neighbor_filled = self.board:IsFilled(self:before(pos)) or self.board:IsFilled(self:after(pos)) or self.board:IsFilled(self:beforeCross(pos)) or self.board:IsFilled(self:afterCross(pos))
		--print("completed")
		if empty and neighbor_filled then
			table.insert(anchors,pos)
		end
	end
	return anchors
end



--yikes

function Solver:beforePart(partial_word,current_node,anchor_pos,limit)

	--print("before part / extend after:")
	self:extendAfter(partial_word,current_node,anchor_pos,false)

	if limit > 1 and current_node ~= nil then
		for next_letter in current_node:getChildren(partial_word) do

			local contains = false
			for i=1,i<#self.rack do
				if self.rack[i] == next_letter then return true end
			end

			if contains then
				--print("herre??????????")
				--prob have to find index of this letter
				table.remove(self.rack, next_letter)
				--prob have to get a index from next letter
				self:beforePart(
				partial_word..next_letter, 
				current_node:getChildren()[next_letter],
				anchor_pos,
				limit-1)

			end
			table.insert(self.rack, next_letter)
		end
	end

end


function Solver:extendAfter(partial_word,current_node,next_pos,anchor_filled)
	print(current_node)

	if not current_node == nil and not self.board:IsFilled(next_pos) and current_node.isEnd and anchor_filled then
		self:legalMove(partial_word, self:before(next_pos))
	if not current_node == nil and self.board:InBounds(next_pos) then
		if self.board:IsEmpty(next_pos) then
			print("ever here?")
			for next_letter in current_node:getChildren() do
				local isInRack = false
				local isInCrossCheck = next_letter == self.cross_check_results[next_pos]
				for i=1,#self.rack do
					if self.rack[i] == next_letter then isInRack = true end
				end
				if isInRack and isInCrossCheck then
					--prob have to find index of this letter
					table.remove(self.rack,next_letter)
					print("i betcha its here")
					self:extendAfter(
						partial_word..next_letter,
						--prob have to get a index from next letter
						current_node:getChildren()[next_letter],
						self:after(next_pos),
						true
					)
				end

			end
		else
			local existing_letter = self.board:GetTile(next_pos)
			local isInChildren = false
			for i=1,#current_node:getChildren() do
				if existing_letter == current_node:getChildren()[i] then isInChildren = true end
			end
			if isInChildren then
				self:extendAfter(
					partial_word..existing_letter,
					--likely need to change this as well
					current_node:getChildren()[existing_letter],
					self:after(next_pos),
					true
				)
			end
		end
	end
end
end

function Solver:findAllOptions()
	local directions = {"across", "down"}
	for i,direction in pairs(directions) do
		self.direction = direction
		local anchors = self:findAnchors()
		self.cross_check_results = self:crossCheck()

		for i,anchor_pos in pairs(anchors) do
			if self.board:IsFilled(self:before(anchor_pos)) then
				local scan_pos = self:before(anchor_pos)
				local partial_word = self.board:GetTile(scan_pos)
				while self.board:IsFilled(self:before(scan_pos)) do
					scan_pos = self:before(scan_pos)
					partial_word = self.board:GetTile(scan_pos) .. partial_word
				end
				local pw_node = self.trie:search("partial_word")
				if pw_node ~= nil then
					self:extendAfter(
						partial_word,
						pw_node,
						anchor_pos,
						false
					)
				end
			else
				local limit = 0
				local scan_pos = anchor_pos
				local isInAnchors = false
				--may mess it up since its a while loop, not just 1 check
				for i=1,#anchors do
					if self:before(scan_pos) == anchors[i] then isInAnchors=true end
				end
				while self.board:IsEmpty(self:before(scan_pos)) and not isInAnchors do
					limit = limit + 1
					scan_pos = self:before(scan_pos)
				end
				--print("this is where")
				self:beforePart("", self.trie:getRoot(), anchor_pos, limit)

			end
		end

	end
	
end
