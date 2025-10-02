--Battledrone Charge
Duel.LoadScript("c1337.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.ctfilter(c,tp)
	return c:IsKasinaoDrone() and c:IsSummonLocation(LOCATION_EXTRA) and c:GetOwner()==tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.ctfilter,nil,tp)
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsCanAddCounter(0x1952,1) then
			tc:AddCounter(0x1952,1)
		end
	end
end