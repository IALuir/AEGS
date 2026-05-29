local aegs_gacha = {}
local registerGachaPools

local function scheduleRetryRegister()
	if type(Helper) == "table" and type(Helper.addDelayedOneTimeCallbackOnUpdate) == "function" then
		Helper.addDelayedOneTimeCallbackOnUpdate(0.5, function()
			DebugError("AEGS Gacha: retry register after delay")
			registerGachaPools()
		end, true)
	end
end

registerGachaPools = function()
	if type(GachaAPI) ~= "table" or type(GachaAPI.RegisterPool) ~= "function" then
		DebugError("AEGS Gacha: GachaAPI not available, skip pool registration.")
		scheduleRetryRegister()
		return
	end

	if type(GachaAPI.RegisterCurrencies) == "function" then
		GachaAPI.RegisterCurrencies({
			aegs_xenon_vncl_money = {
				label = ReadText(996680, 1),
				amount = 300,
			}
		})
	end

	local pools = {
		{
			id = "aegs_xenon_vncl",
			name = ReadText(996680, 3),
			leftIcon = "left_aegs_xenon_vncl",
			rightPosterIcon = "poster_aegs_xenon_vncl",
			description = ReadText(996680, 4),
			currencyKey = "aegs_xenon_vncl_money",
			drawCost1 = 10,
			drawCost10 = 100,
			items = {
				{ ware = "mauler", rarity = 6, type = "ship", probability = 0.003, icon = "ship_mauler_macro" },
				{ ware = "ship_xen_l_terraformer_01_a", rarity = 6, type = "ship", probability = 0.003, icon = "ship_ship_xen_l_terraformer_01_a_macro" },
				{ ware = "scythe", rarity = 5, type = "ship", probability = 0.025, icon = "ship_scythe_macro" },
				{ ware = "glaive", rarity = 5, type = "ship", probability = 0.025, icon = "ship_glaive_macro" },
				{ ware = "ship_xen_m_corvette_01_a", rarity = 4, type = "ship", probability = 0.060, icon = "ship_ship_xen_m_corvette_01_a_macro" },
				{ ware = "ship_xen_m_corvette_02_a", rarity = 4, type = "ship", probability = 0.060, icon = "ship_ship_xen_m_corvette_02_a_macro" },
				{ ware = "ship_xen_m_miner_solid_01_a", rarity = 3, type = "ship", probability = 0.180, icon = "ship_ship_xen_m_miner_solid_01_a_macro" },
				{ ware = "engine_xen_l_allround_02_mk1", rarity = 2, type = "equipment", probability = 0.062, icon = "upgrade_engine_xen_l_allround_02_mk1_macro" },
				{ ware = "engine_xen_m_virtual_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_engine_xen_m_virtual_01_mk1_macro" },
				{ ware = "engine_xen_s_virtual_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_engine_xen_s_virtual_01_mk1_macro" },
				{ ware = "shield_xen_l_standard_02_mk1", rarity = 2, type = "equipment", probability = 0.062, icon = "upgrade_shield_xen_l_standard_02_mk1_macro" },
				{ ware = "shield_xen_l_standard_02_mk2", rarity = 2, type = "equipment", probability = 0.062, icon = "upgrade_shield_xen_l_standard_02_mk2_macro" },
				{ ware = "shield_xen_m_virtual_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_shield_xen_m_virtual_01_mk1_macro" },
				{ ware = "shield_xen_m_standard_04_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_shield_xen_m_standard_04_mk1_macro" },
				{ ware = "shield_xen_s_virtual_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_shield_xen_s_virtual_01_mk1_macro" },
				{ ware = "weapon_xen_m_mining_02_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_weapon_xen_m_mining_02_mk1_macro" },
				{ ware = "weapon_xen_m_laser_02_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_weapon_xen_m_laser_02_mk1_macro" },
				{ ware = "weapon_xen_m_beam_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_weapon_xen_m_beam_01_mk1_macro" },
				{ ware = "weapon_xen_s_gatling_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_weapon_xen_s_gatling_01_mk1_macro" },
				{ ware = "turret_xen_m_gatling_01_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_turret_xen_m_gatling_01_mk1_macro" },
				{ ware = "turret_xen_m_gatling_02_mk1", rarity = 1, type = "equipment", probability = 0.036, icon = "upgrade_turret_xen_m_gatling_02_mk1_macro" },
				{ ware = "turret_xen_l_plasma_01_mk1", rarity = 2, type = "equipment", probability = 0.062, icon = "upgrade_turret_xen_l_plasma_01_mk1_macro" },
			},
		},
	}

	if type(GachaAPI.RegisterPools) == "function" then
		local count = GachaAPI.RegisterPools(pools)
	end
end

function aegs_gacha.init()
	registerGachaPools()
end

if Register_OnLoad_Init then
	Register_OnLoad_Init(aegs_gacha.init, "AEGS_Gacha_Init")
else
	aegs_gacha.init()
end

return aegs_gacha
