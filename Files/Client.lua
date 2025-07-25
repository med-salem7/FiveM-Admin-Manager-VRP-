KEYS = {
    ["ESC"] = tonumber("322"),["F1"] = tonumber("288"),["F2"] = tonumber("289"),["F3"] = tonumber("170"),["F5"] = tonumber("166"),["F6"] = tonumber("167"),["F7"] = tonumber("168"),["F8"] = tonumber("169"),["F9"] = tonumber("56"),["F10"] = tonumber("57"),["F11"] = tonumber("344"),["~"] = tonumber("243"),["1"] = tonumber("157"),["2"] = tonumber("158"),["3"] = tonumber("160"),["4"] = tonumber("164"),["5"] = tonumber("165"),["6"] = tonumber("159"),["7"] = tonumber("161"),["8"] = tonumber("162"),["9"] = tonumber("163"),["-"] = tonumber("84"),["="] = tonumber("83"),["BACKSPACE"] = tonumber("177"),["TAB"] = tonumber("37"),["Q"] = tonumber("44"),["W"] = tonumber("32"),["E"] = tonumber("38"),["R"] = tonumber("45"),["T"] = tonumber("245"),["Y"] = tonumber("246"),["U"] = tonumber("303"),["P"] = tonumber("199"),["["] = tonumber("39"),["]"] = tonumber("40"),["ENTER"] = tonumber("18"),["CAPS"] = tonumber("137"),["A"] = tonumber("34"),["S"] = tonumber("8"),["D"] = tonumber("9"),["F"] = tonumber("23"),["G"] = tonumber("47"),["H"] = tonumber("74"),["K"] = tonumber("311"),["L"] = tonumber("182"),["LEFTSHIFT"] = tonumber("21"),["Z"] = tonumber("20"),["X"] = tonumber("73"),["C"] = tonumber("26"),["V"] = tonumber("0"),["B"] = tonumber("29"),["N"] = tonumber("249"),["M"] = tonumber("244"),[","] = tonumber("82"),["."] = tonumber("81"),["LEFTCTRL"] = tonumber("36"),["LEFTALT"] = tonumber("19"),["SPACE"] = tonumber("22"),["RIGHTCTRL"] = tonumber("70"),["HOME"] = tonumber("213"),["PAGEUP"] = tonumber("10"),["PAGEDOWN"] = tonumber("11"),["DELETE"] = tonumber("178"),["LEFT"] = tonumber("174"),["RIGHT"] = tonumber("175"),["TOP"] = tonumber("27"),["DOWN"] = tonumber("173"),["NENTER"] = tonumber("201"),["N4"] = tonumber("124"),["N5"] = tonumber("126"),["N6"] = tonumber("125"),["N+"] = tonumber("96"),["N-"] = tonumber("97"),["N7"] = tonumber("117"),["N8"] = tonumber("61"),["N9"] = tonumber("118"),["MOUSE1"] = tonumber("24")
}
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(
      function()
          local iter, id = initFunc()
          if not id or id == tonumber("0") then
              disposeFunc(iter)
              return
          end
          local enum = {handle = iter, destructor = disposeFunc}
          setmetatable(enum, entityEnumerator)
          local next = true
          repeat
              coroutine.yield(id)
              next, id = moveFunc(iter)
          until not next
          enum.destructor, enum.handle = nil, nil
          disposeFunc(iter)
      end
  )
end
function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end
function EnumerateProps()
  return EnumerateEntities(FindFirstProp, FindNextProp, EndFindProp)
end
function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end
function GetAllEnumerators()
  return {vehicles = EnumerateVehicles, objects = EnumerateObjects, peds = EnumeratePeds, pickups = EnumeratePickups}
end
function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
local enumerator = {
  __gc = function(enum)
      if enum.destructor and enum.handle then
          enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
  end
}
local function getEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == tonumber("0") then
            disposeFunc(iter)
            return
        end
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, enumerator)
        local next = true
        repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
        until not next
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end
function getVehicles()
  return getEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
RegisterNetEvent("CMam:DeleteCars")
AddEventHandler("CMam:DeleteCars", function()
    theVehicles = getVehicles()
    TriggerEvent("chatMessage", "^8["..CMam.Settings.Server.."]", {tonumber("0"), tonumber("255"), tonumber("0")}, "سيتم مسح السيارات المهمله بعد 10 ثواني")
    Citizen.Wait(10000)
    TriggerEvent("chatMessage", "^8["..CMam.Settings.Server.."]", {tonumber("0"), tonumber("255"), tonumber("0")}, "تم حذف جميع السيارات")
    for veh in theVehicles do
        if ( DoesEntityExist( veh ) ) then 
            if((GetPedInVehicleSeat(veh, tonumber("-1"))) == false) or ((GetPedInVehicleSeat(veh,tonumber("-1"))) == nil) or ((GetPedInVehicleSeat(veh, tonumber("-1"))) == tonumber("0"))then
                Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( veh ) )
            end
        end
    end
end)
RegisterNetEvent("CMam:DeleteAllPeds")
AddEventHandler("CMam:DeleteAllPeds",function()
    PedStatus = tonumber("0")
    for ped in EnumeratePeds() do
        PedStatus = PedStatus + tonumber("1")
        if not (IsPedAPlayer(ped)) then
            RemoveAllPedWeapons(ped, true)
            DeleteEntity(ped)
        end
    end
end)
RegisterNetEvent("CMam:DeleteAllObject")
AddEventHandler("CMam:DeleteAllObject",function()
    objst = tonumber("0")
    for obj in EnumerateObjects() do
        objst = objst + tonumber("1")
        DeleteEntity(obj)
    end
end)

RegisterNetEvent('CMam_spec')
  AddEventHandler('CMam_spec', function(idSent)
          local id1 = idSent
          local sonid = GetPlayerFromServerId(id1)
          local targetPed = GetPlayerPed(sonid)
    NetworkSetInSpectatorMode(tonumber("1"), targetPed)
    local x,y,z = table.unpack(GetEntityCoords(targetPed, true))
    RequestCollisionAtCoord(x, y, z)
    while not HasCollisionLoadedAroundEntity(targetPed) do
      RequestCollisionAtCoord(x, y, z)
      Citizen.Wait(tonumber("100"))
    end
end)
RegisterNetEvent('CMam_specstop')
AddEventHandler('CMam_specstop', function()
        NetworkSetInSpectatorMode(tonumber("0"), GetPlayerPed(tonumber("-1")))
end)
RegisterFontFile("A9eelsh")
local font = RegisterFontId("A9eelsh")
function Draw3DText(x,y,z,textInput,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
    local scale = (tonumber("1")/dist)*tonumber("20")
    local fov = (1/GetGameplayCamFov())*tonumber("100")
    local scale = scale*fov   
    SetTextScale(scaleX*scale, scaleY*scale)
    RegisterFontFile('A9eelsh')
    fontId = RegisterFontId('A9eelsh')
    SetTextFont(fontId)
    SetTextProportional(tonumber("1"))
    SetTextColour(tonumber("250"), tonumber("250"), tonumber("250"), tonumber("250"))
    SetTextDropshadow(tonumber("1"), tonumber("1"), tonumber("1"), tonumber("1"), tonumber("250"))
    SetTextEdge(tonumber("2"), tonumber("0"), tonumber("0"), tonumber("0"), tonumber("150"))
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+tonumber("2"), tonumber("0"))
    DrawText(tonumber("0.0"), tonumber("0.0"))
end
RegisterFontFile("A9eelsh")
RegisterNetEvent("CMam:teleport")
AddEventHandler("CMam:teleport",function(nuser_id)
        UseParticleFxAssetNextCall("core")
        local CMam = StartParticleFxLoopedOnPedBone("ent_amb_foundry_arc_heat",GetPlayerPed(tonumber("-1")),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("1"),tonumber("0.5"),false,false,true)
        local CMam2 = StartParticleFxLoopedOnPedBone("veh_exhaust_spacecraft",GetPlayerPed(tonumber("-1")),tonumber("0.0"),tonumber("0.7"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("1"),tonumber("1.0"),false,false,true)
        StartParticleFxLoopedOnPedBone("veh_rotor_break",GetPlayerPed(tonumber("-1")),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("1"),tonumber("0.5"),false,false,true)
        Wait(tonumber("1000"))
        StopParticleFxLooped(CMam)
        StopParticleFxLooped(CMam2)
    end
)
if CMam.Settings.Control.AdminControl.CallAdmin.client.influence then
RegisterNetEvent("CMam:TicketsAn")
AddEventHandler("CMam:TicketsAn",function()
UseParticleFxAssetNextCall("core")
local CMam = StartParticleFxLoopedOnPedBone("ent_amb_foundry_arc_heat",GetPlayerPed(tonumber("-1")),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("1"),tonumber("0.5"),false,false,true)
  local CMam2 = StartParticleFxLoopedOnPedBone("veh_exhaust_spacecraft",GetPlayerPed(tonumber("-1")),tonumber("0.0"),tonumber("0.7"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("1"),tonumber("1.0"),false,false,true)
    StartParticleFxLoopedOnPedBone("veh_rotor_break",GetPlayerPed(tonumber("-1")),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("0.0"),tonumber("1"),tonumber("0.5"),false,false,true)
    Wait(tonumber("1000"))
    StopParticleFxLooped(CMam)
    StopParticleFxLooped(CMam2)
end)
end


--[[
  ░█████╗░██████╗░███████╗░█████╗░████████╗██╗██╗░░░██╗██╗████████╗██╗░░░██╗
  ██╔══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██║██║░░░██║██║╚══██╔══╝╚██╗░██╔╝
  ██║░░╚═╝██████╔╝█████╗░░███████║░░░██║░░░██║╚██╗░██╔╝██║░░░██║░░░░╚████╔╝░
  ██║░░██╗██╔══██╗██╔══╝░░██╔══██║░░░██║░░░██║░╚████╔╝░██║░░░██║░░░░░╚██╔╝░░
  ╚█████╔╝██║░░██║███████╗██║░░██║░░░██║░░░██║░░╚██╔╝░░██║░░░██║░░░░░░██║░░░
  ░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝░░░░░░╚═╝░░░                                                           


███╗░░░███╗░█████╗░██╗░░██╗░█████╗░███╗░░░███╗███████╗██████╗░  ░██████╗░█████╗░██╗░░░░░███████╗███╗░░░███╗
████╗░████║██╔══██╗██║░░██║██╔══██╗████╗░████║██╔════╝██╔══██╗  ██╔════╝██╔══██╗██║░░░░░██╔════╝████╗░████║
██╔████╔██║██║░░██║███████║███████║██╔████╔██║█████╗░░██║░░██║  ╚█████╗░███████║██║░░░░░█████╗░░██╔████╔██║
██║╚██╔╝██║██║░░██║██╔══██║██╔══██║██║╚██╔╝██║██╔══╝░░██║░░██║  ░╚═══██╗██╔══██║██║░░░░░██╔══╝░░██║╚██╔╝██║
██║░╚═╝░██║╚█████╔╝██║░░██║██║░░██║██║░╚═╝░██║███████╗██████╔╝  ██████╔╝██║░░██║███████╗███████╗██║░╚═╝░██║
╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░  ╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░░░░╚═╝
]]--