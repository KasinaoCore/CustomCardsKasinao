-- Dice Dungeon II
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Roll die on Summon (exactly 1 monster)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.rollcon)
	e2:SetOperation(s.rollop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- Summon monsters when this card leaves the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(s.summonop)
	c:RegisterEffect(e4)
end
-- Roll die on Summon (exactly 1 monster)
function s.rollcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1
end
function s.rollop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p=tc:GetControler() -- Controller of the Summoned monster
	local roll=Duel.TossDice(p,1)
	if roll==6 then
		-- Place in Spell/Trap Zone as Continuous Spell
		if Duel.GetLocationCount(p,LOCATION_SZONE)>0 then
			Duel.MoveToField(tc,p,p,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			tc:RegisterEffect(e1)
		else
			Duel.SendtoGrave(tc,REASON_RULE)
		end
	else
		-- Move to specific Monster Zone
		local zone=roll-1
		local current_zone=tc:GetSequence()
		if current_zone==zone then
			-- Monster is already in the correct zone; do nothing
			return
		elseif Duel.CheckLocation(p,LOCATION_MZONE,zone) then
			Duel.MoveSequence(tc,zone)
		else
			-- Place in Spell/Trap Zone as Continuous Spell
			if Duel.GetLocationCount(p,LOCATION_SZONE)>0 then
				Duel.MoveToField(tc,p,p,LOCATION_SZONE,POS_FACEUP,true)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				tc:RegisterEffect(e1)
			else
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		end
	end
end
-- Summon monsters when this card leaves the field
function s.summonop(e,tp,eg,ep,ev,re,r,rp)
	-- Each player summons their own monsters
	for p=0,1 do
		local g=Duel.GetMatchingGroup(s.summonfilter,p,LOCATION_SZONE,0,nil)
		if #g>0 then
			Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
		end
	end
end
function s.summonfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_CONTINUOUS) and c:IsOriginalType(TYPE_MONSTER) and not c:IsLocation(LOCATION_PZONE)
end