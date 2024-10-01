function love.load()
    love.window.setTitle("Sugaroids")
    
    love.graphics.setBackgroundColor(1, 1, 1)
    spaceshipImage = love.graphics.newImage("res/sprites/player/spaceship.png")
    sugaroidImage = love.graphics.newImage("res/sprites/enemies/sugaroid.png")

    playerLives = 3
    playerPosX = 0
    playerPosY = 0
    playerAngle = 0
    playerWidth = 64  -- Establecer el ancho deseado
    playerHeight = 64 -- Establecer el alto deseado
    playerSpeed = 100.0

    sugaroids = {}
    spawnTimer = 0
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()

    if love.keyboard.isDown("right") then
        playerPosX = playerPosX + playerSpeed * dt
    end
    
    if love.keyboard.isDown("left") then
        playerPosX = playerPosX - playerSpeed * dt
    end
    
    if love.keyboard.isDown("up") then
        playerPosY = playerPosY - playerSpeed * dt
    end
    
    if love.keyboard.isDown("down") then
        playerPosY = playerPosY + playerSpeed * dt
    end

    playerAngle = math.atan2(mouseY - playerPosY, mouseX - playerPosX)

    spawnTimer = spawnTimer + dt
    if spawnTimer > 1 then
        spawnSugaroid()
        spawnTimer = 0
    end

    for i = #sugaroids, 1, -1 do
        local sugaroid = sugaroids[i]
        sugaroid.x = sugaroid.x + sugaroid.speedX * dt
        sugaroid.y = sugaroid.y + sugaroid.speedY * dt

        if sugaroid.x < -50 or sugaroid.x > love.graphics.getWidth() + 50 or
           sugaroid.y < -50 or sugaroid.y > love.graphics.getHeight() + 50 then
            table.remove(sugaroids, i)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.draw(spaceshipImage, playerPosX, playerPosY, playerAngle, playerWidth / spaceshipImage:getWidth(), playerHeight / spaceshipImage:getHeight(), playerWidth / 2, playerHeight / 2)

    for _, sugaroid in ipairs(sugaroids) do
        love.graphics.draw(sugaroid.image, sugaroid.x, sugaroid.y, 0, 32 / sugaroid.image:getWidth(), 32 / sugaroid.image:getHeight())
    end
end

function spawnSugaroid()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Decide desde qué borde aparecerá
    local edge = love.math.random(1, 4)  -- 1: arriba, 2: abajo, 3: izquierda, 4: derecha
    local sugaroid = {
        image = sugaroidImage,
        speedX = 0,
        speedY = 0,
        x = 0,
        y = 0,
    }

    if edge == 1 then  -- Desde arriba
        sugaroid.x = love.math.random(0, screenWidth)
        sugaroid.y = 0  -- Coordenada y en el borde superior
    elseif edge == 2 then  -- Desde abajo
        sugaroid.x = love.math.random(0, screenWidth)
        sugaroid.y = screenHeight  -- Coordenada y en el borde inferior
    elseif edge == 3 then  -- Desde la izquierda
        sugaroid.x = 0  -- Coordenada x en el borde izquierdo
        sugaroid.y = love.math.random(0, screenHeight)
    elseif edge == 4 then  -- Desde la derecha
        sugaroid.x = screenWidth  -- Coordenada x en el borde derecho
        sugaroid.y = love.math.random(0, screenHeight)
    end

    -- Calcular la dirección hacia el jugador
    local directionX = playerPosX - sugaroid.x
    local directionY = playerPosY - sugaroid.y
    local length = math.sqrt(directionX^2 + directionY^2)

    if length > 0 then
        sugaroid.speedX = (directionX / length) * 100  -- Ajusta la velocidad
        sugaroid.speedY = (directionY / length) * 100  -- Ajusta la velocidad
    end

    table.insert(sugaroids, sugaroid)
end
