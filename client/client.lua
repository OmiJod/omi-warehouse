local QBCore = exports["qb-core"]:GetCoreObject()
Targets = {} 

local function despawntargets()
    for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
end

RegisterNetEvent("moon-warehouse:client:openmenu", function(meow)
    DisablePurchase = false
    DisableOwnerMenu = true
    DisablePoliceRaid = true
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.type == "leo" then DisablePoliceRaid = false end
    QBCore.Functions.TriggerCallback('moon-warehouse:server:warehousepurchased', function(result)
        if not result then
            DisablePurchase = false
            DisableOwnerMenu = true
        else
            DisablePurchase = true
        end
    end, meow)

    QBCore.Functions.TriggerCallback('moon-warehouse:server:isowner', function(result)
        local CitizenID = QBCore.Functions.GetPlayerData().citizenid
        if result then
            DisableOwnerMenu = false
        else
            DisableOwnerMenu = true
        end
    end, meow)

    Wait(400)

    lib.registerContext({
        id = 'warehouse_menu',
        title = 'Warehouse Interaction',
        options = {
            {
                icon = "check",
                title = 'Manage Warehouse',
                disabled = DisableOwnerMenu,
                arrow = false, -- puts arrow to the right
                onSelect = function()
                    lib.registerContext({
                        id = 'warehouse_owner_menu',
                        title = 'Warehouse Interaction',
                        options = {
                            {
                                icon = "hand",
                                title = 'Open Warehouse Stash',
                                arrow = false, -- puts arrow to the right
                                onSelect = function()
                                    TriggerEvent("moon-warehouse:client:openwarehousestash", meow)
                                end
                            },
                            {
                                icon = "arrows-up-to-line",
                                title = "Upgrade Warehouse",
                                arrow = false, -- puts arrow to the right
                                onSelect = function()
                                    lib.registerContext({
                                        id = 'warehouse_upgrade_menu',
                                        title = 'Warehouse Upgradation',
                                        options = {
                                            {
                                                icon = "arrows-up-to-line",
                                                title = 'Upgrade Warehouse Stash',
                                                arrow = false,
                                                onSelect = function()
                                                    TriggerEvent("moon-warehouse:client:upgradewarehousesize", meow)
                                                end
                                            },
                                            {
                                                icon = "arrows-up-to-line",
                                                title = 'Upgrade Warehouse Slots',
                                                arrow = false,
                                                onSelect = function()
                                                    TriggerEvent("moon-warehouse:client:upgradewarehouseslots", meow)
                                                end
                                            },
                                            {
                                                icon = "backward",
                                                title = "Go Back",
                                                arrow = false, -- puts arrow to the right
                                                onSelect = function()
                                                    TriggerEvent("moon-warehouse:client:openmenu", meow)
                                                end,
                                            },
                                        }
                                    })
                                    lib.showContext('warehouse_upgrade_menu')
                                end,
                            },        
                            {
                                icon = "arrows-up-to-line",
                                title = 'Reset Warehouse Password',
                                arrow = false,
                                onSelect = function()
                                    TriggerEvent("moon-warehouse:client:resetpassword", meow)
                                end
                            },                    
                            {
                                icon = "xmark",
                                title = "Sell Warehouse",
                                arrow = false, -- puts arrow to the right
                                onSelect = function()
                                    TriggerEvent("moon-warehouse:client:sellwarehouse", {location = meow})
                                end,
                            },
                            {
                                icon = "clock",
                                title = 'Renew Warehouse',
                                arrow = false,
                                onSelect = function()
                                    TriggerEvent("moon-warehouse:client:renewwarehouse", meow)
                                end
                            },
                            {
                                icon = "clock",
                                title = 'Check Warehouse Expiry Date',
                                arrow = false,
                                onSelect = function()
                                    TriggerEvent("moon-warehouse:client:checkwarehouse", meow)
                                end
                            },
                            {
                                icon = "backward",
                                title = "Go Back",
                                arrow = false, -- puts arrow to the right
                                onSelect = function()
                                    TriggerEvent("moon-warehouse:client:openmenu", meow)
                                end,
                            },
                        }
                    })
                    lib.showContext('warehouse_owner_menu')
                end
            },
            {
                icon = "dollar-sign",
                title = 'Purchase Warehouse',
                disabled = DisablePurchase,
                arrow = false, -- puts arrow to the right
                onSelect = function()
                    TriggerEvent("moon-warehouse:client:openbuyingcontext", meow)
                end,
            },
            {
                icon = "dollar-sign",
                title = 'Open Stash With Password',
                arrow = false, -- puts arrow to the right
                onSelect = function()
                    TriggerEvent("moon-warehouse:client:openwithpassword", meow)
                end,
            },
            {
                icon = "dollar-sign",
                title = 'Raid Warehouse',
                disabled = DisablePoliceRaid,
                arrow = false, -- puts arrow to the right
                onSelect = function()
                    local HasItem = exports['qb-inventory']:HasItem("police_stormram")
                    if not HasItem then QBCore.Functions.Notify("You Dont have ".. QBCore.Shared.Items["police_stormram"].label .." To raid this warehouse", "primary", 2500) return end
                    TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
                    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
                    if success then
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        TriggerEvent("moon-warehouse:client:openwarehousestash", meow)
                    else
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        QBCore.Functions.Notify("You Failed to Raid", "primary", 2500)
                    end
                end,
            },
            {
                icon = "xmark",
                title = "Close Menu",
                arrow = false, -- puts arrow to the right
                onSelect = function()
                    lib.hideContext()
                end,
            },
        }
    })
    lib.showContext('warehouse_menu')
end)

RegisterNetEvent("moon-warehouse:client:openwithpassword", function(id)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:ispwdset', function(result)
        if result then
            isPwdSet = true
        else
            isPwdSet = false
        end
        Wait(100)
        if isPwdSet then
            local input = lib.inputDialog('Enter Password for Warehouse #'..warehouseid, {
                { type = 'input', label = 'Enter Password', password = true, disabled = false },
            })
            if input ~= nil then
                QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
                    if result.password == input[1] then
                        local stashname = "warehouse"..warehouseid.."_moon"
                        TriggerEvent("inventory:client:SetCurrentStash", stashname) 
                        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashname, 
                        { maxweight = result.stashsize, slots = result.slots }) 
                    else
                        QBCore.Functions.Notify("Wrong Password", "error", 3000)
                    end
                end, warehouseid)
            else
                QBCore.Functions.Notify("You Cancelled the Process", "error", 2500)
            end
        elseif not isPwdSet then
            QBCore.Functions.Notify("Owner Did not Set A Password Yet", "error", 2500)
        end
    end, warehouseid)
end)    

RegisterNetEvent("moon-warehouse:client:resetpassword", function(id)
    local input = lib.inputDialog('Set Password for Warehouse #'..id, {
        { type = 'input', label = 'Enter Password', password = true, disabled = false },
    })
    if input ~= nil then
        TriggerEvent("moon-warehouse:client:client:updatepassword", { location = id, password = input[1]})
    else
        QBCore.Functions.Notify("You Cancelled the Process", "error", 2500)
    end
end)    

RegisterNetEvent("moon-warehouse:client:openwarehousestash", function(id)
    local warehouseid = id
    if Config.inventory == "qb" then
        QBCore.Functions.TriggerCallback('moon-warehouse:server:ispwdset', function(result)
            if result then
                isPwdSet = true
            else
                isPwdSet = false
            end
            Wait(100)
            if isPwdSet then
                local input = lib.inputDialog('Enter Password for Warehouse #'..warehouseid, {
                    { type = 'input', label = 'Enter Password', password = true, disabled = false },
                })
                if input ~= nil then
                    QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
                        if result.password == input[1] then
                            local stashname = "warehouse"..warehouseid.."_moon"
                            TriggerEvent("inventory:client:SetCurrentStash", stashname) 
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", stashname, 
                            { maxweight = result.stashsize, slots = result.slots }) 
                        else
                            QBCore.Functions.Notify("Wrong Password", "error", 3000)
                        end
                    end, warehouseid)
                else
                    QBCore.Functions.Notify("You Cancelled the Process", "error", 2500)
                end
            elseif not isPwdSet then
                local input = lib.inputDialog('Set Password for Warehouse #'..warehouseid, {
                    { type = 'input', label = 'Enter Password', password = true, disabled = false },
                })
                if input ~= nil then
                    TriggerEvent("moon-warehouse:client:client:updatepassword", { location = warehouseid, password = input[1]})
                else
                    QBCore.Functions.Notify("You Cancelled the Process", "error", 2500)
                end
            end
        end, warehouseid)
    elseif Config.inventory == "ox" then
        QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
            local stashname = "warehouse"..warehouseid.."_moon"
            TriggerServerEvent('moon:warehouse:server:oxinventorystash', warehouseid, stashname, result.stashsize, result.slots)
        end, warehouseid)
    end
end)

RegisterNetEvent('moon-warehouse:client:openstash', function(id)
    exports["ox_inventory"]:openInventory("stash", {
      id = id
    })
end)

RegisterNetEvent("moon-warehouse:client:checkwarehouse", function(id)
    local warehouseid = id
    QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
        local date = result.date_purchased / 1000
        TriggerServerEvent("moon-warehouse:server:checkwarehouse", warehouseid, date)
    end, warehouseid)
end)

RegisterNetEvent("moon-warehouse:client:renewwarehouse", function(id)
    local warehouseid = id
    QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
        local renewwarehouse = lib.alertDialog({
            header = 'Renew Warehouse',
            content = 'Your Renewal Will Cost $'.. result.price.. ', Do you Want Renew?',
            centered = true,
            cancel = true
        })
        if renewwarehouse == "cancel" then QBCore.Functions.Notify("You Cancelled the Renwal of your Warehouse", "error", 3500) return end
        local date = result.date_purchased / 1000
        TriggerServerEvent("moon-warehouse:server:renewwarehouse", warehouseid, result.price, date)
    end, warehouseid)
end)

RegisterNetEvent("moon-warehouse:client:upgradewarehouseslots", function(meow)
    local warehouseid = meow
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
        local requiredSlotsOptions = {}
        
        if result.slots == 50 then
            requiredSlotsOptions = {
                { label = "+20 Slots", value = 20 },
            }
        elseif result.slots == 70 then
            requiredSlotsOptions = {
                { label = "+40 Slots", value = 40 },
            }
        elseif result.slots == 110 then
            requiredSlotsOptions = {
                { label = "+60 Slots", value = 60 },
            }
        elseif result.slots == 170 then
            QBCore.Functions.Notify("Can't Upgrade More", "error", 5200)
            return
        end

        local input = lib.inputDialog('Upgrade Warehouse #'..warehouseid, {
            { type = 'input', label = 'Warehouse Location', default = locationInfo.." Warehouse#"..warehouseid, disabled = true },
            { type = 'input', label = 'Default Stash Slots', default = result.slots, disabled = true, min = 1, max = 7 },
            { type = 'select', label = 'Required Stash Slots', options = requiredSlotsOptions, disabled = false },
        })

        if input ~= nil then
            TriggerEvent("moon-warehouse:client:client:upgradewarehouseslots", { location = warehouseid, slotsinc = input[3]})
        else
            QBCore.Functions.Notify("You Cancelled the Process", "error", 2500)
        end
    end, warehouseid)
end)

RegisterNetEvent("moon-warehouse:client:upgradewarehousesize", function(meow)
    local warehouseid = meow
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
        local requiredSizeOptions = {}
        
        if result.stashsize == 3000 * 1000 then
            requiredSizeOptions = {
                { label = "+500 Kg", value = 500 },
            }
        elseif result.stashsize == 3500 * 1000 then
            requiredSizeOptions = {
                { label = "+1000 Kg", value = 1000 },
            }
        elseif result.stashsize == 4500 * 1000 then
            requiredSizeOptions = {
                { label = "+1500 Kg", value = 1500 },
            }
        elseif result.stashsize == 6000 * 1000 then
            QBCore.Functions.Notify("Can't Upgrade More", "error", 5200)
            return
        end

        local input = lib.inputDialog('Upgrade Warehouse #'..warehouseid, {
            { type = 'input', label = 'Warehouse Location', default = locationInfo.." Warehouse#"..warehouseid, disabled = true },
            { type = 'input', label = 'Default Stash Size [Kg]', default = result.stashsize / 1000, disabled = true, min = 1, max = 7 },
            { type = 'select', label = 'Required Stash Size', options = requiredSizeOptions, disabled = false },
        })

        if input ~= nil then
            TriggerEvent("moon-warehouse:client:client:upgradewarehousesize", {location = warehouseid, sizeinc = input[3]})
        else
            QBCore.Functions.Notify("Your Cancelled the Process", "error", 2500)
        end
    end, warehouseid)
end)

RegisterNetEvent('moon-warehouse:client:client:upgradewarehouseslots', function(data)
    local warehouseid = data.location
    local slots = data.slotsinc
    local CitizenID = QBCore.Functions.GetPlayerData().citizenid
    canUpgrade = false
    Wait(5)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:isowner', function(result)
        if result then
            canUpgrade = true
        else
            QBCore.Functions.Notify("You Dont Own This Warehouse", 'error', 7500)
            canUpgrade = false
        end
    end, warehouseid)
    Wait(400)
    if canUpgrade then
        TriggerServerEvent('moon-warehouse:server:Upgradewarehouseslots', warehouseid, CitizenID, slots)
    else
        QBCore.Functions.Notify("Cannot Sale the Ware House", 'error', 7500)
    end
end)

RegisterNetEvent('moon-warehouse:client:client:updatepassword', function(data)
    local warehouseid = data.location
    local password = data.password
    local CitizenID = QBCore.Functions.GetPlayerData().citizenid
    ispwdset = false
    Wait(5)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:isowner', function(result)
        if result then
            ispwdset = true
        else
            QBCore.Functions.Notify("You Dont Own This Warehouse", 'error', 7500)
            ispwdset = false
        end
    end, warehouseid)
    Wait(400)
    if ispwdset then
        TriggerServerEvent('moon-warehouse:server:updatepassword', warehouseid, CitizenID, password)
    else
        QBCore.Functions.Notify("Cannot Sale the Ware House", 'error', 7500)
    end
end)

RegisterNetEvent('moon-warehouse:client:client:upgradewarehousesize', function(data)
    local warehouseid = data.location
    local size = data.sizeinc
    local CitizenID = QBCore.Functions.GetPlayerData().citizenid
    canUpgrade = false
    Wait(5)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:isowner', function(result)
        if result then
            canUpgrade = true
        else
            QBCore.Functions.Notify("You Dont Own This Warehouse", 'error', 7500)
            canUpgrade = false
        end
    end, warehouseid)
    Wait(400)
    if canUpgrade then
        TriggerServerEvent('moon-warehouse:server:upgradewarehousesize', warehouseid, CitizenID, size)
    else
        QBCore.Functions.Notify("Cannot Sale the Ware House", 'error', 7500)
    end
end)

RegisterNetEvent("moon-warehouse:client:openbuyingcontext", function(meow)
    local warehouseid = meow
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    local Player = QBCore.Functions.GetPlayerData()
    QBCore.Functions.TriggerCallback('moon-warehouse:server:getdetails', function(result)
        local input = lib.inputDialog('Buy Warehouse #'..warehouseid, {
            {type = 'input', label = 'Warehouse Location', default = locationInfo.." Warehouse#"..warehouseid, disabled = true},
            {type = 'input', label = 'Price', default = result.price, disabled = true, min = 1, max = 7},
            {type = 'input', label = 'Stash Size', default = result.stashsize / 1000 .. " Kg", disabled = true, min = 1, max = 7},
            {type = 'input', label = 'CitizenID', default = Player.citizenid, disabled = true, min = 1, max = 7},
            {type = 'input', label = 'Full Name', default = Player.charinfo.firstname.. " " .. Player.charinfo.lastname, disabled = true, min = 1, max = 7},
            {type = 'input', label = 'Birthdate', default = Player.charinfo.birthdate, disabled = true, min = 1, max = 7},
        }) 
        if input ~= nil then
            TriggerEvent("moon-warehouse:client:client:purchasewarehouse", {location = warehouseid, price = result.price})
        else
            QBCore.Functions.Notify("Your Cancelled the Process", "error", 2500)
        end
    end, warehouseid)
end)

RegisterNetEvent('moon-warehouse:client:client:purchasewarehouse', function(data)
    local warehouseid = data.location
    local price = data.price
    local CitizenID = QBCore.Functions.GetPlayerData().citizenid
    CanOpen = false
    Wait(5)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:warehousepurchased', function(result)
        if result then
            IsOwned = true
        else
            IsOwned = false
        end
    end, warehouseid)
    Wait(400)
    if not IsOwned then
        TriggerServerEvent('moon-warehouse:server:buyWareHouse', warehouseid, CitizenID, price)
    elseif IsOwned then
        QBCore.Functions.Notify("Warehouse Already Owned", 'error', 7500)
    end
end)

RegisterNetEvent('moon-warehouse:client:sellwarehouse', function(data)
    local sellwarehousealert = lib.alertDialog({
        header = 'Sell Warehouse',
        content = 'Your Upgradation Would be Reset, Do you Want To Still Sell the warehouse?',
        centered = true,
        cancel = true
    })
    if sellwarehousealert == "cancel" then QBCore.Functions.Notify("You Cancelled the Sale of your Warehouse", "error", 3500) return end
    local warehouseid = data.location
    local CitizenID = QBCore.Functions.GetPlayerData().citizenid
    CanSell = false
    Wait(5)
    QBCore.Functions.TriggerCallback('moon-warehouse:server:isowner', function(result)
        if result then
            CanSell = true
        else
            QBCore.Functions.Notify("You Dont Own This Warehouse", 'error', 7500)
            CanSell = false
        end
    end, warehouseid)
    Wait(400)
    if CanSell then
        TriggerServerEvent('moon-warehouse:server:sellwarehouse', warehouseid)
    else
        QBCore.Functions.Notify("Cannot Sale the Ware House", 'error', 7500)
    end
end)

RegisterNetEvent("moon-warehouse:client:pullstash", function(id)
    local warehouseid = id
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "warehouse"..warehouseid.."_moon")
end)

CreateThread(function()
    while true do
        for k, v in pairs(Config.WareHouses) do 
            for k, v in pairs(v) do
                local name = "Warehouse "..k
                QBCore.Functions.TriggerCallback('moon-warehouse:server:warehousepurchased', function(result)
                    if result then
                        IsOwned2 = true
                    else
                        IsOwned2 = false
                    end
                end, k)
                Wait(400)
                if not IsOwned2 then
                    makeBlip({coords = v, sprite = 474, col = 2, name = name})
                elseif IsOwned2 then
                    makeBlip({coords = v, sprite = 474, col = 5, name = name})
                end
            end
        end
        Wait(Config.RefreshBlipInterval * 60 * 60 * 1000)
    end
end)

CreateThread(function()
    for k,v in pairs(Config.WareHouses) do 
        for k,v in pairs(v) do
            local name = 'WareHouse'.. k
            Targets[name] =
            exports['qb-target']:AddBoxZone(name, v.xyz, 2.0, 2.0, {
                heading = v.w,
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 4,
            }, {
                options = {
                    {
                        action = function()
                            TriggerEvent("moon-warehouse:client:openmenu", k)
                        end,
                        icon = "fas fa-clipboard",
                        label = 'Interact',
                    },
                },
                distance = 3.0
            })
        end
    end
end)

AddEventHandler('onResourceStop', function(resource) 
    if resource == GetCurrentResourceName() then 
        despawntargets() 
    end 
end)
