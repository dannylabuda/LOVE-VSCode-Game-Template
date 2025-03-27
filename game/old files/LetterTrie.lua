LetterTrie = Object.extend(Object)

function LetterTrie:runTrie()
	function table_print (tt, indent, done)
		done = done or {}
		indent = indent or 0
		if type(tt) == "table" then
		for key, value in pairs (tt) do
			io.write(string.rep (" ", indent)) -- indent it
			if type (value) == "table" and not done [value] then
			done [value] = true
			io.write(string.format("[%s] => table\n", tostring (key)));
			io.write(string.rep (" ", indent+4)) -- indent it
			io.write("(\n");
			table_print (value, indent + 7, done)
			io.write(string.rep (" ", indent+4)) -- indent it
			io.write(")\n");
			else
			io.write(string.format("[%s] => %s\n",
				tostring (key), tostring(value)))
			end
		end
		else
		io.write(tt .. "\n")
		end
	end
	
	-- Returns its argument.
	function identity(...)
		return ...
	end
	
	-- Returns the first logical true value of (pred x) for any x in coll, else nil.
	-- One common idiom is to use a set as pred, for example this will return :fred
	-- if :fred is in the sequence, otherwise nil: (some #{:fred} coll)
	function some(pred, ts)
		for _, v in pairs(ts) do
		local res = pred(v)
		if res then
			return res
		end
		end
		return false
	end
	
	-- Returns true if (pred x) is logical true for every x in coll, else false.
	function every(pred, ts)
		for _, v in pairs(ts) do
		if not pred(v) then
			return false
		end
		end
		return true
	end
	
	-- Converts a string into a table
	function letters(word)
		local res = {}
		for i = 1, #word do
		res[#res+1] = word:sub(i,i)
		end
		return res
	end
	
	-- Composes f and g such that (f . g)(x) = f(g(x))
	function compose(f, g)
		return function(...)
		return f(g(...))
		end
	end
	
	-- f should be a function of 2 arguments. If val is not supplied, returns the
	-- result of applying f to the first 2 items in coll, then applying f to that
	-- result and the 3rd item, etc. If coll contains no items, f must accept no
	-- arguments as well, and reduce returns the result of calling f with no
	-- arguments. If coll has only 1 item, it is returned and f is not called. If
	-- val is supplied, returns the result of applying f to val and the first item
	-- in coll, then applying f to that result and the 2nd item, etc. If coll
	-- contains no items, returns val and f is not called.
	function reduce(f, acc, t)
		for _, v in ipairs(t) do
		acc = f(acc, v)
		end
		return acc
	end
	
	-- Returns a lazy sequence consisting of the result of applying f to the set of
	-- first items of each coll, followed by applying f to the set of second items
	-- in each coll, until any one of the colls is exhausted. Any remaining items in
	-- other colls are ignored. Function f should accept number-of-colls arguments.
	function map(f, t)
		return reduce(function(memo, e)
		memo[#memo+1] = f(e)
		return memo
		end, {}, t)
	end
	
	-- Returns a key v from table t or default if v is not in t.
	function get(t, v, default)
		if not t then return default end
		return t[v] or default
	end
	
	-- assoc[iate]. When applied to a map, returns a new map of the same
	-- (hashed/sorted) type, that contains the mapping of key(s) to val(s). When
	-- applied to a vector, returns a new vector that contains val at index. Note -
	-- index must be <= (count vector).
	function assoc(t, k, v)
		t[k] = v
		return t
	end
	
	-- Returns the first element of table t
	function first(t)
		return t[1]
	end
	
	-- Returns the remaining elements of table t
	function rest(t)
		local res = {}
		for i, v in ipairs(t) do
		if i > 1 then
			res[#res+1] = v
		end
		end
		return res
	end
	
	-- conj[oin]. Returns a new collection with the xs 'added'. (conj nil item)
	-- returns (item). The 'addition' may happen at different 'places' depending on
	-- the concrete type.
	function conj(t1, t2)
		if type(t1) == "table" and type(t2) == "table" then
		for k, v in pairs(t2) do
			t1[k] = v
		end
		return t1
		else
		return nil
		end
	end
	
	-- Returns the value in a nested associative structure, where ks is a sequence
	-- of ke(ys. Returns nil if the key is not present, or the not-found value if
	-- supplied.
	function get_in(t, ks, not_found)
		if not_found == nil then
		return reduce(get, t, ks)
		else
		if #ks == 0 then
			return t
		else
			local v = get(t, first(ks))
			if v == nil then
			return not_found
			else
			return get_in(v, rest(ks), not_found)
			end
		end
		end
	end
	
	-- Associates a value in a nested associative structure, where ks is a sequence
	-- of keys and v is the new value and returns a new nested structure.  If any
	-- levels do not exist, hash-maps will be created.
	function assoc_in(t, ks, v)
		local k = first(ks)
		if #ks > 1 then
		return assoc(t, k, assoc_in(get(t, k, {}), rest(ks), v))
		else
		return assoc(t, k, v)
		end
	end
	
	-- Returns a map that consists of the rest of the maps conj-ed onto the first.
	-- If a key occurs in more than one map, the mapping from the latter
	-- (left-to-right) will be the mapping in the result.
	function merge(...)
		local args = { ... }
		if some(identity, args) then
		return reduce(function(memo, t)
			memo = memo or {}
			return conj(memo, t)
		end, first(args), rest(args))
		end
	end

	--[[
	--me trying something wacky
	function getChildren(trie,prefix)
		local node = get_in(trie,prefix)
		if not node then
			return nil
		end

		local children = {}
		for key,value in pairs(node) do
			if key ~= "val" and key ~= "terminal" then
				table.insert(children,key)
				print(key)
			end
		end
		return children
	end
	]]--
	
	-- Trie Implementation --
	
	function add_to_trie(trie, v)
		return assoc_in(trie, v, merge(get_in(trie, v, {}), {val = v, terminal = true}))
	end
	
	function in_trie(trie, v)
		return get(get_in(trie, v), "terminal", false)
	end
	
	function build_trie(words)
		return reduce(add_to_trie, {}, map(letters, words))
	end
	
	-- Example Usage --
	
	--words = {"abc", "bcd", "caa", "cab", "cac", "cad"}


	--Load trie with words from dict
	local f = io.open("dictionary.json", "r")
	if f == nil then
		return nil, print("   Could not read file ")
	end

	local content = f:read "*a"
	f:close()

	words = json.decode(content)
	trie = build_trie(words)
	--table_print(trie)
	print("HERE")
	--print( in_trie(trie, letters("understand")))
	return trie
end
