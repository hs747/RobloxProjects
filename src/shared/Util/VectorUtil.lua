-- vector utilities
local vectorUtil = {}

local prismNormals = {} do
	for _, normalId in ipairs(Enum.NormalId:GetEnumItems()) do
		table.insert(prismNormals, {normalId, Vector3.fromNormalId(normalId)})
	end
end

function vectorUtil.getNormalIdFromLocalNormal(faceNormal: Vector3): Enum.NormalId
	-- find normal with maximum dot product of that normal & faceNormal
	local maxId, maxDot = nil, -1 -- there should always be at least one vector with a normal > 0?
	for _, n in ipairs(prismNormals) do
		local dot = faceNormal:Dot(n[2])
		if dot > maxDot then
			maxId = n[1]
			maxDot = dot
		end
	end
	return maxId, maxDot
end

function vectorUtil.getNormalIdFromGlobalNormal(partCFrame: CFrame, faceNormal: Vector3): Enum.NormalId
	local localizedFaceNormal = partCFrame:VectorToObjectSpace(faceNormal)
	return vectorUtil.getNormalIdFromLocalNormal(localizedFaceNormal)
end

function vectorUtil.getDimensionFromNormalId(part, normal)
	return part.Size * Vector3.new(math.abs(normal.X), math.abs(normal.Y), math.abs(normal.Z))
end

vectorUtil.transformVector = {
	flattenToXY = Vector3.new(1, 1, 0),
	flattenToXZ = Vector3.new(1, 0, 1),
	flattenToYZ = Vector3.new(0, 1, 1),
}

return vectorUtil