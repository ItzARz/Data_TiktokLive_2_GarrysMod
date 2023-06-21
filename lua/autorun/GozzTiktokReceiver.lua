if SERVER then
    require("gwsockets")
    print("Modsito Tisto")

    local socket = GWSockets.createWebSocket("ws://127.0.0.1:8080")

    function spawnZombie(comment)
        local minBounds = Vector(-200, -200, 0) -- Límites mínimos
        local maxBounds = Vector(200, 200, 0) -- Límites máximos

        local xPos = math.random(minBounds.x, maxBounds.x)
        local yPos = math.random(minBounds.y, maxBounds.y)
        local zPos = math.random(minBounds.z, maxBounds.z)

        local npc = ents.Create("npc_vj_l4d_com_female")
        npc:SetPos(Vector(xPos, yPos, zPos)) -- Establece la posición aleatoria donde deseas spawnear el zombie

        -- Asigna un nombre personalizado al zombie utilizando una etiqueta
        local usertiktok = string.match(comment, "^(.-)%s*->")
        npc:SetNWString("CustomName", usertiktok)
        npc:Spawn()
        
    end

    function socket:onMessage(comment)
        PrintMessage(HUD_PRINTTALK, comment)
        spawnZombie(comment)
    end

    concommand.Add( "connect_tiktok", function( ply, cmd, args )
        if not socket:isConnected() then
            socket:open()
            function socket:onConnected()
                print("Addon conectado a Socket-TikTok")
            end
            function socket:onDisconnected()
                print("Error de conexión Socket-TikTok")
            end
        else
            print("Addon YA conectado a Socket-TikTok")
        end 
    end )

    concommand.Add( "disconnect_tiktok", function( ply, cmd, args)
        if socket:isConnected() then
            socket:close()
            print("Addon desconectado de Socket-TikTok")
        else
            print("Addon NO conectado a Socket-TikTok")
        end
    end )
end

if CLIENT then

    surface.CreateFont( "Gotham-Light", {
        font = "Gotham-LightItalic", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = 17,
        weight = 500,
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
    } )

    local function DrawNPCNames()
        for _, npc in ipairs(ents.FindByClass("npc_*")) do
            local name = npc:GetNWString("CustomName", "")
            -- Si el nombre del npc no está vacío, dibuja el nametag
            if name ~= "" then
                local pos = npc:GetPos() + Vector(0, 0, 80)
                local ang = LocalPlayer():EyeAngles()
                ang:RotateAroundAxis(ang:Forward(), 90)
                ang:RotateAroundAxis(ang:Right(), 90)

                local screenPos = pos:ToScreen()
                if screenPos.visible then
                    surface.SetFont("DermaDefault")
                    local textWidth, textHeight = surface.GetTextSize(name)
                    local x = screenPos.x - textWidth / 2
                    local y = screenPos.y - textHeight / 2

                    draw.SimpleText(name, "Gotham-Light", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end
        end
    end

    hook.Add("HUDPaint", "DrawNPCNames", DrawNPCNames)
end
