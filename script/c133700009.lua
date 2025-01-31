--Different Dimension Hangar
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.retarget)
    e1:SetOperation(s.reactivate)
    c:RegisterEffect(e1)
    local sg=Group.CreateGroup()
    sg:KeepAlive()
    e1:SetLabelObject(sg)
    --Special Summon the banished Unions
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCountLimit(1,id+1) -- Once per turn limit
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    e3:SetLabelObject(sg)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    --Cannot have multiple copies
    c:SetUniqueOnField(1,0,id)
end
function s.refilter(c)
    return c:IsType(TYPE_UNION) and c:IsLevelBelow(4) and c:IsAbleToRemove()
end
function s.retarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_DECK,0,3,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
function s.reactivate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_DECK,0,nil)
    if #g>=3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,3,3,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        local og=e:GetLabelObject()
        og:Clear()
        for tc in aux.Next(sg) do
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            og:AddCard(tc)
        end
    end
end
function s.spfilter(c,e,tp,ec)
    return c:GetFlagEffect(id)>0 
        and c:CheckUnionTarget(ec)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ec=eg:GetFirst()
    if chk==0 then
        return ec and ec:IsControler(tp) 
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,ec)
    end
    Duel.SetTargetCard(ec)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local ec=Duel.GetFirstTarget()
    if not ec or not ec:IsRelateToEffect(e) then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,ec)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
            --Cannot attack
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            --Cannot be tributed
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UNRELEASABLE_SUM)
            e2:SetValue(1)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            local e3=e2:Clone()
            e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
            tc:RegisterEffect(e3)
        end
    end
end