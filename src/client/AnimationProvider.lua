local animationProvider = {}
-- dependencies --
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

-- public --
function animationProvider:getAnimationFromAsset(asset: Animation|KeyframeSequence): Animation
	if asset:IsA("Animation") then
		return asset
	elseif asset:IsA("KeyframeSequence") then
		local id = KeyframeSequenceProvider:RegisterKeyframeSequence(asset)
		local animation = Instance.new("Animation")
		animation.Name = asset.Name .. "FromKeySequence"
		animation.AnimationId = id
		return animation
	end
end

return animationProvider