local Player = {}
Player.__index = Player

local Track = require(script.Track)

local Render = {}

function Player.newAnimator(Character : Model)
	local Transform = {}

	for _, Motor in Character:GetDescendants() do 
		if Motor:IsA("Motor6D") then 
			Transform[Motor.Part1] = {
				Object = Motor,
				Index = 1,
				Skip = 1,
				Alpha = 0,
			}
		end
	end

	return setmetatable({
		Transform = Transform,
		Character = Character
	}, Player)
end

function Player:LoadAnimation(KeyframeSequence : KeyframeSequence)
	local NewTrack = Track.new(self.Transform, self.Character, KeyframeSequence)
	
	table.insert(Render, NewTrack)
	
	
	return NewTrack
end

game:GetService("RunService").RenderStepped:Connect(function(DeltaTime : number)
	local Camera = workspace.CurrentCamera
	for _, Track in Render do 
		Track:_update(DeltaTime)
	end
end)

return Player
