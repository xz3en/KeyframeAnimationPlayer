local Track = {}
Track.__index = Track

function Track.new(Transform : any, Character : Model, Sequence : KeyframeSequence)
	local NewTrack = setmetatable({}, Track)
	local TransformAmount = 0

	NewTrack.Playing = false
	NewTrack.Looped = false
	NewTrack.Speed = 1
	NewTrack.Character = Character
	
	for _ in Transform do 
		TransformAmount += 1
	end
	NewTrack.TransformAmount = TransformAmount
	
	NewTrack.Transform = Transform
	
	local SequenceSorted = {}
	
	for _, Object in Sequence:GetChildren() do 
		if Object:IsA("Keyframe") then
			table.insert(SequenceSorted, Object)
		end
	end
	
	table.sort(SequenceSorted, function(A, B)
		return A.Time < B.Time
	end)
	
	NewTrack.Keyframes = SequenceSorted
	
	return NewTrack
end

function Track:AdjustSpeed(Value : number)
	self.Speed = Value
end

function Track:Play()
	self.Speed = 1
	self.Playing = true
end

function Track:Stop()
	self.Playing = false
end

function Track:_update(DeltaTime : number)	
	local Keyframes = self.Keyframes
	
	local Finished = 0
	for Part1, Motor in self.Transform do 
		if Motor.Done then Finished += 1 continue end
		
		local CurrentKeyframe = Keyframes[Motor.Index]
		local NextKeyframe = Keyframes[Motor.Index + Motor.Skip]
		if not NextKeyframe then continue end
		
		local CurrentPose = CurrentKeyframe:FindFirstChild(Part1.Name, true)
		if not CurrentPose then continue end
		
		local NextPose = NextKeyframe:FindFirstChild(Part1.Name, true)
		if not NextPose then Motor.Skip += 1 continue end
		
		Motor.Skip = 1
		Motor.Alpha += DeltaTime * self.Speed
		
		local Alpha = Motor.Alpha / (NextKeyframe.Time - CurrentKeyframe.Time)
		
		if Alpha >= 1 then
			Motor.Alpha = 0
			Motor.Index += 1
			
			if not Keyframes[Motor.Index + Motor.Skip] then
				Motor.Done = true
			end
		end
		Motor.Object.C0 = CurrentPose.CFrame:Lerp(NextPose.CFrame, math.clamp(Alpha, 0, 1))
	end
	
	if Finished == self.TransformAmount then
		if self.Looped then
			for Part1, Motor in self.Transform do 
				Motor.Index = 1
				Motor.Skip = 1
				Motor.Done = false
				Motor.Alpha = 0
			end
		else 
			self.Playing = false
		end
	end
end

return Track
