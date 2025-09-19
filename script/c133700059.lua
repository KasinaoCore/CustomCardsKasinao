--Adamantine Sword Revival (K)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={133700058}

-- filter: Dragon SS this turn
function s.ssfilter(c,tp)
	return c:IsRace(RACE_DRAGON)
		and c:IsControler(tp)
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsStatus(STATUS_SPSUMMON_TURN)
		and c:IsReleasable()
end

-- condition: must control at least 1 valid tribute candidate
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end

-- target: tribute 1 valid Dragon, then prepare to summon from Deck
function s.filter(c,e,tp)
	return c:IsCode(133700058) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,s.ssfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- operation: tribute the chosen Dragon, then summon the target monster
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_COST)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP_ATTACK)
		end
	end
end
