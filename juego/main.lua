function love.load()
  
    love.window.setTitle("Ejemplo")
    
    love.graphics.setBackgroundColor(1, 1, 1)
    spaceshipImage = love.graphics.newImage("sprites/walk/basil.png")
    
    posX = 0
    posY = 0
    angle = 0
  
    speed = 100.0
  
  end
  
  
  function love.update(dt)
    
    if love.keyboard.isDown("right") then
      posX = posX + speed * dt
    end
    
    if love.keyboard.isDown("left") then
      posX = posX - speed * dt
    end
    
    if love.keyboard.isDown("up") then
      posY = posY - speed * dt
    end
    
    if love.keyboard.isDown("down") then
      posY = posY + speed * dt
    end
    
  end
  
  
  function love.draw()

    love.graphics.setBackgroundColor(0,0,0)
    love.graphics.setColor(1, 0, 0)
    love.graphics.draw(spaceshipImage, posX, posY, angle)
  
  end
  