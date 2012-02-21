local _M = {}

function _M.new(str)
	local pos = 0
	return function()
		pos = pos + 1
		if pos <= str:len() then
			return str:byte(pos)
		else
			return 0
		end
	end
end

return _M
