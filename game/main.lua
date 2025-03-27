function love.load()
	Object = require "classic"
	json = require "dkjson"
	tick = require "tick"
	require "Board"
	require "LetterTreeNode"
	require "SolveState"

	Solve = SolveState:test()

end

function love.update(dt)
	tick.update(dt)
	
end


function love.draw()

end
