--Ragnarok (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARK_MAGICIAN}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DARK_MAGICIAN) and c:IsType(TYPE_MONSTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return #g==2 and aux.dncheck(g)
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemove() and (c:IsLocation(LOCATION_DECK|LOCATION_HAND) or aux.SpElimFilter(c))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,0x13,0,1,nil) end
	local rg=Duel.GetMatchingGroup(s.rmfilter,tp,0x13,0,nil)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.rmfilter,tp,0x13,0,nil)
	if Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
