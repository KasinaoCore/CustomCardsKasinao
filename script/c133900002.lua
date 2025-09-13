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
	-- The check for being able to be tributed as cost.
	return c:IsFaceup() and c:IsSetCard(0xf) and not c:IsRace(RACE_MACHINE)
end

-- Filter for LIGHT Machine monsters with specific level
function s.spfilter(c,e,tp,sum_lv)
	return c:IsLevelBelow(sum_lv) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		-- Use Duel.IsExistingMatchingCard with the "any number of monsters" check
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,99,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TO_GRAVE,e:GetTargetCards(),1,tp,0)
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Get the targeted cards
	local g=e:GetTargetCards()
	-- A variable to hold the combined level of the monsters
	local lv_sum=0
	local tg=Group.CreateGroup()
	if not g:Is_Empty() then
		-- Check if the monsters are still on the field and can be tributed
		for tc in aux.Next(g) do
			if tc:IsRelateToEffect(e) and tc:IsAbleToGraveAsCost() then
				tg:AddCard(tc)
			end
		end
	end

	-- If there are no valid targets to tribute, the effect resolves without effect
	if tg:Is_Empty() then return end
	
	-- Get the sum of the levels *before* sending them to the graveyard
	for tc in aux.Next(tg) do
		lv_sum=lv_sum+tc:GetLevel()
	end
	
	-- Send the selected monsters to the graveyard as a cost
	Duel.SendtoGrave(tg,REASON_COST+REASON_RELEASE)
	
	-- If the number of monsters tributed is 0, the effect stops here.
	if lv_sum==0 then return end

	-- Check for space on the field
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	
	-- Select and special summon from the deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sp=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv_sum)
	if not sp:Is_Empty() then
		Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
	end
end
