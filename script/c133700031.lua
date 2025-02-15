--Beckon to the Dark
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local player_ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local opp_total=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
	local opp_main=Duel.GetMatchingGroupCount(s.filter,1-tp,LOCATION_MZONE,0,nil)
	return (player_ct==0 or player_ct<opp_total) and opp_main>=2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_MZONE,0,nil)
	local leftmost=s.get_leftmost(g)
	if leftmost then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,leftmost,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_MZONE,0,nil)
	local leftmost=s.get_leftmost(g)
	if leftmost then
		Duel.SendtoGrave(leftmost,REASON_EFFECT)
	end
end
function s.filter(c)
	local seq=c:GetSequence()
	return seq>=0 and seq<=4
end
function s.get_leftmost(g)
	local min_seq=5
	local leftmost=nil
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if seq<min_seq then
			min_seq=seq
			leftmost=tc
		end
	end
	return leftmost
end