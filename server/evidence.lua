local evidence = {}
local addEvidence = {}
local clearEvidence = {}
local evidenceExpire = 20 * 60 -- seconds until evidence is removed
local evidenceMetadata = lib.load("data.evidence")

local bulletText = {
    projectile = "Projectile from ",
    casing = "Casing from "
}


CreateThread(function()
    while true do
        Wait(1000)

        if next(addEvidence) or next(clearEvidence) then
            TriggerClientEvent('ND_Police:updateEvidence', -1, addEvidence, clearEvidence)

            table.wipe(addEvidence)
            table.wipe(clearEvidence)
        end

        local time = os.time()
        for coords, data in pairs(evidence) do
            if time - data.time > evidenceExpire then
                evidence[coords] = nil
                clearEvidence[coords] = true
            end
        end
    end
end)

RegisterCommand('removepdmisc', function(src)
    if src > 0 and not Bridge.hasJobs(src, lib.load('data.config').policeGroups) then return end

    for coords in pairs(evidence) do
        evidence[coords] = nil
        clearEvidence[coords] = true
    end
end)

RegisterServerEvent('ND_Police:distributeEvidence', function(nodes)
    local src = source
    local state = Player(src).state
    state.lastShot = os.time()

    if not state.shot then
        state.shot = true
    end

    for coords, items in pairs(nodes) do
        if evidence[coords] then
            lib.table.merge(evidence[coords].items, items)
        else
            evidence[coords] = { items = items, time = os.time() }
            addEvidence[coords] = true
        end
    end
end)

