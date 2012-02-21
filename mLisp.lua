local Compiler = require "mLisp.compiler.Compiler"
local Parser = require "mLisp.compiler.Parser"
local StringStream = require "mLisp.compiler.StringStream"
local LangDef = require "mLisp.lang.LangDef"

local _M = {}

--convert an mLisp string to lua
--return a string if succeeded
--return false, error if failed
function _M.toLua(str)
	local stream = StringStream.new(str)
	local parser = Parser.new(stream)
	local compiler = Compiler.new(LangDef)

	while true do
		local status, data = parser()
		if status then--no parsing error
			if data then--still has data
				local status, err = compiler:compileSafe("ignore", data)
				if not status then--compile error
					return status, err
				end
			else--end of stream
				return compiler:generateCode()
			end
		else--parse error
			local errMsg, line, pos = unpack(data)
			return status, errMsg.."(line "..line..", pos "..pos..")"
		end
	end
end

local function newLineStream()
	local line
	local count = 1
	local len = 0
	pos = 1

	return function()
		if line == nil then--new line
			io.write(count, ">")
			line = io.read("*l")
			len = line:len()
			pos = 1
			count = count + 1
		end
		if pos > len then--end of line
			line = nil
			return ("\n"):byte()
		end

		local ch = line:byte(pos)
		pos = pos + 1

		return ch
	end
end

--A read-eval-print loop
function _M.repl()
	local stream, parser, compiler;
	
	local function reset()
		stream = newLineStream()
		parser = Parser.new(stream)
		compiler = Compiler.new(LangDef)
	end

	reset()

	while true do
		local status, data = parser()
		if status then--no parsing error
			if data then--still has data
				local status, err = compiler:compileSafe("return", data)
				if not status then--compile error
					print("Compile error:"..err)
				else
					local code = compiler:generateCode()
					print("---Generated code---")
					print(code)
					print("--------------------")
					local func, err = loadstring(code)
					if func then
						local status, result = pcall(func)
						if status then
							if result ~= nil then
								print(result)
							end
						else
							print("Runtime error:"..result)
						end
					else
						print("Compile error:"..err)
					end
				end
				reset()
			else--end of stream
				return
			end
		else--parse error
			local errMsg, line, pos = unpack(data)
			print("Parse error:"..errMsg.."(line "..line..", pos "..pos..")")
			reset()
		end
	end
end

return _M
