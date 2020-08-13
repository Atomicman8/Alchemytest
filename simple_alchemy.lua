simpleAlc = {}
-- simpleAlc.camera = {}
simpleAlc.ingredients = {}
simpleAlc.effects = {}
simpleAlc.recipes = {}
simpleAlc.network = {}
simpleAlc.interface = {}

if ( SERVER ) then 
	util.AddNetworkString( "SimpleAlchemyNetwork" )
	util.AddNetworkString( "SimpleAlchemyModificationLive" )
end

-- Camera
if ( SERVER ) then
	AddCSLuaFile( "simple_alchemy/cl_camera.lua" )
else
	include( "simple_alchemy/cl_camera.lua" )
end

-- Interface
if ( SERVER ) then
	AddCSLuaFile( "simple_alchemy/cl_interface.lua" )
else
	include( "simple_alchemy/cl_interface.lua" )
end

-- Effects
if ( SERVER ) then
	AddCSLuaFile( "simple_alchemy/sh_effects.lua" )
	include( "simple_alchemy/sh_effects.lua" )
else
	include( "simple_alchemy/sh_effects.lua" )
end

-- Ingredients
if ( SERVER ) then
	AddCSLuaFile( "simple_alchemy/sh_ingredients.lua" )
	include( "simple_alchemy/sh_ingredients.lua" )
else
	include( "simple_alchemy/sh_ingredients.lua" )
end

-- Recipe
if ( SERVER ) then
	AddCSLuaFile( "simple_alchemy/sh_recipe.lua" )
	include( "simple_alchemy/sh_recipe.lua" )
else
	include( "simple_alchemy/sh_recipe.lua" )
end

-- Player
if ( SERVER ) then
	include( "simple_alchemy/sv_obj_player.lua" )
end

-- Recipe
if ( SERVER ) then
	AddCSLuaFile( "simple_alchemy/sh_network.lua" )
	include( "simple_alchemy/sh_network.lua" )
else
	include( "simple_alchemy/sh_network.lua" )
end

CreateConVar( "SimpleAlc_enableDynamicLight", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Enable the mod to use dynamic light" )


if ( CLIENT ) then
	simpleAlc.recipes.playerKnowledge = { ["heal_tier_1"] = true }
end

simpleAlc.interface.openRecipeBook = function()
	if ( IsValid( simpleAlc.interface.mainPanelRecipe ) ) then return end
	simpleAlc.interface.mainPanelRecipe = vgui.Create( "DFrame", simpleAlc.interface.mainTable )
	local mainPanel = simpleAlc.interface.mainPanelRecipe
	local rcpOrder = { "heal_tier_1", "heal_tier_2", "armor_tier_1", "armor_tier_2" }
	
	mainPanel:SetSize( ScrW()*0.5, ScrH()*0.8 )
	mainPanel:SetText( "" )
	mainPanel:Center()
	-- mainPanel:MakePopup()
	-- mainPanel.OnFocusChanged = function( self, get ) end
	mainPanel.Paint = function( self, w, h )
			
		surface.SetDrawColor( 50, 50, 50, 150 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( 50, 170, 50, 240  )
		surface.DrawRect( 0, 0, w, 28 )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 20, 50, w - 40, h-100 )
		draw.SimpleText( "Liste des recettes", "Trebuchet24", 2, 2, Color( 255, 255, 255, 255), 0, 0 )
		
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.DrawOutlinedRect( 1, 1, w-2, h-2 )
		
		local yPos = 0
		for k, v in pairs ( self.recipeButtons ) do
			v:SetPos( 5, yPos )
			local _, h = v:GetSize()
			yPos = yPos + h + 20
		end	
	end
	
	mainPanel.scrollPanel = vgui.Create( "DScrollPanel", mainPanel )
	mainPanel.scrollPanel:SetPos( 20, 50 )
	mainPanel.scrollPanel:SetSize( ScrW()*0.5 - 40, ScrH()*0.8 - 100 )
	
	mainPanel.recipeButtons = {}
	
	local y = 0
	for k, v in pairs ( simpleAlc.recipes.data ) do
		mainPanel.recipeButtons[k] = vgui.Create( "DButton", mainPanel.scrollPanel )
		
		local addIng = mainPanel.recipeButtons[k]
		addIng:SetText( "" )
		addIng:SetPos( 5, y )
		addIng:SetSize( ScrW()*0.45, 30 )
		addIng.opened = false
		addIng.recKey = k
		addIng.Paint = function( self, w, h )
			local learned = simpleAlc.recipes.playerKnowledge[self.recKey]
			if ( learned ) then
				surface.SetDrawColor( 110, 110, 110, 240 )
				surface.DrawRect( 0, 30, w, h-30 )
				surface.SetDrawColor( 180, 180, 180, 240 )
				surface.DrawRect( 0, 0, w, 30 )
				draw.SimpleText( tostring( v.name ), "Trebuchet24", 10, 15, Color( 255, 255, 255, 255), 0, 1 )
				local str = ""
				for key, amount in pairs ( simpleAlc.recipes.data[self.recKey].ingredients ) do
					str = str .. simpleAlc.ingredients.getIngredientData( key ).name .. " : x" .. amount 
				end
				draw.SimpleText( "Ingredients : " .. str, "Trebuchet18", 10, 50, Color( 0, 0, 0, 255), 0, 1 )
			else
				surface.SetDrawColor( 30, 30, 30, 240 )
				surface.DrawRect( 0, 0, w, h )
				draw.SimpleText( "????", "Trebuchet24", 10, h/2, Color( 255, 255, 255, 255), 0, 1 )
			end
		end
		-- addIng.Think = function( self )
			
		-- end
		addIng.DoClick = function( self)
			local learned = simpleAlc.recipes.playerKnowledge[self.recKey]
			if ( learned ) then
				if ( self.opened ) then
					self:SetSize( ScrW()*0.45, 30 )
					self.opened = false
				else
					self:SetSize( ScrW()*0.45, ScrH()*0.3 )
					self.opened = true
				end
			end
		end
		
		y = y + ScrH()*0.05 + 5
	end
	
end

-- Client
simpleAlc.network.clientData = {}
simpleAlc.network.clientData["openTableMenu"] = function( entTable )
	
	simpleAlc.interface.mainTable = vgui.Create( "DFrame" )
	
	local mainTable = simpleAlc.interface.mainTable
	local ingredientsData = simpleAlc.ingredients.data
	
	mainTable:SetPos( 0, 0 )
	mainTable:SetSize( ScrW(), ScrH() )
	mainTable:MakePopup()
	
	mainTable.tableEnt = entTable
	mainTable.potionEnt = entTable:GetNWEntity( "LinkedPotion" )
	mainTable.selectedIng = ""
	
	mainTable.Think = function( self )
		if ( mainTable.potionEnt ~= entTable:GetNWEntity( "LinkedPotion" ) ) then
			mainTable.potionEnt = entTable:GetNWEntity( "LinkedPotion" )
		end
	end
	mainTable.OnRemove = function( self )
		simpleAlc.network.sendCommand( "stopUsingTable", mainTable.tableEnt )
		simpleAlc.camera.enabled = false
	end
	mainTable.Paint = function( self, w, h )
		-- draw.SimpleText( "Menu alchemie Version 0.2 ", "DermaLarge", w/2, 15, color_white, 1 )
		-- draw.SimpleText( "Acces anticipé ( Ceci ne représente pas le produit final )", "Trebuchet18", w/2, 45, color_white, 1 )
	end

	mainTable.ingList 		= {}
	mainTable.potionIngList	= vgui.Create( "Panel", mainTable )
	mainTable.ingFrame 		= vgui.Create( "Panel", mainTable )
	mainTable.ingFrameModel = vgui.Create( "DModelPanel", mainTable.ingFrame )
	mainTable.scrollPanel 	= vgui.Create( "DScrollPanel", mainTable )
	-- mainTable.closeButton 	= vgui.Create( "DButton", mainTable )
	-- mainTable.recipeList 	= vgui.Create( "DButton", mainTable )
	
	mainTable.potionIngList:SetPos( ScrW() - ScrW()*0.25 - 20, 20 )
	mainTable.potionIngList:SetSize( ScrW()*0.25, ScrH()*0.25 )
	mainTable.potionIngList.Paint = function( self, w, h )
		surface.SetDrawColor( 30, 30, 30, 210 )
		surface.DrawRect( 0, 0, w, h )
		
		if ( IsValid( mainTable.tableEnt:GetNWEntity( "LinkedPotion" ) ) ) then
			local ingList = mainTable.tableEnt:GetNWEntity( "LinkedPotion" ):GetIngredientTable()
			local yPos = 5
			for k, v in pairs ( ingList ) do
				draw.SimpleText( "-" .. tostring( simpleAlc.ingredients.data[k].name or "?" ) .. " : " .. tostring( v ), "Trebuchet18", 10, yPos, Color( 255, 255, 255, 255), 0, 0 )
				yPos = yPos + 20
			end
		end
	end
	
	mainTable.ingFrame:SetPos( 10, 10 )
	mainTable.ingFrame:SetSize( ScrW()*0.25, ScrH()*0.4 )
	mainTable.ingFrame.Paint = function( self, w, h )
		surface.SetDrawColor( 0, 0, 0, 180 )
		surface.DrawRect( 0, 0, w, h )	
		surface.SetDrawColor( 180, 180, 180, 120 )
		surface.DrawRect( 10, 10, w - 20, h - 20 )
		
		surface.SetDrawColor( 255, 255, 255, 200 )
		surface.DrawRect( 40, 50, ScrW()*0.25 - 80, ScrH()*0.2 )
		surface.SetDrawColor( 60, 70, 80, 255 )
		surface.DrawRect( 43, 53, ScrW()*0.25 - 86, ScrH()*0.2 - 6 )
		
		if ( mainTable.selectedIng ~= "" ) then
			draw.SimpleText( ingredientsData[mainTable.selectedIng].name, "DermaLarge", w/2, 18, color_white, 1 )
			draw.SimpleText( ingredientsData[mainTable.selectedIng].description, "DermaDefaultBold", w/2, h*0.56, color_white, 1 )
		end
	end
	
	
	-- mainTable.closeButton:SetPos( ScrW() - ScrW()*0.25 - 20, ScrH()*0.25 + 40 )
	-- mainTable.closeButton:SetSize( ScrW()*0.25, ScrH()*0.05 )
	
	-- mainTable.recipeList:SetPos( ScrW() - ScrW()*0.25 - 20, ScrH()*0.30 + 60 )
	-- mainTable.recipeList:SetSize( ScrW()*0.25, ScrH()*0.05 )
	-- mainTable.recipeList.DoClick = function( self )
		-- simpleAlc.interface.openRecipeBook()
	-- end
	
	local addIng = vgui.Create( "DButton", mainTable.ingFrame )
	-- local removeIng = vgui.Create( "DButton", mainTable.ingFrame )

	addIng:SetText( "" )
	addIng:SetPos( 40, 10 + ScrH()*.25 )
	addIng:SetSize( ScrW()*0.25 - 80, ScrW()*0.06 )
	addIng.Paint = function( self, w, h )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )	
		
		local col = Color( 40, 40, 40 )
		if ( self:IsHovered() ) then
			col = Color( 140, 170, 140 )
		end
		surface.SetDrawColor( col )
		surface.DrawRect( 3, 3, w - 6, h - 6 )
		draw.SimpleText( "Add ingredient", "DermaLarge", w/2, h/2, Color( col.r * 3, col.g*3, col.b*3 ), 1, 1 )
	end
	addIng.DoClick = function( self )
		simpleAlc.network.sendCommand( "useTable", mainTable.tableEnt, "putIngPotion", mainTable.selectedIng, true )
	end

	-- removeIng:SetText( "-" )
	-- removeIng:SetPos( ScrW()*0.175 - 40, 10 + ScrH()*.25 )
	-- removeIng:SetSize( ScrW()*0.075, ScrW()*0.075 )
	-- removeIng.DoClick = function( self )
		-- simpleAlc.network.sendCommand( "useTable", mainTable.tableEnt, "excIngPotion", mainTable.selectedIng )
	-- end
	
	mainTable.ingFrameModel:SetPos( 40, 50 )
	mainTable.ingFrameModel:SetSize( ScrW()*0.25 - 80, ScrH()*0.2 )
	-- mainTable.ingFrameModel:SetModel( "models/props_junk/garbage_milkcarton002a.mdl" )
	mainTable.ingFrameModel:SetCamPos( Vector( 25, 0, 8 ) )
	mainTable.ingFrameModel:SetLookAt( Vector( 0, 0, 0 ) )
	
	mainTable.scrollPanel:SetPos( 10, 20 + ScrH()*0.4 )
	mainTable.scrollPanel:SetSize( ScrW()*0.25, ScrH()*0.5 )
	mainTable.scrollPanel:GetVBar():SetHideButtons( true )
	mainTable.scrollPanel.Paint = function( self, w, h )
		surface.SetDrawColor( 20, 20, 20, 200 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local y = 0

	for k, v in pairs ( ingredientsData ) do
	
		mainTable.ingList[k] = vgui.Create( "DButton", mainTable.scrollPanel )
		mainTable.ingList[k]:SetText( v.name )
		mainTable.ingList[k]:SetPos( 5, 5 + ( ScrH()*0.06 ) * y )
		mainTable.ingList[k]:SetSize( ScrW()*0.25 - 10, ScrH()*0.05 )
		
		mainTable.ingList[k].marginY = 0
		mainTable.ingList[k].clickEffect = 100
		mainTable.ingList[k].ingKey = k
		mainTable.ingList[k].ingA = mainTable.tableEnt:GetIngredient( k )
		
		mainTable.ingList[k].Paint = function( self, w, h )
			local ingAmount = mainTable.tableEnt:GetIngredient( k )
			local rbgV, textA = 0, 255
			local font = "CloseCaption_Normal"
			
			if ( ingAmount ) then
				if ( self:IsHovered() ) then
					rbgV = 150 + math.sin( CurTime() * 3 ) * 30
					font = "CloseCaption_Bold"
				else
					rbgV = 120
				end
			else
				rbgV, textA = 50, 50
			end
			
			local gY = self.marginY
			local gH = h - self.marginY
	
			-- surface.SetDrawColor( 255, 255, 255, 255 )
			-- surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( rbgV, rbgV, rbgV, 255 )
			surface.DrawRect( 0, gY, w, gH - ( gY ) )
			surface.SetDrawColor( 255, 255, 255, ((100 - self.clickEffect)/100)*255 )
			surface.DrawRect( 0, gY, (self.clickEffect/100)*w, gH - ( gY * 2 ) )
			
			surface.SetFont( font )
			local message = v.name .. " ( x" .. ( ingAmount or 0 ) .." )"
			local width = surface.GetTextSize( message )
			
			draw.SimpleText( message, font, 10 + width/2, h/2 - self.marginY *0.5, Color( 255, 255, 255, textA), 1, 1 )
			return true
		end
		
		mainTable.ingList[k].OnAmountModified = function( self )
			self.marginY = 5
			self.clickEffect = 0
		end
		
		mainTable.ingList[k].OnCursorEntered = function( self )
			local ingAmount = mainTable.tableEnt:GetIngredient( self.ingKey )
			if ( ingAmount ) then
				surface.PlaySound( "simple_alchemy/interface/hover_6.wav" )
			end
		end
		
		mainTable.ingList[k].Think = function( self )
			if ( self.ingA ~= mainTable.tableEnt:GetIngredient( k ) ) then
				self.ingA = mainTable.tableEnt:GetIngredient( k )
				self:OnAmountModified()
			end
			if ( self.clickEffect < 100 ) then
				self.clickEffect = math.Clamp( self.clickEffect + ( 290 * RealFrameTime() ), 0, 100 )
			end
			if ( self.marginY > 0 ) then
				self.marginY = math.Clamp( self.marginY - ( 35 * RealFrameTime() ), 0, 100 )
			end
		end
		
		mainTable.ingList[k].DoClick = function( self )
			mainTable.ingFrameModel:SetModel( v.model )
			mainTable.selectedIng = self.ingKey
			surface.PlaySound( "simple_alchemy/interface/click_1.wav" )

			self.clickEffect = 0
		end
	 
		y = y + 1
	end
	
	
	local ang = entTable:GetAngles()
	simpleAlc.camera.enabled = true
	simpleAlc.camera.newPos = LocalPlayer():GetShootPos()
	simpleAlc.camera.setNewPos( entTable:GetPos() + ang:Up() * 52 + ang:Forward() * 15 )
	
	simpleAlc.camera.newAng = LocalPlayer():GetAngles()
	simpleAlc.camera.setNewAng( entTable:GetAngles() - Angle( -30, 180, 0 ) )
	
end

simpleAlc.network.clientData["syncTableIngredient"] = function( entTable, key, amount )
	if ( not IsValid( entTable ) ) then return end
	if ( entTable:GetClass() == "spl_alchemy_table" ) then
		entTable.alcIngredients[key] = amount
	end
end

simpleAlc.network.clientData["applyEffectFunc"] = function( ply, key, args )
	simpleAlc.effects.data[key].func( ply, args )
end

simpleAlc.network.clientData["receiveBuff"] = function( key, data )
	if ( not LocalPlayer().simpleAlcBuffs ) then
		LocalPlayer().simpleAlcBuffs = {}
	end
	if ( key ) then
		LocalPlayer().simpleAlcBuffs[key] = data
		data.mat = Material( "simple_alchemy/" .. data.img .. ".png" )
	else
		table.insert( LocalPlayer().simpleAlcBuffs, data )
		data.mat = Material( "simple_alchemy/" .. data.img .. ".png" )
	end
end

simpleAlc.network.clientData["removeBuff"] = function( key )
	if ( not LocalPlayer().simpleAlcBuffs ) then LocalPlayer().simpleAlcBuffs = {} end
	if ( key ) then
		LocalPlayer().simpleAlcBuffs[key] = nil
	else
		LocalPlayer().simpleAlcBuffs = {}
	end
end

simpleAlc.network.clientData["syncPotionIngredient"] = function( entPotion, key, amount, animation )
	if ( not IsValid( entPotion ) ) then return end
	
	if ( entPotion:GetClass() == "spl_alchemy_potion" ) then
		entPotion.alcIngredients[key] = amount
		
		if ( animation or false ) then
			entPotion:CreateIngredientModel( simpleAlc.ingredients.data[key].model )
		end
		
		local totalIng = 0
		local red, green, blue = 0, 0, 0
		local ingredients = entPotion:GetIngredientTable()
		local ingredientsData = simpleAlc.ingredients.data
		for k, a in pairs ( ingredients ) do
			local color = ingredientsData[k].col
			red = red + color.r * a
			green = green + color.g * a
			blue = blue + color.b * a
			totalIng = totalIng + a
		end
		
		entPotion:SetWaterColor( Color( (red/(255*totalIng))*255, (green/(255*totalIng))*255, (blue/(255*totalIng))*255, 255 ) )
	end
end
hook.Add( "KeyPress", "keypress_jump_super", function( ply, key )
	if ( key == IN_JUMP ) then
		if ( ply:GetNWInt( "SimpleAlcJumpBuff", -1 ) > 0 ) then
			if ( ply:IsOnGround() ) then
				ply:SetVelocity( ply:GetVelocity() + Vector( 0, 0, ply:GetNWInt( "SimpleAlcJumpBuff", 0 ) ) )
			end
		end
	end
end )

-- Server
simpleAlc.network.serverData = {}

simpleAlc.network.serverData["requestTableSync"] = function( ply, entTable ) 
	for k, a in pairs ( entTable.alcIngredients ) do
		simpleAlc.network.sendCommand( "syncTableIngredient", ply, entTable, k, a )
	end
end

simpleAlc.network.serverData["requestPotionSync"] = function( ply, entPotion ) 
	for k, a in pairs ( entPotion.alcIngredients ) do
		simpleAlc.network.sendCommand( "syncPotionIngredient", ply, entPotion, k, a )
	end
end

simpleAlc.network.serverData["stopUsingTable"] = function( ply, entTable ) 
	if ( not IsValid( ply ) ) or ( not IsValid( entTable ) ) then return end
	if ( entTable:GetClass() ~= "spl_alchemy_table" ) then return end
	if ( ply == entTable.user ) then
		entTable.user = nil
	end
end

simpleAlc.network.serverData["useTable"] = function( ply, entTable, act, ... ) 
	if ( not IsValid( ply ) ) or ( not IsValid( entTable ) ) then return end
	if ( entTable:GetClass() ~= "spl_alchemy_table" ) then return end
	local simpleIngData = simpleAlc.ingredients.data
	local args = { ... }
	
	if ( act == "putIngPotion" ) then
		local linkedPotion = entTable:GetNWEntity( "LinkedPotion" )
		local ingKey = args[1]
		
		if ( not IsValid( linkedPotion ) ) then return end
		if ( entTable.alcIngredients[ingKey] ) then
			if ( entTable.user == ply ) then
				if ( entTable.alcIngredients[ingKey] > 0 ) then
					if ( linkedPotion:GetIngredientAmount() < 8 ) then
						entTable:RemoveIngredient( ingKey, 1 )
						linkedPotion:AddIngredient( ingKey, 1 )
					end
				end
			end
		end
	elseif ( act == "excIngPotion" ) then
		local linkedPotion = entTable:GetNWEntity( "LinkedPotion" )
		local ingKey = args[1]
		
		if ( not IsValid( linkedPotion ) ) then return end
		if ( entTable.user == ply ) then
			if ( linkedPotion:GetIngredient( ingKey ) ) then
				if ( linkedPotion:GetIngredient( ingKey ) > 0 ) then
					linkedPotion:RemoveIngredient( ingKey, 1 )
					entTable:AddIngredient( ingKey, 1 )
				end
			end
		end
	end	
	
end

-- Network client
if ( CLIENT ) then
    simpleAlc.network.sendCommand = function( networkKey, ... )
        net.Start( "SimpleAlchemyNetwork" )
            net.WriteTable( { networkKey = networkKey, args = { ... } } )
        net.SendToServer()
    end

    local function receiveNetworkCommand()
        local NTab = net.ReadTable()
        simpleAlc.network.clientData[NTab.networkKey]( unpack( NTab.args ) )
    end
    net.Receive( "SimpleAlchemyNetwork", receiveNetworkCommand )
end

-- Network server
if ( SERVER ) then
    simpleAlc.network.sendCommand = function( networkKey, receiver, ... )
        net.Start( "SimpleAlchemyNetwork" )
            net.WriteTable( { networkKey = networkKey, args = { ... } } )
        net.Send( receiver )
    end

    local function receiveNetworkCommand( len, ply )
        local NTab = net.ReadTable()
		if ( simpleAlc.network.serverData[NTab.networkKey] ) then
			simpleAlc.network.serverData[NTab.networkKey]( ply, unpack( NTab.args ) )
		else
			print( "The network key " .. NTab.networkKey .. " don't exists" )
		end
    end
    net.Receive( "SimpleAlchemyNetwork", receiveNetworkCommand )
end

hook.Add("loadCustomDarkRPItems", "TEST", function()
	DarkRP.createCategory{
		name = "Alchemy",
		categorises = "entities",
		startExpanded = true,
		color = Color(170, 255, 120, 255),
		sortOrder = 2,
	}
	for k, v in pairs ( simpleAlc.ingredients.data ) do
		DarkRP.createEntity( v.name, {
			ent = "spl_alchemy_ingredient",
			model = v.model,
			price = 150,
			max = 100,
			category = "Alchemy",
			cmd = "alchemy_ingredient_" .. k,
			
			spawn = function( ply, tr, tblEnt )
				local ent = ents.Create( "spl_alchemy_ingredient" )
				ent:SetPos( tr.HitPos )
				ent:Spawn()
				ent:SetIngredient( k )
				local phys = ent:GetPhysicsObject()
				if (phys:IsValid()) then
					phys:Wake()
				end
				return ent
			end
		})
	end
	
	DarkRP.createEntity( "Potion", {
		ent = "spl_alchemy_potion",
		model = "models/props/alchemy/fiole_ballon01.mdl",
		price = 300,
		max = 100,
		category = "Alchemy",
		cmd = "spl_alchemy_potion",
	})
	
end)

hook.Add( "PlayerSpawn", "SimpleAlcPlayerSpawn", function( ply )
	ply:ResetCustomVal()
	ply:ResetAlcBuff()

end )

hook.Add( "PlayerDeath", "SimpleAlcPlayerDeath", function( ply )
	if ( ply.timerEffect ) then
		for k, v in pairs( ply.timerEffect ) do
			if ( v.timer.deathFunc ) then
				simpleAlc.effects.data[v.key].deathFunc( ply, v.args )
			end
		end
	end
	ply.timerEffect  = {}
	ply:ResetAlcBuff()
	simpleAlc.network.sendCommand( "removeBuff", ply )
end )


hook.Add( "PreDrawHalos", "AddPropHalos", function()
	if ( CurTime() < LocalPlayer():GetNWInt( "SimpleAlcAuraVision" ) ) then
		local allPlayers = player.GetAll()
		for k, v in pairs ( allPlayers ) do
			if ( v:Alive() ) then
				if ( LocalPlayer():GetPos():DistToSqr( v:GetPos() ) < ( 2000*2000 ) ) then
				local hpR = v:Health() / v:GetMaxHealth()
				halo.Add( { v }, Color( 255 - ( hpR * 255 ), ( hpR * 255 ), 0 ), 1, 1, 7 + math.sin( CurTime() * 5 ) * 2, true, true )
				end
			end
		end

		for k, v in pairs ( ents.GetAll() ) do
			if ( v:IsNPC() ) then
				if ( v:Health() > 0 ) then
					if ( LocalPlayer():GetPos():DistToSqr( v:GetPos() ) < ( 2000*2000 ) ) then
					local hpR = v:Health() / v:GetMaxHealth()
					halo.Add( { v }, Color( 255 - ( hpR * 255 ), ( hpR * 255 ), 0 ), 2, 2, 7 + math.sin( CurTime() * 5 ) * 2, true, true )
					end
				end
			end
		end
	end
end )


hook.Add( "Think", "SimpleAlcThinkHeal", function()
	for k, ply in pairs ( player.GetAll() ) do
		if ( ply.timerEffect ) then
			for timerK, timerV in pairs ( ply.timerEffect ) do
				if ( CurTime() > timerV.timer.nextTime ) then
					simpleAlc.effects.data[timerV.key].timerFunc( ply, timerV.args )
					timerV.timer.nextTime = CurTime() + timerV.timer.interval
					timerV.timer.totalCount = timerV.timer.totalCount + 1
					if ( timerV.timer.totalCount == timerV.timer.amount ) then
						ply.timerEffect[timerK] = nil
					end
				end
			end
		end
	end
end )

hook.Add( "EntityTakeDamage", "SimpleAlcEntityTakeDamage", function( ply, dmginfo )
	if ( ply:GetNWInt( "SimpleAlcGlobalResistance", -1 ) > 0 ) then
		dmginfo:ScaleDamage( 1 - (ply:GetNWInt( "SimpleAlcGlobalResistance", 100 )/100) )
	end
end )

--Veiw Shirnk 
	hook.Add( "Think", "Shit goes down with my pro code - alex5511",function() 
	
	for k,v in pairs(player.GetAll()) do
    v:SetViewOffset(Vector(0,0,64 * v:GetModelScale())) //v:OBBCenter() * 64)
	
	v:SetWalkSpeed( 250*v:GetModelScale() )
	v:SetRunSpeed( 500*v:GetModelScale() )
	v:SetJumpPower( 200*v:GetModelScale() )
	
	/*if v:GetModelScale() <= 0.9 then
	
	v:SetWalkSpeed( 80 )
	v:SetRunSpeed( 150 + 80 )
	v:SetJumpPower( 120 )
	
	elseif v:GetModelScale() >= 1.1 then
	
	v:SetWalkSpeed( 800 )
	v:SetRunSpeed( 800 + 500 )
	v:SetJumpPower( 450 )
	
	elseif v:GetModelScale() == 1 then
	
	v:SetWalkSpeed( 250 )
	v:SetRunSpeed( 500 )
	v:SetJumpPower( 200 )
	
	end
	
	if !v:Alive() and v:IsValid() then
	
	v:SetWalkSpeed( 250 )
	v:SetRunSpeed( 500 )
	v:SetModelScale( 1,1 )
	
	end*/
	
	end
	
	
	
	end )
	
hook.Add( "HUDPaint", "SimpleAlcHUDPaint", function()
	local buffs = LocalPlayer().simpleAlcBuffs
	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity
	
	if ( buffs ) then
		local x = 0
		local mX, mY = input.GetCursorPos()
		
		for k, buff in pairs ( buffs ) do
			local col = buff.col
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect( 8 + ( x * 74 ), 8, 68, 68 )
			surface.SetDrawColor( col.r, col.g, col.b, col.a )
			surface.DrawRect( 10 + ( x * 74 ), 10, 64, 64 )
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( buff.mat )
			surface.DrawTexturedRect( 15 + ( x * 74 ), 15, 54, 54 )
			
			local localCurTime = CurTime() - buff.startTime
			draw.SimpleText( math.Round( buff.activeTime - localCurTime ) .. " sec", "Trebuchet24", 10 + ( x * 74 ) + 32, 85, color_white, 1, 1 )
			
	
			if ( mX > 10 + ( x * 74 ) and mX < 10 + ( x * 74 ) + 64 and mY > 10 and mY < 10 + 64 ) then
				surface.SetDrawColor( 255, 255, 255, 100 )
				surface.DrawRect( 8 + ( x * 74 ), 8, 68, 68 )
				draw.SimpleText( buff.desc or "No description", "Trebuchet24", 10, 100, color_white, 0, 0 )
			end
			
			if ( localCurTime > buff.activeTime ) then
				buffs[k] = nil
			end
			
			x = x + 1
		end
	end

end )

local function MyCalcView( ply, pos, angles, fov )
	if ( simpleAlc.camera.enabled ) then
		simpleAlc.camera.update( 1.5 )
		simpleAlc.camera.actualPos =  LerpVector( simpleAlc.camera.lerp, simpleAlc.camera.previousPos, simpleAlc.camera.newPos )
		simpleAlc.camera.actualAng =  LerpAngle( simpleAlc.camera.lerp, simpleAlc.camera.previousAng, simpleAlc.camera.newAng )

		local view = {}
		
		view.origin = simpleAlc.camera.actualPos
		view.angles = simpleAlc.camera.actualAng
		view.fov = fov
		view.drawviewer = true

		return view
	end
end
hook.Add( "CalcView", "SimpleAlcCalcView", MyCalcView )






