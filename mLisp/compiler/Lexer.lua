local _M = {}

local function char(ch)
	return ch:byte()
end
--Constants
local LEFT_PAREN = char('(')
local RIGHT_PAREN = char(')')
local SINGLE_QUOTE = char("'")
local DOUBLE_QUOTE = char('"')
local SPACE = char(' ')
local TAB = char('\t')
local CR = char('\r')
local LF = char('\n')
local ZERO = char('0')
local NINE = char('9')
local DOT = char('.')
local A_LOWER = char('a')
local Z_LOWER = char('z')
local A_UPPER = char('A')
local Z_UPPER = char('Z')

local function isWhiteSpace(ch)
	return ch == SPACE or ch == TAB or ch == CR or ch == LF
end

local function isNum(ch)
	return ZERO <= ch and ch <= NINE
end

local function isAlpha(ch)
	return (A_LOWER <= ch and ch <= Z_LOWER) or (A_UPPER <= ch and ch <= Z_UPPER)
end

local function isAlphanum(ch)
	return isAlpha(ch) or isNum(ch)
end

local function numberPredicate(ch)
	return isNum(ch) or ch == DOT--a number or a dot
end

local function stringPredicate(ch)--TODO: escape sequence
	return ch ~= DOUBLE_QUOTE and ch ~= 0
end

local function symbolPredicate(ch)
	return
		ch ~= LEFT_PAREN
		and ch ~= RIGHT_PAREN
		and not isWhiteSpace(ch)
		and ch ~= 0
end

--turn input to ast
function _M.new(inputStream)
	local pos = 0
	local line = 1
	local peeked = false
	local buff

	local function peek()
		peeked = true
		buff = inputStream()
		return buff
	end

	local function getChar()
		pos = pos + 1

		local ch
		if not peeked then
			ch = inputStream()
		else
			peeked = false
			ch = buff
		end

		if ch == CR or ch == LF then
			line = line + 1
			pos = 0
		end

		if ch == CR and peek() == LF then--Windows line ending
			getChar()--eat \n
			pos = 0
		end

		return ch
	end

	local function capture(predicate, buff)
		local output = buff or {}
		while true do
			local ch = peek()
			if predicate(ch) then
				table.insert(output, ch)
				getChar()--consume the character
			else
				break
			end
		end
		return string.char(unpack(output))
	end

	return function()--return token type, token, line, pos
		local char
		--skip white spaces
		repeat
			char = getChar()--get a character from the input stream
			if char == 0 then
				return "EndOfStream"
			end
		until not isWhiteSpace(char)

		if char == LEFT_PAREN then
			return "LeftParen", "(", line, pos

		elseif char == RIGHT_PAREN then
			return "RightParen", ")", line, pos

		elseif isNum(char) then--number literal
			--TODO: check for multiple dot
			local number = tonumber(capture(numberPredicate, {char}))
			return "Number", number, line, pos

		elseif char == DOUBLE_QUOTE then--string literal
			local str = capture(stringPredicate)
			getChar()--consume the other DOUBLE_QUOTE
			return "String", str, line, pos

		else--symbol
			local symbol = capture(symbolPredicate, {char})
			return "Symbol", symbol, line, pos
		end
	end
end

return _M
