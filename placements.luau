local p = {}
local easy = "dif_easy"
local med = "dif_normal"
local hard = "dif_hard"
local extreme = "dif_expert"

p["farm - level 1"] = {
	dif = easy,
	{type = "PlaceUnit", unit = "unit_cactus", id = 3, position = Vector3.new(-332.280, 61.680, -134.541), rotation = -180},
	{type = "PlaceUnit", unit = "unit_cactus", id = 4, position = Vector3.new(-332.312, 61.680, -132.878), rotation = -180},
	{type = "PlaceUnit", unit = "unit_palm_tree", id = 11, position = Vector3.new(-326.046, 61.680, -128.048), rotation = -180},
	{type = "PlaceUnit", unit = "unit_cactus", id = 18, position = Vector3.new(-332.369, 61.680, -131.291), rotation = -180},
	{type = "PlaceUnit", unit = "unit_flame_leaf", id = 30, position = Vector3.new(-324.627, 61.680, -124.958), rotation = -180},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 30, level = 2},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 30, level = 3},
	{type = "PlaceUnit", unit = "unit_flame_leaf", id = 42, position = Vector3.new(-327.966, 61.680, -98.302), rotation = -180},
	{type = "PlaceUnit", unit = "unit_flame_leaf", id = 48, position = Vector3.new(-327.803, 61.680, -102.565), rotation = -180},
	{type = "PlaceUnit", unit = "unit_flame_leaf", id = 49, position = Vector3.new(-327.233, 61.680, -108.134), rotation = -180},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 42, level = 2},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 48, level = 2},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 49, level = 2},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 42, level = 3},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 48, level = 3},
	{type = "UpgradeUnit", unit = "unit_flame_leaf", id = 49, level = 3},
	{type = "UpgradeUnit", unit = "unit_palm_tree", id = 11, level = 2},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 18, level = 2},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 4, level = 2},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 3, level = 2},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 3, level = 3},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 4, level = 3},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 18, level = 3},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 3, level = 4},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 4, level = 4},
	{type = "UpgradeUnit", unit = "unit_cactus", id = 18, level = 4},
}

p["farm - level 1, rb saw"] = {
	dif = easy,
	{type = "PlaceUnit", unit = "unit_razor_rainbow", id = 7, position = Vector3.new(-331.822, 61.680, -100.958), rotation = -180},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 7, level = 2},
	{type = "PlaceUnit", unit = "unit_razor_rainbow", id = 11, position = Vector3.new(-331.801, 61.680, -97.667), rotation = -180},
	{type = "PlaceUnit", unit = "unit_razor_rainbow", id = 18, position = Vector3.new(-339.267, 61.680, -98.833), rotation = -180},
	{type = "PlaceUnit", unit = "unit_razor_rainbow", id = 22, position = Vector3.new(-339.083, 61.680, -101.156), rotation = -180},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 11, level = 2},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 18, level = 2},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 22, level = 2},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 7, level = 3},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 11, level = 3},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 18, level = 3},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 22, level = 3},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 7, level = 4},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 11, level = 4},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 18, level = 4},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 22, level = 4},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 7, level = 5},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 11, level = 5},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 18, level = 5},
	{type = "UpgradeUnit", unit = "unit_razor_rainbow", id = 22, level = 5},
}

return p