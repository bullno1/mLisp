local Compiler = require "mLisp.compiler.Compiler"
local Parser = require "mLisp.compiler.Parser"
local StringStream = require "mLisp.compiler.StringStream"
local LangDef = require "mLisp.lang.LangDef"

local _M = {}

function _M.compileString(str)
	local stream = StringStream.new(str)
	local parser = Parser.new(stream)
	local compiler = Compiler.new(LangDef)
	repeat
		local status, exp = parser()
		if status and exp then
			print(compiler:generateCode())
			local status, err = compiler:compile("ignore", exp)
			if not status then
				print("Compile error", err)
				break
			end
		elseif exp then
			print("Parse error", exp)
		end
	until (not status) or (not exp)
	return compiler:generateCode()
end

return _M
