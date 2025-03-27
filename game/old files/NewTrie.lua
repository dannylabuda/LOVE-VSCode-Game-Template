NewTrie = Object.extend(Object)

--NewTrie = {}

function NewTrie:new()
    local obj = { root = { children = {}, isEnd = false } }
    self.__index = self
    return setmetatable(obj, self)
end

function NewTrie:insert(word)
    local node = self.root
    for i = 1, #word do
        local char = word:sub(i, i)
        if not node.children[char] then
            node.children[char] = { children = {}, isEnd = false }
        end
        node = node.children[char]
    end
    node.isEnd = true
end

function NewTrie:getRoot()
    return self.root
end

function NewTrie:getChildren(prefix)
    local node = self.root
    for i = 1, #prefix do
        local char = prefix:sub(i, i)
        if not node.children[char] then
            return {}  -- Prefix not found
        end
        node = node.children[char]
    end
    
    local children = {}
    for char, _ in pairs(node.children) do
        table.insert(children, char)
    end
    return children
end

function NewTrie:search(word)
    local node = self:getRoot()
    for i = 1, #word do
        local char = word:sub(i, i)
        --if not node.children[char] then
		if not node or not node.children[char] then
            return false
        end
        node = node.children[char]
    end
    return node.isEnd
end

function NewTrie:fillFromTable(wordList)
    for _, word in ipairs(wordList) do
        self:insert(word)
    end
end


function NewTrie:Test()

	-- Example usage:
local trie = NewTrie:new()
--local words = {"cat", "car", "cart", "dog", "dot"}
--Load trie with words from dict

local f = io.open("dictionary.json", "r")
if f == nil then
	return nil, print("   Could not read file ")
end
local content = f:read "*a"
f:close()

local words = json.decode(content)
trie:fillFromTable(words)

print("Children of root:", table.concat(trie:getChildren(""), ", ")) -- Should print: c, d
print("Children of 'ca':", table.concat(trie:getChildren("ca"), ", ")) -- Should print: t, r
print("Is 'car' in trie?", trie:search("car")) -- Should print: true
print("Is 'candfdf' in trie?", trie:search("candfdf")) -- Should print: false

end

