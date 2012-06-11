FPSCounter = class()

function FPSCounter:init()
    self.FPS = 60
    self.frames = 0
    self.time = 0
end

function FPSCounter:draw()
    self.time = self.time + DeltaTime    
    self.frames = self.frames + 1
    
    if self.time > 1 then
        self.FPS = self.frames
        self.time = self.time - 1
        self.frames = 0
    end
    
    fill(255)
    fontSize(20)
    text("FPS:" .. self.FPS, WIDTH - 50, 20)
end