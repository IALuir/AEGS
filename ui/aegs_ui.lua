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
    mapMenu.registerCallback("aegs_map_shipInformation_shiptypename_override", aegs_sc.mapShipTypeChange)
    mapMenu.registerCallback("aegs_map_ship_subordinateassignments_insert", aegs_sc.mapShipSubAssignmentInsert)
    mapMenu.registerCallback("aegs_map_ship_assignments_insert", aegs_sc.mapShipAssignmentInsert04)
    mapMenu.registerCallback("aegs_map_loadoutinfo_double_insert", aegs_sc.mapLoadoutinfoDoubleInsert)
    mapMenu.registerCallback("aegs_map_propertyowned_constructionships_insert", aegs_sc.mapPropertyOwnedConstructionShipsInsert)
    interactMenu.registerCallback("aegs_map_rightMenu_shipOverview_insert", aegs_sc.mapShipBuildingOverviewInsert)
    interactMenu.registerCallback("aegs_map_rightMenu_shipBuilding_insert", aegs_sc.mapShipBuildingInsert)
    interactMenu.registerCallback("prepareActions_prepare_custom_action", aegs_sc.prepareCustomActions)
    interactMenu.registerCallback("insertLuaAction_insert_custom_action", aegs_sc.insertCustomAction)
    interactMenu.registerCallback("aegs_map_rightMenu_shipassignments_insert_01", aegs_sc.mapShipAssignmentInsert01)
    interactMenu.registerCallback("aegs_map_rightMenu_shipassignments_insert_02", aegs_sc.mapShipAssignmentInsert02)
    interactMenu.registerCallback("aegs_map_rightMenu_shipassignments_insert_03", aegs_sc.mapShipAssignmentInsert03)
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
        menu.object.shiptypename = ReadText(20221, 5063)
    elseif menu.id == "ship_aegs_l_bengal_b_macro" then
        menu.object.shiptypename = ReadText(20221, 5064)
    else

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

function aegs_sc.mapShipBuildingInsert(shiptrader, isdock, in_macro, doessellshipstoplayer, isplayerownedtarget, mode, issupplyship, container, dockedships)
    if in_macro ~= "ship_aegs_l_bengal_macro" then
        return nil, nil
    end
    if mode == "purchase" then
        if not isplayerownedtarget then
            return nil, nil
        end
        local active = true
        local mouseovertext = ""
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
        return true, {
            category = "main",
            type = "buildships",
            text = ReadText(1001, 7875),
            helpOverlayID = "interactmenu_buildship",
            helpOverlayText = " ",
            helpOverlayHighlightOnly = true,
            script = function () return interactMenu.buttonShipConfig("purchase") end,
            active = active,
            mouseOverText = mouseovertext
        }
    elseif mode ~= "upgrade" then
        return nil, nil
    end

    if not (isdock and isplayerownedtarget) then
        return nil, nil
    end
    local active = false
    for _, ship in ipairs(dockedships or {}) do
        if C.CanContainerEquipShip(container, ship) or C.CanContainerSupplyShip(container, ship) then
            active = true
            break
        end
    end

    local mouseovertext
    if not doessellshipstoplayer then
        active = false
        mouseovertext = ReadText(1026, 7865)
    elseif not shiptrader then
        active = false
        mouseovertext = ReadText(1026, 7827)
    elseif not active then
        if #(dockedships or {}) > 0 then
            if C.IsComponentClass(dockedships[1], "ship_l") or C.IsComponentClass(dockedships[1], "ship_xl") then
                mouseovertext = ReadText(1026, 7807)
            else
                mouseovertext = ReadText(1026, 7806)
            end
        else
            mouseovertext = ReadText(1026, 7808)
        end
    end

    return true, {
        category = "main",
        type = "upgradeships",
        text = issupplyship and ReadText(1001, 7877) or ReadText(1001, 7841),
        helpOverlayID = "interactmenu_upgradeships",
        helpOverlayText = " ",
        helpOverlayHighlightOnly = true,
        script = function () return interactMenu.buttonShipConfig("upgrade") end,
        active = active,
        mouseOverText = mouseovertext
    }
end

function aegs_sc.prepareCustomActions(actions, definedactions)
    local convertedComponent = interactMenu.data and interactMenu.data.convertedComponent or 0
    if convertedComponent == 0 then
        return
    end

    local in_macro, isdock, issupplyship = GetComponentData(convertedComponent, "macro", "isdock", "issupplyship")
    if in_macro ~= "ship_aegs_l_bengal_macro" then
        return
    end
    if not isdock then
        return
    end
    if issupplyship or C.IsComponentClass(interactMenu.componentSlot.component, "station") then
        return
    end
    if not ((#interactMenu.selectedplayerships > 0) and interactMenu.possibleorders["Repair"] and (interactMenu.numorderloops == 0)) then
        return
    end
    if definedactions["lua;aegs_upgrade_bengal"] then
        return
    end

    table.insert(actions, {
        id = 0,
        text = "",
        active = true,
        actiontype = "lua;aegs_upgrade_bengal",
        istobedisplayed = true
    })
    definedactions["lua;aegs_upgrade_bengal"] = #actions
end

function aegs_sc.insertCustomAction(actiontype, istobedisplayed)
    if actiontype ~= "aegs_upgrade_bengal" or (not istobedisplayed) then
        return
    end

    local convertedComponent = interactMenu.data and interactMenu.data.convertedComponent or 0
    if convertedComponent == 0 then
        return
    end

    local shiptrader, isdock, issupplyship, owner = GetComponentData(convertedComponent, "shiptrader", "isdock", "issupplyship", "owner")
    local in_macro = GetComponentData(convertedComponent, "macro")
    if in_macro ~= "ship_aegs_l_bengal_macro" then
        return
    end
    if not ((#interactMenu.selectedplayerships > 0) and interactMenu.possibleorders["Repair"] and isdock and (not issupplyship) and (not C.IsComponentClass(interactMenu.componentSlot.component, "station")) and (interactMenu.numorderloops == 0)) then
        return
    end

    local doessellshipstoplayer = GetFactionData(owner, "doessellshipstoplayer")
    local active = false
    local haspilot = false
    for _, ship in ipairs(interactMenu.selectedplayerships) do
        local pilot = GetComponentData(ship, "assignedpilot")
        if pilot then
            haspilot = true
            if C.CanContainerEquipShip(interactMenu.componentSlot.component, ship) or C.CanContainerSupplyShip(interactMenu.componentSlot.component, ship) then
                active = true
                break
            end
        end
    end

    local mouseovertext
    if not doessellshipstoplayer then
        active = false
        mouseovertext = ReadText(1026, 7865)
    elseif not shiptrader then
        active = false
        mouseovertext = ReadText(1026, 7827)
    elseif not haspilot then
        mouseovertext = ReadText(1026, 7830)
    elseif (not active) and (#interactMenu.selectedplayerships > 0) then
        if C.IsComponentClass(interactMenu.selectedplayerships[1], "ship_l") or C.IsComponentClass(interactMenu.selectedplayerships[1], "ship_xl") then
            mouseovertext = ReadText(1026, 7805)
        else
            mouseovertext = ReadText(1026, 7804)
        end
    end

    interactMenu.insertInteractionContent("selected_orders", {
        type = "upgrade",
        text = interactMenu.orderIconText("Repair") .. ReadText(1001, 7826),
        helpOverlayID = "interactmenu_upgrade",
        helpOverlayText = " ",
        helpOverlayHighlightOnly = true,
        script = function () return interactMenu.buttonUpgrade(true) end,
        active = active,
        mouseOverText = mouseovertext,
        orderid = "Repair"
    })
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

function aegs_sc.mapPropertyOwnedConstructionShipsInsert(infoTableData)
    local inserted = {}
    local dedup = {}

    if infoTableData and infoTableData.constructionShips then
        for _, entry in ipairs(infoTableData.constructionShips) do
            if entry and entry.id then
                dedup[tostring(entry.id)] = true
            end
        end
    end

    local function appendTasks(container, isinprogress)
        if container == nil or container == 0 then
            return
        end
        local n = C.GetNumBuildTasks(container, 0, isinprogress, false)
        if n <= 0 then
            return
        end
        local buf = ffi.new("BuildTaskInfo[?]", n)
        n = C.GetBuildTasks(buf, n, container, 0, isinprogress, false)
        for i = 0, n - 1 do
            if ffi.string(buf[i].factionid) == "player" then
                local key = tostring(buf[i].id)
                if not dedup[key] then
                    dedup[key] = true
                    table.insert(inserted, {
                        id = buf[i].id,
                        buildingcontainer = buf[i].buildingcontainer,
                        component = buf[i].component,
                        macro = ffi.string(buf[i].macro),
                        factionid = "player",
                        buildercomponent = buf[i].buildercomponent,
                        price = buf[i].price,
                        ismissingresources = buf[i].ismissingresources,
                        queueposition = buf[i].queueposition,
                        inprogress = isinprogress
                    })
                end
            end
        end
    end

    local playerobjects = GetContainedObjectsByOwner("player")
    for _, ship in ipairs(playerobjects or {}) do
        if GetComponentData(ship, "macro") == "ship_aegs_l_bengal_macro" then
            local ship64 = ConvertStringTo64Bit(tostring(ship))
            appendTasks(ship64, true)
            appendTasks(ship64, false)
        end
    end

    if #inserted > 0 then
        return { constructionships = inserted }
    end
    return nil
end

init()
