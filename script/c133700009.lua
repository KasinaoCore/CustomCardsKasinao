--Different Dimension Hangar
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Field uniqueness
    c:SetUniqueOnField(1,0,id)
    --Equip effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
--Banish 3 Unions from Deck
function s.filter(c)
    return c:IsType(TYPE_UNION) and c:IsLevelBelow(4) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
    if #g>=3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,3,3,nil)
        if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
            for tc in aux.Next(sg) do
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            end
        end
    end
end
--Equip functions
function s.eqfilter(c,ec)
    return c:GetFlagEffect(id)>0
        and c:IsType(TYPE_UNION)
        and c:CheckUnionTarget(ec)
        and c:IsCanBeEffectTarget()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local sc=eg:GetFirst()
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.eqfilter(chkc,sc) end
    if chk==0 then 
        return sc:IsControler(tp) 
            and sc:IsFaceup()
            and sc:IsLocation(LOCATION_MZONE)
            and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_REMOVED,0,1,nil,sc)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,1,nil,sc)
    e:SetLabelObject(sc)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local sc=e:GetLabelObject() -- Get stored summoned monster
    local tc=Duel.GetFirstTarget()
    -- Validate both monsters
    if not (sc and sc:IsFaceup() and sc:IsLocation(LOCATION_MZONE)) then return end
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- Perform equip
    if Duel.Equip(tp,tc,sc) then
        aux.SetUnionState(tc)
        --Cannot be Special Summoned
        local e_sp=Effect.CreateEffect(e:GetHandler())
        e_sp:SetType(EFFECT_TYPE_SINGLE)
        e_sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e_sp:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e_sp:SetDescription(aux.Stringid(id,2))
        e_sp:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e_sp)
    end
end
