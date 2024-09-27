function love.load()
  
    love.window.setTitle("Ejemplo")
    
    love.graphics.setBackgroundColor(1, 1, 1)
    spaceshipImage = love.graphics.newImage("sprites/walk/basil.png")

    playerPosx = 0
    playerPosY = 0
    playerAngle = 0
    playerWitdh = spaceshipImage:getWidth()
    playerHeight = spaceshipImage:getHeight()
    playerSpeed = 100.0
  
  end
  
  
  function love.update(dt)
    
    mousex = 0
    mousey = 0

    mousex, mousey = love.mouse.getPosition()

    if love.keyboard.isDown("right") then
      playerPosx = playerPosx + playerSpeed * dt
    end
    
    if love.keyboard.isDown("left") then
      playerPosx = playerPosx - playerSpeed * dt
    end
    
    if love.keyboard.isDown("up") then
      playerPosY = playerPosY - playerSpeed * dt
    end
    
    if love.keyboard.isDown("down") then
      playerPosY = playerPosY + playerSpeed * dt
    end

    playerAngle = math.atan2(mousex - playerPosx, mousey - playerPosY)

  end
  
  
  function love.draw()

    love.graphics.setBackgroundColor(0,0,0)
    love.graphics.setColor(1, 0, 0)
    love.graphics.draw(spaceshipImage, playerPosx, playerPosY, playerAngle, 1, 1, playerWitdh / 2, playerHeight / 2)
  
  end
  