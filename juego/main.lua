function love.load()
  
    love.window.setTitle("Sugaroids")
    
    love.graphics.setBackgroundColor(1, 1, 1)
    spaceshipImage = love.graphics.newImage("res/sprites/player/spaceship.png")

    playerPosX = 0
    playerPosY = 0
    playerAngle = 0
    playerWitdh = spaceshipImage:getWidth()
    playerHeight = spaceshipImage:getHeight()
    playerSpeed = 100.0
  
  end
  
  
  function love.update(dt)
    
    mouseX = 0
    mouseY = 0

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

  end
  
  
  function love.draw()

    love.graphics.setBackgroundColor(0,0,0)
    
    love.graphics.draw(spaceshipImage, playerPosX, playerPosY, playerAngle, 1, 1, playerWitdh / 2, playerHeight / 2)
  
  end
  