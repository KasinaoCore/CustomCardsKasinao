-- Mecha Ojama King Transformation
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
	return c:IsFaceup() and c:IsSetCard(0xf) and not c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end

-- Filter for LIGHT Machine monsters with specific level
function s.spfilter(c,lv,e,tp)
	return c:IsLevel(lv) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- select any number of non-Machine Ojamas
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,#g)
	if not sg then return end
	-- sum their levels
	local lv=0
	for tc in sg:Iter() do
		lv=lv+tc:GetLevel()
	end
	-- tribute selected monsters
	Duel.SendtoGrave(sg,REASON_COST+REASON_RELEASE)
	-- special summon from the deck
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sp=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if #sp>0 then
		Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
	end
end
