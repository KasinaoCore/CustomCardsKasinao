--Flying Dragon Whirl (K)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave()
end
function s.tgfilter2(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter2(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tgfilter,tp, LOCATION_DECK,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local deck=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local g=Group.CreateGroup()
	local used_codes = {}
	while g:GetCount() <4 and deck:GetCount() >0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sel = deck:Select(tp,1,1,nil):GetFirst()
		if not used_codes[sel:GetCode()] then
			g:AddCard(sel)
			used_codes[sel:GetCode()] = true
		end
		deck:RemoveCard(sel)
	end
	Duel.SendtoGrave(g, REASON_COST)
	Duel.SetTargetParam(g:GetCount())
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and ct>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end