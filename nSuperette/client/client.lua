ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Wait(10)
    end
end)


local arrowColors, arrowIndex, QuantityList, SelectedQuantity, Panier = {"~r~", "~o~", "~y~", "~g~", "~c~", "~b~", "~p~", "~m~", "~w~"}, 1, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, {}, {}


CreateThread(function()
    while true do
        arrowIndex = arrowIndex + 1
        if arrowIndex > #arrowColors then arrowIndex = 1 end
        Wait(500)
    end
end)

local function AnimatedArrow()
    return arrowColors[arrowIndex]
end


local function AddToPanier(item, label, price, quantity)
    if Panier[item] then
        Panier[item].quantity = Panier[item].quantity + quantity
    else
        Panier[item] = {
            label = label,
            price = price,
            quantity = quantity
        }
    end

    local totalPrice = price * quantity
    ESX.ShowNotification(label.." x"..quantity.." ajouté au panier (~g~"..totalPrice.."$~s~)")
end



local function GetTotalPanier()
    local total = 0
    for _, v in pairs(Panier) do
        total = total + (v.price * v.quantity)
    end
    return total
end


local superetteOpen = false

local MenuSuperette = RageUI.CreateMenu("Supérette", "nSuperette")
local MenuPanier = RageUI.CreateSubMenu(MenuSuperette, "Panier", "Actions disponibles")
local MenuNourritures = RageUI.CreateSubMenu(MenuSuperette, "Nourritures", "Rayon Nourritures")
local MenuBoissons = RageUI.CreateSubMenu(MenuSuperette, "Boissons", "Rayon Boissons")
local MenuDivers = RageUI.CreateSubMenu(MenuSuperette, "Divers", "Rayon Divers")


function OpenSuperette()
    if superetteOpen then
        superetteOpen = false
        RageUI.CloseAll()
        return
    end

    superetteOpen = true
    RageUI.Visible(MenuSuperette, true)

    CreateThread(function()
        while superetteOpen do
            Wait(1)


            RageUI.IsVisible(MenuSuperette, function()


                RageUI.Button(AnimatedArrow().."→ ~s~Votre panier", "Voir les produits enregistrés", {}, true, {
                    onSelected = function()
                        RageUI.Visible(MenuPanier, true)
                    end
                })

                RageUI.Separator("↓ ~b~Rayons disponibles~s~ ↓")

                RageUI.Button("Nourritures", nil, { RightLabel = "→" }, true, {
                    onSelected = function()
                        RageUI.Visible(MenuNourritures, true)
                    end
                })

                RageUI.Button("Boissons", nil, { RightLabel = "→" }, true, {
                    onSelected = function()
                        RageUI.Visible(MenuBoissons, true)
                    end
                })

                RageUI.Button("Divers", nil, { RightLabel = "→" }, true, {
                    onSelected = function()
                        RageUI.Visible(MenuDivers, true)
                    end
                })

            end)


            RageUI.IsVisible(MenuPanier, function()


                
            local totalPanier = GetTotalPanier()
            RageUI.Separator(AnimatedArrow().."Total du panier : ~s~"..(totalPanier > 0 and totalPanier.."~g~$" or "0$"))

                RageUI.Separator("~o~↓ ~s~Votre panier ~o~↓")

                local isEmpty = true

                for _, v in pairs(Panier) do
                    isEmpty = false

                    RageUI.Button(v.label.." x"..v.quantity, "Prix total : "..(v.price * v.quantity).."$", { RightLabel = ""..(v.price * v.quantity).."~g~$" }, true, {}
                    )
                end

                if isEmpty then
                    RageUI.Separator(AnimatedArrow().."Panier vide")
                end

                
            RageUI.Separator("~g~↓ ~s~Action possible ~g~↓")

            RageUI.Button(AnimatedArrow().."→ ~s~Supprimer votre panier", nil, {}, (next(Panier) ~= nil), {
                    onSelected = function()
                        Panier = {} -- vide le panier
                        ESX.ShowNotification("~r~Votre panier a été vidé !")
                    end
                })


            RageUI.Button(AnimatedArrow().."→ ~s~Procéder au paiement", nil, {}, (next(Panier) ~= nil), {
                onSelected = function()
                    _G.pendingPanier = Panier
                    local totalPanier = GetTotalPanier()
                    TriggerEvent("universalPayment:open", totalPanier) 
                    RageUI.CloseAll()
                    superetteOpen = false
                end
            })
                
    end)


            RageUI.IsVisible(MenuNourritures, function()
                RageUI.Separator("~b~↓ ~s~Produits en vente ~b~↓")

                for _, v in pairs(Config.Nourritures) do

                    if not SelectedQuantity[v.item] then
                        SelectedQuantity[v.item] = 1
                    end

                    RageUI.List(v.label, QuantityList, SelectedQuantity[v.item], "Prix unitaire : "..v.price.."~g~$", {}, true, {
                            onListChange = function(index)
                                SelectedQuantity[v.item] = index
                            end,

                            onSelected = function()
                                local quantity = QuantityList[SelectedQuantity[v.item]]
                                AddToPanier(v.item, v.label, v.price, quantity)

                            end
                        }
                    )
                end
            end)



            RageUI.IsVisible(MenuBoissons, function()
                RageUI.Separator("~b~↓ ~s~Produits en vente ~b~↓")

                for _, v in pairs(Config.Boissons) do

                    if not SelectedQuantity[v.item] then
                        SelectedQuantity[v.item] = 1
                    end

                    RageUI.List(v.label, QuantityList, SelectedQuantity[v.item], "Prix unitaire : "..v.price.."~g~$", {}, true, {
                            onListChange = function(index)
                                SelectedQuantity[v.item] = index
                            end,

                            onSelected = function()
                                local quantity = QuantityList[SelectedQuantity[v.item]]
                                AddToPanier(v.item, v.label, v.price, quantity)

                            end
                        }
                    )
                end
            end)


            RageUI.IsVisible(MenuDivers, function()
                RageUI.Separator("~b~↓ ~s~Produits en vente ~b~↓")

                for _, v in pairs(Config.Divers) do

                    if not SelectedQuantity[v.item] then
                        SelectedQuantity[v.item] = 1
                    end

                    RageUI.List(v.label, QuantityList, SelectedQuantity[v.item], "Prix unitaire : "..v.price.."~g~$", {}, true, {
                            onListChange = function(index)
                                SelectedQuantity[v.item] = index
                            end,

                            onSelected = function()
                                local quantity = QuantityList[SelectedQuantity[v.item]]
                                AddToPanier(v.item, v.label, v.price, quantity)

                            end
                        }
                    )
                end
            end)

            if not RageUI.Visible(MenuSuperette)
            and not RageUI.Visible(MenuPanier)
            and not RageUI.Visible(MenuNourritures)
            and not RageUI.Visible(MenuBoissons)
            and not RageUI.Visible(MenuDivers) then
                superetteOpen = false
            end



        end
    end)
end



RegisterNetEvent("universalPayment:result")
AddEventHandler("universalPayment:result", function(success)
    if success and _G.pendingPanier then
        print("[CLIENT] Paiement validé, envoi des items au serveur")

        for itemName, v in pairs(_G.pendingPanier) do
            TriggerServerEvent('sup:giveInventoryItem', itemName, v.label, v.quantity)
        end

        _G.pendingPanier = nil
        Panier = {}
    end
end)



Citizen.CreateThread(function()
    while true do
        local pCoords2 = GetEntityCoords(PlayerPedId())
        local activerfps = false
        local dst = GetDistanceBetweenCoords(pCoords2, true)
        for _,v in pairs(Config.positionshop) do
            if #(pCoords2 - v.position) < 1.0 then
                activerfps = true
                Visual.Subtitle("Appuyez sur ~g~[E]~s~ pour accéder à la supérette")
            if superetteOpen == false then
                if IsControlJustReleased(0, 38) then
                    OpenSuperette()
                end
            end
            elseif #(pCoords2 - v.position) < 7 then
                activerfps = true
                DrawMarker(22, v.position, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 170, 1, 1, 2, 1, nil, nil, 0)
            end
        end
        if activerfps then
            Wait(1)
        else
            Wait(1500)
        end
    end
end)



local AllBlips = {}

Citizen.CreateThread(function()
      Citizen.Wait(1000)
    for _,v in pairs(Config.BlipsMap) do
        local blipMap = AddBlipForCoord(v.pos)
        SetBlipSprite(blipMap, v.id)
        SetBlipDisplay(blipMap, 4)
        SetBlipScale(blipMap, 0.6)
        SetBlipColour(blipMap, v.color)
        SetBlipAsShortRange(blipMap, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.name)
        EndTextCommandSetBlipName(blipMap)
        SetBlipPriority(blipMap, 5)
    end
end)
