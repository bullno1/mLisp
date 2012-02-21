local LangUtils = require "mLisp.lang.LangUtils"
local compileBinaryOp = LangUtils.compileBinaryOp
local compileUnaryOp = LangUtils.compileUnaryOp
--Arithmetic operators are registered as special form to optimize compilation
local function add_sf(compiler, resultUsage, list)
	assert(#list >= 2, "add(+) expects at least one argument")
	return compileBinaryOp(compiler, resultUsage, list, "+")
end

local function sub_sf(compiler, resultUsage, list)
	assert(#list >= 2, "sub(-) expects at least one argument")
	if #list == 2 then--negate
		return compileUnaryOp(compiler, resultUsage, list, "-")
	else--subtract
		return compileBinaryOp(compiler, resultUsage, list, "-")
	end
end

local function mul_sf(compiler, resultUsage, list)
	assert(#list >= 2, "mul(*) expects at least one argument")
	return compileBinaryOp(compiler, resultUsage, list, "*")
end

local function div_sf(compiler, resultUsage, list)
	assert(#list >= 2, "div(/) expects at least one argument")
	if #list == 2 then--invert
		return compileUnaryOp(compiler, resultUsage, list, "1 / ")
	else--divide
		return compileBinaryOp(compiler, resultUsage, list, "/")
	end
end

local function pow_sf(compiler, resultUsage, list)
	assert(#list == 3, "pow expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, "^")
end

local function concat_sf(compiler, resultUsage, list)
	assert(#list >= 2, "concat expects at least two arguments")
	return compileBinaryOp(compiler, resultUsage, list, "..")
end

local function identity_sf(compiler, resultUsage, list)
	assert(#list == 2, "identity expects at one arguments")
	return compiler:compile(resultUsage, list[2])
end

local function add(first, ...)
	local acc = first
	for _, v in ipairs(arg) do
		acc = acc + v
	end
	return acc
end

local function mul(first, ...)
	local acc = first
	for _, v in ipairs(arg) do
		acc = acc * v
	end
	return acc
end

local function sub(first, ...)
	if #arg == 0 then--negate
		return -first
	else
		local acc = first
		for _, v in ipairs(arg) do
			acc = acc - v
		end
		return acc
	end
end

local function div(first, ...)
	if #arg == 0 then--invert
		return 1 / first
	else
		local acc = first
		for _, v in ipairs(arg) do
			acc = acc / v
		end
		return acc
	end
end

local function pow(base, power)
	return base ^ power
end

local function concat(...)
	return table.concat(arg)
end

local function identity(a)
	return a
end

return function(def)
	local mergeTable = LangUtils.mergeTable

	mergeTable(def.specialForms, {
		["+"] = add_sf,
		["add"] = add_sf,

		["-"] = sub_sf,
		["sub"] = sub_sf,

		["*"] = mul_sf,
		["mul"] = mul_sf,

		["/"] = div_sf,
		["div"] = div_sf,

		["pow"] = pow_sf,

		["concat"] = concat_sf,

		["identity"] = identity_sf
	})

	mergeTable(def.builtins, {
		add = add,
		sub = sub,
		mul = mul,
		div = div,
		pow = pow,
		concat = concat,
		identity = identity_sf
	})

	mergeTable(def.aliases, {
		["+"] = "add",
		["-"] = "sub",
		["*"] = "mul",
		["/"] = "div"
	})
end
