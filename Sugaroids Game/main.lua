local gameState = "menu"
local buttonSelected = 1 

function love.load()
    love.window.setTitle("Sugaroids")
    love.graphics.setBackgroundColor(1, 1, 1)

    font = love.graphics.newFont("res/fonts/rubikBubbles/RubikBubbles-Regular.ttf", 24)

    spawnTimer = 0

    points = 0

    mainTitle = love.graphics.newImage("res/title.png")

    creditsMusic = love.audio.newSource("res/music/Game Over! - Harris Cole.mp3", "stream")
    mainMenuMusic = love.audio.newSource("res/music/yawgooh - falling apart - Lofi Girl Ambient.mp3", "stream")
    gameOverMusic = love.audio.newSource("res/music/JEN - QUIET NIGHTS - soulmate.mp3", "stream")
    gamePlayMusic = love.audio.newSource("res/music/JEN - FACADE - soulmate.mp3", "stream")

    hurtSound = love.audio.newSource("res/soundEffects/hurt.wav", "stream")
    boomSound = love.audio.newSource("res/soundEffects/boom.wav", "stream")
    dieSound = love.audio.newSource("res/soundEffects/die.wav", "stream")
    shootSound = love.audio.newSource("res/soundEffects/shoot.wav", "stream")

    confirmMenu = love.graphics.newImage("res/sprites/menu/confirm.png")
    menuMove = love.graphics.newImage("res/sprites/menu/menuMove.png")
    spaceshipImage = love.graphics.newImage("res/sprites/player/spaceship.png")
    sugaroidImage = love.graphics.newImage("res/sprites/enemies/sugaroid.png")
    backgroundImage = love.graphics.newImage("res/backgrounds/pacific.jfif")  
    bulletsImage = love.graphics.newImage("res/sprites/bullets/star.png")


    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact)


    player = {
        image = spaceshipImage,
        lives = 3,
        width = 64 * 1.5,
        height = 64 * 1.5,
        speed = 150.0
    }
    
    playerBody = love.physics.newBody(world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, "dynamic")
    playerShape = love.physics.newCircleShape(player.width / 3) 
    playerFixture = love.physics.newFixture(playerBody, playerShape)
    playerFixture:setUserData("Player")

    gameOverMusic:setLooping(true)
    gamePlayMusic:setLooping(true)

    sugaroids = {}
    bullets = {}
end

function love.update(dt)

    if gameState == "menu" and not mainMenuMusic:isPlaying() then

        love.audio.stop(gamePlayMusic)
        love.audio.stop(gameOverMusic)
        love.audio.stop(creditsMusic)
        mainMenuMusic:seek(0)
        love.audio.play(mainMenuMusic)

    elseif gameState == "credits" and not creditsMusic:isPlaying() then

        love.audio.stop(gamePlayMusic)
        love.audio.stop(gameOverMusic)
        love.audio.stop(mainMenuMusic)
        creditsMusic:seek(0)
        love.audio.play(creditsMusic)

    elseif gameOver and not gameOverMusic:isPlaying() and not dieSound:isPlaying() then

        love.audio.stop(creditsMusic)
        love.audio.stop(gamePlayMusic)
        love.audio.stop(mainMenuMusic)
        gameOverMusic:seek(0)
        love.audio.play(gameOverMusic)

    elseif not gameOver and gameState == "playing" and not gamePlayMusic:isPlaying() then
        love.audio.stop(creditsMusic)
        love.audio.stop(gameOverMusic)
        love.audio.stop(mainMenuMusic)
        gamePlayMusic:seek(0)
        love.audio.play(gamePlayMusic)
    end

    if gameState == "playing" then
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

        -- Update Sugaroid movements and destroy if needed
        for i = #sugaroids, 1, -1 do
            local sugaroid = sugaroids[i]

        
            if sugaroid.toDestroy then
                sugaroid.body:destroy()
                table.remove(sugaroids, i)
            elseif sugaroid.body:getX() < -50 or sugaroid.body:getX() > love.graphics.getWidth() + 50 or
                   sugaroid.body:getY() < -50 or sugaroid.body:getY() > love.graphics.getHeight() + 50 then
                sugaroid.body:destroy()
                table.remove(sugaroids, i)
                points = points + 5
            end
        end

        for i = #bullets, 1, -1 do
            local bullet = bullets[i]
        

            if bullet.toDestroy then
                bullet.body:destroy()
                table.remove(bullets, i)
        

            elseif bullet.body:getX() < -50 or bullet.body:getX() > love.graphics.getWidth() + 50 or
                   bullet.body:getY() < -50 or bullet.body:getY() > love.graphics.getHeight() + 50 then
                bullet.body:destroy()
                table.remove(bullets, i)
            end
        end
        
    end
end


function love.draw()

    love.graphics.draw(backgroundImage, 0, 0)

    if gameState == "menu" then

        drawMenu()

    elseif gameState == "rules" then

        drawRules()

    elseif gameState == "playing" then

        if gameOver then

            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
            love.graphics.setColor(1, 1, 1)

            drawGameOverButtons()
            return
        end
        
        drawGamePlay()

    elseif gameState == "pause" then
        drawGamePlay()
        drawPauseMenu()

    elseif gameState == "credits" then
        drawCredits()

    end
end

function drawGamePlay()


    for _, bullet in ipairs(bullets) do
        love.graphics.draw(bulletsImage, bullet.body:getX(), bullet.body:getY(), 0, bullet.size / bulletsImage:getWidth(), bullet.size / bulletsImage:getHeight(), bulletsImage:getWidth() / 2, bulletsImage:getHeight() / 2)
    end

   
    love.graphics.draw(spaceshipImage, playerBody:getX(), playerBody:getY(), playerBody:getAngle(), player.width / spaceshipImage:getWidth(), player.height / spaceshipImage:getHeight(), spaceshipImage:getWidth() / 2, spaceshipImage:getHeight() / 2)

 
    for _, sugaroid in ipairs(sugaroids) do
        love.graphics.draw(sugaroidImage, sugaroid.body:getX(), sugaroid.body:getY(), 0, sugaroid.size / sugaroidImage:getWidth(), sugaroid.size / sugaroidImage:getHeight(), sugaroidImage:getWidth() / 2, sugaroidImage:getHeight() / 2)
    end

    drawHUD()
end

function drawPauseMenu()
    love.graphics.setColor(0, 0, 0, 0.7) 
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1) 
    love.graphics.setFont(font)

 
    love.graphics.printf("PAUSE", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")


    local pauseMenuButtons = { "Continue", "Restart", "Menu", "Exit" }
    for i, button in ipairs(pauseMenuButtons) do
        if i == buttonSelected then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(1, 1, 1) 
        end
        love.graphics.printf(button, 0, love.graphics.getHeight() / 2 + (i - 2) * 40, love.graphics.getWidth(), "center")
    end

    love.graphics.setColor(1, 1, 1)
end

function drawRules() 
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font)
    
    -- Title
    love.graphics.printf("Game Rules", 0, love.graphics.getHeight(), love.graphics.getWidth(), "center")

    -- Controls
    love.graphics.printf("Controls:", 0, love.graphics.getHeight() / 6 - 80, love.graphics.getWidth(), "center")
    love.graphics.printf("Up Arrow: Move Up", 0, love.graphics.getHeight() / 6 - 40, love.graphics.getWidth(), "center")
    love.graphics.printf("Down Arrow: Move Down", 0, love.graphics.getHeight() / 6, love.graphics.getWidth(), "center")
    love.graphics.printf("Left Arrow: Move Left", 0, love.graphics.getHeight() / 6 + 40, love.graphics.getWidth(), "center")
    love.graphics.printf("Right Arrow: Move Right", 0, love.graphics.getHeight() / 6 + 80, love.graphics.getWidth(), "center")
    love.graphics.printf("Left Click: Fire", 0, love.graphics.getHeight() / 6 + 120, love.graphics.getWidth(), "center")
    love.graphics.printf("ESC: Pause", 0, love.graphics.getHeight() / 6 + 160, love.graphics.getWidth(), "center")
    
    -- Points / lifes
    love.graphics.printf("Points for destroying sugaroids: 25", 0, love.graphics.getHeight() / 6 + 240, love.graphics.getWidth(), "center")
    love.graphics.printf("Points for avoiding sugaroids: 5", 0, love.graphics.getHeight() / 6 + 280, love.graphics.getWidth(), "center")
    love.graphics.printf("You start with 3 lives.", 0, love.graphics.getHeight() / 6 + 340, love.graphics.getWidth(), "center")
    love.graphics.printf("Lose all lives to end the game.", 0, love.graphics.getHeight() / 6 + 380, love.graphics.getWidth(), "center")

    love.graphics.printf("Press ESC to return to menu", 0, love.graphics.getHeight() - 60, love.graphics.getWidth(), "center")

    love.graphics.setColor(1, 1, 1)
end




function drawGameOverButtons()
    love.graphics.setColor(0, 0, 0) 
    love.graphics.setFont(font)

    local buttons = { "Replay", "Menu", "Exit" }
    for i, button in ipairs(buttons) do
        if i == buttonSelected then
            love.graphics.setColor(1, 0, 0) 
        else
            love.graphics.setColor(0, 0, 0) 
        end
        love.graphics.printf(button, 0, love.graphics.getHeight() / 2 + (i * 30), love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1)
end

function drawMenu()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)

    -- Adapt Main Title Size
    local scaleX = love.graphics.getWidth() / mainTitle:getWidth()
    local scaleY = love.graphics.getHeight() / mainTitle:getHeight()
    local scale = math.min(scaleX, scaleY) 

    -- Center Title
    local drawX = (love.graphics.getWidth() - (mainTitle:getWidth() * scale)) / 2
    local drawY = (love.graphics.getHeight() / 2 - (mainTitle:getHeight() * scale)) / 2

   
    love.graphics.draw(mainTitle, drawX, drawY, 0, scale, scale)

   
    local confirmX = 10 
    local confirmY = love.graphics.getHeight() - 100 - 10 

    local menuMoveX = confirmX + 100 + 10 
    local menuMoveY = confirmY 

   
    love.graphics.draw(confirmMenu, confirmX, confirmY, 0, 100 / confirmMenu:getWidth(), 100 / confirmMenu:getHeight())

    love.graphics.draw(menuMove, menuMoveX, menuMoveY, 0, 100 / menuMove:getWidth(), 100 / menuMove:getHeight())

   
    local buttons = { "Play", "Rules","Credits", "Exit" }
    for i, button in ipairs(buttons) do
        if i == buttonSelected then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(0, 0, 0) 
        end
        love.graphics.printf(button, 0, love.graphics.getHeight() / 2 + (i - 2) * 30, love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1)  
end


function drawHUD()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font) 
    love.graphics.print("Vidas: " .. player.lives, 10, 10)
    love.graphics.print("Points: " .. points, 10, 50)
    love.graphics.setColor(1, 1, 1) 
end

function drawCredits()
    love.graphics.setColor(0, 0, 0) 
    love.graphics.setFont(font)

    love.graphics.printf("Credits", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")

 
    love.graphics.printf("Developer: Lucio Stefano Piccioni.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")

 
    love.graphics.printf("Music:", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
    love.graphics.printf("1. 'Game Over!' - Harris Cole", 0, love.graphics.getHeight() / 2 + 70, love.graphics.getWidth(), "center")
    love.graphics.printf("2. 'Falling Apart' - yawgooh (Lofi Girl Ambient)", 0, love.graphics.getHeight() / 2 + 90, love.graphics.getWidth(), "center")
    love.graphics.printf("3. 'Quiet Nights' - JEN", 0, love.graphics.getHeight() / 2 + 110, love.graphics.getWidth(), "center")
    love.graphics.printf("4. 'Facade' - JEN", 0, love.graphics.getHeight() / 2 + 130, love.graphics.getWidth(), "center")

    love.graphics.printf("Sound Effects:", 0, love.graphics.getHeight() / 2 + 160, love.graphics.getWidth(), "center")
    love.graphics.printf("  ChipTone", 0, love.graphics.getHeight() / 2 + 180, love.graphics.getWidth(), "center")


    love.graphics.printf("Press ESC to go back to the Menu.", 0, love.graphics.getHeight() / 2 + 210, love.graphics.getWidth(), "center")

    love.graphics.setColor(1, 1, 1) 
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not gameOver and gameState == "playing" then  
        shootSound:stop()
        shootSound:play()
        spawnStarBullet()
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "up" then
            buttonSelected = (buttonSelected - 1) < 1 and 4 or buttonSelected - 1  
        elseif key == "down" then
            buttonSelected = (buttonSelected + 1) > 4 and 4 or buttonSelected + 1  
        elseif key == "return" then
            if buttonSelected == 1 then
                resetGame()
                gameState = "playing"
                gameOver = false 
            elseif buttonSelected == 2 then
                gameState = "rules"
            elseif buttonSelected == 3 then
                gameState = "credits" 
            elseif buttonSelected == 4 then
                love.event.quit()  
            end
        end
    elseif gameState == "credits" then
        if key == "escape" then
            gameState = "menu"  
        end
    elseif gameState == "rules" then
        if key == "escape" then
            gameState = "menu"  
        end
    elseif gameOver then 
        if key == "up" then
            buttonSelected = (buttonSelected - 1) < 1 and 3 or buttonSelected - 1 
        elseif key == "down" then
            buttonSelected = (buttonSelected + 1) > 3 and 1 or buttonSelected + 1  
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
    elseif gameState == "playing" then
        if key == "escape" then
            gameState = "pause"  
        end
    elseif gameState == "pause" then
        if key == "up" then
            buttonSelected = (buttonSelected - 1) < 1 and 4 or buttonSelected - 1
        elseif key == "down" then
            buttonSelected = (buttonSelected + 1) > 4 and 1 or buttonSelected + 1
        elseif key == "return" then
            if buttonSelected == 1 then
                gameState = "playing"  
            elseif buttonSelected == 2 then
                resetGame()  
                gameState = "playing"
            elseif buttonSelected == 3 then
                gameState = "menu"  
            elseif buttonSelected == 4 then
                love.event.quit()  
            end
        elseif key == "escape" then
            gameState = "playing" 
        end 
    end
end

function resetGame()
    
    for _, sugaroid in ipairs(sugaroids) do
        sugaroid.body:destroy()
    end


    for _, bullet in ipairs(bullets) do
        bullet.body:destroy()
    end

  
    sugaroids = {}
    bullets = {}

    
    player.lives = 3
    player.width = 64 * 1.5
    player.height = 64 * 1.5
    player.speed = 150.0


    playerBody:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    playerBody:setLinearVelocity(0, 0)  
    playerBody:setAngularVelocity(0)  

  
    spawnTimer = 0

    points = 0

    
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
  
    local sugaroidBody = love.physics.newBody(world, x, y, "dynamic")
    local sugaroidShape = love.physics.newCircleShape(16) 
    local sugaroidFixture = love.physics.newFixture(sugaroidBody, sugaroidShape)
    sugaroidFixture:setUserData("Sugaroid")

 
    sugaroidFixture:setCategory(2)
    sugaroidFixture:setMask(2)  

  
    local directionX = playerBody:getX() - x
    local directionY = playerBody:getY() - y
    local length = math.sqrt(directionX^2 + directionY^2)

    local speed = love.math.random(100, 200)

    if length > 0 then
        sugaroidBody:setLinearVelocity((directionX / length) * speed, (directionY / length) * speed)
    end

    table.insert(sugaroids, { body = sugaroidBody, shape = sugaroidShape, fixture = sugaroidFixture, toDestroy = false, size = size})
end

function spawnStarBullet()

    local size = 32 

  
    local starBody = love.physics.newBody(world, playerBody:getX(), playerBody:getY(), "dynamic")
    local starShape = love.physics.newCircleShape(16) 
    local starFixture = love.physics.newFixture(starBody, starShape) 
    starFixture:setUserData("starBullet")

   
    starFixture:setCategory(1)
    starFixture:setMask(1)

  
    local playerAngle = playerBody:getAngle()  
    local directionX = math.cos(playerAngle)   
    local directionY = math.sin(playerAngle)   
    local length = math.sqrt(directionX^2 + directionY^2)

    local speed = 500

   
    if length > 0 then
        starBody:setLinearVelocity((directionX / length) * speed, (directionY / length) * speed)
    end

   
    table.insert(bullets, { body = starBody, shape = starShape, fixture = starFixture, toDestroy = false, size = size})
end


function beginContact(a, b, coll)
    
    coll:setEnabled(false)

   
    if (a:getUserData() == "Player" and b:getUserData() == "Sugaroid") or
       (a:getUserData() == "Sugaroid" and b:getUserData() == "Player") then

        
        player.lives = player.lives - 1

      
        local sugaroidBody = (a:getUserData() == "Sugaroid") and a:getBody() or b:getBody()

        for i, sugaroid in ipairs(sugaroids) do
            if sugaroid.body == sugaroidBody then
                sugaroid.body:destroy()
                table.remove(sugaroids, i)
                break
            end
        end

        if not gameOver then
            hurtSound:stop()
            hurtSound:play()
        end

       
        if player.lives <= 0 then

            if not gameOver then
                dieSound:stop()
                dieSound:play()
            end

            gameOver = true
        end

    elseif (a:getUserData() == "starBullet" and b:getUserData() == "Sugaroid") or
           (a:getUserData() == "Sugaroid" and b:getUserData() == "starBullet") then

       
        local sugaroidBody = (a:getUserData() == "Sugaroid") and a:getBody() or b:getBody()
        local starBody = (a:getUserData() == "starBullet") and a:getBody() or b:getBody()

        for i, sugaroid in ipairs(sugaroids) do
            if sugaroid.body == sugaroidBody then
                sugaroid.body:destroy()
                table.remove(sugaroids, i)
                break
            end
        end

        for i, bullet in ipairs(bullets) do
            if bullet.body == starBody then
                bullet.body:destroy()
                table.remove(bullets, i)
                break
            end
        end

        boomSound:stop()
        boomSound:play()

        points = points + 25
    end

end