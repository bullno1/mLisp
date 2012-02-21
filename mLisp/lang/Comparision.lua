local LangUtils = require "mLisp.lang.LangUtils"
local compileBinaryOp = LangUtils.compileBinaryOp
local compileUnaryOp = LangUtils.compileUnaryOp

--comparision operators are registered as special form to optimize compilation
local function lt_sf(compiler, resultUsage, list)
	assert(#list == 3, "lt(<) expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, "<")
end

local function gt_st(compiler, resultUsage, list)
	assert(#list == 3, "gt(>) expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, ">")
end

local function eq_st(compiler, resultUsage, list)
	assert(#list == 3, "eq(=) expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, "==")
end

local function neq_st(compiler, resultUsage, list)
	assert(#list == 3, "neq(!=) expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, "~=")
end

local function lte_sf(compiler, resultUsage, list)
	assert(#list == 3, "lte(<=) expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, "<=")
end

local function gte_sf(compiler, resultUsage, list)
	assert(#list == 3, "gte(>=) expects two arguments")
	return compileBinaryOp(compiler, resultUsage, list, ">=")
end

local function lt(a, b)
	return a < b
end

local function gt(a, b)
	return a > b
end

local function lte(a, b)
	return a <= b
end

local function gte(a, b)
	return a >= b
end

local function eq(a, b)
	return a == b
end

local function neq(a, b)
	return a ~= b
end

return function(def)
	local mergeTable = LangUtils.mergeTable

	mergeTable(def.specialForms, {
		["<"] = lt_sf,
		lt = lt_sf,

		[">"] = gt_sf,
		gt = gt_sf,

		["<="] = lte_sf,
		lte = lte_sf,

		[">="] = gte_sf,
		gte = gte_sf,

		["="] = eq_sf,
		eq = eq_sf,

		["!="] = neq_sf,
		neq = neq_sf
	})

	mergeTable(def.builtins, {
		lt = lt,
		gt = gt,
		lte = lte,
		gte = gte,
		eq = eq,
		neq = neq
	})

	mergeTable(def.aliases, {
		["<"] = "lt",
		[">"] = "gt",
		["<="] = "lte",
		[">="] = "gte",
		["="] = "eq",
		["!="] = "neq"
	})
end
