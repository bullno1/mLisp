local code = [[
	(define a (sub 1 3 4))
	(print (mul (+ a (/ b))
				(+ (sub c) d)))

	((identity +) a b)
	(((identity identity) -) (mul c d e))

	(+ 2 3)
	(- 2 3)
	(* 2 3)
	(/ 2 3)
	(+ 2 3 4)
	(/ 2 3 4)
	((getFunc "hoho") a 
					 (some other
					       shit))
	(define b (c d))

	(if (not this)
		(- (that)))

	(if (not that)
		(this))

	(defun
	test
	()
		(if a
			b
			(d (+ "c" "b" (d))
				c)))

	(print "A")

	(os.time)
	(defun fib (n)
		(if (<= n 2)
			1
			(+ (fib (- n 1))
			   (fib (- n 2)))))

	(fib (if (<= 2 3)
			 4
			 5))
]]

local mLisp = require "mLisp"
local luaCode = mLisp.compileString(code)
print(luaCode)
print(loadstring(luaCode))

local fibLispCode = [[
(defun fibLisp (n)
	(if (<= n 2)
		1
		(+ (fibLisp (- n 1))
		   (fibLisp (- n 2)))))

(defun loop (from to)
	(if (< from to)
		(loop (+ from 1) to)))
]]

local fibLispCode_lua = mLisp.compileString(fibLispCode)
print(fibLispCode_lua)
loadstring(fibLispCode_lua)()

function fibLua(n)
	if n <= 2 then
		return 1
	else
		return fibLua(n - 1) + fibLua(n - 2)
	end
end

print("fibLisp")
local start = os.clock()
print(fibLisp(37))
print(os.clock() - start)

print("fibLua")
local start = os.clock()
print(fibLua(37))
print(os.clock() - start)

loop(1, 1000)
