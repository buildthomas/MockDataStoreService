stds.roblox = {
	globals = {
		"game",
		"workspace"
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

ignore = { "111", "212" }

std = "lua51+roblox"