local cuffItems = {"cuffs", "zipties"}


local function cuffCheck(src, target, cuffType)
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 or
        not lib.table.contains(cuffItems, cuffType) then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and

        targetState.handsUp or cuffType == "cuffs" and
        not targetState.gettingCuffed and
        not targetState.isCuffing and
        not targetState.isCuffed
end

local function uncuffCheck(src, target, cuffType)
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)

    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and
        targetState.isCuffed
end

RegisterNetEvent("ND_Police:syncAgressiveCuff", function(target, angle, cuffType, heading)
    local src = source
    if not cuffCheck(src, target, cuffType) then return end

    local escaped = lib.callback.await("ND_Police:syncAgressiveCuff", target, angle, cuffType, heading)
    if escaped then return end

    Player(target).state.handsUp = false
end)

RegisterNetEvent("ND_Police:syncNormalCuff", function(target, angle, cuffType)
    local src = source
    if not cuffCheck(src, target, cuffType) then return end
    TriggerClientEvent("ND_Police:syncNormalCuff", target, angle, cuffType)
end)

RegisterNetEvent("ND_Police:uncuffPed", function(target, cuffType)
    local src = source
    if not uncuffCheck(src, target, cuffType) then return end

    local playerCuffType = Player(target).state.cuffType or "cuffs"
    if playerCuffType ~= cuffType then return end

    TriggerClientEvent("ND_Police:uncuffPed", target)
end)
