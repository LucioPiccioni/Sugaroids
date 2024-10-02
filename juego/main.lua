
function love.load()
    love.window.setTitle("Sugaroids")
    
    love.graphics.setBackgroundColor(1, 1, 1)
    spaceshipImage = love.graphics.newImage("res/sprites/player/spaceship.png")
    sugaroidImage = love.graphics.newImage("res/sprites/enemies/sugaroid.png")
    backgroundImage = love.graphics.newImage("res/backgrounds/pacific.jfif")  

    player = {
        lives = 3,
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        angle = 0,
        width = 64 * 1.5,
        height = 64 * 1.5,
        speed = 100.0
    }

    sugaroids = {}
    spawnTimer = 0
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()

    if love.keyboard.isDown("right") then
       if(player.x < love.graphics.getWidth()) then
        player.x = player.x + player.speed * dt
        end
    end
    
    if love.keyboard.isDown("left") then
        if(player.x > 0) then
            player.x = player.x - player.speed * dt
        end
    end
    
    if love.keyboard.isDown("up") then
        if(player.y > 0) then
            player.y = player.y - player.speed * dt
        end
    end
    
    if love.keyboard.isDown("down") then
        if(player.y < love.graphics.getHeight()) then
            player.y = player.y + player.speed * dt
        end
    end

    player.angle = math.atan2(mouseY - player.y, mouseX - player.x)

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
    love.graphics.draw(backgroundImage, 0, 0)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.draw(spaceshipImage, player.x, player.y, player.angle, player.width / spaceshipImage:getWidth(), player.height / spaceshipImage:getHeight(), spaceshipImage:getWidth() / 2, spaceshipImage:getHeight() / 2)

    for _, sugaroid in ipairs(sugaroids) do
        love.graphics.draw(sugaroid.image, sugaroid.x, sugaroid.y, sugaroid.angle, 32 / sugaroid.image:getWidth(), 32 / sugaroid.image:getHeight(), sugaroid.image:getWidth() / 2, sugaroid.image:getHeight() / 2)
    end
end

function spawnSugaroid()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Decide desde qué borde aparecerá
    local edge = love.math.random(1, 4)
    local sugaroid = {
        image = sugaroidImage,
        speedX = 0,
        speedY = 0,
        x = 0,
        y = 0,
        angle = love.math.random(0, 2 * math.pi)  -- Ángulo aleatorio en radianes
    }

    if edge == 1 then  -- Desde arriba
        sugaroid.x = love.math.random(0, screenWidth)
        sugaroid.y = 0
    elseif edge == 2 then  -- Desde abajo
        sugaroid.x = love.math.random(0, screenWidth)
        sugaroid.y = screenHeight
    elseif edge == 3 then  -- Desde la izquierda
        sugaroid.x = 0
        sugaroid.y = love.math.random(0, screenHeight)
    elseif edge == 4 then  -- Desde la derecha
        sugaroid.x = screenWidth
        sugaroid.y = love.math.random(0, screenHeight)
    end

    -- Calcular la dirección hacia el jugador
    local directionX = player.x - sugaroid.x
    local directionY = player.y - sugaroid.y
    local length = math.sqrt(directionX^2 + directionY^2)

    if length > 0 then
        sugaroid.speedX = (directionX / length) * 100
        sugaroid.speedY = (directionY / length) * 100
    end

    table.insert(sugaroids, sugaroid)
end
