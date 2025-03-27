require "NewTrie"
require "Board"
require "Position"
require "LetterTreeNode"
SolveState = {}
SolveState.__index = SolveState



function SolveState:new(dictionary, board, rack)
    local obj = {
        dictionary = dictionary,
        board = board,
        rack = rack,
        cross_check_results = nil,
        direction = nil,
		possibleBoards = {},
		boardCount = 1
    }
    setmetatable(obj, SolveState)
    return obj
end

function SolveState:before(pos)
    local row, col = pos[1], pos[2]
	if not pos or #pos < 2 then
        error("Invalid position format in before(): " .. tostring(pos))
    end
    if self.direction == "across" then
        return {row, col - 1}
    else
        return {row - 1, col}
    end
end

function SolveState:after(pos)
    local row, col = pos[1], pos[2]
    if self.direction == "across" then
        return {row, col + 1}
    else
        return {row + 1, col}
    end
end

function SolveState:before_cross(pos)
    local row, col = pos[1], pos[2]
    if self.direction == "across" then
        return {row - 1, col}
    else
        return {row, col - 1}
    end
end

function SolveState:after_cross(pos)
    local row, col = pos[1], pos[2]
    if self.direction == "across" then
        return {row + 1, col}
    else
        return {row, col + 1}
    end
end

function SolveState:legal_move(word, last_pos)
    --print("found a word:", word)
    local board_if_we_played_that = self.board:Copy()
    local play_pos = last_pos
    local word_idx = #word
    while word_idx >= 1 do
        board_if_we_played_that:SetTile(play_pos, word:sub(word_idx, word_idx))
        word_idx = word_idx - 1
        play_pos = self:before(play_pos)
    end

	self.boardCount = self.boardCount + 1
	--board_if_we_played_that:Print()
	local tempBoard = board_if_we_played_that:Copy()
	table.insert(self.possibleBoards, tempBoard)

end

function SolveState:cross_check()
    local result = {}
    for _, pos in ipairs(self.board:All_Positions()) do
		--print("pos is filled: " .. tostring(self.board:IsFilled(pos)))
        if self.board:IsFilled(pos) then
            goto continue
        end
        local letters_before = ""
        local scan_pos = pos
        while self.board:IsFilled(self:before_cross(scan_pos)) do
            scan_pos = self:before_cross(scan_pos)
            letters_before = self.board:GetTile(scan_pos) .. letters_before
        end
        local letters_after = ""
        scan_pos = pos
        while self.board:IsFilled(self:after_cross(scan_pos)) do
            scan_pos = self:after_cross(scan_pos)
            letters_after = letters_after .. self.board:GetTile(scan_pos)
        end

        local legal_here = {}
        if #letters_before == 0 and #letters_after == 0 then
            legal_here = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
        else
            for _, letter in ipairs({"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}) do
                local word_formed = letters_before .. letter .. letters_after
                if self.dictionary:is_word(word_formed) then
                    table.insert(legal_here, letter)
                end
            end
        end

		--print("pos: " .. pos[1]..","..pos[2])
		local tempConCat = pos[1]..","..pos[2]
        result[tempConCat] = legal_here
        ::continue::
    end
    return result
end

function SolveState:find_anchors()
    local anchors = {}
	--print("in anchors")
    for _, pos in ipairs(self.board:All_Positions()) do
		--print(pos[1])
        local empty = self.board:IsEmpty(pos)
        local neighbor_filled = self.board:IsFilled(self:before(pos)) or
                                self.board:IsFilled(self:after(pos)) or
                                self.board:IsFilled(self:before_cross(pos)) or
                                self.board:IsFilled(self:after_cross(pos))
        if empty and neighbor_filled then
            table.insert(anchors, pos)
        end
    end
    return anchors
end

function SolveState:before_part(partial_word, current_node, anchor_pos, limit)
    -- Extend after the partial word
    self:extend_after(partial_word, current_node, anchor_pos, false)

    -- Recursively extend if the limit allows
    if limit > 0 then
        for next_letter, _ in pairs(current_node.children) do
            if self:contains(self.rack, next_letter) then
                -- Remove the letter from the rack temporarily
                self:remove_from_rack(next_letter)

                -- Recursively call before_part with the updated word and node
				--maybe here
                self:before_part(partial_word .. next_letter, current_node.children[next_letter], anchor_pos, limit - 1)

                -- Add the letter back to the rack after recursion
                self:add_to_rack(next_letter)
            end
        end
    end
end

function SolveState:extend_after(partial_word, current_node, next_pos, anchor_filled)
    -- Debug: Check the type of current_node
    if type(current_node) ~= "table" then
        print("Error: current_node is not a table. It is:", type(current_node))
        return
    end

    -- If the board tile is not filled, and the current_node is a word, and anchor is filled, make the move
	--print("Is next pos on board filled: " .. tostring(self.board:IsFilled(next_pos)))
	--print("Is current node word: " .. tostring(current_node.is_word))
	--print("Is Anchor filled: " .. tostring(anchor_filled))
    if not self.board:IsFilled(next_pos) and current_node.is_word and anchor_filled then
        self:legal_move(partial_word, self:before(next_pos))
    end

    -- Ensure we're within board bounds
    if self.board:InBounds(next_pos) then
        -- If the next position is empty, we can try placing letters
        if self.board:IsEmpty(next_pos) then
            -- Ensure self.rack is not nil
            if not self.rack then
                print("Error: self.rack is nil!")
                return
            end

            -- Ensure cross_check_results[next_pos] is a valid table
			--cross check results is nil here!!!!!!!!!
			--print(next_pos[1])
			local tempPosStr = next_pos[1] .. "," .. next_pos[2]
			--print(tostring(self.cross_check_results[tempPosStr]))


            if not self.cross_check_results[tempPosStr] then
                self.cross_check_results[tempPosStr] = {} -- Initialize as empty table if nil
            end

				--nextPos is for example nextpos[1] = 1, nextpos[2] = 2


            -- Check for available next letters in current_node children
            for next_letter, child_node in pairs(current_node.children) do
				
                -- Ensure the letter exists in rack and cross_check_results
				--here or below
				--print("rack contains next letter: " .. tostring(table.contains(self.rack, next_letter)))
				--print("crossCheck results: " .. tostring(table.contains(self.cross_check_results[next_pos], next_letter)))
				--print(tostring(self.cross_check_results[next_pos]))
                if table.contains(self.rack, next_letter) and table.contains(self.cross_check_results[tempPosStr], next_letter) then
                    -- Remove the letter from rack and recurse
					--print("table contains self.rack")
                    self:remove_from_rack(next_letter)
                    self:extend_after(
                        partial_word .. next_letter,
                        child_node,
                        self:after(next_pos),
                        true
                    )
                    -- Add the letter back to rack
                    self:add_to_rack(next_letter)
                end
            end
        else
            -- If the tile is already filled, check if it matches a valid child letter
            local existing_letter = self.board:GetTile(next_pos)
            if current_node.children[existing_letter] then
				--print("table contains existingletter")
                self:extend_after(
                    partial_word .. existing_letter,
                    current_node.children[existing_letter],
                    self:after(next_pos),
                    true
                )
            end
        end
    end
end

function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end


-- Utility function to check if a rack contains a letter
function SolveState:contains(rack, letter)
    for _, item in ipairs(rack) do
        if item == letter then
            return true
        end
    end
    return false
end

-- Utility function to remove a letter from the rack
function SolveState:remove_from_rack(letter)
    for i, item in ipairs(self.rack) do
        if item == letter then
            table.remove(self.rack, i)
            return
        end
    end
end

-- Utility function to add a letter back to the rack
function SolveState:add_to_rack(letter)
    table.insert(self.rack, letter)
end

function SolveState:find_all_options()
    for _, direction in ipairs({"across", "down"}) do
        self.direction = direction
        local anchors = self:find_anchors()
        self.cross_check_results = self:cross_check()
        for _, anchor_pos in ipairs(anchors) do
            if self.board:IsFilled(self:before(anchor_pos)) then
                local scan_pos = self:before(anchor_pos)
                local partial_word = self.board:GetTile(scan_pos)
                while self.board:IsFilled(self:before(scan_pos)) do
                    scan_pos = self:before(scan_pos)
                    partial_word = self.board:GetTile(scan_pos) .. partial_word
                end
                local pw_node = self.dictionary:lookup(partial_word)
                if self.dictionary:is_word(partial_word) then
					--print("pw node")
                    self:extend_after(partial_word, pw_node, anchor_pos, false)
                end
            else
				local limit = 0
                local scan_pos = anchor_pos
                local before_pos = self:before(scan_pos)
                local is_anchor = false
                for _, anchor in ipairs(anchors) do
                    if anchor[1] == before_pos[1] and anchor[2] == before_pos[2] then
                        is_anchor = true
                        break
                    end
                end
                while self.board:IsEmpty(before_pos) and not is_anchor do
                    limit = limit + 1
                    scan_pos = before_pos
                    before_pos = self:before(scan_pos)
                end
                self:before_part("", self.dictionary.root, anchor_pos, limit)
            end
        end
    end
	return self.possibleBoards
end

function GetRandomRack()
	local rack = {}
	for i=1,7 do
		table.insert(rack, string.char(love.math.random(97, 97 + 25)))
	end
	return rack
end

function SolveState:ProposedBoard(word, startpos, direction)
	
	local pBoard = Board()
	pBoard = pBoard:update(self.board.size)
	pBoard = self.board:Copy()
	local row = startpos[2]
	local col = startpos[1]

	if direction == "across" then
		for i=1, #word do
			pBoard:SetTile({row,col},word:sub(i,i))
			col = col + 1
		end
	elseif direction == "down" then
		for i=1, #word do
			pBoard:SetTile({row,col},word:sub(i,i))
			row = row + 1
		end
	end

	return pBoard
end

function SolveState:IsProposedValid(validBoards)
	local isValid = false
	for i=1, #validBoards do
		if self.board:Equals(validBoards[i]) then
			isValid = true
			goto continue
		end
	end
	::continue::
	return isValid
end

function SolveState:test()
	TempBoard = Board()
	TempBoard = TempBoard:update(13)
	TempBoard:SetTile({7,7}, 's')
	TempBoard:SetTile({8,7}, 'a')
	TempBoard:SetTile({9,7}, 'd')


	local trie = basic_english()




	--create new solvestate object, passing the trie and the temporary starting board, and the rack
	local solver = SolveState:new(trie, TempBoard, {"s","o","d"})

	--fill allOptions table with all possible boards
	local allOptions = solver:find_all_options()

	--create a proposed board (this would be a player's proposed play)
	local pBoard = solver:ProposedBoard("dos",{5,7},"across")
	--creates a player object (maybe not necessary?) and sets the board to that temp board
	local player = SolveState:new(trie, pBoard, {"s","o","d"})

	--store if valid bool in a variable
	local isValidWord = player:IsProposedValid(allOptions)
	print(isValidWord)


	return SolveState
end
