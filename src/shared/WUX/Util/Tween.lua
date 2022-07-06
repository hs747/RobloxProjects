local TweenService = game:GetService("TweenService")

return function(object, tweenInfo, tweenData, playNow)
	local tween = TweenService:Create(object, tweenInfo, tweenData)
	if playNow then
		tween:Play()
	end
	return tween
end