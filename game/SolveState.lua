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
	
	--print(self.boardCount)
	--self.possibleBoards[self.boardCount] = board_if_we_played_that
	--self.possibleBoards[self.boardCount] = board_if_we_played_that:Copy()
	self.boardCount = self.boardCount + 1
	--board_if_we_played_that:Print()
	local tempBoard = board_if_we_played_that:Copy()
	table.insert(self.possibleBoards, tempBoard)

    --print()
	--return board_if_we_played_that
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

function SolveState:AddWordToBoard(trie)
	local tempRack = GetRandomRack()
	local solver = SolveState:new(trie, self.board, tempRack)
	for i=1,#tempRack do
		print(tempRack[i])
	end
	solver = solver:find_all_options()
	--add a random word to the board, update the board
	solver.board = solver.possibleBoards[love.math.random(1,solver.boardCount-1)]:Copy()
	solver.boardCount = 1
	solver.possibleBoards = {}
	self.board = solver.board
	self.board:Print()
end


--[[
function SolveState:PlayerWordValid(proposedBoard)
	local isValid = false
	local tempPossibleBoards = self:find_all_options()

	print("current board:")
	self.board:Print()

	print("proposedBoard:")
	proposedBoard:Print()

	print("first possible board:")
	tempPossibleBoards[1]:Print()

	print(self.boardCount)

	for i=1, self.boardCount-1 do
		--self.possibleBoards[i]:Print()
		if self.possibleBoards[i]:Equals(proposedBoard) then 
			isValid = true
			goto continue
		end
	end

	::continue::
	return isValid
end
]]--

function SolveState:ValidateWordPlacement(word, start_pos, direction)
    local row, col = start_pos[1], start_pos[2]
    local word_length = #word

    -- Ensure the word fits within the board bounds
    if direction == "across" then
        if col + word_length - 1 > self.board.size then
            print("Word extends beyond board width")
            return false
        end
    else
        if row + word_length - 1 > self.board.size then
            print("Word extends beyond board height")
            return false
        end
    end

    -- Check letter placement and build the formed word
    local formed_word = ""
    local used_letters = {}
    
    for i = 1, word_length do
        local current_pos = {row, col}
        local existing_letter = self.board:GetTile(current_pos)

        -- Ensure the placement aligns with existing letters or uses letters from the rack
        if existing_letter == nil or existing_letter == "" then
            if not self:contains(self.rack, word:sub(i, i)) then
                print("Rack does not contain letter: " .. word:sub(i, i))
                return false
            end
            table.insert(used_letters, word:sub(i, i)) -- Track letters taken from rack
        elseif existing_letter ~= word:sub(i, i) then
            print("Mismatch with existing board letter at position: " .. row .. "," .. col)
            return false
        end

        formed_word = formed_word .. word:sub(i, i)

        -- Move to the next position
        if direction == "across" then
            col = col + 1
        else
            row = row + 1
        end
    end

    -- Check if the formed word is valid in the dictionary
    if not self.dictionary:is_word(formed_word) then
        print("Word is not valid in dictionary: " .. formed_word)
        return false
    end

    -- Check if the word is connected to existing words (i.e., it is not floating)
    local connected = false
    for _, letter in ipairs(used_letters) do
        local before_pos = self:before({row, col})
        local after_pos = self:after({row, col})
        if self.board:IsFilled(before_pos) or self.board:IsFilled(after_pos) then
            connected = true
        end
    end

    if not connected then
        print("Word is not connected to existing words")
        return false
    end

    print("Word placement is valid!")
    return true
end




function SolveState:run()
	TempBoard = Board()
	TempBoard = TempBoard:update(13)
	TempBoard:SetTile({7,7}, 's')
	TempBoard:SetTile({8,7}, 't')
	TempBoard:SetTile({9,7}, 'r')
	TempBoard:SetTile({10,7}, 'a')
	TempBoard:SetTile({11,7}, 'i')
	TempBoard:SetTile({12,7}, 'n')
	TempBoard:SetTile({13,7}, 's')

	local trie = basic_english()




	local solver = SolveState:new(trie, TempBoard, GetRandomRack())
	local player = SolveState:new(trie, solver.board, {"s","o","d"})
	
	--print("is sod valid: " .. tostring(player:ValidateWordPlacement("sod", {7,7}, "across")))




	--print(solver.board:Print())
	--local player = SolveState:new(trie, solver.board, {"s","o","d"})

	--local tBoard = Board()
	--tBoard = player.board:Copy()
	--print(tostring(player.board:Equals(player.board)))
	
	--player.board:Print()
	--tBoard:SetTile({7,8}, 'o')
	--tBoard:SetTile({7,9}, 'd')
	--print(tostring(player.board:Equals(tBoard)))
	--print(tostring(player:PlayerWordValid(tBoard)))

	--print(tostring(player:PlayerWordValid(tBoard)))
	

	





	--solver:AddWordToBoard(trie)
	--solver:AddWordToBoard(trie)
	--[[
	--add a random word to the board, update the board
	solver.board = solver.possibleBoards[love.math.random(1,solver.boardCount-1)]:Take()
	solver.boardCount = 1
	solver.possibleBoards = {}
	solver.board:Print()
	--start another iteration, add another word
	solver = SolveState:new(basic_english(), solver.board, GetRandomRack())
	solver = solver:find_all_options()
	solver.board = solver.possibleBoards[love.math.random(1,solver.boardCount-1)]:Take()
	solver.boardCount = 1
	solver.possibleBoards = {}
	solver.board:Print()
	]]--




	--for i=1,solver.boardCount-1 do
		--solver.possibleBoards[i]:Print()
	--end
	



	return SolveState
end
