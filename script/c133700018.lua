--Dark Tuner Dark Goddess Wittaka
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Special Summon procedure
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    -- Name and Level change effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
end
-- Special Summon condition
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLP(tp)>=1000
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- Special Summon filter (non-DARK Synchro Monster)
function s.spfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and not c:IsAttribute(ATTRIBUTE_DARK)
end
-- Special Summon operation (pay 1000 LP)
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.PayLPCost(tp,1000)
end
-- Level change effect
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
    local lv=Duel.AnnounceNumber(tp,1,2,3,4,5,6,7,8)
    e:SetLabel(lv)
end
-- Level change operation
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        -- Change name to "Supay"
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(78552773)
        e1:SetReset(RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        -- Change Level
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_LEVEL)
        e2:SetValue(e:GetLabel())
        e2:SetReset(RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end