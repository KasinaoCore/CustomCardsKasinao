-- Ascension Spiral
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_RANK_UP_MAGIC,0x801} -- 0x801 = New Order
-- RUM filter
function s.rumfilter(c)
    return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- Grave to banish filter
function s.grave_filter(c,e,tp)
    local rk=c:GetRank()
    return c:IsSetCard(0x801) and c:IsType(TYPE_XYZ) and rk<=6
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk+2)
end
-- Extra Deck special summon filter
function s.spfilter(c,e,tp,rk)
    return c:IsSetCard(0x801) and c:IsType(TYPE_XYZ) and c:IsRank(rk)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.grave_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.grave_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
    local rk=tc:GetRank()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rk+2)
    local sc=sg:GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Optional RUM recovery
        if Duel.IsExistingMatchingCard(s.rumfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local rg=Duel.SelectMatchingCard(tp,s.rumfilter,tp,LOCATION_GRAVE,0,1,1,nil)
            Duel.SendtoHand(rg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,rg)
        end
    end
end
