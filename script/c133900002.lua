-- Mecha Ojama King Transformation (K)
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id) -- Once per turn
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

-- Filter: non-Machine Ojamas
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf) and not c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end

-- Filter: LIGHT Machine with exact level
function s.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- Targeting: selects any number of non-Machine Ojamas
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
		return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Operation: tribute selected Ojamas, sum levels, special summon LIGHT Machine
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end

	-- Player selects any number of monsters (1 to all)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,#g,nil)

	-- Sum their Levels
	local lv=0
	for tc in aux.Next(sg) do
		lv=lv+tc:GetLevel()
	end

	-- Tribute selected monsters
	Duel.SendtoGrave(sg,REASON_COST+REASON_RELEASE)

	-- Check MZONE space
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	-- Special Summon from Deck
	local sp=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if #sp>0 then
		Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
	end
end
