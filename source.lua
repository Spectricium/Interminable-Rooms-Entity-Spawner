local spawner = {}
local function convertToAsset(str)
    if isfile(str) then
        return Functions.GetAsset(str)
        
    elseif str:find("rbxassetid") or tonumber(str) then
        local numberId = str:gsub("%D", "")
        return "rbxassetid://".. numberId
        
    elseif str:find("http") then
        local req = Functions.Request({Url=str, Method="GET"})
        
        if req.Success then
            local name = "customObject_".. tick().. ".txt"
            writefile(name, req.Body)
            return Functions.GetAsset(name)
        end
    end

    return str
end
spawner.LoadCustomInstance = function(str)
    if str ~= "" then
        local asset = convertToAsset(str)
        local success, result = pcall(function()
            return game:GetObjects(asset)[1]
        end)
    
        if success then
            return result
        end
    end

    warn("Something went wrong attempting to load custom instance")
end
function loadSound(soundData)
    local sound = Instance.new("Sound")
    local soundId = tostring(soundData[1])
    local properties = soundData[2]
    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" then
            sound[i] = v
        end
    end
    if soundId:find("rbxasset://") then
        sound.SoundId = soundId
    else
        local numberId = soundId:gsub("%D", "")
        sound.SoundId = "rbxassetid://".. numberId
    end
    sound.Parent = workspace
    return sound
end
spawner.createEntity = function(config)
config.Speed = 60 / 100 * config.Speed
--model
local entityModel = LoadCustomInstance(config.Model)
if typeof(entityModel) == "Instance" and entityModel.ClassName == "Model" then
entityModel.PrimaryPart = entityModel.PrimaryPart or entityModel:FindFirstChildWhichIsA("BasePart")
if entityModel.PrimaryPart then
            entityModel.PrimaryPart.Anchored = true
            if config.CustomName then
                entityModel.Name = config.CustomName
            end
            entityModel:SetAttribute("IsCustomEntity", true)
            entityModel:SetAttribute("NoAI", false)
            local entityTable = {
                Model = entityModel,
                Config = config,
                Debug = {
                    OnEntitySpawned = function() end,
                    OnEntityDespawned = function() end,
                    OnEntityStartMoving = function() end,
                    OnEntityFinishedRebound = function() end,
                    OnEntityEnteredRoom = function() end,
                    OnLookAtEntity = function() end,
                    OnDeath = function() end
                }
            }

            return entityTable
        end

end
end
spawner.runEntity = function(entityTable)
local nodes = {}

    for _, room in next, workspace.MonsterMove2Parts:GetChildren() do
       table.insert(nodes,v.Name)
        end
local entityModel = entityTable.Model:Clone()
local spawnerpos = math.min(table.unpack(nodes))
entityModel:PivotTo(workspace.MonsterMove2Parts:FindFirstChild(spawnerpos))
local goal = math.max(table.unpack(nodes))
task.spawn(entityTable.Debug.OnEntitySpawned)
task.wait(entityTable.Config.DelayTime)
local distance = (workspace.MonsterMove2Parts:FindFirstChild(goal).Position - entityModel.PrimaryPart.Position).Magnitude
local delayed = distance / entityTable.Config.Speed
entityModel.Parent = workspace
local pepe = game:GetService("TweenService").Create(entityModel.PrimaryPart,TweenInfo.new(delayed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{Position = workspace.MonsterMove2Parts:FindFirstChild(goal).Position + Vector3.new(0,entityTable.Config.HeighOffset,0)})
pepe:Play()
pepe.Completed:Wait()
local pepe2 = game:GetService("TweenService").Create(entityModel.PrimaryPart,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{Position = entityModel.PrimaryPart.Position + Vector3.new(0,-30,0)})
pepe2:Play()
pepe2.Completed:Wait()
entityModel:Destroy()
end
return spawner
