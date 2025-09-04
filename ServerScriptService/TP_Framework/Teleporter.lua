-- @ScriptType: ModuleScript

-- OKAY SO
-- roblox has a built in OOP feature, but i dont use it bc i dont think its good and metatables arent good either imo bc of performance stuff and other complex stuff that shouldnt be needed
-- so what i do is write OOP with normal tables and theres not really any difference, the only difference is u have to set the functions manually which is just a few lines

--[[

OOP its very simple, all u do is basically create "objects" and each one has properties and functions u can assign to
its very good for systems like this for example, or like a combat system, interaction, etc

its helpful because it helps being more organized and makes debugging easy since everything is like organized

first, we'll begin by having a function that creates an object
now, if u wanna assign functions to it, its also simple

so as u can see i made 3 remotes
- new teleporter is obviously to receive the newly created teleporters
- remove is when u have used a teleporter and to remove it from ur UI
- and receive teleporter data will be for whenever a new player joins he will receive the teleporter stuff

and i just remembered, that theres one more variable that the teleporter object needs which i forgot to add and its the name

SO NOW, what goes next is, actually removing the thing from the UI, ofc...................

]]--

-- // Variables

-- services
local rs = game:GetService('ReplicatedStorage')

-- rs
local common, remotes = rs:WaitForChild('Common'), rs:WaitForChild('Remotes')
local assets = common:WaitForChild('Assets')
local tRemotes = remotes:WaitForChild('Teleporter')

-- asset folder
local telFx = assets:WaitForChild('Teleporters'):WaitForChild('Fx')
local beaconSample = telFx:WaitForChild('Beacon')

-- vars
local teleporter = {}

-- // Functions

local function teleport(self, plr : Player) -- lets make a function to teleport a player to the object
	-- what is self? basically its "ourselves" as in the object, so basically it contains every of the variables and functions u assigned to this object
	-- okay so obv we'll need a player to teleport, right?
	
	-- so heres where the teleported table comes into play, we want to make sure that player hasnt been teleporter already and its gonna be pretty simple
	if table.find(self.Teleported, plr.UserId) then warn('Cannot teleport! '..plr.Name..' has been teleported already.') return end -- this line is all u need to make sure they havent been teleported there already
	
	-- add to the teleported table
	print('Request to teleport '..plr.Name)
	table.insert(self.Teleported, plr.UserId) -- ill change to the user id so its more accurate
	
	-- teleport
	plr.Character:WaitForChild('HumanoidRootPart'):PivotTo(CFrame.new(self.Position))
	
	-- effect
	remotes:FindFirstChild('RenderRequest'):FireAllClients('Teleporters', self.Position, self.Id) -- once again we send the position info required to render and before the position ill send the "action"
	tRemotes:FindFirstChild('RemoveTeleporter'):FireClient(plr, self.Id) -- whoops, not fire all clients, only fire it to the one who teleported
end

------------------------------------------------------------------------------------------------------------------------------

function teleporter.new(id : string, position : Vector3, name : string) -- so with this u will make new objects, very simple.
	-- ofc, we'll render it on the function that creates the teleporter itself!
	local beacon = beaconSample:Clone()
	beacon.Parent = workspace -- u can have a rendering folder or whatever, it doesnt rlly matter its mostly for organization. i wont make one RN since im not rendering on the client
	beacon:PivotTo(CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))) -- if u ask why i make the vector3's Cframes here its bc the function PivotTo only accepts cframes
	
	-- as u can see the object itself is just a table where everything gets stored, we can assign some attributes to it just like you'd do with a normal model
	local object = {
		-- vars
		BeaconModel = beacon,
		Name = name,
		
		Id = id,
		Position = position,
		Teleported = {},
		
		-- funcs (this is how u can assign manually the functions without having to use roblox's OOP. as i said its super simple and just needs a few more lines of code)
		Teleport = teleport,
	}
	
	-- okay, so once again we're in the fuction that creates an object, and this is where ill fire the new event
	tRemotes:FindFirstChild('NewTeleporter'):FireAllClients(object.Name, object.Id) -- the only information we need to send is the name and the Id
	
	return object
end

return teleporter