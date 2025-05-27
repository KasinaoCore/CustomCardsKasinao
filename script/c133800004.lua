--New Order 12: Etheric Mahes
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon: 2 Level 12 LIGHT monsters or Horus alternate
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),12,2,
        s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
    c:EnableReviveLimit()
    -- Main Ignition: return materials → Special Summon → grant effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end
s.listed_series={SET_RANK_UP_MAGIC,0x801,0x802}
s.listed_names={133800003}

-- Horus alternate
function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,133800003)
end
function s.cfilter(c)
    return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsSpell() and c:IsDiscardable()
end
function s.xyzop(e,tp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST)
    return true
end

-- Target
function s.spfilter(c,e,tp,rank,sg)
    return c:IsSetCard(0x801)
       and c:GetRank()<rank
       and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
       and not sg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetHandler():GetOverlayCount()
    if chk==0 then
        return ct>0
           and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,
                e, tp, e:GetHandler():GetRank(), Group.CreateGroup())
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_EXTRA)
end

-- Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
    local ct=c:GetOverlayCount()
    if ct==0 then return end

    -- Return materials: Extra Deck vs Main Deck
    local og=c:GetOverlayGroup()
    if #og>0 then
        Duel.SendtoDeck(og, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end

    -- Select and Special Summon
    local sg=Group.CreateGroup()
    local rank=c:GetRank()
    for i=1,ct do
        local g=Duel.GetMatchingGroup(function(tc)
            return s.spfilter(tc,e,tp,rank,sg)
        end, tp, LOCATION_EXTRA, 0, nil)
        if #g==0 then break end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        sg:AddCard(tc)
    end
    if #sg==0 then return end
    local res=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    if res==0 then return end

    -- Mark, grant continuous destroy-if-Mahes-gone, and End Phase attach
    for tc in aux.Next(sg) do
        -- 1) Destroy if no Mahes
        local eD=Effect.CreateEffect(c)
        eD:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        eD:SetCode(EVENT_ADJUST)
        eD:SetRange(LOCATION_MZONE)
        eD:SetCountLimit(1)
        eD:SetCondition(function(e) 
            return not Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(),
                LOCATION_MZONE,0,1,nil, id)
        end)
        eD:SetOperation(function(e)
            local rc=e:GetHandler()
            if rc:IsFaceup() then Duel.Destroy(rc,REASON_EFFECT) end
        end)
        eD:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(eD)

        -- 2) End Phase attach-back
        local eE=Effect.CreateEffect(c)
        eE:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        eE:SetCode(EVENT_PHASE+PHASE_END)
        eE:SetRange(LOCATION_MZONE)
        eE:SetCountLimit(1)
        eE:SetCondition(function(e)
            return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(),
                LOCATION_MZONE,0,1,nil, id)
        end)
        eE:SetOperation(function(e,tp)
            local rc=e:GetHandler()
            local mh=Duel.GetFirstMatchingCard(Card.IsCode,tp,
                LOCATION_MZONE,0,nil,id)
            if rc:IsFaceup() and mh then
                local mat=Group.FromCards(rc)
                Duel.Overlay(mh, mat)
            end
        end)
        eE:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(eE)
    end
end
