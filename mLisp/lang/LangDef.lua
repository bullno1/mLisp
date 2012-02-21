local def = {
	specialForms = {},
	wrapWithLambda = {},
	aliases = {},
	builtins = {}
}

require("mLisp.lang.Arithmetic")(def)
require("mLisp.lang.SpecialForms")(def)
require("mLisp.lang.Comparision")(def)

return def
