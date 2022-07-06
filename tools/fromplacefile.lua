---@diagnostic disable: undefined-global
-- Wafflechad's place file source code extractor
-- uses my folder layout

-- DO NOT DO THIS IF YOU HAVE UNSTAGED WORK IN THE PROJECT DIRECTORY --
local PLACE_FILE_PATH = "build.rbxlx"

local game = remodel.readPlaceFile(PLACE_FILE_PATH)

local sources = {
    {game.ReplicatedStorage.Source.Client, "src/client"},
    {game.ReplicatedStorage.Source.Shared, "src/shared"},
    {game.ServerStorage.Server, "src/server"},
    {game.ServerScriptService, "src/server_scripts"},
    {game.StarterPlayer.StarterPlayerScripts, "src/client_scripts"},
}

local fileWhitelist = {
    ["Folder"] = true,
    ["ModuleScript"] = true,
    ["Script"] = true,
    ["LocalScript"] = true,
}

local function toFileFromScript(script, path)
    remodel.writeFile(path, remodel.getRawProperty(script, "Source"))
end

local function toFile(instance, parentPath)
    print(parentPath)
    if not fileWhitelist[instance.ClassName] then
        return
    end
    local children = instance:GetChildren()
    local count = 0
    for _, child in ipairs(children) do
        if fileWhitelist[child.ClassName] then
            count = count + 1
        end
    end
    local path = (parentPath .. "/" .. instance.Name)
    if count > 0 then
        remodel.createDirAll(path)
        if instance.ClassName == "ModuleScript" then
            toFileFromScript(instance, path .. "/init.lua")
        elseif instance.ClassName == "Script" then
            toFileFromScript(instance, path .. "/init.server.lua")
        elseif instance.ClassName == "LocalScript" then
            toFileFromScript(instance, path .. "/init.client.lua")
        end
        for _, child in ipairs(children) do
            if fileWhitelist[child.ClassName] then
                toFile(child, path)
            end
        end
    else
        if instance.ClassName == "ModuleScript" then
            toFileFromScript(instance, path .. ".lua")
        elseif instance.ClassName == "Script" then
            toFileFromScript(instance, path .. ".server.lua")
        elseif instance.ClassName == "LocalScript" then
            toFileFromScript(instance, path .. ".client.lua")
        end
    end
end

for _, v in ipairs(sources) do
    for _, c in ipairs(v[1]:GetChildren()) do
        remodel.createDirAll(v[2])
        toFile(c, v[2]) 
    end
end