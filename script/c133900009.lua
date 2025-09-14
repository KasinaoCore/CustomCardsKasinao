--Front Change (K)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	local lv=c:GetLevel()
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAbleToExtra()
		and lv>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,lv,e,tp,c)
end

function s.spfilter(c,lv,e,tp,mc,code)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE)
		and c:GetLevel()==lv
		and c:GetCode()~=code
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and ((c:IsCode(133900007) or c:IsCode(133900008)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
			or (not c:IsCode(133900007) and not c:IsCode(133900008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	local code=tc:GetCode()
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,tc,code)
	local sc=g:GetFirst()
	if sc then
		Duel.BreakEffect()
		if sc:IsCode(133900007,133900008) then
			if Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
		else
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
