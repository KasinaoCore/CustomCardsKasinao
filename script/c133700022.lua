-- Ancient City (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
    	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    -- Unaffected by Traps/Monsters while Ancient Dragon exists
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.immcon)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)
    -- Send materials to Special Summon Dragon and gain effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3) 
end
s.listed_names={133700021} --Ancient Dragon of the Capital
function s.immcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,133700021),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.immval(e,te)
    return te:IsActiveType(TYPE_TRAP+TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.cspfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL)
        and not c:IsType(TYPE_FIELD) and c:IsAbleToGraveAsCost()
end
function s.monfilter(c)
    return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cspfilter,tp,LOCATION_SZONE,0,2,nil)
        and Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil) end
    local g1=Duel.SelectMatchingCard(tp,s.cspfilter,tp,LOCATION_SZONE,0,2,2,nil)
    local g2=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil)
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsCode(133700021) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    -- Special Summon Dragon
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g==0 then return end
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Add continuous effect
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e1:SetType(EFFECT_TYPE_IGNITION)
        e1:SetRange(LOCATION_FZONE)
        e1:SetCountLimit(1)
        e1:SetTarget(s.sptg)
        e1:SetOperation(s.spop)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
