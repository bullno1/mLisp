local function unpackArgs(list)
	return select(2, unpack(list))
end

local function _define(compiler, resultUsage, symbol, value, ...)
	assert(value and #{...} == 0, "define expects 2 arguments")
	assert(symbol[1] == "Symbol", "define expects argument 1 to be symbol")

	compiler:compile("asParam", symbol)
	compiler:emit(" = ")

	if resultUsage == "return" then
		compiler:compile("asParam", value)
		return compiler:emit(";return;")
	else
		compiler:compile("asParam", value)
		return compiler:emit(";")
	end
end

local function define(compiler, resultUsage, list)
	return _define(compiler, resultUsage, unpackArgs(list))
end

local function _defun(compiler, resultUsage, funcName, params, ...)
	assert(funcName[1] == "Symbol", "defun expects argument 1 to be symbol")
	assert(params[1] == "List", "defun expects argument 2 to be list")

	compiler:emit(funcName[3], funcName[2])--function name
	compiler:emit(params[3], "(")--begin parameter list

	for i, param in ipairs(params[2]) do
		local paramType, paramName, paramLoc = unpack(param)
		assert(paramType == "Symbol", "parameter name must be symbol")
		compiler:emit(paramLoc, paramName)
		if i ~= #params[2] then
			compiler:emit(", ")--separate parameters
		end
	end
	compiler:emit(")")--end parameter list
	--function body
	for i, exp in ipairs(arg) do
		compiler:compile(i == #arg and "return" or "ignore", exp)
	end

	if resultUsage == "return" then
		return compiler:emit(" end;return;")
	else
		return compiler:emit(" end")
	end
end

local function defun(compiler, resultUsage, list)
	assert(#list >= 3, "defun expects at least 3 arguments")
	compiler:emit(list[1][3], "function ")
	return _defun(compiler, resultUsage, unpackArgs(list))
end

local function If(compiler, resultUsage, condition, thenClause)
	compiler:compile("asParam", condition)
	compiler:emit(" ")
	compiler:emit(thenClause[3], "then ")
	compiler:compile(resultUsage, thenClause)
	return compiler:emit(" end")
end

local function IfElse(compiler, resultUsage, condition, thenClause, elseClause)
	compiler:compile("asParam", condition)
	compiler:emit(" ")
	compiler:emit(thenClause[3], "then ")
	compiler:compile(resultUsage, thenClause)
	compiler:emit(" ")
	compiler:emit(elseClause[3], "else ")
	compiler:compile(resultUsage, elseClause)
	return compiler:emit(" end")
end

local function if_(compiler, resultUsage, list)
	if #list == 3 then
		compiler:emit(list[1][3], "if ")
		return If(compiler, resultUsage, unpackArgs(list))
	elseif #list == 4 then
		compiler:emit(list[1][3], "if ")
		return IfElse(compiler, resultUsage, unpackArgs(list))
	else
		error("if expects 2 or 3 arguments")
	end
end

return function(def)
	local LangUtils = require "mLisp.lang.LangUtils"
	local mergeTable = LangUtils.mergeTable
	local mergeSet = LangUtils.mergeSet

	mergeTable(def.specialForms, {
		["if"] = if_,
		define = define,
		defun = defun
	})

	mergeSet(def.wrapWithLambda, {
		"if",
		"define",
		"defun"
	})
end
