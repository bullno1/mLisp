local _M = {}

local Lexer = require "mLisp.compiler.Lexer"

function _M.new(inputStream)
	local lexer = Lexer.new(inputStream)

	--A node looks like this { type, data, line, pos, depth }
	--Return true and an expression tree if no error
	--Return true and nil at the end of a stream
	--Return false and an error object in case of error
	--error object: {message, line, pos}
	return function()
		local currentList = false
		local listStack = {}

		while true do
			local token = {lexer()}
			local tokenType, lexeme, line, pos = unpack(token)
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
					return false, {"Unexpected right parenthesis", line, pos}
				end
				local list = currentList
				currentList = table.remove(listStack)--pop from the stack
				if #listStack == 0 then--completed an expression
					return true, list
				else
					table.insert(currentList[2], list)
				end
			elseif tokenType == "Error" then
				return false, {lexeme, line, pos}
			elseif tokenType == "EndOfStream" then
				if #listStack ~= 0 then
					return false, {"Unexpected end of stream", line, pos}--TODO: print which parenthesis is still unmatched
				else
					return true
				end
			else
				if currentList then
					table.insert(currentList[2], {tokenType, lexeme, line, pos, #listStack + 1})
				else
					return true, {tokenType, lexeme, line, pos, 1}
				end
			end
		end
	end
end

return _M
