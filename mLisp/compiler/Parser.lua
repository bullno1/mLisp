local _M = {}

local Lexer = require "mLisp.compiler.Lexer"

function _M.new(inputStream)
	local lexer = Lexer.new(inputStream)

	return function()
		local currentList = false
		local listStack = {}

		while true do
			local tokenType, token, line, pos = lexer()
			if tokenType == "LeftParen" then
				table.insert(listStack, currentList)--save currentList
				currentList = {
					"List",
					{},
					line,
					pos,
					#listStack
				}
			elseif tokenType == "RightParen" then
				if #listStack == 0 then
					return false, "Unexpected right parenthesis", {tokenType, token, line}
				end
				local list = currentList
				currentList = table.remove(listStack)--pop from the stack
				if #listStack == 0 then--completed an expression
					return true, list
				else
					table.insert(currentList[2], list)
				end
			elseif tokenType == "Error" then
				return false, token, line
			elseif tokenType == "EndOfStream" then
				if #listStack ~= 0 then
					return false, "Unexpected end of stream", {tokenType, token, line}
				else
					return true
				end
			else
				if currentList then
					table.insert(currentList[2], {tokenType, token, line, pos, #listStack + 1})
				else
					return true, {tokenType, token, line, pos, 1}
				end
			end
		end
	end
end

return _M
