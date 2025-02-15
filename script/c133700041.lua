--Fusion Dig
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    --Excavate top 5 cards
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    local mg=g:Filter(Card.IsCanBeFusionMaterial,nil)
    local tg=Duel.GetMatchingGroup(function(c,e,tp,mg)
        return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
            and c:CheckFusionMaterial(mg,nil,tp|FUSPROC_NOTFUSION)
    end,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
    if #tg>0 then
        --Fusion Summon
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=tg:Select(tp,1,1,nil):GetFirst()
        local mat=Duel.SelectFusionMaterial(tp,tc,mg)
        tc:SetMaterial(mat)
        Duel.SendtoGrave(mat,REASON_FUSION+REASON_MATERIAL)
        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    else
        Duel.Damage(tp,2000,REASON_EFFECT)
    end
    local rg=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
    if #rg>0 then
        Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
    end
end