local gameState = "menu"  -- Estado del juego: "menu", "playing", "credits"
local buttonSelected = 1   -- Índice del botón seleccionado

function love.load()
    love.window.setTitle("Sugaroids")
    love.graphics.setBackgroundColor(1, 1, 1)

    -- Cargar la fuente
    font = love.graphics.newFont("res/fonts/rubikBubbles/RubikBubbles-Regular.ttf", 24)

    spawnTimer = 0

    spaceshipImage = love.graphics.newImage("res/sprites/player/spaceship.png")
    sugaroidImage = love.graphics.newImage("res/sprites/enemies/sugaroid.png")
    backgroundImage = love.graphics.newImage("res/backgrounds/pacific.jfif")  

    -- Configurar el mundo de física (sin gravedad)
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact)

    -- Inicializar el jugador
    player = {
        image = spaceshipImage,
        lives = 3,
        width = 64 * 1.5,
        height = 64 * 1.5,
        speed = 150.0
    }
    
    playerBody = love.physics.newBody(world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, "dynamic")
    playerShape = love.physics.newCircleShape(player.width / 3)  -- Usamos un círculo para colisiones
    playerFixture = love.physics.newFixture(playerBody, playerShape)
    playerFixture:setUserData("Player")

    sugaroids = {}
end

function love.update(dt)

        world:update(dt)

        -- Player movement
        if love.keyboard.isDown("right") then
            playerBody:setX(playerBody:getX() + player.speed * dt)
        elseif love.keyboard.isDown("left") then
            playerBody:setX(playerBody:getX() - player.speed * dt)
        end
        
        if love.keyboard.isDown("up") then
            playerBody:setY(playerBody:getY() - player.speed * dt)
        elseif love.keyboard.isDown("down") then
            playerBody:setY(playerBody:getY() + player.speed * dt)
        end

        -- Rotate player towards the mouse
        mouseX, mouseY = love.mouse.getPosition()
        local angle = math.atan2(mouseY - playerBody:getY(), mouseX - playerBody:getX())
        playerBody:setAngle(angle)

        -- Spawning sugaroids
        spawnTimer = spawnTimer + dt
        if spawnTimer > 1 then
            spawnSugaroid()
            spawnTimer = 0
        end

        -- Update sugaroid movements and destroy if needed
        for i = #sugaroids, 1, -1 do
            local sugaroid = sugaroids[i]

            -- Remove sugaroids marked for destruction
            if sugaroid.toDestroy then
                sugaroid.body:destroy()
                table.remove(sugaroids, i)
            elseif sugaroid.body:getX() < -50 or sugaroid.body:getX() > love.graphics.getWidth() + 50 or
                   sugaroid.body:getY() < -50 or sugaroid.body:getY() > love.graphics.getHeight() + 50 then
                sugaroid.body:destroy()
                table.remove(sugaroids, i)
            end
        end
end


function love.draw()
    love.graphics.draw(backgroundImage, 0, 0)

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "playing" then

        if gameOver then

            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
            love.graphics.setColor(1, 1, 1)

            drawGameOverButtons()
            return
        end
        
        -- Dibujar jugador
        love.graphics.draw(spaceshipImage, playerBody:getX(), playerBody:getY(), playerBody:getAngle(), player.width / spaceshipImage:getWidth(), player.height / spaceshipImage:getHeight(), spaceshipImage:getWidth() / 2, spaceshipImage:getHeight() / 2)

        -- Dibujar sugaroids
        for _, sugaroid in ipairs(sugaroids) do
            love.graphics.draw(sugaroidImage, sugaroid.body:getX(), sugaroid.body:getY(), 0, sugaroid.size / sugaroidImage:getWidth(), sugaroid.size / sugaroidImage:getHeight(), sugaroidImage:getWidth() / 2, sugaroidImage:getHeight() / 2)
        end

        drawHUD()

    elseif gameState == "credits" then
        drawCredits()
    end
end

function drawGameOverButtons()
    love.graphics.setColor(0, 0, 0)  -- Color negro para el texto
    love.graphics.setFont(font)

    local buttons = { "Rejugar", "Menu", "Salir" }
    for i, button in ipairs(buttons) do
        if i == buttonSelected then
            love.graphics.setColor(1, 0, 0)  -- Rojo para el botón seleccionado
        else
            love.graphics.setColor(0, 0, 0)  -- Negro para los demás
        end
        love.graphics.printf(button, 0, love.graphics.getHeight() / 2 + (i * 30), love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1)  -- Volver al color blanco
end

function drawMenu()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font)

    -- Dibujar título
    love.graphics.printf("Sugaroids", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")

    -- Botones
    local buttons = { "Play", "Credits", "Exit" }
    for i, button in ipairs(buttons) do
        if i == buttonSelected then
            love.graphics.setColor(1, 0, 0)  -- Rojo para el botón seleccionado
        else
            love.graphics.setColor(0, 0, 0)  -- Negro para los demás
        end
        love.graphics.printf(button, 0, love.graphics.getHeight() / 2 + (i - 2) * 30, love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1)  -- Volver al color blanco
end

function drawHUD()
    love.graphics.setColor(0, 0, 0)  -- Color negro para el texto
    love.graphics.setFont(font)  -- Usar la fuente personalizada
    love.graphics.print("Vidas: " .. player.lives, 10, 10)  -- Coordenadas (10, 10)
    love.graphics.setColor(1, 1, 1)  -- Volver al color blanco
end

function drawCredits()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font)
    love.graphics.printf("Creditos", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")
    love.graphics.printf("Developer: Lucio Stefano Piccioni.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    love.graphics.printf("Press ESC to go back to the Menu.", 0, love.graphics.getHeight() / 2 + 30, love.graphics.getWidth(), "center")
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "up" then
            buttonSelected = (buttonSelected - 1) < 1 and 3 or buttonSelected - 1  -- Ciclo hacia arriba
        elseif key == "down" then
            buttonSelected = (buttonSelected + 1) > 3 and 1 or buttonSelected + 1  -- Ciclo hacia abajo
        elseif key == "return" then
            if buttonSelected == 1 then
                resetGame()
                gameState = "playing"
                gameOver = false 
            elseif buttonSelected == 2 then
                gameState = "credits" 
            elseif buttonSelected == 3 then
                love.event.quit()  
            end
        end
    elseif gameState == "credits" then
        if key == "escape" then
            gameState = "menu"  -- Volver al menú
        end
    elseif gameOver then  -- Agregar esta condición para manejar el Game Over
        if key == "up" then
            buttonSelected = (buttonSelected - 1) < 1 and 3 or buttonSelected - 1  -- Ciclo hacia arriba
        elseif key == "down" then
            buttonSelected = (buttonSelected + 1) > 3 and 1 or buttonSelected + 1  -- Ciclo hacia abajo
        elseif key == "return" then
            if buttonSelected == 1 then
                resetGame()
                gameState = "playing"
                gameOver = false 
            elseif buttonSelected == 2 then
                gameState = "menu" 
                gameOver = false 
            elseif buttonSelected == 3 then
                love.event.quit() 
            end
        end
    end
end

function resetGame()
    -- Destruir todos los cuerpos de los sugaroids antes de reiniciar
    for _, sugaroid in ipairs(sugaroids) do
        sugaroid.body:destroy()
    end

    -- Limpiar la lista de sugaroids
    sugaroids = {}

    -- Reiniciar vidas y otras propiedades del jugador
    player.lives = 3
    player.width = 64 * 1.5
    player.height = 64 * 1.5
    player.speed = 150.0

    -- Reiniciar la posición del jugador
    playerBody:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    playerBody:setLinearVelocity(0, 0)  -- Reiniciar velocidad a 0
    playerBody:setAngularVelocity(0)  -- Reiniciar rotación a 0

    -- Reiniciar temporizador de spawn
    spawnTimer = 0

    -- Reiniciar el estado de gameOver
    gameOver = false
end



function spawnSugaroid()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local edge = love.math.random(1, 4)
    local x, y = 0, 0
    if edge == 1 then
        x = love.math.random(0, screenWidth)
        y = 0
    elseif edge == 2 then
        x = love.math.random(0, screenWidth)
        y = screenHeight
    elseif edge == 3 then
        x = 0
        y = love.math.random(0, screenHeight)
    elseif edge == 4 then
        x = screenWidth
        y = love.math.random(0, screenHeight)
    end

    local size = love.math.random(32, 64) 
    -- Crear un cuerpo para el sugaroid
    local sugaroidBody = love.physics.newBody(world, x, y, "dynamic")
    local sugaroidShape = love.physics.newCircleShape(16) 
    local sugaroidFixture = love.physics.newFixture(sugaroidBody, sugaroidShape)
    sugaroidFixture:setUserData("Sugaroid")

    -- Categoria de colision de los sugaroids (2) y mascara de colision para ignorar otros sugaroids
    sugaroidFixture:setCategory(2)
    sugaroidFixture:setMask(2)  -- Los sugaroids no colisionaran entre ellos

    -- Movimiento hacia el jugador
    local directionX = playerBody:getX() - x
    local directionY = playerBody:getY() - y
    local length = math.sqrt(directionX^2 + directionY^2)

    local speed = love.math.random(100, 200)

    if length > 0 then
        sugaroidBody:setLinearVelocity((directionX / length) * speed, (directionY / length) * speed)
    end

    table.insert(sugaroids, { body = sugaroidBody, shape = sugaroidShape, fixture = sugaroidFixture, toDestroy = false, size = size})
end

function beginContact(a, b, coll)

    -- Si el Player colisiona con un Sugaroid
    if (a:getUserData() == "Player" and b:getUserData() == "Sugaroid") or
       (a:getUserData() == "Sugaroid" and b:getUserData() == "Player") then

        -- Deshabilitar la transferencia de fuerza/impulso en la colision
        coll:setEnabled(false)

        -- Reducir la vida del jugador
        player.lives = player.lives - 1

        -- Marcar el sugaroid para ser destruido
        local sugaroidBody = (a:getUserData() == "Sugaroid") and a:getBody() or b:getBody()

        -- Buscar el sugaroid correspondiente y marcarlo para destruir
        for _, sugaroid in ipairs(sugaroids) do
            if sugaroid.body == sugaroidBody then
                sugaroid.toDestroy = true
                break
            end
        end

        -- Si las vidas del jugador llegan a 0, marcar game over
        if player.lives <= 0 then
            gameOver = true
        end
    end
end
