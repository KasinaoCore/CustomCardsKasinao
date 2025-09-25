local function MakeCheck(setcodes, list, extrafuncs)
	return function(c)
		if extrafuncs then
			for _,f in ipairs(extrafuncs) do
				if f(c) then return true end
			end
		end
		if setcodes then
			for _,setc in ipairs(setcodes) do
				if c:IsSetCard(setc) then return true end
			end
		end
		if list then
			for _,code in ipairs(list) do
				if c:IsCode(code) then return true end
			end
		end
		return false
	end
end

KasinaoArchetype = {}

KasinaoArchetype.Drone = {
	756652 -- Doron
}

Card.IsKasinaoDrone = MakeCheck({0x803}, KasinaoArchetype.Drone)
