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
	756652, -- Doron
	4474060, -- SPYRAL Gear - Drone
	24610207 -- Star Drawing
}
KasinaoArchetype.Can = {
	62651957,
	5861892,
	69831560,
	23846921,
	39761418,
	97452817,
	59712426,
	60953118,
	1876841,
	34568403,
	97574404,
	3376703,
	61175706,
	35781051,
	45159319,
	8396952,
	95614612,
	62892347,
	75198893,
	8251996,
	11819473,
	32062913,
	76302448,
	77066768,
	133700044,
	3492538,
	28120197,
	25096909,
	70916046
}

Card.IsKasinaoDrone = MakeCheck({0x803}, KasinaoArchetype.Drone)
Card.IsKasinaoCan = MakeCheck((0x805), KasinaoArchetype.Can)

