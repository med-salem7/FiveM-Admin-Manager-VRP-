local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("lib/htmlEntities")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", GetCurrentResourceName())

MySQL = module("vrp_mysql", "MySQL")
MySQL.createCommand("vRP/CMam_check_id", "SELECT last_login,whitelisted,banned FROM vrp_users WHERE id = @id")
MySQL.createCommand("vRP/DeleteTickets", "DELETE FROM vrp_user_data WHERE dkey = @dkey")

MySQL.createCommand("vRP/GetTickets", "SELECT user_id,dkey,dvalue FROM vrp_user_data WHERE dkey = @dkey")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("vrp", "lib/htmlEntities")

local a = "Made By xM7mD#0001"
local CMnotify = CMam.Settings.Notify
local CMchat = CMam.Settings.Chats
local CMamAV4 = CMam.Settings.Control.AdminControl
StopTicketsS = {}
TicketsBack = {}
Position = {}
TicketsStatus = true

RegisterCommand(
    CMamAV4.CallAdmin.Command.com,
    function(player)
        local user_id = vRP.getUserId({player})
        vRPclient.getPosition(
            player,
            {},
            function(x, y, z)
                if user_id ~= nil then
                    if TicketsBack[player] == true then
                        vRPclient.teleport(player, Position[player])
                        local coords = x .. "," .. y .. "," .. z
                        TicketsBack[player] = false
                        CMam_Webhook(
                            1752220,
                            CMamAV4.CallAdmin.Command.Webhook,
                            "** Admin: `[ " ..
                                GetPlayerName(player) ..
                                    " ]` ID: `[ " .. user_id .. " ]` \n  Coords: **```css\n" .. coords .. "``` ",
                            "العودة الى اخر موقع"
                        )
                    else
                        CMnotify(player, "لقد استخدمت الامر من قبل ")
                    end
                end
            end
        )
    end
)

AddEventHandler(
    "onResourceStart",
    function(resourceName)
        Citizen.CreateThread(
            function()
                while true do
                    Citizen.Wait(5 * 1000)
                    local players = vRP.getUsers({})
                    for k, v in pairs(players) do
                        local user_id = vRP.getUserId({v})
                        if vRP.hasPermission({user_id, CMamAV4.AdminsPermission}) then
                            vRP.getUData(
                                {
                                    user_id,
                                    "CMam:Tickets",
                                    function(value)
                                        if value == "" or value == nil then
                                            vRP.setUData({user_id, "CMam:Tickets", 0})
                                        end
                                    end
                                }
                            )
                        end
                    end
                end
            end
        )
    end
)

AddEventHandler(
    "vRP:playerSpawn",
    function(user_id, player)
        TicketsBack[player] = false
    end
)

AddEventHandler(
    "vRP:playerSpawn",
    function(user_id, player)
        if vRP.hasPermission({user_id, CMamAV4.AdminsPermission}) then
            vRP.getUData(
                {
                    user_id,
                    "CMam:Tickets",
                    function(value)
                        if value == nil or value == "" then
                            vRP.setUData({user_id, "CMam:Tickets", 0})
                        end
                    end
                }
            )
        end
    end
)

AddEventHandler(
    "vRP:playerLeave",
    function(user_id, player)
        if vRP.hasPermission({user_id, CMamAV4.AdminsPermission}) then
            local name = GetPlayerName(player)
            vRP.getUData(
                {
                    user_id,
                    "CMam:Tickets",
                    function(value)
                        CMam_Webhook(
                            16711680,
                            CMamAV4.AdminConnect.left,
                            "**  Admin: `[ " ..
                                name .. " ]` ID: `[ " .. user_id .. " ]` \n Total Tickets: `[ " .. value .. " ]` **",
                            "Left"
                        )
                    end
                }
            )
        end
    end
)

AddEventHandler(
    "vRP:playerSpawn",
    function(user_id, player)
        if vRP.hasPermission({user_id, CMamAV4.AdminsPermission}) then
            local name = GetPlayerName(player)
            vRP.getUData(
                {
                    user_id,
                    "CMam:Tickets",
                    function(value)
                        CMam_Webhook(
                            65280,
                            CMamAV4.AdminConnect.joined,
                            "** Admin: `[ " ..
                                name .. " ]` ID: `[ " .. user_id .. " ]` \n Total Tickets: `[ " .. value .. " ]` **",
                            "Join"
                        )
                    end
                }
            )
        end
        --	for k , v in pairs(CMam.Settings.Groups) do
        --		if vRP.hasGroup({user_id , v[1]}) then
        --			vRP.removeUserGroup({user_id , v[1]})
        --		end
        --	end
    end
)
-- >>>>>>>>>>>>>>>>>>>>>> لوحة تحكم الادارة <<<<<<<<<<<<<<<<<<<<<<
-- >> سحب جميع الاداريين <<
function PullAdmins(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRP.request(
            {
                player,
                "هل انت متاكد من سحب جميع الاداريين ؟؟",
                60,
                function(player, ok)
                    if ok then
                        vRPclient.getPosition(
                            player,
                            {},
                            function(x, y, z)
                                local permissionsas = vRP.getUsersByPermission({CMamAV4.AdminsPermission})
                                list = ""
                                for k, v in pairs(permissionsas) do
                                    local nplayer = vRP.getUserSource({v})
                                    list =
                                        list ..
                                        "" ..
                                            GetPlayerName(nplayer) .. " = [ ID: " .. vRP.getUserId({nplayer}) .. " ]\n"
                                    local coords = x .. "," .. y .. "," .. z
                                    CMam_Webhook(
                                        3447003,
                                        CMamAV4.AdminsMenu.Pullmenu.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    user_id ..
                                                        " ]` \n Coords: ```css\n" ..
                                                            coords .. "```**\n**Admins:**```CSS\n" .. list .. "```",
                                        "Pull All Admins"
                                    )
                                    if nplayer ~= player then
                                        vRPclient.teleport(nplayer, {x, y, z})
                                    end
                                end
                            end
                        )
                    end
                end
            }
        )
    end
end
-- >> ايقاف الشات <<
local function CMam_chatclear(player)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        TriggerClientEvent("chat:clear", -1)
        CMam_Webhook(
            10181046,
            CMamAV4.Chatmenu.Clearchat.Webhook,
            "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]`**",
            "Clear Chat"
        )
        CMnotify(player, "تم مسح الشات بنجاح ")
        TriggerClientEvent(
            "chatMessage",
            tonumber("-1"),
            "^8[" .. CMam.Settings.Server .. "]   ^6تم حذف الشات من قبل ادارة السيرفر"
        )
    end
end
-- >> ايقاف الشات <<
function CMam_StopChat(player, choices)
    local user_id = vRP.getUserId({player})
    if DiChat ~= true then
        DiChat = true
        CMam_Webhook(
            10181046,
            CMamAV4.Chatmenu.stopchat.Webhook,
            "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]`**",
            "Stoped Chat"
        )
        CMnotify(player, "تم ايقاف الشات بنجاح ")
        TriggerClientEvent(
            "chatMessage",
            tonumber("-1"),
            "^8[" .. CMam.Settings.Server .. "]   ^6تم ايقاف الشات من قبل ادارة السيرفر"
        )
    end
end
function CMam_startChat(player, choices)
    local user_id = vRP.getUserId({player})
    DiChat = false
    CMam_Webhook(
        15844367,
        CMamAV4.Chatmenu.stopchat.Webhook,
        "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]`**",
        "Started Chat"
    )
    CMnotify(player, "تم تشغيل الشات بنجاح ")
    TriggerClientEvent(
        "chatMessage",
        tonumber("-1"),
        "^8[" .. CMam.Settings.Server .. "]   ^6تم تشغيل الشات من قبل الادارة"
    )
end
AddEventHandler(
    "chatMessage",
    function(source, name, msg)
        if DiChat == true then
            if msg then
                CancelEvent()
                TriggerClientEvent(
                    "chatMessage",
                    source,
                    "^8[" .. CMam.Settings.Server .. "]   ^6الشات موقف من ادارة السيرفر"
                )
            end
        end
    end
)
-- >> ميوت , فك ميوت <<
muted = {}
muteminute = {}
function CMam_MuteChat(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب ؟",
            "",
            function(player, id)
                id = parseInt(id)
                local id_source = vRP.getUserSource({id})
                if vRP.getUserId({vRP.getUserSource({tonumber(id)})}) ~= nil then
                    if muted[id_source] == nil then
                        vRP.prompt(
                            {
                                player,
                                "مدة الميوت بالدقائق؟",
                                "",
                                function(player, mutetime)
                                    if mutetime ~= nil and mutetime ~= "" then
                                        muteminute[id_source] = mutetime
                                        muted[id_source] = true
                                        TriggerClientEvent(
                                            "chatMessage",
                                            tonumber("-1"),
                                            "^8 [" ..
                                                CMam.Settings.Server ..
                                                    "] ^6 Admin: [ " ..
                                                        user_id ..
                                                            " ] Muted: [ " ..
                                                                vRP.getUserId({id_source}) ..
                                                                    " ] For: " .. mutetime .. " "
                                        )
                                        CMam_Webhook(
                                            15105570,
                                            CMamAV4.Chatmenu.Mutechat.Webhook,
                                            "** Admin: `[ " ..
                                                user_id ..
                                                    " ]` \n Player: `[ " ..
                                                        vRP.getUserId({id_source}) ..
                                                            " ]` \n For: `[ " .. mutetime .. " ]` **",
                                            "Mute Chat"
                                        )
                                        SetTimeout(
                                            mutetime * 60000,
                                            function()
                                                muted[id_source] = nil
                                                CMnotify(id_source, " تم فك ميوت الشات  عنك")
                                            end
                                        )
                                    else
                                        CMnotify(Source, "الرجاء كتابة مدة الميوت")
                                    end
                                end
                            }
                        )
                    else
                        CMnotify(Source, "الرجاء كتابة ايدي اللاعب")
                    end
                end
            end
        }
    )
end
function CMam_UnMute(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب ؟",
            "",
            function(player, id)
                id = parseInt(id)
                local id_source = vRP.getUserSource({id})
                if vRP.getUserId({vRP.getUserSource({tonumber(id)})}) ~= nil then
                    if muted[id_source] == true then
                        muted[id_source] = nil
                        CMnotify(player, "تم فك الميوت بنجاح")
                        CMnotify(id_source, "تم فك ميوت الشات")
                        TriggerClientEvent(
                            "chatMessage",
                            tonumber("-1"),
                            "^2 [" ..
                                CMam.Settings.Server ..
                                    "] ^6 Admin: [ " ..
                                        user_id .. " ] UnMuted: [ " .. vRP.getUserId({id_source}) .. " ]"
                        )
                    elseif muted[id_source] == nil then
                        CMnotify(player, "لايوجد ميوت على هذا اللاعب")
                    end
                else
                    CMnotify(player, "الرجاء كتابة ايدي اللاعب")
                end
            end
        }
    )
end
AddEventHandler(
    "chatMessage",
    function(Source, Name, Msg)
        local pid = vRP.getUserId({Source})
        if Msg then
            if muted[Source] == true then
                CMnotify(Source, "انت محضور من الكتابة في الشات ")
                CancelEvent()
            elseif muted[Source] == nil then
                return
            end
        end
    end
)
-- >> سحب وحمل لاعب <<
function CMam_Drag(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب ؟",
            "",
            function(player, id)
                local ID = vRP.getUserSource({tonumber(id)})
                local id_source = vRP.getUserId({ID})
                if id_source ~= nil and id_source ~= user_id then
                    CMam_Webhook(
                        15158332,
                        CMamAV4.AdminsMenu.Dragmenu.Webhook,
                        "** Admin: `[ " ..
                            GetPlayerName(player) ..
                                " ]` ID: `[ " ..
                                    user_id ..
                                        " ]` \n Player: `[ " ..
                                            GetPlayerName(ID) .. " ]` ID: `[ " .. id_source .. " ]` **",
                        "سحب وكلبشة"
                    )
                    vRPclient.toggleHandcuff(ID, {})
                    TriggerClientEvent("dr:drag", ID, player)
                else
                    CMnotify(player, "الرجاء كتابة ايدي اللاعب")
                end
            end
        }
    )
end
-- >> تحقق من رتب <<
function CMam_CGroups(player, choice)
    vRP.prompt(
        {
            player,
            "Player ID:",
            "",
            function(player, Pid)
                local Psource = vRP.getUserSource({tonumber(Pid)})
                local nuser_id = vRP.getUserId({Psource})
                if nuser_id ~= nil then
                    local name = GetPlayerName(Psource)
                    if not vRP.hasPermission({nuser_id, CMamAV4.AdminsMenu.Groupsmenu.CheckGroup.DontCheck}) then
                        list = ""
                        listw = ""
                        local tgroups = vRP.getUserGroups({nuser_id})
                        for k, v in pairs(tgroups) do
                            list = list .. "" .. k .. "<br>"
                        end
                        for k, v in pairs(tgroups) do
                            listw = listw .. " " .. k .. " \n"
                        end
                        CMnotify(player, "" .. list .. "")
                        CMam_Webhook(
                            9807270,
                            CMamAV4.AdminsMenu.Groupsmenu.CheckGroup.Webhook,
                            "** Admin: `[ " ..
                                GetPlayerName(player) ..
                                    " ]` ID: `[ " ..
                                        vRP.getUserId({player}) ..
                                            " ]` \n Player: `[ " ..
                                                name ..
                                                    " ]` ID: `[ " .. nuser_id .. " ]` **\n ```fix\n" .. listw .. "```",
                            "تحقق من الرتب"
                        )
                    else
                        CMnotify(player, " لايمكنك تحقق من رتب هذا اللاعب")
                    end
                else
                    CMnotify(player, "خطاء في كتابة الايدي")
                end
            end
        }
    )
end
-- >>>>>>>>>>>>>>>>> سجن اوفلاين <<<<<<<<<<<<<<<<<<<
local aUnjailed = {}
function CMam_Cco(target_id, timer)
    local target = vRP.getUserSource({tonumber(target_id)})
    local users = vRP.getUsers({})
    local online = false
    for k, v in pairs(users) do
        if tonumber(k) == tonumber(target_id) then
            online = true
        end
    end
    if online then
        if timer > 0 then
            CMnotify(target, "الوقت المتبقي على السجن " .. timer .. "")
            vRP.setUData({tonumber(target_id), "CMam:Jail", json.encode(timer)})
            SetTimeout(
                60 * 1000,
                function()
                    for k, v in pairs(aUnjailed) do -- check if player has been unjailed by cop or admin
                        if v == tonumber(target_id) then
                            aUnjailed[v] = nil
                            timer = 0
                        end
                    end
                    CMam_Cco(tonumber(target_id), timer - 1)
                end
            )
        else
            vRP.setUData({tonumber(target_id), "CMam:Jail", json.encode(-1)})
            vRPclient.teleport(
                target,
                {CMamAV4.Jailmenu.Jailout.x, CMamAV4.Jailmenu.Jailout.y, CMamAV4.Jailmenu.Jailout.z}
            ) -- teleport to outside jail
            vRPclient.setHandcuffed(target, {false})
            CMnotify(target, "انتهت مدة السجن الرجاء الالتزام في القوانين")
        end
    end
end
function CMamAdmin_Jail(player)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب",
            "",
            function(player, target_id)
                if target_id ~= nil and target_id ~= "" then
                    vRP.prompt(
                        {
                            player,
                            "وقت السجن",
                            "",
                            function(player, jail_time)
                                if jail_time ~= nil and jail_time ~= "" then
                                    vRP.prompt(
                                        {
                                            player,
                                            "سبب السجن",
                                            "",
                                            function(player, jail_reason)
                                                if jail_reason ~= nil and jail_reason ~= "" then
                                                    local target = vRP.getUserSource({tonumber(target_id)})
                                                    if target ~= nil then
                                                        if tonumber(jail_time) > 500 then
                                                            jail_time = 500
                                                        end
                                                        if tonumber(jail_time) < 1 then
                                                            jail_time = 1
                                                        end
                                                        local Playerid = vRP.getUserId({target})
                                                        local PlayerName = GetPlayerName(target)
                                                        local Reason = jail_reason
                                                        vRPclient.teleport(
                                                            target,
                                                            {
                                                                CMamAV4.Jailmenu.Jailin.x,
                                                                CMamAV4.Jailmenu.Jailin.y,
                                                                CMamAV4.Jailmenu.Jailin.z
                                                            }
                                                        ) -- teleport to inside jail
                                                        CMchat(user_id, PlayerName, Playerid, Reason)
                                                        CMam_Cco(tonumber(target_id), tonumber(jail_time))
                                                        vRPclient.setHandcuffed(target, {true})
                                                        CMam_Webhook(
                                                            8359053,
                                                            CMamAV4.Jailmenu.Jail.Webhook,
                                                            "**Admin: `[ " ..
                                                                GetPlayerName(player) ..
                                                                    " ]` ID: `[ " ..
                                                                        user_id ..
                                                                            " ]` \n Player: `[ " ..
                                                                                GetPlayerName(target) ..
                                                                                    " ]` ID: `[ " ..
                                                                                        vRP.getUserId({target}) ..
                                                                                            " ]` \n For: `[ " ..
                                                                                                jail_time .. " ]` **",
                                                            "Admin Jail"
                                                        )
                                                    else
                                                        CMnotify(player, "خطاء في كتابة الايدي")
                                                    end
                                                else
                                                    CMnotify(player, "الرجاء كتابة سبب السجن")
                                                end
                                            end
                                        }
                                    )
                                else
                                    CMnotify(player, "الرجاء كتابة مدة السجن")
                                end
                            end
                        }
                    )
                else
                    CMnotify(player, "الرجاء كتابة ايدي اللاعب ")
                end
            end
        }
    )
end
function CMam_UnJail(player)
    vRP.prompt(
        {
            player,
            "ايدي اللاعب",
            "",
            function(player, target_id)
                if target_id ~= nil and target_id ~= "" then
                    vRP.getUData(
                        {
                            tonumber(target_id),
                            "CMam:Jail",
                            function(value)
                                if value ~= nil then
                                    custom = json.decode(value)
                                    if custom ~= nil then
                                        local user_id = vRP.getUserId({player})
                                        if tonumber(custom) > 0 then
                                            local target = vRP.getUserSource({tonumber(target_id)})
                                            if target ~= nil then
                                                aUnjailed[target] = tonumber(target_id)
                                                CMnotify(player, "تم فك سجن اللاعب بنجاح")
                                                CMam_Webhook(
                                                    3426654,
                                                    CMamAV4.Jailmenu.UnJail.Webhook,
                                                    "** Admin: `[ " ..
                                                        GetPlayerName(player) ..
                                                            " ]` ID: `[ " ..
                                                                user_id ..
                                                                    " ]` \n  Player: `[ " ..
                                                                        GetPlayerName(target) ..
                                                                            " ]` ID: `[ " ..
                                                                                vRP.getUserId({target}) .. " ]` **",
                                                    "Un Jail"
                                                )
                                                CMnotify(target, "تم فك سجنك")
                                            else
                                                CMnotify(player, "خطاء في كتابة الايدي ")
                                            end
                                        else
                                            CMnotify(player, "اللاعب غير مسجون")
                                        end
                                    end
                                end
                            end
                        }
                    )
                else
                    CMnotify(player, "خطاء في كتابة الايدي ")
                end
            end
        }
    )
end
function CMam_OffLineJail(player)
    local player = player
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRP.prompt(
            {
                player,
                "ايدي اللاعب ؟",
                "",
                function(player, id)
                    if id ~= "" then
                        id = tonumber(id)
                        if id ~= nil and id ~= "" then
                            vRP.prompt(
                                {
                                    player,
                                    "وقت السجن ؟",
                                    "",
                                    function(player, time)
                                        if time ~= nil and time ~= "" then
                                            vRP.prompt(
                                                {
                                                    player,
                                                    "سبب السجن ؟",
                                                    "",
                                                    function(player, Reason)
                                                        if Reason ~= nil and Reason ~= "" then
                                                            MySQL.query(
                                                                "vRP/CMam_check_id",
                                                                {id = id},
                                                                function(rows, affected)
                                                                    if #rows > 0 then
                                                                        if not vRP.isConnected({id}) then
                                                                            vRP.setUData(
                                                                                {
                                                                                    tonumber(id),
                                                                                    "CMam:Jail",
                                                                                    json.encode(time)
                                                                                }
                                                                            )
                                                                            CMnotify(player, "تم سجن اللاعب بنجاح")
                                                                            CMam_Webhook(
                                                                                1146986,
                                                                                CMamAV4.Jailmenu.OffLineJail.Webhook,
                                                                                "** Admin: `[ " ..
                                                                                    GetPlayerName(player) ..
                                                                                        " ]` ID: `[ " ..
                                                                                            user_id ..
                                                                                                " ]` \n Player: `[ " ..
                                                                                                    id ..
                                                                                                        " ]` \n Jail Time: `[ " ..
                                                                                                            time ..
                                                                                                                " ]` \n Reason: `[ " ..
                                                                                                                    Reason ..
                                                                                                                        " ]` **",
                                                                                "OffLine Jail"
                                                                            )
                                                                        else
                                                                            CMnotify(player, "الاعب متصل")
                                                                        end
                                                                    else
                                                                        CMnotify(player, "خطاء في كتابة الايدي ")
                                                                    end
                                                                end
                                                            )
                                                        else
                                                            CMnotify(player, "الرجاء كتابة سبب السجن")
                                                        end
                                                    end
                                                }
                                            )
                                        else
                                            CMnotify(player, "الرجاء كتابة مدة السجن")
                                        end
                                    end
                                }
                            )
                        else
                            CMnotify(player, "الاعب ليس مسجل بقاعده البيانات")
                        end
                    else
                        CMnotify(player, "الرجاء كتابة ايدي اللاعب")
                    end
                end
            }
        )
    end
end
AddEventHandler(
    "vRP:playerSpawn",
    function(user_id, source, first_spawn)
        local target = vRP.getUserSource({user_id})
        local h = vRP.getUserId({player})
        SetTimeout(
            2000,
            function()
                local custom = {}
                vRP.getUData(
                    {
                        user_id,
                        "CMam:Jail",
                        function(value)
                            if value ~= nil then
                                custom = json.decode(value)
                                if custom ~= nil then
                                    if tonumber(custom) > 0 then
                                        vRPclient.setHandcuffed(target, {true})
                                        vRPclient.teleport(
                                            target,
                                            {
                                                CMamAV4.Jailmenu.Jailin.x,
                                                CMamAV4.Jailmenu.Jailin.y,
                                                CMamAV4.Jailmenu.Jailin.z
                                            }
                                        ) -- teleport inside jail
                                        CMam_Cco(tonumber(user_id), tonumber(custom))
                                    end
                                end
                            end
                        end
                    }
                )
            end
        )
    end
)
function StopTickets(player, choice)
    local user_id = vRP.getUserId({player})
    if TicketsStatus == true then
        TicketsStatus = false
        CMam_Webhook(
            2067276,
            CMamAV4.Ticket.StopTickets.Webhook,
            "** Player: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
            "ايقاف طلبات الادمن"
        )
        CMnotify(player, "تم ايقاف طلبات الادمن ")
        CMam_Stop = true
        CMam_Start = true
    end
end
-- >> تشغيل الطلبات <<
function StartTickets(player, choice)
    local user_id = vRP.getUserId({player})
    if TicketsStatus == false then
        TicketsStatus = true
        CMam_Webhook(
            2123412,
            CMamAV4.Ticket.StopTickets.Webhook,
            "** Player: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
            "تشغيل طلبات الادمن"
        )
        CMnotify(player, "تم تشغيل طلبات الادمن")
        CMam_Stop = false
        CMam_Start = false
    end
end
-- > ايقاف استقبال الطلبات <
function StopSeTickets(player, choice)
    local user_id = vRP.getUserId({player})
    if StopTicketsS[user_id] ~= true then
        StopTicketsS[user_id] = true
        CMam_Webhook(
            7419530,
            CMamAV4.Ticket.stopreception.Webhook,
            "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
            "ايقاف استقبال طلبات الادمن"
        )
        CMnotify(player, " تم ايقاف استقبال الطلبات")
        CMam_StoptI = true
        CMam_StartI = true
    end
end
-- >> تشغيل استقبال الطلبات <<
function StartSeTickets(player, choice)
    local user_id = vRP.getUserId({player})
    if StopTicketsS[user_id] ~= false then
        StopTicketsS[user_id] = false
        CMam_Webhook(
            12745742,
            CMamAV4.Ticket.stopreception.Webhook,
            "**Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
            "تشغيل استقبال طلبات الادمن"
        )
        CMnotify(player, "تم تشغيل استقبال الطلبات ")
        CMam_StoptI = false
        CMam_StartI = false
    end
end
-- >> رسالة لجميع الادارينن <<
function CMam_MessageTOAdmin(player)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRP.prompt(
            {
                player,
                "الرسالة ؟",
                "",
                function(player, msg)
                    if msg ~= "" then
                        for i, p in pairs(vRP.getUsersByPermission({CMamAV4.AdminsPermission})) do
                            local pp = vRP.getUserSource({p})
                            CMnotify(
                                pp,
                                "Message From: [ " ..
                                    GetPlayerName(player) .. " ] ID: [ " .. user_id .. " ] <br> <h2> " .. msg .. ""
                            )
                            CMam_Webhook(
                                11027200,
                                CMamAV4.AdminsMenu.SendMsgMenu.Webhook,
                                "**Admin: `[ " ..
                                    GetPlayerName(player) ..
                                        " ]` ID: `[ " .. user_id .. " ]` \n Message: `[ " .. msg .. " ]` **",
                                "رسالة لجميع الاداريين"
                            )
                        end
                    else
                        CMnotify(player, "الرجاء كتابة الرسالة")
                    end
                end
            }
        )
    end
end
-- >> رسالة للجميع <<
function CMam_MessageTOAll(player)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRP.prompt(
            {
                player,
                "الرسالة ؟",
                "",
                function(player, msg)
                    if msg ~= "" then
                        CMnotify(
                            tonumber("-1"),
                            " Message From: [ " ..
                                GetPlayerName(player) .. " ] ID: [ " .. user_id .. " ] <br> <h2> " .. msg .. ""
                        )
                        CMam_Webhook(
                            10038562,
                            CMamAV4.AdminsMenu.msgTOAll.Webhook,
                            "** Admin: `[ " ..
                                GetPlayerName(player) ..
                                    " ]` ID: `[ " .. user_id .. " ]` \n Message: `[ " .. msg .. " ]` **",
                            "رسالة لجميع اللاعبين"
                        )
                    else
                        CMnotify(player, "الرجاء كتابة الرسالة")
                    end
                end
            }
        )
    end
end
-- >> الاداريين المتصلين <<
local function AdminOnline(player, choice)
    local user_id = vRP.getUserId({player})
    local gusers = vRP.getUsersByPermission({CMamAV4.AdminsPermission})
    local user_list = ""
    local user_listwebhook = ""
    for k, v in pairs(gusers) do
        user_list = user_list .. "" .. GetPlayerName(k) .. " = [ ID: " .. vRP.getUserId({k}) .. " ]<br/>"
    end
    for k, v in pairs(gusers) do
        user_listwebhook = user_listwebhook .. "" .. GetPlayerName(k) .. " = [ ID: " .. vRP.getUserId({k}) .. " ]\n"
    end
    CMnotify(player, "الادمنية المتصلين <br> <h2> " .. user_list .. "")
    CMam_Webhook(
        9936031,
        CMamAV4.AdminsMenu.Onlinememu.Webhook,
        "**Admin: `[ " ..
            GetPlayerName(player) ..
                " ]` ID: `[ " .. vRP.getUserId({player}) .. " ]` \n Admins: **```CSS\n" .. user_listwebhook .. "```",
        "الادمنية المتصلين"
    )
end
-- >> انزال سيارة <<
function CMam_SpawnCar(player)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRPclient.getNearestPlayer(
            player,
            {10},
            function(nplayer)
                local nuser_id = vRP.getUserId({nplayer})
                if nuser_id ~= nil then
                    CMam_Webhook(
                        12370112,
                        CMamAV4.AdminsMenu.SpawnCar.Webhook,
                        "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
                        "انزال سيارة"
                    )
                    vRPclient.spawnGarageVehicle(nplayer, {"adminmangment", CMamAV4.AdminsMenu.SpawnCar.VehiclCode})
                else
                    CMnotify(player, "لايوجد لاعب قريب ")
                end
            end
        )
    end
end
-- >> حذف جميع السيارات <<
function CMam_DeleteAllCars(player, choice)
    local user_id = vRP.getUserId({player})
    TriggerClientEvent("CMam:DeleteCars", tonumber("-1"))
    CMam_Webhook(
        2899536,
        CMamAV4.DeleteMenu.DeleteAllCars.Webhook,
        "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
        "حذف جميع السيارات "
    )
    CMnotify(player, "تم حذف جميع السيارات")
end
-- >> حذف جميع البوتات <<
function CMam_DeleteAllPeds(player, choice)
    local user_id = vRP.getUserId({player})
    TriggerClientEvent("CMam:DeleteAllPeds", tonumber("-1"))
    CMam_Webhook(
        16580705,
        CMamAV4.DeleteMenu.DeleteAllPeds.Webhook,
        "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
        "حذف جميع البوتات"
    )
    CMnotify(player, "تم حذف جميع البوتات")
end
-- >> حذف جميع الاوبجكتات <<
function CMam_DeleteAllObject(player, choice)
    local user_id = vRP.getUserId({player})
    TriggerClientEvent("CMam:DeleteAllObject", tonumber("-1"))
    CMam_Webhook(
        12320855,
        CMamAV4.DeleteMenu.DeleteAllObject.Webhook,
        "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
        "حذف جميع الاوبكتات "
    )
    CMnotify(player, "تم حذف جميع الاوبجكتات")
end
-- >> مراقبة الاداريين <<
local function CMam_StartSpectet(player, choice)
    local nuser = spec[choice]
    local user_id = vRP.getUserId({player})
    local nuser_id = vRP.getUserId({nuser})
    if user_id ~= nil and nuser_id ~= nil then
        TriggerClientEvent("CMam_spec", player, nuser)
        CMam_Webhook(
            3066993,
            CMamAV4.AdminsMenu.Spectet.Webhook,
            "** Admin: `[ " ..
                GetPlayerName(player) ..
                    " ]` ID: `[ " ..
                        user_id .. " ]` \n Player: `[ " .. GetPlayerName(nuser) .. " ]` ID: `[ " .. nuser_id .. " ]` **",
            "سبكتيت"
        )
    end
end
-- ايقاف المراقبة --
local function CMam_StopSpectet(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        TriggerClientEvent("CMam_specstop", player)
    end
end
spec = {}
vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Spectet.Permission}) then
                    choices[CMamAV4.AdminsMenu.Spectet.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "مراقبة",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        menu["!-ايقاف المراقبة-!"] = {CMam_StopSpectet, ""}
                                        for k, v in pairs(users) do
                                            local nuser_id = vRP.getUserId({v})
                                            playerName = tostring(GetPlayerName(v))
                                            if
                                                nuser_id ~= nil and
                                                    vRP.hasPermission({nuser_id, CMamAV4.AdminsPermission})
                                             then
                                                spec[playerName] = v
                                                menu[playerName] = {
                                                    CMam_StartSpectet,
                                                    " Admin id : " .. nuser_id .. ""
                                                }
                                            end
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)
-- >> استعلام عن تيكتات اداري <<
function CMam_GetAdminTickets(player, choice)
    vRP.prompt(
        {
            player,
            "ايدي اللاعب ؟",
            "",
            function(player, user_id)
                local tplayer = vRP.getUserSource({tonumber(user_id)})
                if user_id ~= nil and user_id ~= "" then
                    local tplayer_id = vRP.getUserId({user_id})
                    local admin_id = vRP.getUserId({player})
                    vRP.getUData(
                        {
                            user_id,
                            "CMam:Tickets",
                            function(value)
                                CMnotify(player, "مجموع تيكتات الاداري [ " .. value .. " ] تيكت ")
                                if vRP.getUserId({tplayer}) ~= nil then
                                    CMam_Webhook(
                                        65280,
                                        CMamAV4.Ticket.GetAdminTickets.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    admin_id ..
                                                        " ]` \n Player: `[ " ..
                                                            vRP.getUserId({tplayer}) ..
                                                                " ]` \n Total Tickets: `[ " .. value .. " ]` **",
                                        "استعلام عن تيكتات اداري"
                                    )
                                end
                            end
                        }
                    )
                end
            end
        }
    )
end
-- >> حذف تيكتات اداري <<
function CMam_DelteeAdminTickets(player, choice)
    vRP.prompt(
        {
            player,
            "ايدي اللاعب ؟",
            "",
            function(player, user_id)
                local tplayer = vRP.getUserSource({tonumber(user_id)})
                if user_id ~= nil and user_id ~= "" then
                    local tplayer_id = vRP.getUserId({user_id})
                    local admin_id = vRP.getUserId({player})
                    CMnotify(player, "تم تصفير تيكتات الاداري بنجاح")
                    vRP.setUData({user_id, "CMam:Tickets", 0})
                    if vRP.getUserId({tplayer}) ~= nil then
                        CMam_Webhook(
                            65280,
                            CMamAV4.Ticket.DelteeAdminTickets.Webhook,
                            "** Admin: `[ " ..
                                GetPlayerName(player) ..
                                    " ]` ID: `[ " ..
                                        admin_id .. " ]` \n Player: `[ " .. vRP.getUserId({tplayer}) .. " ]` **",
                            "تصفير تيكتات اداري"
                        )
                    end
                end
            end
        }
    )
end
function CMam_DeleteAllTickets(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.request(
        {
            player,
            "هل انت متاكد من تصفير جميع التيكتات ؟؟",
            60,
            function(player, ok)
                if ok then
                    MySQL.execute("vRP/DeleteTickets", {dkey = "CMam:Tickets"})
                    CMnotify(player, "تم تصفير جميع التيكتات بنجاح")
                    CMam_Webhook(
                        65380,
                        CMamAV4.Ticket.DeleteAllTickets.Webhook,
                        "**Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
                        "تصفير تيكتات جميع الاداريين"
                    )
                end
            end
        }
    )
end
-- >> اعطاء ملاحظة <<
function CMam_Note(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب:",
            "",
            function(player, id)
                id = parseInt(id)
                local id_source = vRP.getUserSource({id})
                if id_source ~= "" then
                    vRP.prompt(
                        {
                            player,
                            "الملاحظة:",
                            "",
                            function(player, message)
                                if
                                    message ~= nil and message ~= "" and
                                        vRP.getUserId({vRP.getUserSource({tonumber(id)})}) ~= nil
                                 then
                                    CMnotify(player, "تم تسجيل الملاحظة بنجاح")
                                    CMam_Webhook(
                                        3447003,
                                        CMamAV4.Notes.Note.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    user_id ..
                                                        " ]` \n Player: `[ " ..
                                                            GetPlayerName(id_source) ..
                                                                " ]` ID: `[ " ..
                                                                    id .. " ]` \n Note: `[ " .. message .. " ]` **",
                                        "تدوين ملاحظة "
                                    )
                                    vRP.getUData(
                                        {
                                            id,
                                            "CMam:Notes",
                                            function(value)
                                                if value then
                                                    vRP.setUData({id, "CMam:Notes", value .. "<br>" .. message})
                                                else
                                                    vRP.setUData({id, "CMam:Notes", message})
                                                end
                                            end
                                        }
                                    )
                                end
                            end
                        }
                    )
                else
                    CMnotify(player, "خطاء في كتابة الايدي")
                end
            end
        }
    )
end
-- >> استعلام عن ملاحظات لاعب <<
function CMam_CheckNote(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب:",
            "",
            function(player, id)
                id = parseInt(id)
                local id_source = vRP.getUserSource({id})
                if id_source ~= nil or id_source ~= nil then
                    vRP.getUData(
                        {
                            id,
                            "CMam:Notes",
                            function(value)
                                if value ~= nil or value ~= "" then
                                    CMnotify(player, "" .. value .. "")
                                    CMam_Webhook(
                                        15844367,
                                        CMamAV4.Notes.CheckNote.Webhook,
                                        "**  Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    user_id ..
                                                        " ]` \n Player: `[ " ..
                                                            GetPlayerName(id_source) .. " ]` ID: `[ " .. id .. " ]` **",
                                        "استعلام عن ملاحظات لاعب"
                                    )
                                else
                                    CMnotify(player, "لايوجد ملاحظات على هذا اللاعب")
                                end
                            end
                        }
                    )
                end
            end
        }
    )
end
-- >> حذف ملاحظات لاعب <<
function CMam_RemoveNote(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt(
        {
            player,
            "ايدي اللاعب:",
            "",
            function(player, id)
                id = parseInt(id)
                local id_source = vRP.getUserSource({id})
                if id_source ~= nil or id_source ~= nil then
                    vRP.getUData(
                        {
                            id,
                            "CMam:Notes",
                            function(value)
                                if value ~= nil or value ~= "" then
                                    vRP.setUData({id, "CMam:Notes", ""})
                                    CMnotify(player, "تم حذف جميع ملاحظات اللاعب")
                                    CMam_Webhook(
                                        15105570,
                                        CMamAV4.Notes.RemoveNote.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    user_id ..
                                                        " ]` \n Player: `[ " ..
                                                            GetPlayerName(id_source) .. " ]` ID: `[ " .. id .. " ]` **",
                                        "حذف جميع ملاحظات لاعب"
                                    )
                                else
                                    CMnotify(player, "لايوجد ملاحظات على هذا اللاعب")
                                end
                            end
                        }
                    )
                end
            end
        }
    )
end
-- >> اعطاء رتبة <<
local function CMam_AddPlayerToGroup(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        local menu = {name = "اعطاء رتبة", css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}}
        menu.onclose = function(player)
            vRP.openMainMenu({player})
        end -- nest menu
        local choose = function(player, choice)
            vRP.prompt(
                {
                    player,
                    "Player ID:",
                    "",
                    function(player, id)
                        if id ~= nil and id ~= "" then
                            id = parseInt(id)
                            local nplayer = vRP.getUserSource({tonumber(id)})
                            if nplayer ~= nil then
                                local AdminRoles = CMamAV4.AdminsMenu.Groupsmenu.GroupsList[choice]
                                if AdminRoles ~= nil then
                                    vRP.addUserGroup({id, AdminRoles})
                                    CMnotify(player, "تم اعطاء الرتبة بنجاح ")
                                    CMam_Webhook(
                                        65280,
                                        CMamAV4.AdminsMenu.Groupsmenu.addGroup.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    vRP.getUserId({player}) ..
                                                        " ]` \n ID: `[ " ..
                                                            id .. " ]` \n Group: `[ " .. choice .. " ]` **",
                                        "اعطاء رتب"
                                    )
                                end
                            else
                                CMnotify(player, "خطاء في كتابة الايدي")
                            end
                        end
                    end
                }
            )
        end
        for k, v, a in pairs(CMamAV4.AdminsMenu.Groupsmenu.GroupsList) do
            menu[k] = {choose}
        end
        vRP.openMenu({player, menu})
    end
end

local function CMam_RemovePlayerFromGroup(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        local menu = {name = "سحب رتبه", css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}}
        menu.onclose = function(player)
            vRP.openMainMenu({player})
        end -- nest menu
        local choose = function(player, choice)
            vRP.prompt(
                {
                    player,
                    "Player ID:",
                    "",
                    function(player, id)
                        if id ~= nil and id ~= "" then
                            id = parseInt(id)
                            local nplayer = vRP.getUserSource({tonumber(id)})
                            if nplayer ~= nil then
                                local AdminRoles2 = CMamAV4.AdminsMenu.Groupsmenu.GroupsList[choice]
                                if AdminRoles2 ~= nil and vRP.hasGroup({id, AdminRoles2}) then
                                    vRP.removeUserGroup({id, AdminRoles2})
                                    CMnotify(player, "تم ازالة الرتبة بنجاح ")
                                    CMam_Webhook(
                                        16711680,
                                        CMamAV4.AdminsMenu.Groupsmenu.removeGroup.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    vRP.getUserId({player}) ..
                                                        " ]` \n ID: `[ " ..
                                                            id .. " ]` \n Group: `[ " .. choice .. " ]` **",
                                        "سحب رتب"
                                    )
                                end
                            else
                                CMnotify(player, "خطاء في كتابة الايدي")
                            end
                        end
                    end
                }
            )
        end
        for k, v, a in pairs(CMamAV4.AdminsMenu.Groupsmenu.GroupsList) do
            menu[k] = {choose}
        end
        vRP.openMenu({player, menu})
    end
end
-- >> حذف اسلحة اللاعبين <<
function CMam_ClearWeapons(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRP.request(
            {
                player,
                "هل انت متاكد من حذف اسلحة جميع اللاعبين ؟؟",
                60,
                function(player, ok)
                    if ok then
                        local users = vRP.getUsers({})
                        for k, v in pairs(users) do
                            local nplayer = vRP.getUserSource({k})
                            vRPclient.giveWeapons(nplayer, {{}, true})
                            CMam_Webhook(
                                15105570,
                                CMamAV4.DeleteMenu.ClearWeapons.Webhook,
                                "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
                                "حذف جميع اسلحة اللاعبين"
                            )
                            CMnotify(player, "تم حذف جميع اسلحة اللاعبين")
                        end
                    end
                end
            }
        )
    end
end
-- >> حذف اسلحة لاعب واحد <<
function CMam_RemovePlayerWeapons(player, choice)
    vRP.prompt(
        {
            player,
            "ايدي اللاعب ؟",
            "",
            function(player, user_id)
                local tplayer = vRP.getUserSource({tonumber(user_id)})
                local tplayer_id = vRP.getUserId({user_id})
                local admin_id = vRP.getUserId({player})
                CMnotify(player, "تم حذف اسلحة اللاعب")
                vRPclient.giveWeapons(tplayer, {{}, true})
                CMam_Webhook(
                    15105570,
                    CMamAV4.DeleteMenu.RemovePlayerWeapons.Webhook,
                    "** Admin: `[ " ..
                        GetPlayerName(player) ..
                            " ]` ID: `[ " ..
                                admin_id ..
                                    " ]` \n Player: `[ " ..
                                        GetPlayerName(tplayer) .. " ]` ID: `[ " .. vRP.getUserId({tplayer}) .. " ]` **",
                    "حذف اسلحة لاعب"
                )
            end
        }
    )
end
-- >> اخذ اسلحة <<
function CMam_GiveWeapons(player, choice)
    local user_id = vRP.getUserId({player})
    for k, v in pairs(CMamAV4.AdminsMenu.Weapons.WeaponsList) do
        vRPclient.giveWeapons(
            player,
            {
                {
                    [k] = {ammo = v[1]}
                },
                false
            }
        )
    end
    CMnotify(player, "تم اخذ الاسلحة بنجاح ")
    CMam_Webhook(
        15105570,
        CMamAV4.AdminsMenu.Weapons.Webhook,
        "** Admin: `[ " .. GetPlayerName(player) .. " ]` ID: `[ " .. user_id .. " ]` **",
        "اخذ اسلحة"
    )
end
TPSpam = {}
-- >> طلب انتقال <<
local function CMam_TPRequest(player, choice)
    local nuser = TP[choice]
    local user_id = vRP.getUserId({player})
    local nuser_id = vRP.getUserId({nuser})
    if TPSpam[user_id] ~= true then
        TPSpam[user_id] = true
        if user_id ~= nil and nuser_id ~= nil then
            vRP.request(
                {
                    nuser,
                    "Admin: [ " .. GetPlayerName(player) .. " ] ID: [ " .. user_id .. " ] | طلب انتقال",
                    60,
                    function(nuser, ok)
                        if ok then
                            vRPclient.getPosition(
                                nuser,
                                {},
                                function(x, y, z)
                                    vRPclient.teleport(player, {x, y, z})
                                    CMnotify(player, "تم قبول طلب الانتقال")
                                    if CMamAV4.CallAdmin.client.influence then
                                        TriggerClientEvent("CMam:TicketsAn", player)
                                        TriggerClientEvent("CMam:TicketsAn", nuser)
                                    end
                                    CMam_Webhook(
                                        001238,
                                        CMamAV4.TPRequest.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    user_id ..
                                                        " ]` \n Player: `[ " ..
                                                            GetPlayerName(nuser) ..
                                                                " ]` ID: `[ " ..
                                                                    nuser_id ..
                                                                        " ]` \n Coords: `[ " ..
                                                                            x .. "," .. y .. "," .. z .. " ]` **",
                                        "طلب انتقال"
                                    )
                                end
                            )
                        else
                            CMnotify(player, "تم رفض طلب الانتقال")
                        end
                    end
                }
            )
        end
        SetTimeout(
            CMam.Settings.Control.Spams.RequestSpam * 1000,
            function()
                TPSpam[user_id] = false
            end
        )
    else
    end
end
function CMam_TPID(player, choice)
    if TPSpam[player] ~= true then
        TPSpam[player] = true
        vRP.prompt(
            {
                player,
                "ايدي اللاعب ؟",
                "",
                function(player, user_id)
                    local tplayer = vRP.getUserSource({tonumber(user_id)})
                    local tplayer_id = vRP.getUserId({tplayer})
                    local admin_id = vRP.getUserId({player})
                    if tplayer ~= nil then
                        vRP.request(
                            {
                                tplayer,
                                "Admin: [ " .. GetPlayerName(player) .. " ] ID: [ " .. admin_id .. " ] | طلب انتقال",
                                60,
                                function(tplayer, ok)
                                    if ok then
                                        vRPclient.getPosition(
                                            tplayer,
                                            {},
                                            function(x, y, z)
                                                vRPclient.teleport(player, {x, y, z})
                                                CMnotify(player, "تم قبول طلب الانتقال")
                                                if CMamAV4.CallAdmin.client.influence then
                                                    TriggerClientEvent("CMam:TicketsAn", player)
                                                    TriggerClientEvent("CMam:TicketsAn", tplayer)
                                                end
                                                CMam_Webhook(
                                                    001238,
                                                    CMamAV4.TPRequest.Webhook,
                                                    "** Admin: `[ " ..
                                                        GetPlayerName(player) ..
                                                            " ]` ID: `[ " ..
                                                                admin_id ..
                                                                    " ]` \n Player: `[ " ..
                                                                        GetPlayerName(tplayer) ..
                                                                            " ]` ID: `[ " ..
                                                                                tplayer_id ..
                                                                                    " ]` \n Coords: `[ " ..
                                                                                        x ..
                                                                                            "," ..
                                                                                                y ..
                                                                                                    "," .. z .. " ]` **",
                                                    "طلب انتقال"
                                                )
                                            end
                                        )
                                    else
                                        CMnotify(player, "تم رفض طلب الانتقال")
                                    end
                                end
                            }
                        )
                    else
                        CMnotify(player, "خطاء في كتابة الايدي")
                    end
                end
            }
        )
        SetTimeout(
            CMam.Settings.Control.Spams.RequestSpam * 1000,
            function()
                TPSpam[player] = false
            end
        )
    else
    end
end
TP = {}
local CMam_TPRequestChoice = {
    function(player, choice)
        local user_id = vRP.getUserId({player})
        local menu = {}
        users = vRP.getUsers({})
        menu.name = a
        menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
        menu.onclose = function(player)
            vRP.openMainMenu({player})
        end
        menu["! طلب بالايدي !"] = {CMam_TPID}
        for k, v in pairs(users) do
            local nuser_id = vRP.getUserId({v})
            playerName = tostring(GetPlayerName(v))

            if nuser_id ~= nil and vRP.hasPermission({nuser_id, CMamAV4.AdminsPermission}) and nuser_id ~= user_id then
                TP[playerName] = v
                menu[playerName] = {CMam_TPRequest}
            end
        end
        vRP.openMenu({player, menu})
    end,
    a
}
-- >> طلب سحب <<
local function CMam_6LBS7B(player, choice)
    local nuser = TPs7b[choice]
    local user_id = vRP.getUserId({player})
    local nuser_id = vRP.getUserId({nuser})
    if TPSpam[user_id] ~= true then
        TPSpam[user_id] = true
        if user_id ~= nil and nuser_id ~= nil then
            vRP.request(
                {
                    nuser,
                    "Admin: [ " .. GetPlayerName(player) .. " ] ID: [ " .. user_id .. " ] | طلب سحب",
                    60,
                    function(nuser, ok)
                        if ok then
                            vRPclient.getPosition(
                                player,
                                {},
                                function(x, y, z)
                                    vRPclient.teleport(nuser, {x, y, z})
                                    CMnotify(player, "تم قبول طلب الانتقال ")
                                    if CMamAV4.CallAdmin.client.influence then
                                        TriggerClientEvent("CMam:TicketsAn", player)
                                        TriggerClientEvent("CMam:TicketsAn", nuser)
                                    end
                                    CMam_Webhook(
                                        001238,
                                        CMamAV4.TPRequest.Webhook,
                                        "** Admin: `[ " ..
                                            GetPlayerName(player) ..
                                                " ]` ID: `[ " ..
                                                    user_id ..
                                                        " ]` \n Player: `[ " ..
                                                            GetPlayerName(nuser) ..
                                                                " ]` ID: `[ " ..
                                                                    nuser_id ..
                                                                        " ]` \n Coords: `[ " ..
                                                                            x .. "," .. y .. "," .. z .. " ]` **",
                                        "طلب انتقال"
                                    )
                                end
                            )
                        else
                            CMnotify(player, "تم رفض طلب الانتقال")
                        end
                    end
                }
            )
        end
        SetTimeout(
            CMam.Settings.Control.Spams.RequestSpam * 1000,
            function()
                TPSpam[user_id] = false
            end
        )
    else
    end
end
function CMam_6LBS7BID(player, choice)
    if TPSpam[player] ~= true then
        TPSpam[player] = true
        vRP.prompt(
            {
                player,
                "ايدي اللاعب ؟",
                "",
                function(player, user_id)
                    local tplayer = vRP.getUserSource({tonumber(user_id)})
                    local tplayer_id = vRP.getUserId({tplayer})
                    local admin_id = vRP.getUserId({player})
                    if tplayer ~= nil then
                        vRP.request(
                            {
                                tplayer,
                                "Admin: [ " .. GetPlayerName(player) .. " ] ID: [ " .. admin_id .. " ] | طلب سحب",
                                60,
                                function(tplayer, ok)
                                    if ok then
                                        vRPclient.getPosition(
                                            player,
                                            {},
                                            function(x, y, z)
                                                vRPclient.teleport(tplayer, {x, y, z})
                                                CMnotify(player, "تم قبول طلب السحب ")
                                                if CMamAV4.CallAdmin.client.influence then
                                                    TriggerClientEvent("CMam:TicketsAn", player)
                                                    TriggerClientEvent("CMam:TicketsAn", tplayer)
                                                end
                                                CMam_Webhook(
                                                    001238,
                                                    CMamAV4.TPRequest.Webhook,
                                                    "** Admin: `[ " ..
                                                        GetPlayerName(player) ..
                                                            " ]` ID: `[ " ..
                                                                admin_id ..
                                                                    " ]` \n Player: `[ " ..
                                                                        GetPlayerName(tplayer) ..
                                                                            " ]` ID: `[ " ..
                                                                                tplayer_id ..
                                                                                    " ]` \n Coords: `[ " ..
                                                                                        x ..
                                                                                            "," ..
                                                                                                y ..
                                                                                                    "," .. z .. " ]` **",
                                                    "طلب سحب"
                                                )
                                            end
                                        )
                                    else
                                        CMnotify(player, "تم رفض طلب السحب ")
                                    end
                                end
                            }
                        )
                    else
                        CMnotify(player, "خطاء في كتابة الايدي")
                    end
                end
            }
        )
        SetTimeout(
            CMam.Settings.Control.Spams.RequestSpam * 1000,
            function()
                TPSpam[player] = false
            end
        )
    else
    end
end
local function CMamskinsmodel(player, B)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil and vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Addskins.Permission}) then
        vRP.prompt(
            {
                player,
                "ايدي الاعب :",
                "",
                function(player, id)
                    if id ~= nil then
                        id = parseInt(id)
                        local ab = vRP.getUserSource({id})
                        if ab ~= nil then
                            vRP.prompt(
                                {
                                    player,
                                    "اسم السكن :",
                                    "",
                                    function(player, skinsmodel)
                                        if skinsmodel ~= nil then
                                            local ad = {model = skinsmodel}
                                            for i = 0, 300 do
                                                ad[i] = {0, 0}
                                            end
                                            vRPclient.setCustomization(ab, {ad})
                                            CMnotify(player, "لقد تم اعطاء الاعب السكن بنجاح ")
                                            CMam_Webhook(
                                                0x070bed,
                                                CMamAV4.AdminsMenu.Addskins.Webhook,
                                                "** Admin: `" ..
                                                    GetPlayerName(player) ..
                                                        "`  ID :  `" ..
                                                            user_id ..
                                                                "`  **\n  **Player ID : `" ..
                                                                    id .. "`  Skin Model : `" .. skinsmodel .. "`**",
                                                "اعطاء ملابس"
                                            )
                                        else
                                            CMnotify(player, "خطاء في كتابة اسم السكن ")
                                        end
                                    end
                                }
                            )
                        end
                    else
                        CMnotify(player, "خطاء في كتابة الايدي")
                    end
                end
            }
        )
    end
end

RegisterCommand(
    CMamAV4.UnCuffed.Command,
    function(source)
        local user_source = source
        local user_id = vRP.getUserId({source})
        if vRP.hasPermission({user_id, CMamAV4.UnCuffed.Permission}) then
            if user_id ~= nil then
                vRPclient.isHandcuffed(
                    source,
                    {},
                    function(handcuffed)
                        if not handcuffed then
                            vRPclient.toggleHandcuff(source, {})
                            CMam_Webhook(
                                0,
                                CMamAV4.UnCuffed.Webhook,
                                "** Admin: `" ..
                                    GetPlayerName(source) .. "`  ID :  `" .. user_id .. "` \n  Has UnCuffed HimSelf**",
                                "كشلبة الادمن"
                            )
                            CMnotify(source, "لقد تم تقيدك")
                        else
                            vRPclient.toggleHandcuff(source, {})
                            CMam_Webhook(
                                0,
                                CMamAV4.UnCuffed.Webhook,
                                "** Admin: `" ..
                                    GetPlayerName(source) .. "`  ID :  `" .. user_id .. "` \n  Has UnCuffed HimSelf**",
                                "فك كشلبة الادمن"
                            )
                            CMnotify(source, "لقد تم فك قيدك")
                        end
                    end
                )
            end
        end
    end
)

TPs7b = {}
local CMam_TPRequestChoice6lbs7b = {
    function(player, choice)
        local user_id = vRP.getUserId({player})
        local menu = {}
        users = vRP.getUsers({})
        menu.name = a
        menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
        menu.onclose = function(player)
            vRP.openMainMenu({player})
        end
        menu["! طلب بالايدي !"] = {CMam_6LBS7BID}
        for k, v in pairs(users) do
            local nuser_id = vRP.getUserId({v})
            playerName = tostring(GetPlayerName(v))

            if nuser_id ~= nil and vRP.hasPermission({nuser_id, CMamAV4.AdminsPermission}) and nuser_id ~= user_id then
                TPs7b[playerName] = v
                menu[playerName] = {CMam_6LBS7B}
            end
        end
        vRP.openMenu({player, menu})
    end,
    a
}

local Adminmanger = {
    function(player, choice)
        local user_id = vRP.getUserId({player})
        local menu = {}
        menu.name = a
        menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
        menu.onclose = function(player)
            vRP.openMainMenu({player})
        end

        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Dragmenu.Permission}) then
            menu[CMamAV4.AdminsMenu.Dragmenu.name] = {CMam_Drag, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.SendMsgMenu.Permission}) then
            menu[CMamAV4.AdminsMenu.SendMsgMenu.name] = {CMam_MessageTOAdmin, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Onlinememu.Permission}) then
            menu[CMamAV4.AdminsMenu.Onlinememu.name] = {AdminOnline, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.msgTOAll.Permission}) then
            menu[CMamAV4.AdminsMenu.msgTOAll.name] = {CMam_MessageTOAll, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Pullmenu.Permission}) then
            menu[CMamAV4.AdminsMenu.Pullmenu.name] = {PullAdmins, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.SpawnCar.Permission}) then
            menu[CMamAV4.AdminsMenu.SpawnCar.name] = {CMam_SpawnCar, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Addskins.Permission}) then
            menu[CMamAV4.AdminsMenu.Addskins.name] = {CMamskinsmodel, a}
        end
        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Weapons.Permission}) then
            menu[CMamAV4.AdminsMenu.Weapons.name] = {CMam_GiveWeapons, a}
        end

        vRP.openMenu({player, menu})
    end,
    a
}

-- قائمه الادارة

vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if
                    vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Groupsmenu.addGroup.Permission}) or
                        vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Groupsmenu.removeGroup.Permission}) or
                        vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Groupsmenu.CheckGroup.Permission})
                 then
                    choices[CMamAV4.AdminsMenu.Groupsmenu.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "س",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        if
                                            vRP.hasPermission(
                                                {user_id, CMamAV4.AdminsMenu.Groupsmenu.addGroup.Permission}
                                            )
                                         then
                                            menu[CMamAV4.AdminsMenu.Groupsmenu.addGroup.name] = {
                                                CMam_AddPlayerToGroup,
                                                a
                                            }
                                        end
                                        if
                                            vRP.hasPermission(
                                                {user_id, CMamAV4.AdminsMenu.Groupsmenu.removeGroup.Permission}
                                            )
                                         then
                                            menu[CMamAV4.AdminsMenu.Groupsmenu.removeGroup.name] = {
                                                CMam_RemovePlayerFromGroup,
                                                a
                                            }
                                        end
                                        if
                                            vRP.hasPermission(
                                                {user_id, CMamAV4.AdminsMenu.Groupsmenu.CheckGroup.Permission}
                                            )
                                         then
                                            menu[CMamAV4.AdminsMenu.Groupsmenu.CheckGroup.name] = {
                                                CMam_CGroups,
                                                a
                                            }
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

-- قائمة السجن

vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if
                    vRP.hasPermission({user_id, CMamAV4.Jailmenu.UnJail.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Jailmenu.OffLineJail.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Jailmenu.Jail.Permission})
                 then
                    choices[CMamAV4.Jailmenu.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "س",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        if vRP.hasPermission({user_id, CMamAV4.Jailmenu.UnJail.Permission}) then
                                            menu[CMamAV4.Jailmenu.UnJail.name] = {CMam_UnJail, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Jailmenu.OffLineJail.Permission}) then
                                            menu[CMamAV4.Jailmenu.OffLineJail.name] = {CMam_OffLineJail, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Jailmenu.Jail.Permission}) then
                                            menu[CMamAV4.Jailmenu.Jail.name] = {CMamAdmin_Jail, a}
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

-- قائمة التكتات

vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if
                    vRP.hasPermission({user_id, CMamAV4.Ticket.GetAdminTickets.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Ticket.DelteeAdminTickets.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Ticket.DeleteAllTickets.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Ticket.StopTickets.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Ticket.stopreception.Permission}) 
                 then
                    choices[CMamAV4.Ticket.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "س",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        if vRP.hasPermission({user_id, CMamAV4.Ticket.GetAdminTickets.Permission}) then
                                            menu[CMamAV4.Ticket.GetAdminTickets.name] = {
                                                CMam_GetAdminTickets,
                                                a
                                            }
                                        end
                                        if
                                            vRP.hasPermission(
                                                {user_id, CMamAV4.Ticket.DelteeAdminTickets.Permission}
                                            )
                                         then
                                            menu[CMamAV4.Ticket.DelteeAdminTickets.name] = {
                                                CMam_DelteeAdminTickets,
                                                a
                                            }
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Ticket.DeleteAllTickets.Permission}) then
                                            menu[CMamAV4.Ticket.DeleteAllTickets.name] = {
                                                CMam_DeleteAllTickets,
                                                a
                                            }
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Ticket.StopTickets.Permission}) then
                                            if CMam_Stop ~= true then
                                                menu[CMamAV4.Ticket.StopTickets.stop] = {StopTickets, a}
                                            end
                                            if CMam_Start == true then
                                                menu[CMamAV4.Ticket.StopTickets.start] = {StartTickets, a}
                                            end
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Ticket.stopreception.Permission}) then
                                            if CMam_StoptI ~= true then
                                                menu[CMamAV4.Ticket.stopreception.stop] = {StopSeTickets, a}
                                            end
                                            if CMam_StartI == true then
                                                menu[CMamAV4.Ticket.stopreception.start] = {StartSeTickets, a}
                                            end
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

-- قائمة الملاحظات

vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if
                    vRP.hasPermission({user_id, CMamAV4.Notes.Note.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Notes.CheckNote.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Notes.RemoveNote.Permission})
                 then
                    choices[CMamAV4.Notes.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "س",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        if vRP.hasPermission({user_id, CMamAV4.Notes.Note.Permission}) then
                                            menu[CMamAV4.Notes.Note.name] = {CMam_Note, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Notes.CheckNote.Permission}) then
                                            menu[CMamAV4.Notes.CheckNote.name] = {CMam_CheckNote, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Notes.RemoveNote.Permission}) then
                                            menu[CMamAV4.Notes.RemoveNote.name] = {CMam_RemoveNote, a}
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

-- قائمة الشات

vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if
                    vRP.hasPermission({user_id, CMamAV4.Chatmenu.Mutechat.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Chatmenu.Clearchat.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.Chatmenu.stopchat.Permission}) 
                 then
                    choices[CMamAV4.Chatmenu.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "س",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        if vRP.hasPermission({user_id, CMamAV4.Chatmenu.stopchat.Permission}) then
                                            menu[CMamAV4.Chatmenu.stopchat.stop] = {CMam_StopChat, a}
                                            menu[CMamAV4.Chatmenu.stopchat.start] = {CMam_startChat, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Chatmenu.Mutechat.Permission}) then
                                            menu[CMamAV4.Chatmenu.Mutechat.Mute] = {CMam_MuteChat, a}
                                            menu[CMamAV4.Chatmenu.Mutechat.UnMute] = {CMam_UnMute, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Chatmenu.Clearchat.Permission}) then
                                            menu[CMamAV4.Chatmenu.Clearchat.Clear] = {CMam_chatclear, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Chatmenu.stopchat.Permission}) then
                                            menu[CMamAV4.Chatmenu.stopchat.stop] = {CMam_StopChat, a}
                                            menu[CMamAV4.Chatmenu.stopchat.start] = {CMam_startChat, a}
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.Chatmenu.Mutechat.Permission}) then
                                            menu[CMamAV4.Chatmenu.Mutechat.Mute] = {CMam_MuteChat, a}
                                            menu[CMamAV4.Chatmenu.Mutechat.UnMute] = {CMam_UnMute, a}
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

--قائمة الحذف

vRP.registerMenuBuilder(
    {
        "CMamTheBest",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if
                    vRP.hasPermission({user_id, CMamAV4.DeleteMenu.DeleteAllCars.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.DeleteMenu.DeleteAllPeds.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.DeleteMenu.DeleteAllObject.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.DeleteMenu.ClearWeapons.Permission}) or
                    vRP.hasPermission({user_id, CMamAV4.DeleteMenu.RemovePlayerWeapons.Permission}) 
                 then
                    choices[CMamAV4.DeleteMenu.name] = {
                        function(player, choice)
                            users = vRP.getUsers({})
                            vRP.buildMenu(
                                {
                                    "س",
                                    {player = player},
                                    function(menu)
                                        menu.name = ""
                                        menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                                        menu.onclose = function(player)
                                            vRP.closeMenu({player})
                                        end
                                        myName = tostring(GetPlayerName(player))
                                        if vRP.hasPermission({user_id, CMamAV4.DeleteMenu.DeleteAllCars.Permission}) then
                                            menu[CMamAV4.DeleteMenu.DeleteAllCars.name] = {
                                                CMam_DeleteAllCars,
                                                a
                                            }
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.DeleteMenu.DeleteAllPeds.Permission}) then
                                            menu[CMamAV4.DeleteMenu.DeleteAllPeds.name] = {
                                                CMam_DeleteAllPeds,
                                                a
                                            }
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.DeleteMenu.DeleteAllObject.Permission}) then
                                            menu[CMamAV4.DeleteMenu.DeleteAllObject.name] = {
                                                CMam_DeleteAllObject,
                                                a
                                            }
                                        end
                                        if vRP.hasPermission({user_id, CMamAV4.DeleteMenu.ClearWeapons.Permission}) then
                                            menu[CMamAV4.DeleteMenu.ClearWeapons.name] = {CMam_ClearWeapons, a}
                                        end
                                        if
                                            vRP.hasPermission(
                                                {user_id, CMamAV4.DeleteMenu.RemovePlayerWeapons.Permission}
                                            )
                                         then
                                            menu[CMamAV4.DeleteMenu.RemovePlayerWeapons.name] = {
                                                CMam_RemovePlayerWeapons,
                                                a
                                            }
                                        end
                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

vRP.registerMenuBuilder(
    {
        "admin",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if vRP.hasPermission({user_id, CMamAV4.ChoicePermission}) then
                    choices[CMamAV4.MainMenu] = {
                        function(player, choice)
                            vRP.buildMenu(
                                {
                                    "CMamTheBest",
                                    {player = player},
                                    function(menu)
                                        menu.name = a
                                        if vRP.hasPermission({user_id, CMamAV4.AdminsMenu.Permission}) then
                                            menu[CMamAV4.AdminsMenu.MenuName] = Adminmanger
                                        end
                                    

                                        vRP.openMenu({player, menu})
                                    end
                                }
                            )
                        end,
                        a
                    }
                end
                add(choices)
            end
        end
    }
)

Tickets = {}
CMamSpam = {}
TestCMam = {}
T8yymSpam = {}
admins = {}
-- >> طلب  ادمن <<
function CMam_AdminTickets(player, choices)
    local user_id = vRP.getUserId({player})
    if CMamSpam[user_id] ~= true then
        CMamSpam[user_id] = true
        if user_id ~= nil then
            vRP.prompt(
                {
                    player,
                    "اكتب مشكلتك؟",
                    "",
                    function(player, desc)
                        if string.len(desc) <= CMamAV4.CallAdmin.MxDesc then
                            desc = desc or ""
                            if desc ~= nil and desc ~= "" then
                                local answered = false
                                local players = {}
                                for k, v in pairs(vRP.getUsers({})) do
                                    local player = vRP.getUserSource({tonumber(k)})
                                    if
                                        vRP.hasPermission({k, CMamAV4.CallAdmin.calladmin.Permission}) and
                                            player ~= nil
                                     then
                                        table.insert(players, player)
                                    end
                                end
                                for k, v in pairs(players) do
                                    if v~=player then
                                    if StopTicketsS[vRP.getUserId({v})] ~= true then
                                        vRP.request(
                                            {
                                                v,
                                                "Admin ticket (user_id = " ..
                                                    user_id .. ") take/TP to ?: " .. htmlEntities.encode(desc),
                                                60,
                                                function(v, ok)
                                                    if ok then
                                                        if admins[v] == nil then
                                                            admins[v] = false
                                                        end
                                                        if admins[v] == false then
                                                            if not answered then
                                                                CMnotify(
                                                                    player,
                                                                    "تم قبول طلبك من الاداري [ " ..
                                                                        GetPlayerName(v) ..
                                                                            " ] ID: [ " .. vRP.getUserId({v}) .. " ]"
                                                                )
                                                                vRP.getUData(
                                                                    {
                                                                        vRP.getUserId({v}),
                                                                        "CMam:Tickets",
                                                                        function(Tickets)
                                                                            if Tickets ~= nil or Tickets ~= "" then
                                                                                TotalTi = Tickets + 1
                                                                                vRP.setUData(
                                                                                    {
                                                                                        vRP.getUserId({v}),
                                                                                        "CMam:Tickets",
                                                                                        TotalTi
                                                                                    }
                                                                                )
                                                                            else
                                                                                vRP.setUData(
                                                                                    {
                                                                                        vRP.getUserId({v}),
                                                                                        "CMam:Tickets",
                                                                                        tonumber("0")
                                                                                    }
                                                                                )
                                                                            end
                                                                            vRPclient.getPosition(
                                                                                v,
                                                                                {},
                                                                                function(x, y, z)
                                                                                    if
                                                                                        TicketsBack[v] == false or
                                                                                            TicketsBack[v] == nil
                                                                                     then
                                                                                        Position[v] = {x, y, z}
                                                                                        TicketsBack[v] = true
                                                                                    end
                                                                                end
                                                                            )
                                                                            vRPclient.getPosition(
                                                                                player,
                                                                                {},
                                                                                function(x, y, z)
                                                                                    vRPclient.teleport(v, {x, y, z})
                                                                                    CMam_Webhook(
                                                                                        0,
                                                                                        CMamAV4.CallAdmin.calladmin.Webhook,
                                                                                        "** Admin: `[ " ..
                                                                                            GetPlayerName(v) ..
                                                                                                " ]` ID: `[ " ..
                                                                                                    vRP.getUserId({v}) ..
                                                                                                        " ]` \n Citizen: `[ " ..
                                                                                                            GetPlayerName(
                                                                                                                player
                                                                                                            ) ..
                                                                                                                " ]` ID: `[ " ..
                                                                                                                    user_id ..
                                                                                                                        " ]` \n Description: `[ " ..
                                                                                                                            desc ..
                                                                                                                                " ]`  **",
                                                                                        "طلب  ادمن"
                                                                                    )
                                                                                    if
                                                                                        CMamAV4.CallAdmin.client.influence
                                                                                     then
                                                                                        TriggerClientEvent(
                                                                                            "CMam:TicketsAn",
                                                                                            player
                                                                                        )
                                                                                    end
                    
                                                                                end
                                                                            )
                                                                            answered = true
                                                                            admins[v] = true
                                                                            SetTimeout(
                                                                                CMam.Settings.Control.Spams.RequestSpam *
                                                                                    1000,
                                                                                function()
                                                                                    admins[v] = false
                                                                                end
                                                                            )
                                                                        end
                                                                    }
                                                                )
                                                            else
                                                                CMnotify(v, "الطلب مقبول من اداري اخر ")
                                                            end
                                                        end
                                                    end
                                                end
                                            }
                                        )
                                    end
                                    end
                                end
                            else
                                CMnotify(player, "لايمكنك ترك الطلب فارغ")
                                CMamSpam[user_id] = false
                            end
                        else
                            CMnotify(player, "لقد وصلت الحد الاقصى من الحروف")
                            CMamSpam[user_id] = false
                        end
                    end
                }
            )
        end
        SetTimeout(
            CMam.Settings.Control.Spams.TicketsSpam * 1000,
            function()
                CMamSpam[user_id] = false
            end
        )
    else
        CMnotify(player, "الرجاء عدم عمل سبام ")
    end
end
-- >> طلب  ادمن رتب <<
function CMam_AdminTicketsGroup(player, choices)
    local user_id = vRP.getUserId({player})
    if CMamSpam[user_id] ~= true then
        CMamSpam[user_id] = true
        if user_id ~= nil then
            vRP.prompt(
                {
                    player,
                    "الرتبة المطلوبة",
                    "",
                    function(player, desc)
                        if string.len(desc) <= CMamAV4.CallAdmin.MxDesc then
                            desc = desc or ""
                            if desc ~= nil and desc ~= "" then
                                local answered = false
                                local players = {}
                                for k, v in pairs(vRP.getUsers({})) do
                                    local player = vRP.getUserSource({tonumber(k)})
                                    if
                                        vRP.hasPermission({k, CMamAV4.CallAdmin.calladminGroup.Permission}) and
                                            player ~= nil
                                     then
                                        table.insert(players, player)
                                    end
                                end
                                for k, v in pairs(players) do
                                    if v~=player then
                                    if StopTicketsS[vRP.getUserId({v})] ~= true then
                                        vRP.request(
                                            {
                                                v,
                                                "Admin ticket (user_id = " ..
                                                    user_id .. ") take/TP to ?: " .. htmlEntities.encode(desc),
                                                60,
                                                function(v, ok)
                                                    if ok then
                                                        if admins[v] == nil then
                                                            admins[v] = false
                                                        end
                                                        if admins[v] == false then
                                                            if not answered then
                                                                CMnotify(
                                                                    player,
                                                                    "تم قبول طلبك من الاداري [ " ..
                                                                        GetPlayerName(v) ..
                                                                            " ] ID: [ " .. vRP.getUserId({v}) .. " ]"
                                                                )
                                                                vRP.getUData(
                                                                    {
                                                                        vRP.getUserId({v}),
                                                                        "CMam:Tickets",
                                                                        function(Tickets)
                                                                            if Tickets ~= nil or Tickets ~= "" then
                                                                                TotalTi = Tickets + 1
                                                                                vRP.setUData(
                                                                                    {
                                                                                        vRP.getUserId({v}),
                                                                                        "CMam:Tickets",
                                                                                        TotalTi
                                                                                    }
                                                                                )
                                                                            else
                                                                                vRP.setUData(
                                                                                    {
                                                                                        vRP.getUserId({v}),
                                                                                        "CMam:Tickets",
                                                                                        tonumber("0")
                                                                                    }
                                                                                )
                                                                            end
                                                                            vRPclient.getPosition(
                                                                                v,
                                                                                {},
                                                                                function(x, y, z)
                                                                                    if
                                                                                        TicketsBack[v] == false or
                                                                                            TicketsBack[v] == nil
                                                                                     then
                                                                                        Position[v] = {x, y, z}
                                                                                        TicketsBack[v] = true
                                                                                    end
                                                                                end
                                                                            )
                                                                            vRPclient.getPosition(
                                                                                player,
                                                                                {},
                                                                                function(x, y, z)
                                                                                    vRPclient.teleport(v, {x, y, z})
                                                                                    CMam_Webhook(
                                                                                        0,
                                                                                        CMamAV4.CallAdmin.calladminGroup.Webhook,
                                                                                        "** Admin: `[ " ..
                                                                                            GetPlayerName(v) ..
                                                                                                " ]` ID: `[ " ..
                                                                                                    vRP.getUserId({v}) ..
                                                                                                        " ]` \n Citizen: `[ " ..
                                                                                                            GetPlayerName(
                                                                                                                player
                                                                                                            ) ..
                                                                                                                " ]` ID: `[ " ..
                                                                                                                    user_id ..
                                                                                                                        " ]` \n Description: `[ " ..
                                                                                                                            desc ..
                                                                                                                                " ]`  **",
                                                                                        "طلب  ادمن رتب"
                                                                                    )
                                                                                    if
                                                                                        CMamAV4.CallAdmin.client.influence
                                                                                     then
                                                                                        TriggerClientEvent(
                                                                                            "CMam:TicketsAn",
                                                                                            player
                                                                                        )
                                                                                    end
                                                                                end
                                                                            )
                                                                            answered = true
                                                                            admins[v] = true
                                                                            SetTimeout(
                                                                                CMam.Settings.Control.Spams.RequestSpam *
                                                                                    1000,
                                                                                function()
                                                                                    admins[v] = false
                                                                                end
                                                                            )
                                                                        end
                                                                    }
                                                                )
                                                            else
                                                                CMnotify(v, "الطلب مقبول من اداري اخر")
                                                            end
                                                        end
                                                    else
                                                        CMnotify(v, "الرجاء عدم تكرار قبول الطلبات")
                                                    end
                                                end
                                            }
                                        )
                                    end
                                    end
                                end
                            else
                                CMnotify(player, "لايمكنك ترك الطلب فارغ")
                                CMamSpam[user_id] = false
                            end
                        else
                            CMnotify(player, "لقد وصلت الحد الاقصى من الحروف")
                            CMamSpam[user_id] = false
                        end
                    end
                }
            )
        end
        SetTimeout(
            CMam.Settings.Control.Spams.TicketsSpam * 1000,
            function()
                CMamSpam[user_id] = false
            end
        )
    else
        CMnotify(player, "الرجاء عدم عمل سبام")
    end
end
vRP.registerMenuBuilder(
    {
        "admin",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            if user_id ~= nil then
                local choices = {}
                if TicketsStatus == true then
                    choices[CMamAV4.CallAdmin.calladmin.name] = {CMam_AdminTickets}
                    choices[CMamAV4.CallAdmin.calladminGroup.name] = {CMam_AdminTicketsGroup}
                end

                add(choices)
            end
        end
    }
)

Spamlogin = {}
join = true
left = false
local function CMam_Login(player, choice)
    local user_id = vRP.getUserId({player})
    if Spamlogin[user_id] ~= true then
        Spamlogin[user_id] = true
        for k, v in pairs(CMamAV4.Attendance.Groups) do
            if vRP.hasGroup({user_id, v.Groupfake}) then
                Login1 = not Login1
                if Login1 then
                    vRP.addUserGroup({user_id, v.Group})
                    TriggerClientEvent(
                        "chatMessage",
                        tonumber("-1"),
                        "^2 " ..
                            CMam.Settings.Server .. " : ^0 سجل دخوله للمدينة " .. GetPlayerName(player) .. " الادمن"
                    )
                    CMnotify(player, "تم تسجيل دخولك بنجاح")
                    join = false
                    left = true
                    local idle_copy = {model = v.Skinlogin}
                    for i = 0, 300 do
                        idle_copy[i] = {0, 0}
                    end
                    vRPclient.setCustomization(player, {idle_copy})
                    CMam_Webhook(
                        0,
                        CMamAV4.Attendance.login,
                        "** Admin: `" ..
                            GetPlayerName(player) ..
                                "`  ID: `" .. user_id .. "` \n Admin Group:** **`" .. v.NameLog .. "`  **",
                        "Login"
                    )
                else
                    vRP.removeUserGroup({user_id, v.Group})
                    TriggerClientEvent(
                        "chatMessage",
                        tonumber("-1"),
                        "^8 " ..
                            CMam.Settings.Server .. " : ^0 سجل خروجه للمدينة " .. GetPlayerName(player) .. " الادمن"
                    )
                    CMnotify(player, "تم تسجيل خروجك بنجاح")
                    join = true
                    left = false
                    CMam_Webhook(
                        0,
                        CMamAV4.Attendance.Logout,
                        "** Admin: `" ..
                            GetPlayerName(player) ..
                                "`  ID: `" .. user_id .. "` \n Admin Group:** **`" .. v.NameLog .. "`  **",
                        "Logout"
                    )
                end
                SetTimeout(
                    CMam.Settings.Control.Spams.Login * 1000,
                    function()
                        Spamlogin[user_id] = false
                    end
                )
            end
        end
    else
        CMnotify(player, "الرجاء عدم عمل سبام")
    end
end

vRP.registerMenuBuilder(
    {
        "admin",
        function(add, data)
            local user_id = vRP.getUserId({data.player})
            for k, v in pairs(CMamAV4.Attendance.Groups) do
                if user_id ~= nil then
                    local choices = {}
                    if vRP.hasGroup({user_id, v.Groupfake}) then
                        if join == true then
                            choices["!-تسجيل دخول-!"] = {CMam_Login, "Made By xM7mD#0001"}
                        end
                        if left == true then
                            choices["!-تسجيل خروج-!"] = {CMam_Login, "Made By xM7mD#0001"}
                        end
                    end
                    add(choices)
                end
            end
        end
    }
)

function CMam_Webhook(color, link, message, Name)
    local content = {
        {
            ["color"] = color,
            ["title"] = "**" .. Name .. "**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "" .. a .. " | Today at " .. os.date("!%H:%M:%S | %x"),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/656267412458438666/989989598782447616/Creativity-02.png"
            }
        }
    }
    PerformHttpRequest(
        link,
        function(err, text, headers)
        end,
        "POST",
        json.encode(
            {
                username = a,
                avatar_url = "https://cdn.discordapp.com/attachments/656267412458438666/989989598782447616/Creativity-02.png",
                embeds = content
            }
        ),
        {["Content-Type"] = "application/json"}
    )
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