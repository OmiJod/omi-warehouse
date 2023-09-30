local QBCore = exports["qb-core"]:GetCoreObject()

function CleanupWarehouses()
    local currentDate = os.date('%Y-%m-%d') -- Get the current date in YYYY-MM-DD format
    local sevenDaysAgo = os.date('%Y-%m-%d', os.time() - Config.RentPeriod * 24 * 60 * 60) -- Calculate the date 7 days ago
    
    MySQL.Async.execute('UPDATE warehouses SET owned = 0, owner = 0, date_purchased = NULL, stashsize = 3000000, slots = 50, passwordset = 0, password = NULL WHERE `date_purchased` <= ?', {sevenDaysAgo})
end

RegisterNetEvent('moon-warehouse:server:buyWareHouse', function(location, CitizenID, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local CostOfWarehouse = price
    local PlayerBankMoney = Player.PlayerData.money['bank']
    
    if PlayerBankMoney <= CostOfWarehouse then
        TriggerClientEvent('QBCore:Notify', src, "You cannot afford this. You need $".. CostOfWarehouse, "error", 2500)
        return
    end
    
    if Player.Functions.RemoveMoney("bank", CostOfWarehouse, "Purchased Warehouse") then
        local purchaseDate = os.date('%Y-%m-%d') -- Get the current date in YYYY-MM-DD format
        MySQL.Async.execute('UPDATE warehouses SET owned = ?, owner = ?, date_purchased = ? WHERE `location` = ?', {1, CitizenID, purchaseDate, location})
        TriggerClientEvent('QBCore:Notify', src, "You have purchased the warehouse.", "success", 2500)
    end
end)

RegisterServerEvent("moon-warehouse:server:renewwarehouse")
AddEventHandler("moon-warehouse:server:renewwarehouse", function(meow, price, date)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local costtoUpgrade = price
    local PlayerBankMoney = Player.PlayerData.money['bank']
    local FORMATTEDdate = os.date('%Y-%m-%d', date)
    
    if PlayerBankMoney <= costtoUpgrade then
        TriggerClientEvent('QBCore:Notify', src, "You cannot afford this. You need $".. costtoUpgrade, "error", 2500)
        return
    end

    if Player.Functions.RemoveMoney("bank", costtoUpgrade, "Purchased Warehouse") then
        local currentDate = os.date('%Y-%m-%d')
        local dateTimestamp = os.time({year = tonumber(FORMATTEDdate:sub(1, 4)), month = tonumber(FORMATTEDdate:sub(6, 7)), day = tonumber(FORMATTEDdate:sub(9, 10))})
        local newTimestamp = dateTimestamp + 7 * 24 * 60 * 60
        local newPurchaseDate = os.date('%Y-%m-%d', newTimestamp)
        MySQL.Async.execute('UPDATE warehouses SET date_purchased = ? WHERE `location` = ?', {newPurchaseDate, meow})
        TriggerClientEvent('QBCore:Notify', src, "Warehouse Renewed for 7 days.", 'success', 2500)
    end
end)

RegisterServerEvent("moon-warehouse:server:checkwarehouse")
AddEventHandler("moon-warehouse:server:checkwarehouse", function(meow, date)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local FORMATTEDdate = os.date('%Y-%m-%d', date)
    local currentDate = os.date('%Y-%m-%d')
    local dateTimestamp = os.time({year = tonumber(FORMATTEDdate:sub(1, 4)), month = tonumber(FORMATTEDdate:sub(6, 7)), day = tonumber(FORMATTEDdate:sub(9, 10))})
    local newTimestamp = dateTimestamp + 7 * 24 * 60 * 60
    local newPurchaseDate = os.date('%Y-%m-%d', newTimestamp)
    TriggerClientEvent('QBCore:Notify', src, "Your Warehouse Will Expire On ".. newPurchaseDate, 'success', 10000)
end)

RegisterNetEvent('moon-warehouse:server:Upgradewarehouseslots', function(location, CitizenID, slots)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local slotstoincrease = slots
    if slotstoincrease == 20 then 
        Upgradationcost = Config.Upgradation.Slots["+20"]
    elseif slotstoincrease == 40 then 
        Upgradationcost = Config.Upgradation.Slots["+40"]
    elseif slotstoincrease == 60 then 
        Upgradationcost = Config.Upgradation.Slots["+60"]
    end
    local PlayerBankMoney = Player.PlayerData.money['bank']
    if PlayerBankMoney <= Upgradationcost then TriggerClientEvent('QBCore:Notify', src, "You cannot Afford This You Need $".. Upgradationcost, "error", 2500) return end
    if Player.Functions.RemoveMoney("bank", Upgradationcost, "Upgraded Slots") then
        MySQL.Async.fetchScalar('SELECT slots FROM warehouses WHERE `location` = ?', {location}, function(currentSlots)
            if currentSlots then
                local newSlots = tonumber(currentSlots) + tonumber(slotstoincrease)
                MySQL.Async.execute('UPDATE warehouses SET slots = ? WHERE `location` = ?', {newSlots, location})
                TriggerClientEvent('QBCore:Notify', src, "Warehouse Slots are Now Upgraded, You now have ".. newSlots .. " Slots in Your Stash", 'success')
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "Warehouse Slots Cannot Be Upgraded", 'error')
    end
end)

RegisterNetEvent('moon-warehouse:server:updatepassword', function(location, CitizenID, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local password = password
    MySQL.Async.execute('UPDATE warehouses SET passwordset = ?, password = ? WHERE `location` = ?', {1, password, location})
    TriggerClientEvent('QBCore:Notify', src, "You have Updated the Password", 'success')
end)

RegisterNetEvent('moon-warehouse:server:upgradewarehousesize', function(location, CitizenID, size)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local sizetoincrease = size * 1000
    if sizetoincrease == 500 * 1000 then 
        UpgradationcostStash = Config.Upgradation.StashSize["500 Kg"]
    elseif sizetoincrease == 1000 * 1000 then 
        UpgradationcostStash = Config.Upgradation.StashSize["1000 Kg"]
    elseif sizetoincrease == 1500 * 1000 then 
        UpgradationcostStash = Config.Upgradation.StashSize["1500 Kg"]
    end
    local PlayerBankMoney = Player.PlayerData.money['bank']
    if PlayerBankMoney <= UpgradationcostStash then TriggerClientEvent('QBCore:Notify', src, "You cannot Afford This You Need $".. UpgradationcostStash, "error", 2500) return end
    if Player.Functions.RemoveMoney("bank", UpgradationcostStash, "Upgraded Stash") then
        MySQL.Async.fetchScalar('SELECT stashsize FROM warehouses WHERE `location` = ?', {location}, function(currentsize)
            if currentsize then
                local newSize = tonumber(currentsize) + tonumber(sizetoincrease)
                MySQL.Async.execute('UPDATE warehouses SET stashsize = ? WHERE `location` = ?', {newSize, location})
                TriggerClientEvent('QBCore:Notify', src, "Warehouse Stash is Now Upgraded New Stash Size is ".. newSize / 1000 .. " Kg", 'success')
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "Warehouse Stash Cannot Be Upgraded", 'error')
    end
end)

RegisterNetEvent('moon:warehouse:server:oxinventorystash', function(warehouseid, stashname, stashsize, slots)
	local Player = QBCore.Functions.GetPlayer(source)
	local id = warehouseid
    local stashname = stashname
    local slots = slots
    exports["ox_inventory"]:RegisterStash(stashname, stashname, slots, stashsize)
	TriggerClientEvent("moon-warehouse:client:openstash", source, id)
end)

RegisterNetEvent('moon-warehouse:server:sellwarehouse', function(location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local WareHouseSellPrice = Config.WareHouseSellPrice
    if Player.Functions.AddMoney("bank", WareHouseSellPrice, "Sold Warehouse") then
        MySQL.Async.execute('UPDATE warehouses  SET owned = ? WHERE `location` = ?', {0, location})
        MySQL.Async.execute('UPDATE warehouses  SET owner = ? WHERE `location` = ?', {0, location})
        MySQL.Async.execute('UPDATE warehouses  SET slots = ? WHERE `location` = ?', {50, location})
        MySQL.Async.execute('UPDATE warehouses  SET stashsize = ? WHERE `location` = ?', {3000000, location})
        MySQL.Async.execute('UPDATE warehouses  SET date_purchased = NULL WHERE `location` = ?', {location})
        MySQL.Async.execute('UPDATE warehouses  SET passwordset = ? WHERE `location` = ?', {0, location})
        MySQL.Async.execute('UPDATE warehouses  SET password = NULL WHERE `location` = ?', {location})
        TriggerClientEvent('QBCore:Notify', src, "Warehouse Sold", 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, "Warehouse Cannot Be Sold", 'error')
    end
end)

QBCore.Functions.CreateCallback('moon-warehouse:server:getdetails', function(_,cb,location)
    local result = MySQL.query.await('SELECT * FROM warehouses WHERE location = ?', {location})
    if result[1] ~= nil then
        cb(result[1])
    end
end)

QBCore.Functions.CreateCallback('moon-warehouse:server:isowner', function(source, cb, location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll('SELECT * FROM warehouses WHERE `owner` = ? AND location = ?', {citizenid, location})
    if result then
        for _, v in pairs(result) do
            if v.owner == citizenid and v.owned == 1 then
                cb(true)
            else
                cb(false)
            end
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('moon-warehouse:server:ispwdset', function(source, cb, location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT * FROM warehouses WHERE location = ?', {location})
    if result then
        for _, v in pairs(result) do
            if v.passwordset == 0 then
                cb(false)
            elseif v.passwordset == 1 then
                cb(true)
            end
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('moon-warehouse:server:warehousepurchased', function(source, cb, location)
    local result = MySQL.Sync.fetchAll('SELECT * FROM warehouses WHERE `location` = ?', {location})
    if result then
        for k, v in pairs(result) do
            local warehouseinfo = json.encode(v)
            local owned = false
            if v.owned == 1 then
                owned = true
            elseif v.owned == 0 then
                owned = false
            end
            cb(owned)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupWarehouses()
        UpdateWarehouses()
    end
end)

QBCore.Commands.Add("pullwarehousestash", "Pull warehouse Stash through location", {{name = "id", help = "Warehouse ID"}}, false, function(source, args)
    local src = source
    local warehouseId = tonumber(args[1])
    if warehouseId then
        local sql = "SELECT * FROM `warehouses` WHERE `location` = ?"
        local values = {warehouseId}
        MySQL.Async.fetchAll(sql, values, function(result)
            if result and #result > 0 then
                TriggerClientEvent('moon-warehouse:client:pullstash', src, warehouseId)
            else
                -- No warehouse with such ID exists
                TriggerClientEvent('QBCore:Notify', src, "No warehouse with that ID exists.", "error")
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "Invalid warehouse ID.", "error")
    end
end, "admin")

function UpdateWarehouses()
    -- Load existing warehouses from the database
    local existingWarehouses = {}
    local sql = "SELECT * FROM `warehouses`"
    local result = MySQL.Sync.fetchAll(sql, {})
    for _, row in ipairs(result) do
        existingWarehouses[row.location] = "Warehouse "..row.location
    end

    -- Loop through your Config.WareHouses and update as needed
    for location, data in pairs(Config.WareHouses['Warehouses']) do
        if not existingWarehouses[location] then
            local name = "Warehouse "..location
            local sql = "INSERT INTO `warehouses` (`location`, `owned`, `owner`, `stashsize`, `slots`, `price`, `date_purchased`, `passwordset`, `password`) VALUES (?, 0, '0', 3000000, 50, 10000, NULL, 0, NULL )"
            local values = {location}
            MySQL.Async.execute(sql, values, function(rowsInserted)
                if rowsInserted > 0 then
                    print("Added warehouse to database: " .. name)
                else
                    print("Failed to add warehouse to database: " .. name)
                end
            end)

            -- Update the existingWarehouses table
            existingWarehouses[location] = name
        end
    end

    -- Check for locations in the database that are no longer in Config.WareHouses and remove them
    for location, label in pairs(existingWarehouses) do
        if not Config.WareHouses['Warehouses'][location] then
            -- Remove the warehouse from the database
            local sql = "DELETE FROM `warehouses` WHERE `location` = ?"
            local values = {location}
            MySQL.Async.execute(sql, values, function(rowsDeleted)
                if rowsDeleted > 0 then
                    print("Removed warehouse from database: " .. label)
                else
                    print("Failed to remove warehouse from database: " .. label)
                end
            end)

            -- Remove the location from existingWarehouses
            existingWarehouses[location] = nil
        end
    end
end
    
