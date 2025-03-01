local ffi = require("ffi")
local C = ffi.C

local aegs_sc = {
    outputString = {}
}

local shipMenu
local encycMenu
local mapMenu
local interactMenu

function init ()
    shipMenu = Helper.getMenu ("ShipConfigurationMenu")
    encycMenu = Helper.getMenu ("EncyclopediaMenu")
    mapMenu = Helper.getMenu ("MapMenu")
    interactMenu = Helper.getMenu ("InteractMenu")

    shipMenu.registerCallback("evaluateShipOptions_override_shiptypename", aegs_sc.shipTypeChange)
    encycMenu.registerCallback("onShowMenu_addOtherShipTypes", aegs_sc.encyclopediaChange)
    mapMenu.registerCallback("map_shipInformation_shiptypename_override", aegs_sc.mapShipTypeChange)
    mapMenu.registerCallback("map_ship_subordinateassignments_insert", aegs_sc.mapShipSubAssignmentInsert)
    mapMenu.registerCallback("map_ship_assignments_insert", aegs_sc.mapShipAssignmentInsert04)
    mapMenu.registerCallback("map_loadoutinfo_double_insert", aegs_sc.mapLoadoutinfoDoubleInsert)
    interactMenu.registerCallback("map_rightMenu_shipOverview_insert", aegs_sc.mapShipBuildingOverviewInsert)
    interactMenu.registerCallback("map_rightMenu_shipBuilding_insert", aegs_sc.mapShipBuildingInsert)
    interactMenu.registerCallback("map_rightMenu_shipassignments_insert_01", aegs_sc.mapShipAssignmentInsert01)
    interactMenu.registerCallback("map_rightMenu_shipassignments_insert_02", aegs_sc.mapShipAssignmentInsert02)
    interactMenu.registerCallback("map_rightMenu_shipassignments_insert_03", aegs_sc.mapShipAssignmentInsert03)
end

function aegs_sc.shipTypeChange(in_shiptypename, in_shipicon, in_class)
    if in_shipicon == "ship_aegs_dreadnought" then
		return ReadText(20221, 5063)
    elseif in_shipicon == "ship_aegs_cruiser" then
		return ReadText(20221, 5064)
	end
	return in_shiptypename
end

function aegs_sc.encyclopediaChange(menu, ftable)
    if menu.id == "retribution_macro" then
        return menu.addDetailRow(ftable, ReadText(1001, 9051), ReadText(20221, 5063))
    elseif menu.id == "ship_aegs_l_bengal_b_macro" then
        return menu.addDetailRow(ftable, ReadText(1001, 9051), ReadText(20221, 5064))
    else
        return menu.addDetailRow(ftable, ReadText(1001, 9051), menu.object.shiptypename)
    end
end

function aegs_sc.mapShipTypeChange(in_macro)
    if in_macro == "retribution_macro" then
		return ReadText(20221, 5063)
    elseif in_macro == "ship_aegs_l_bengal_b_macro" then
		return ReadText(20221, 5064)
	end
    return nil
end

function aegs_sc.mapShipSubAssignmentInsert(in_macro,miningactive,salvageactive)
    if in_macro == "ship_drak_kraken_macro" then
		return { id = "mining", text = ReadText(20208, 40201), icon = "", displayremoveoption = false,active = miningactive, mouseovertext = miningactive and "" or ReadText(1026, 8602)}
    end
    return nil
end

function aegs_sc.mapShipBuildingOverviewInsert(in_macro)
    if in_macro == "ship_drak_kraken_macro" or in_macro == "ship_aegs_l_bengal_macro"  then
		return true,ReadText(1001,8401)
    end
    return nil,nil
end

function aegs_sc.mapShipBuildingInsert(shiptrader,isdock,in_macro,doessellshipstoplayer,isplayerownedtarget)
    if in_macro == "ship_aegs_l_bengal_macro"  then
        local state = false
		local active = true
        local text = ReadText(1001, 7875)
		local mouseovertext = ""
        if isplayerownedtarget then
            state = true
        end
		if not doessellshipstoplayer then
			active = false
			mouseovertext = ReadText(1026, 7865)
		elseif not isdock then
			active = false
			mouseovertext = ReadText(1026, 8014)
		elseif shiptrader == nil then
			active = false
			mouseovertext = ReadText(1026, 7827)
		end
        return state,active,text,mouseovertext
    end
    return nil,nil,nil,nil
end

function aegs_sc.mapShipAssignmentInsert01(in_macro,numassignableminingships,numassignabletugs)
    if in_macro == "ship_drak_kraken_macro"  then
        if numassignableminingships > 0 then
            return true,"selected_assignments_mining","mining"
        end
    end
    return nil,nil,nil
end

function aegs_sc.mapShipAssignmentInsert02(in_macro)
    if in_macro == "ship_drak_kraken_macro"  then
        return true,"main_assignments_mining","mining","mine"
    end
    return nil,nil,nil,nil
end

function aegs_sc.mapShipAssignmentInsert03(in_macro,allmining,alltugs)
    if in_macro == "ship_drak_kraken_macro"  then
        if allmining then
            return true,"selected_change_assignments_mining","mining"
        end
    end
    return nil,nil,nil
end

function aegs_sc.mapShipAssignmentInsert04(in_macro,primarypurpose)
    if in_macro == "ship_drak_kraken_macro"  then
        if primarypurpose == "mine" then
            return { id = "mining", text = ReadText(20208, 40201), icon = "", displayremoveoption = false }
        end
    end
    return nil
end

function aegs_sc.mapLoadoutinfoDoubleInsert(in_macro)
    if in_macro == "ship_drak_kraken_macro"  then
        local subsystems = {
            { name = ReadText(996679, 3), intro = ReadText(996679, 4), icon = "refinery_factory" },
        }
        return true,ReadText(996671, 48),ReadText(1001, 60),ReadText(1001, 13),subsystems
    elseif in_macro == "ship_aegs_l_bengal_macro"  then
        local subsystems = {
            { name = ReadText(996679, 5), intro = ReadText(996679, 6), icon = "medium_hanger" },
        }
        return true,ReadText(996671, 48),ReadText(1001, 60),ReadText(1001, 13),subsystems
    elseif in_macro == "eclipse_macro" or  in_macro == "sabre_raven_macro" then
        local subsystems = {
            { name = ReadText(996679, 1), intro = ReadText(996679, 2), icon = "stealth_system" },
        }
        return true,ReadText(996671, 48),ReadText(1001, 60),ReadText(1001, 13),subsystems
    elseif in_macro == "retribution_macro"  then
        local subsystems = {
            { name = ReadText(996679, 7), intro = ReadText(996679, 8), icon = "super_heavy_armor" },
            { name = ReadText(996679, 9), intro = ReadText(996679, 10), icon = "high_energy_shield" }
        }
        return true,ReadText(996671, 48),ReadText(1001, 60),ReadText(1001, 13),subsystems
    end
    return nil,nil,nil,nil,nil
end

init()