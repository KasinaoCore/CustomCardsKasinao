local s,id=GetID()
function s.initial_effect(c)
	-- Activate only if you control an "Infernity" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_INFERNITY}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xb),tp,LOCATION_MZONE,0,1,nil)
end
function s.fil(c)
	return c:IsSetCard(0xb) and c:IsLevelBelow(3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsPlayerCanDiscardDeck(tp,4) 
			and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.DiscardDeck(p,4,REASON_EFFECT)
	if Duel.Draw(p,1,REASON_EFFECT) > 0 then
		if not Duel.IsExistingMatchingCard(s.fil,p,LOCATION_GRAVE,0,1,nil) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_SKIP_DP)
			e1:SetTargetRange(1,0)
			if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
				e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
			else
				e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
			end
			Duel.RegisterEffect(e1,tp)
		end
	end
end