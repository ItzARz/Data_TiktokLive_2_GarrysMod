if SERVER then
    require("gwsockets")
    print("Modsito Tisto")

    local isCooldownTime = false
    local isNPCSpawningTime = false
    local cooldownDuration = 30 -- Duración del cooldown en segundos
    local npcSpawningDuration = 60 -- Duración del tiempo de spawn de NPCs en segundos
    local socket = GWSockets.createWebSocket("ws://127.0.0.1:8080")
    local cooldownEndTime = 0 -- Tiempo de finalización del cooldown

    util.AddNetworkString("CooldownTimer") -- Registra la red "CooldownTimer" para la comunicación
    util.AddNetworkString("NPCSpawningTimer") -- Registra la red "CooldownTimer" para la comunicación

    function spawnZombie(comment)
        local minBounds = Vector(-700, -700, 0) -- Límites mínimos
        local maxBounds = Vector(700, 700, 0) -- Límites máximos

        local xPos = math.random(minBounds.x, maxBounds.x)
        local yPos = math.random(minBounds.y, maxBounds.y)
        local zPos = math.random(minBounds.z, maxBounds.z)

        local npc = ents.Create("npc_vj_l4d_com_m_airport")
        npc:SetPos(Vector(xPos, yPos, zPos)) -- Establece la posición aleatoria donde deseas spawnear el zombie

        -- Asigna un nombre personalizado al zombie utilizando una etiqueta
        local usertiktok = string.match(comment, "^(.-)%s*->")
        npc:SetNWString("CustomName", usertiktok)
        npc:Spawn()
    end

    function startNPCSpawningTimer()
        if not isNPCSpawningTime then
            isNPCSpawningTime = true
            print("Iniciando el temporizador de spawn de NPCs...")

            npcSpawningEndTime = CurTime() + npcSpawningDuration
            net.Start("NPCSpawningTimer")
            net.WriteBool(true) -- Envía un booleano indicando que se inició el tiempo de spawn de NPCs
            net.WriteFloat(npcSpawningEndTime) -- Envía el tiempo de finalización del tiempo de spawn de NPCs
            net.Broadcast() -- Envía el mensaje a todos los clientes conectados

            timer.Create("NPCSpawningTimer", npcSpawningDuration, 1, function()
                isNPCSpawningTime = false
                startCooldownTimer()
            end)
        else
            print("El temporizador de spawn de NPCs ya está en marcha.")
        end
    end

    function startCooldownTimer()
        isCooldownTime = true
        net.Start("CooldownTimer")
        net.WriteBool(true) -- Envía un booleano indicando que se inició el cooldown
        cooldownEndTime = CurTime() + cooldownDuration
        net.WriteFloat(cooldownEndTime) -- Envía el tiempo de finalización del cooldown
        net.Broadcast() -- Envía el mensaje a todos los clientes conectados
        print("Iniciando el temporizador de cooldown...")
    end

    function stopCooldownTimer()
        isCooldownTime = false
        print("El cooldown ha finalizado.")
        startNPCSpawningTimer()
    end

    function killCooldownTimer()
        isCooldownTime = false
        net.Start("CooldownTimer")
        net.WriteBool(true) -- Envía un booleano indicando que se inició el cooldown
        cooldownEndTime = 0
        net.WriteFloat(cooldownEndTime) -- Envía el tiempo de finalización del cooldown
        net.Broadcast() -- Envía el mensaje a todos los clientes conectados
    end

    function killSpawningTimer()
        isNPCSpawningTime = false
        net.Start("NPCSpawningTimer")
        net.WriteBool(true) -- Envía un booleano indicando que se inició el cooldown
        npcSpawningEndTime = 0
        net.WriteFloat(npcSpawningEndTime) -- Envía el tiempo de finalización del cooldown
        net.Broadcast() -- Envía el mensaje a todos los clientes conectados
    end

    function socket:onMessage(comment)
        PrintMessage(HUD_PRINTTALK, comment)
        if isNPCSpawningTime then
            if not isCooldownTime then
                spawnZombie(comment)
            else
                print("Es tiempo de cooldown")
            end
        end
    end

    concommand.Add("connect_tiktok", function(ply, cmd, args)
        if not socket:isConnected() then
            socket:open()
            function socket:onConnected()
                print("Addon conectado a Socket-TikTok")
            end
            function socket:onDisconnected()
                print("Error de conexión Socket-TikTok")
            end
        else
            print("Addon YA conectado a SocketTikTok")
        end
    end)

    concommand.Add("disconnect_tiktok", function(ply, cmd, args)
        if socket:isConnected() then
            socket:close()
            print("Addon desconectado de Socket-TikTok")
            killCooldownTimer()
            killSpawningTimer()
        else
            print("Addon NO conectado a Socket-TikTok")
        end
    end)

    concommand.Add("start_timer", function(ply, cmd, args)
        startNPCSpawningTimer()
    end)

    hook.Add("Think", "CooldownTimer", function()
        if isCooldownTime and CurTime() >= cooldownEndTime then
            stopCooldownTimer()
        end
    end)
end

if CLIENT then

    local isCooldownActive = false
    local isNPCSpawningTimerActive = false
    local cooldownEndTime = 0
    local npcSpawningEndTime = 0
    local cooldownAlpha = 0
    local npcSpawningAlpha = 0
    
    surface.CreateFont("FuenteCustom", {
        font = "Gotham-Bold", 
        extended = false,
        size = 17,
        weight = 800,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("Enixe2", {
        font = "Enixe", 
        extended = false,
        size = 15,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("Enixe", {
        font = "Enixe", 
        extended = false,
        size = 35,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("Azonix", {
        font = "Azonix", 
        extended = false,
        size = 35,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("DewiBlack", {
        font = "RFDewiExpanded-Black", 
        extended = false,
        size = 90,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    local function DrawNPCNames()
        for _, npc in ipairs(ents.FindByClass("*")) do
            local name = npc:GetNWString("CustomName", "")
            -- Si el nombre del npc no está vacío, dibuja el nametag
            if name ~= "" then
                local pos = npc:GetPos() + Vector(0, 0, 80)
                local ang = LocalPlayer():EyeAngles()
                ang:RotateAroundAxis(ang:Forward(), 90)
                ang:RotateAroundAxis(ang:Right(), 90)


                local screenPos = pos:ToScreen()
                if screenPos.visible then
                    surface.SetFont("FuenteCustom")
                    local textWidth, textHeight = surface.GetTextSize(name)
                    local x = screenPos.x - textWidth / 2
                    local y = screenPos.y - textHeight / 2

                    draw.SimpleText(name, "FuenteCustom", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end
        end
    end

    function DrawNPCSpawningTimer()
        if isNPCSpawningTimerActive then
            local remainingTime = math.max(0, npcSpawningEndTime - CurTime())
            if remainingTime > 0 then
                local SpawningText = string.format("SPAWN TIME: %.1f", remainingTime)
                surface.SetFont("Enixe2")
                local textWidth, textHeight = surface.GetTextSize(SpawningText)
                local x = 20
                local y = 30
                draw.SimpleText(SpawningText, "Enixe2", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                isNPCSpawningTimerActive = false
            end
        end
    end

    function DrawCooldownTimer()
        if isCooldownActive then
            local remainingTime = math.max(0, cooldownEndTime - CurTime())
            if remainingTime > 0 then
                local cooldownText = string.format("COOLDOWN: %.1f", remainingTime)
                surface.SetFont("Enixe")
                local textWidth, textHeight = surface.GetTextSize(cooldownText)
                local x = (ScrW() - textWidth) / 2
                local y = 50
                draw.SimpleText(cooldownText, "Enixe", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                isCooldownActive = false
            end
        end
    end

    net.Receive("NPCSpawningTimer", function()
        local isNPCSpawningTimerStarted = net.ReadBool()
        npcSpawningEndTime = net.ReadFloat()

        if isNPCSpawningTimerStarted then
            isNPCSpawningTimerActive = true
        end
    end)

    net.Receive("CooldownTimer", function()
        local isCooldownStarted = net.ReadBool()
        cooldownEndTime = net.ReadFloat()

        if isCooldownStarted then
            isCooldownActive = true
        end
    end)

    hook.Add("HUDPaint", "DrawNPCNames", DrawNPCNames)
    hook.Add("HUDPaint", "DrawCooldownTimer", DrawCooldownTimer)
    hook.Add("HUDPaint", "DrawNPCSpawningTimer", DrawNPCSpawningTimer)

    local textX = -1900 -- Posición inicial en el eje X (fuera de la pantalla)
    local textY = 50 -- Posición fija en el eje Y
    local speed = 700 -- Velocidad de movimiento en píxeles por segundo

    hook.Add("HUDPaint", "MoveTextAnimation", function()
        -- Calcula la posición en función del tiempo transcurrido
        local deltaTime = RealFrameTime()
        textX = textX + (speed * deltaTime)

        -- Verifica si el texto ha salido completamente de la pantalla y lo reinicia en la posición inicial
        local textWidth = surface.GetTextSize("COOLDOWN TIME")
        if textX > ScrW()+1400 then
            textX = -textWidth
        end

        -- Dibuja el texto en la posición actualizada
        draw.SimpleText("COOLDOWN TIME  COOLDOWN TIME  COOLDOWN TIME", "DewiBlack", textX, textY, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("COOLDOWN TIME  COOLDOWN TIME  COOLDOWN TIME", "DewiBlack", textX+15, textY-5, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

end
