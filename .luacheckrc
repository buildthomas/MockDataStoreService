stds.roblox = {
	globals = {
		"game"
	},

	read_globals = {
		-- Global objects
		"script",

		-- Global functions
		"spawn",
		"delay",
		"warn",
		"wait",
		"tick",
		"typeof",
		"settings",

		-- Global Namespaces
		"Enum",
		"debug",
		"utf8",

		math = {
			fields = {
				"clamp",
				"sign"
			}
		},

		-- Global types
		"Instance",
		"Vector2",
		"Vector3",
		"CFrame",
		"Color3",
		"UDim",
		"UDim2",
		"Rect",
		"TweenInfo",
		"Random"
	}
}

stds.testez = {
	read_globals = {
		"describe",
		"it", "itFOCUS", "itSKIP",
		"FOCUS", "SKIP", "HACK_NO_XPCALL",
		"expect",
	}
}

ignore = { "111" }

std = "lua51+roblox"

files["**/*.spec.lua"] = {
	std = "+testez",
}