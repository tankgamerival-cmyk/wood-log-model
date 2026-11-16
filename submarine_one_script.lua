-- TWO-PERSON SUBMARINE: paste this entire Script into ServerScriptService.
-- Change this position BEFORE pressing Play. It is the centre of the hull.
local BEGIN_POSISIE = Vector3.new(0, 1.8, 0)
local MODEL_NAAM = "TwoPersonSubmarine_Procedural"

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Never delete or replace anything, even if another object uses this name.
if Workspace:FindFirstChild(MODEL_NAAM) then
    warn("Submarine not built: Workspace already contains " .. MODEL_NAAM .. ". Rename that object or change MODEL_NAAM in this script.")
    return
end

local model = Instance.new("Model")
model.Name = MODEL_NAAM
local basis = CFrame.new(BEGIN_POSISIE)
local donker = Color3.fromRGB(16, 30, 43)
local swart = Color3.fromRGB(7, 13, 19)
local staal = Color3.fromRGB(71, 95, 112)
local liggrys = Color3.fromRGB(151, 173, 184)
local sitplek = Color3.fromRGB(15, 43, 56)
local glas = Color3.fromRGB(43, 159, 190)
local blou = Color3.fromRGB(38, 217, 255)
local wit = Color3.fromRGB(200, 245, 255)

-- All coordinates below are relative to BEGIN_POSISIE. Bow faces -Z.
local function deel(ouer, naam, grootte, raam, kleur, materiaal, deursigtigheid, vorm, bots)
    local p = Instance.new("Part")
    p.Name = naam
    p.Size = grootte
    p.CFrame = basis * raam
    p.Color = kleur
    p.Material = materiaal or Enum.Material.Metal
    p.Transparency = deursigtigheid or 0
    p.Anchored = true
    p.CanCollide = bots == true
    p.CanTouch = false
    p.Shape = vorm or Enum.PartType.Block
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = ouer
    return p
end
local function blok(ouer, naam, x, y, z, sx, sy, sz, kleur, materiaal, bots)
    return deel(ouer, naam, Vector3.new(sx, sy, sz), CFrame.new(x, y, z), kleur, materiaal, 0, nil, bots)
end
local function bol(ouer, naam, x, y, z, sx, sy, sz, kleur, bots)
    return deel(ouer, naam, Vector3.new(sx, sy, sz), CFrame.new(x, y, z), kleur, Enum.Material.Metal, 0, Enum.PartType.Ball, bots)
end
-- Cylinders have a local X axis. lookAt uses local -Z, hence the quarter turn.
local function staaf(ouer, naam, a, b, deursnee, kleur, materiaal)
    local verskil = b - a
    if verskil.Magnitude < 0.001 then return nil end
    local raam = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0)
    return deel(ouer, naam, Vector3.new(verskil.Magnitude, deursnee, deursnee), raam, kleur, materiaal, 0, Enum.PartType.Cylinder, false)
end
local function silinderZ(ouer, naam, x, y, z, lengte, deursnee, kleur, materiaal)
    return deel(ouer, naam, Vector3.new(lengte, deursnee, deursnee), CFrame.new(x,y,z) * CFrame.Angles(0,math.pi/2,0), kleur, materiaal, 0, Enum.PartType.Cylinder, false)
end
local function ring(ouer, naam, x, y, z, radius, dikte, kleur, materiaal)
    local aantal = 12
    for i = 0, aantal - 1 do
        local a, b = 2*math.pi*i/aantal, 2*math.pi*(i+1)/aantal
        staaf(ouer, naam, Vector3.new(x+radius*math.cos(a),y+radius*math.sin(a),z), Vector3.new(x+radius*math.cos(b),y+radius*math.sin(b),z), dikte, kleur, materiaal)
    end
end

-- A low rounded pressure hull, a solid cabin floor, and raised side sills.
bol(model,"Rounded pressure hull",0,0,0,8.4,2.4,13.3,donker,true)
blok(model,"Cabin floor",0,0.82,-1.25,7.4,0.3,9.0,staal,Enum.Material.Metal,true)
for _, kant in ipairs({-1,1}) do
    blok(model,"Side sill",kant*3.95,0.76,-0.15,0.52,0.55,10.4,donker,nil,true)
    blok(model,"Pale side armour",kant*4.18,0.84,2.55,0.13,0.68,3.2,liggrys)
    blok(model,"Side marker",kant*4.27,0.87,3.3,0.08,0.14,0.8,blou,Enum.Material.Neon)
    staaf(model,"Side safety rail",Vector3.new(kant*4.10,1.35,-5.0),Vector3.new(kant*4.10,1.35,1.8),0.18,staal)
    for _, z in ipairs({-4.3,-2.4,-0.5,1.4}) do
        staaf(model,"Rail support",Vector3.new(kant*4.05,0.95,z),Vector3.new(kant*4.10,1.35,z),0.10,staal)
    end
end

-- Actual Roblox Seat parts: occupants face the bow (-Z). No vehicle controls.
for i, x in ipairs({-1.55,1.55}) do
    blok(model,"Seat pedestal",x,1.05,0.1,0.9,0.45,0.9,swart)
    local s = Instance.new("Seat")
    s.Name = i == 1 and "LeftSeat" or "RightSeat"
    s.Size = Vector3.new(1.35,0.3,1.65)
    s.CFrame = basis * CFrame.new(x,1.38,0.05)
    s.Color = sitplek; s.Material = Enum.Material.SmoothPlastic
    s.Anchored = true; s.CanCollide = true; s.CanTouch = true
    s.TopSurface = Enum.SurfaceType.Smooth; s.BottomSurface = Enum.SurfaceType.Smooth
    s.Parent = model
    blok(model,"Seat back",x,2.17,0.87,1.35,1.75,0.32,sitplek)
    blok(model,"Headrest",x,3.15,0.91,0.95,0.42,0.40,donker)
    for _, kant in ipairs({-1,1}) do
        blok(model,"Seat bolster",x+kant*0.70,1.63,0.12,0.16,0.38,1.4,donker)
        blok(model,"Seat blue trim",x+kant*0.55,2.25,0.68,0.06,0.65,0.05,blou,Enum.Material.Neon)
    end
end
blok(model,"Dashboard",0,1.18,-3.22,5.4,0.48,1.20,donker)
for _, x in ipairs({-1.55,1.55}) do
    local raam = CFrame.new(x,1.70,-3.48) * CFrame.Angles(math.rad(-12),0,0)
    deel(model,"Console screen",Vector3.new(1.25,0.80,0.10),raam,Color3.fromRGB(8,78,99),Enum.Material.Glass,0,nil,false)
    blok(model,"Console light",x,1.45,-2.75,0.70,0.05,0.14,blou,Enum.Material.Neon)
    for _, kant in ipairs({-1,1}) do
        staaf(model,"Control handle",Vector3.new(x+kant*0.45,1.35,-2.65),Vector3.new(x+kant*0.45,1.72,-2.45),0.09,staal)
    end
end

-- Protective bow, paired headlights, rear engine casing and beacon.
for _, kant in ipairs({-1,1}) do
    staaf(model,"Bow bumper",Vector3.new(0,0.65,-6.45),Vector3.new(kant*3.45,0.65,-5.95),0.22,staal)
    staaf(model,"Bumper corner",Vector3.new(kant*3.45,0.65,-5.95),Vector3.new(kant*4.05,1.12,-5.0),0.22,staal)
    blok(model,"Headlamp housing",kant*3.03,0.91,-6.05,0.82,0.64,0.55,donker)
    blok(model,"Headlamp",kant*3.03,0.94,-6.34,0.58,0.43,0.06,wit,Enum.Material.Neon)
end
blok(model,"Bow light bar",0,0.95,-6.54,2.2,0.18,0.06,blou,Enum.Material.Neon)
blok(model,"Rear engine deck",0,1.18,3.72,6.6,1.05,3.55,donker)
blok(model,"Rear upper plate",0,1.80,3.20,4.7,0.24,2.55,staal)
for _, kant in ipairs({-1,1}) do
    for _, z in ipairs({2.9,3.35,3.8,4.25}) do
        blok(model,"Cooling vent",kant*3.34,1.25,z,0.06,0.4,0.12,swart)
    end
end
blok(model,"Beacon base",0,2.03,3.1,1.25,0.30,1.15,swart)
staaf(model,"Beacon stem",Vector3.new(0,2.18,3.1),Vector3.new(0,2.82,3.1),0.23,staal)
bol(model,"Beacon",0,2.95,3.1,0.42,0.42,0.42,blou)
staaf(model,"Antenna",Vector3.new(0.55,2.03,3.5),Vector3.new(0.55,3.65,3.5),0.07,swart)
silinderZ(model,"Stern engine",0,0.35,6.0,2.1,2.8,donker)
ring(model,"Stern collar",0,0.35,6.85,1.36,0.17,staal)
silinderZ(model,"Stern exhaust",0,0.35,7.09,0.08,1.75,blou,Enum.Material.Neon)

-- Canopy: translucent tangent panels on a half-ellipsoid, not an imported mesh.
-- Small overlaps reduce visible seams; it is deliberately non-colliding so entry works.
local kap = Instance.new("Model")
kap.Name = "OpeningCanopy"
kap.Parent = model
local kapX, kapY, kapZ = 3.65, 3.55, 4.7
local dek, middelZ = 1.02, -1.2
local lengteStappe, boogStappe = 10, 12
local function kapPunt(t, f)
    return Vector3.new(kapX*math.sin(t)*math.cos(f), dek+kapY*math.sin(t)*math.sin(f), middelZ+kapZ*math.cos(t))
end
for i = 0, lengteStappe-1 do
    for j = 0, boogStappe-1 do
        local t = math.pi*(i+0.5)/lengteStappe
        local f = math.pi*(j+0.5)/boogStappe
        local p = kapPunt(t,f)
        local dt = Vector3.new(kapX*math.cos(t)*math.cos(f),kapY*math.cos(t)*math.sin(f),-kapZ*math.sin(t))
        local df = Vector3.new(-kapX*math.sin(t)*math.sin(f),kapY*math.sin(t)*math.cos(f),0)
        local dwars = df.Unit
        local langs = (dt - dwars * dt:Dot(dwars)).Unit
        local normaal = dwars:Cross(langs).Unit
        -- fromMatrix columns are panel local X, Y, Z; local X follows the cross section.
        local raam = CFrame.fromMatrix(p, dwars, langs, normaal)
        deel(kap,"Glass panel",Vector3.new(df.Magnitude*math.pi/boogStappe*1.05,dt.Magnitude*math.pi/lengteStappe*1.05,0.055),raam,glas,Enum.Material.Glass,0.67,nil,false)
    end
end
for _, i in ipairs({2,5,8}) do
    local t = math.pi*i/lengteStappe
    for j = 0, boogStappe-1 do
        local f1, f2 = math.pi*j/boogStappe, math.pi*(j+1)/boogStappe
        staaf(kap,"Canopy arch",kapPunt(t,f1),kapPunt(t,f2),0.10,donker)
    end
end
for _, f in ipairs({0,math.pi}) do
    for i = 0, lengteStappe-1 do
        staaf(kap,"Canopy rim",kapPunt(math.pi*i/lengteStappe,f),kapPunt(math.pi*(i+1)/lengteStappe,f),0.14,staal)
    end
end

-- Two side ducts and independently rotating decorative rotors.
local rotors = {}
for _, kant in ipairs({-1,1}) do
    local x, y, z = kant*5.0, 0.05, 2.85
    silinderZ(model,"Side thruster housing",x,y,z,2.8,2.35,donker)
    for _, dz in ipairs({-1.25,1.25}) do ring(model,"Duct armour band",x,y,z+dz,1.14,0.16,staal) end
    silinderZ(model,"Duct dark face",x,y,z-1.43,0.08,2.0,swart)
    ring(model,"Duct cyan ring",x,y,z-1.49,0.91,0.065,blou,Enum.Material.Neon)
    staaf(model,"Thruster mount",Vector3.new(kant*3.7,0.4,2.9),Vector3.new(kant*4.45,0.4,2.9),0.4,staal)
    local rotor = Instance.new("Model"); rotor.Name = "ThrusterRotor"; rotor.Parent = model
    silinderZ(rotor,"Rotor hub",x,y,z-1.58,0.20,0.48,liggrys)
    for n = 0,4 do
        local a = 2*math.pi*n/5
        staaf(rotor,"Rotor blade",Vector3.new(x+0.20*math.cos(a),y+0.20*math.sin(a),z-1.60),Vector3.new(x+0.82*math.cos(a+0.32),y+0.82*math.sin(a+0.32),z-1.60),0.18,liggrys)
    end
    table.insert(rotors,{model=rotor, pivot=basis*CFrame.new(x,y,z-1.60)})
end

-- The prompt is reachable from either side; press E / the device prompt to toggle.
local promptDeel = blok(model,"Canopy control",-4.05,1.50,-0.3,0.35,0.3,0.5,blou,Enum.Material.Neon)
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "CanopyPrompt"
prompt.ActionText = "Open canopy"; prompt.ObjectText = "Submarine"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0; prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = promptDeel

-- One interpolated number drives the whole canopy around its rear hinge.
local spil = basis * CFrame.new(0,dek,middelZ+kapZ)
local kapDele = {}
for _, p in ipairs(kap:GetDescendants()) do
    if p:IsA("BasePart") then table.insert(kapDele,{part=p,rel=spil:ToObjectSpace(p.CFrame)}) end
end
local hoek = Instance.new("NumberValue"); hoek.Name = "CanopyAngle"; hoek.Value = 0; hoek.Parent = model
local oop = false
local tween
local verander = hoek.Changed:Connect(function(waarde)
    local doel = spil * CFrame.Angles(math.rad(waarde),0,0)
    for _, item in ipairs(kapDele) do item.part.CFrame = doel * item.rel end
end)
prompt.Triggered:Connect(function()
    oop = not oop
    prompt.ActionText = oop and "Close canopy" or "Open canopy"
    if tween then tween:Cancel() end
    tween = TweenService:Create(hoek,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Value=oop and 65 or 0})
    tween:Play()
end)

-- Single throttled Heartbeat for BOTH rotors; stops when the model is removed.
local tyd, hoekRotor = 0, 0
local verbinding
verbinding = RunService.Heartbeat:Connect(function(dt)
    if not model.Parent then verbinding:Disconnect(); verander:Disconnect(); return end
    tyd = tyd + dt
    if tyd < 1/20 then return end
    hoekRotor = (hoekRotor + tyd*2.5) % (2*math.pi)
    tyd = 0
    for _, r in ipairs(rotors) do r.model:PivotTo(r.pivot*CFrame.Angles(0,0,hoekRotor)) end
end)
model.Parent = Workspace
print("Built " .. MODEL_NAAM .. " at " .. tostring(BEGIN_POSISIE) .. "; decorative only, not drivable.")
