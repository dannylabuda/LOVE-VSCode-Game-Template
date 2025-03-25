function love.load()
	Object = require "classic"
	require "gameTile"
	require "gameBoard"
	json = require "dkjson"
	tick = require "tick"
	require "playTile"
	require "word"
	require "LetterTrie"
	require "Board"
	require "NewTrie"
	require "Solver"
	require "SolveState"

	Solve = SolveState:run()

	local firsttime = os.clock()
	--Trie = LetterTrie:runTrie();
	--print(table_print(Trie))

	trie = NewTrie()
	trie:Test()
	print(os.clock()-firsttime .. " seconds to build Trie")

	--in_trie basically equals is valid word 
	--print(in_trie(Trie,letters("mundane")))
	--getChildren(Trie,"jum")



	--testing board
	--[[
	TempBoard = Board()
	TempBoard = TempBoard:update(13)
	local tempPos = Position()
	tempPos:new(7,7)
	TempBoard:SetTile(tempPos, 'f')
	tempPos:new(8,7)
	TempBoard:SetTile(tempPos, 'o')
	tempPos:new(9,7)
	TempBoard:SetTile(tempPos, 'r')
	TempBoard:Print()
	--end board testing
	]]--

	--TestSolver = Solver()

	--TestSolver = TestSolver:update(trie,TempBoard, {"a","b","c","d"})
	--print(TestSolver.board)
	--TestSolver:findAllOptions()

	--sets number of words
	NumberOfWords = 0

	--set general Board size (kxk)
	BoardSize = 13

	--fills table with all valid word
	WordDict = GenerateWordDict()

	--gets a starting word
	StartingWord = GetRandomWord()

	--fills global 2d array with base game tiles, 7,7 being root
	currentGameTiles = initializeCurrGameTiles()

	--creates game board (skeleton) at 50,50
	GameBoard = gameBoard(50,50)

	--store running words
	RunningWords = {}

	--store letters of first word
	PlotFirstWord()

	for i=1,4 do
		--PlotNewWord()
	end
	--print(RunningWords[3].letters .. " X: " .. RunningWords[3].rootX .. " Y: " .. RunningWords[3].rootY .. " Orientation: " .. RunningWords[3].orientation)


	print(currentGameTiles[7][7].letter)
	
end

function love.update(dt)
	tick.update(dt)
	
end


function love.draw()
	--draw gameboard
	GameBoard:draw()
	--draw 2d array of game tiles
	gameTile:draw(currentGameTiles)

	--plots first word

	currentGameTiles = playTile:drawWordNew(RunningWords[1], currentGameTiles)
	--currentGameTiles = playTile:drawWordNew(RunningWords[2], currentGameTiles)
	--currentGameTiles = playTile:drawWordNew(RunningWords[3], currentGameTiles)
	--currentGameTiles = playTile:drawWordNew(RunningWords[4], currentGameTiles)
	--currentGameTiles = playTile:drawWordNew(RunningWords[5], currentGameTiles)



	--Plots subsequent starting words
	--PlotNewWord()

	
end



--MY Functions--
function initializeCurrGameTiles()
	--initialize empty 2d array 
	tempGameTiles = {}
	tempTile = gameTile("none", true, " ")
	for i=1,13 do
		tempGameTiles[i] = {}
		for j=1,13 do
			tempGameTiles[i][j] = {tempTile}
		end	
	 end
	 --insert basic gameTile into each instance of the array
	for i=1,13 do
		for j=1,13 do
			if ( i == 7 and j == 7) then --if center tile, make root
				tempTile = createGameTile("root", true, " ")
				tempGameTiles[i][j] = tempTile
				--print(i .. " " .. j .. " " .. tostring(tempGameTiles[i][j]))
			end
		if not ( i == 7 and j == 7) then
				tempTile = createGameTile ("none", true, " ")
				tempGameTiles[i][j] = tempTile
				--print(i .. " " .. j .. " " .. tostring(tempGameTiles[i][j]))
			end
		end
	end

	return tempGameTiles
end

function createGameTile(special, isEmpty, letter)

	tempTile = gameTile()
	tempTile:update(special, isEmpty, letter)
	return tempTile
end


function GenerateWordDict()

	local f = io.open("dictionary.json", "r")
	if f == nil then
		return nil, print("   Could not read file ")
	end

	local content = f:read "*a"
	f:close()

	local wordTable = json.decode(content)

	return wordTable


end

function GetRandomWord()
	wordLen = 14
	tempWord = ""

	while (wordLen > 13 and wordLen > 2) do
		--set seed to sys time to make random
		--math.randomseed(os.time())
		--pick random number based on seed
		local randNum = love.math.random(1,170000)
		--return word at random index
		tempWord = WordDict[randNum]
		--print(tempWord)
		wordLen = #tempWord
	end


	return tempWord
end


function PlotFirstWord()
	--for each letter in starting word
	local startingX = 7
	local startingY = 7
	local orientation = love.math.random(0,1)
	
	for i=1,#StartingWord do
		
		if orientation == 0 then
			--print("first word horizontal")
			if (#StartingWord == 3) then
				startingX = love.math.random(5,7)
			end
			if (#StartingWord == 4) then
				startingX = love.math.random(4,7)
			end
			if (#StartingWord == 5) then
				startingX = love.math.random(3,7)
			end
			if (#StartingWord == 6) then
				startingX = love.math.random(2,7)
			end
			if (#StartingWord == 7) then
				startingX = love.math.random(1,7)
			end
			if (#StartingWord == 8) then
				startingX = love.math.random(1,6)
			end
			if (#StartingWord == 9) then
				startingX = love.math.random(1,5)
			end
			if (#StartingWord == 10) then
				startingX = love.math.random(1,4)
			end
			if (#StartingWord == 11) then
				startingX = love.math.random(1,3)
			end
			if (#StartingWord == 12) then
				startingX = love.math.random(1,2)
			end
			if (#StartingWord == 13) then
				startingX = 1
			end
		end

		if orientation == 1 then
			--print("first word vertical")
			if (#StartingWord == 3) then
				startingY = love.math.random(5,7)
			end
			if (#StartingWord == 4) then
				startingY = love.math.random(4,7)
			end
			if (#StartingWord == 5) then
				startingY = love.math.random(3,7)
			end
			if (#StartingWord == 6) then
				startingY = love.math.random(2,7)
			end
			if (#StartingWord == 7) then
				startingY = love.math.random(1,7)
			end
			if (#StartingWord == 8) then
				startingY = love.math.random(1,6)
			end
			if (#StartingWord == 9) then
				startingY = love.math.random(1,5)
			end
			if (#StartingWord == 10) then
				startingY = love.math.random(1,4)
			end
			if (#StartingWord == 11) then
				startingY = love.math.random(1,3)
			end
			if (#StartingWord == 12) then
				startingY = love.math.random(1,2)
			end
			if (#StartingWord == 13) then
				startingY = 1
			end
		end
			

		
	end
	--Create word with starting coords and orientation
	local newWord = word()
	newWord:update(StartingWord, startingX, startingY, orientation)
	print("Starting Word: " .. StartingWord .. ", orientation is: " .. orientation )
	table.insert(RunningWords,newWord)
	NumberOfWords = 1

end

function PlotNewWord()
	--Get Random Word from existing words
	local randCurrWord = RunningWords[love.math.random(#RunningWords)]
	local finishedWord = word()
	wordArr = {}
	local isValid = false


	while(isValid == false) do
		if (randCurrWord.orientation == 0) then
			--math.randomseed(os.time())
			local randIndex = love.math.random(1,#randCurrWord.letters)
			local randomLetter = string.sub(randCurrWord.letters, randIndex, randIndex)
			--print(randomLetter)
			local tempWord = " "
			--very innefficienty find a word that starts with that letter
			while not (string.sub(tempWord,1,1) == randomLetter) do
				tempWord = GetRandomWord()
			end
			--set the new starting X to the true position of the letter on the board
			local newX = randCurrWord.rootX + randIndex - 1
			--keeps the same y coord, this is simply going to start on the same axis, and not account for being in the middle
			local newY = randCurrWord.rootY
			--set orientation to vertical, since the last word was horizontal
			local newOrientation = 1

			--create word object with params
			
			finishedWord:update(tempWord,newX,newY,newOrientation)

			--insert the word into the running words table
			--table.insert(RunningWords, finishedWord)


			for i=1,#finishedWord.letters do
				tempTile = playTile()
				tempTile:update(string.sub(finishedWord.letters,i,i), "none")
				wordArr[i] = tempTile
			end
		end

		if (randCurrWord.orientation == 1) then
			--math.randomseed(os.time())
			local randIndex = love.math.random(1,#randCurrWord.letters)
			local randomLetter = string.sub(randCurrWord.letters, randIndex, randIndex)
			--print(randomLetter)
			local tempWord = " "
			--very innefficienty find a word that starts with that letter
			while not (string.sub(tempWord,1,1) == randomLetter) do
				tempWord = GetRandomWord()
			end
			--set the new starting X to the true position of the letter on the board
			local newX = randCurrWord.rootX 
			--keeps the same y coord, this is simply going to start on the same axis, and not account for being in the middle
			local newY = randCurrWord.rootY+ randIndex - 1
			--set orientation to vertical, since the last word was horizontal
			local newOrientation = 0

			--create word object with params
			
			finishedWord:update(tempWord,newX,newY,newOrientation)

			--insert the word into the running words table
			--table.insert(RunningWords, finishedWord)


			for i=1,#finishedWord.letters do
				tempTile = playTile()
				tempTile:update(string.sub(finishedWord.letters,i,i), "none")
				wordArr[i] = tempTile
			end
		end
		isValid = IsValidPlacement(finishedWord)
		print(isValid)
	end
	table.insert(RunningWords, finishedWord)

	print("Next Word: " .. finishedWord.letters .. ", orientation is: " .. finishedWord.orientation )

	--print(IsValidPlacement(finishedWord))

	
	NumberOfWords = NumberOfWords + 1
	return wordArr



	




end

function IsValidPlacement(proposedWord)
	local wordLen = #proposedWord.letters
	local tempWord = proposedWord.letters
	local tempOrientation = proposedWord.orientation
	local tempX = proposedWord.rootX
	local tempY = proposedWord.rootY
	
	local valid_placement = false

	print("Checking word: " .. tempWord)
--check if first word exists in dictionary, return false if not
	for i=1, #WordDict do
		if WordDict[i] == tempWord then valid_placement = true end
	end
	--if not WordDict[tempWord] then return false end	
--end dictionary check

--check if word is within board boundaries
	--if orientation is horizontal
	if tempOrientation == 1 then
		--if column + word length - 1 > 15, false
		if tempY + wordLen - 1 > BoardSize then print("Outside of Y bounds") return false end
	elseif tempOrientation == 0 then
		if tempX + wordLen - 1 > BoardSize then print("Outside of X bounds") return false end
	else
		return false --invalid direction
	end
--end check if in boundaries

--check if word aligns with existing tiles or extends a word
	-- valid_placement = false
	for i = 1, wordLen do
		local r,c = tempX, tempY
		--iterate either horizontally or vertically through the letters of the word
		if tempOrientation == 0 then
			c = tempY + i - 1
		else
			r = tempX + i - 1
		end

		if r < BoardSize and c < BoardSize then
			if currentGameTiles[r][c].letter ~= " " and currentGameTiles[r][c].letter ~= tempWord:sub(i,i) then print("Conflicts w/ existing tile?") return false end -- conflicts with existing tile

			if currentGameTiles[r][c].letter == tempWord:sub(i,i) then --matches existing tile
				print("Matches Existing Tile")
				valid_placement = true
			end
		end

	end


	--[[
	--perp word 

	for i=1, wordLen do
		local r2,c2 = tempX, tempY

		if tempOrientation == 0 then
			c2 = tempY + i - 1
		else
			r2 = tempX + i - 1
		end
	

		local perpWord = ""
		local pr,pc = r2,c2
		--print(currentGameTiles[pr-1][pc].letter == " ")

		--move backward to find start of perp word
		while (tempOrientation == 0 and pr > 1 and currentGameTiles[pr-1][pc].letter ~= " ") or
		(tempOrientation == 1 and pc > 1 and currentGameTiles[pr][pc-1].letter ~= " ") do
			if tempOrientation == 0 then
				pr = pr - 1
			else
				pc = pc - 1
			end
		end

		--build full perp word
		while (tempOrientation == 0 and pr <= BoardSize and currentGameTiles[pr][pc].letter ~= " ") or
		(tempOrientation ==  1 and pc <= BoardSize and currentGameTiles[pr][pc].letter ~= " ") do
			perpWord = perpWord .. currentGameTiles[pr][pc].letter
			if tempOrientation == 0 then
				pr = pr + 1
			else
				pc = pc + 1
			end
		end

		print(perpWord)





	end
--]]



















	--[[
--check perpendicular words formed by placement *******does not currently work**********
	for i=1, wordLen do
		local r,c = tempX,tempY
		if tempOrientation == 0 then
			c = tempY + i - 1
		else
			r = tempX + i - 1
		end

		local perpendicularWord = ""
		local pr,pc = r,c

		--move backwards to find start of perpendicular word 
		--print("here" .. pc,pr)
		if pc < 13 and pr < 13 then
			print("here")

			--currentGameTiles[pr-1][pc].letter is never not " "

			while pr > 1 and currentGameTiles[pr-1][pc].letter ~= " " do pr = pr - 1 end
			while pc > 1 and currentGameTiles[pr][pc-1].letter ~= " " do pc = pc - 1 end



        -- Construct the perpendicular word in both directions
			while pc > 1 and tempOrientation == 0 and currentGameTiles[pr][pc - 1].letter ~= " " do pc = pc - 1 end
			while pr > 1 and tempOrientation == 1 and currentGameTiles[pr - 1][pc].letter ~= " " do pr = pr - 1 end

			while pr <= BoardSize and tempOrientation == 1 and currentGameTiles[pr][pc].letter ~= " " do
				perpendicularWord = perpendicularWord .. currentGameTiles[pr][pc].letter
				pr = pr + 1
			end
			
			while pc <= BoardSize and tempOrientation == 0 and currentGameTiles[pr][pc].letter ~= " " do
				perpendicularWord = perpendicularWord .. currentGameTiles[pr][pc].letter
				pc = pc + 1
			end

		end

		local perp_valid_placement = false
		--print(perpendicularWord)
		for i=1, #WordDict do
			if WordDict[i] == perpendicularWord then perp_valid_placement = true end
		end

		if #perpendicularWord > 1 and perp_valid_placement == false then print(perpendicularWord .. " invalid perp word") return false end -- invalid perp word


	end

	return valid_placement
	--]]

end
