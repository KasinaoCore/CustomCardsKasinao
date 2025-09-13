-- Mecha Ojama King Transformation (K)
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Filter for non-Machine Ojama monsters
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf) and not c:IsRace(RACE_MACHINE)
end

-- Filter for LIGHT Machine monsters with specific level
function s.spfilter(c,e,tp,sum_lv)
	return c:IsLevelBelow(sum_lv) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,99,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local lv_sum=0
	local tg=Group.CreateGroup()
	if g:GetCount()>0 then
		for tc in aux.Next(g) do
			if tc:IsRelateToEffect(e) and tc:IsAbleToGraveAsCost() then
				tg:AddCard(tc)
			end
		end
	end

	if tg:GetCount()==0 then return end
	
	for tc in aux.Next(tg) do
		lv_sum=lv_sum+tc:GetLevel()
	end
	
	Duel.SendtoGrave(tg,REASON_COST+REASON_RELEASE)
	
	if lv_sum==0 then return end

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sp=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv_sum)
	if sp:GetCount()>0 then
		Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
	end
end