--BEKAS
local s,id=GetID()
Duel.LoadScript("c1337.lua")
function s.initial_effect(c)
	--Skill setup
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	--flip at start of the duel
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.startup)
	c:RegisterEffect(e1)
end

function s.canfilter(c)
	return c:IsKasinaoCan() and c:IsAbleToHand()
end


function s.startup(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SetLP(tp,6000)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(ep,id)>0 then return false end
	return aux.CanActivateSkill(tp)
		and Duel.IsMainPhase()
		and Duel.CheckLPCost(tp,100)
		and Duel.IsExistingMatchingCard(s.canfilter,tp,LOCATION_DECK,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1) -- once per turn

	if Duel.CheckLPCost(tp,100) then
		Duel.PayLPCost(tp,100)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.canfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

