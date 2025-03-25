-- Define the LetterTreeNode class
LetterTreeNode = {}
LetterTreeNode.__index = LetterTreeNode

function LetterTreeNode:new(is_word)
    local self = setmetatable({}, LetterTreeNode)
    self.is_word = is_word or false
    self.children = {}
    return self
end

-- Define the LetterTree class
LetterTree = {}
LetterTree.__index = LetterTree

function LetterTree:new(words)
    local self = setmetatable({}, LetterTree)
    self.root = LetterTreeNode:new(false)
    for _, word in ipairs(words) do
        local current_node = self.root
        for i = 1, #word do
            local letter = word:sub(i, i)
            if not current_node.children[letter] then
                current_node.children[letter] = LetterTreeNode:new(false)
            end
            current_node = current_node.children[letter]
        end
        current_node.is_word = true
    end
    return self
end

function LetterTree:lookup(word)
    local current_node = self.root
    for i = 1, #word do
        local letter = word:sub(i, i)
        if not current_node.children[letter] then
            return nil
        end
        current_node = current_node.children[letter]
    end
    return current_node
end

function LetterTree:is_word(word)
    local word_node = self:lookup(word)
    return word_node and word_node.is_word or false
end

-- Function to read the basic English words from a file
function basic_english()
	local f = io.open("dictionary.json", "r")
	if f == nil then
		return nil, print("   Could not read file ")
	end
	local content = f:read "*a"
	f:close()

	local words = json.decode(content)
    return LetterTree:new(words)
end
