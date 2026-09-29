--Power Load (K)
local s,id=GetID()
function s.initial_effect(c)
	-- Can only be equipped to a Machine monster.
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsRace, RACE_MACHINE))
	--The equipped monster gains 800 ATK for each other Machine monster you control.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkvalue)
	c:RegisterEffect(e2)
	-- Machine monsters you control other than the equipped monster cannot attack.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.antarget)
	c:RegisterEffect(e3)
end

function s.atkfilter(c)
    return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
function s.atkvalue(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,c)*800
end
function s.antarget(e,c)
	return c~=e:GetOwner():GetEquipTarget()
end