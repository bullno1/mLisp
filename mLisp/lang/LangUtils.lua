local _M = {}

function _M.mergeSet(set, table)
	for _, v in pairs(table) do
		set[v] = true
	end
end

function _M.mergeTable(table1, table2)
	for k, v in pairs(table2) do
		if table1[k] == nil then
			table1[k] = v
		end
	end
end

function _M.compileBinaryOp(compiler, resultUsage, list, op)
	if resultUsage == "ignore" then--generate a dummy var
		compiler:emit(list[1][3], "local ", compiler:generateUniqueName(), " = ")
	end
	--asParam or return
	if resultUsage == "return" then
		compiler:emit(list[1][3], "return ")
	end
	--wrap with parenthesis to ensure precedence
	compiler:emit(list[1][3], "(")
	--add all terms
	for i = 2, #list do
		local term = list[i]
		compiler:compile("asParam", term)
		if i ~= #list then
			compiler:emit(term[3], " ", op, " ")
		end
	end
	compiler:emit(")")
	--add a separator if not used as param
	if resultUsage ~= "asParam" then
		return compiler:emit(";")
	else
		return true
	end
end

function _M.compileUnaryOp(compiler, resultUsage, list, op)
	if resultUsage == "ignore" then--generate a dummy var
		compiler:emit(list[1][3], "local ", compiler:generateUniqueName(), " = ")
	end
	--asParam or return
	if resultUsage == "return" then
		compiler:emit(list[1][3], "return ")
	end
	compiler:emit(list[1][3], "(", op)
	compiler:compile("asParam", list[2])
	compiler:emit(")")
	--add a separator if not used as param
	if resultUsage ~= "asParam" then
		return compiler:emit(";")
	else
		return true
	end
end

return _M
