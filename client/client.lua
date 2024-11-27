local ped = PlayerPedId()
local JammedWeapons = {}

function Animation()
    local AnimDict = Config.JamFixAnimation.AnimDict
    local AnimName = Config.JamFixAnimation.AnimName
    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do
        Wait(0)
    end
    Wait(Config.JamFixAnimationDelay)
    TaskPlayAnim(ped, AnimDict, AnimName, 8.0, -8.0, -1, 0, 0, false, false, false)
end

function Minigame(WeaponHash)
    if Config.JamFixAnimationEnable then
        Animation()
    end

    local success = exports["syn_minigame"]:taskBar(3000, 7) -- You can add your minigame export
    if success == 100 then
        JammedWeapons[WeaponHash] = nil
        print("The weapon is fixed, you can use it again") -- You can add your notify
        ClearPedTasks(ped)
    else
        print("Fail, try again!")
    end
end

function CheckGunJam(WeaponHash)
    for _, WhitelistWeapon in ipairs(Config.WhitelistWeapon) do
        if WeaponHash == GetHashKey(WhitelistWeapon) then
            return
        end
    end

    if math.random(1, 100) <= Config.JamChance then
        JammedWeapons[WeaponHash] = true
        print("The gun is jammed! Press [E] to fix it")
    end
end

CreateThread(function()
    while true do
        Wait(0)
        local _, CurrentWeaponHash = GetCurrentPedWeapon(ped, true)

        if JammedWeapons[CurrentWeaponHash] then
            DisablePlayerFiring(ped, true)
            if IsControlJustPressed(0, Config.JamFixKey) then
                Minigame(CurrentWeaponHash)
            end
        elseif IsPedShooting(ped) and not JammedWeapons[CurrentWeaponHash] then
            CheckGunJam(CurrentWeaponHash)
        end
    end
end)