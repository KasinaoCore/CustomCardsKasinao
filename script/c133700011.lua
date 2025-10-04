--Dark Tuner Catastrogue (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
    -- Level adjustment on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.lvtg)
    e1:SetOperation(s.lvop)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
    e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    
    -- Destruction effect when used for DARK/EARTH/WATER Synchro
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

function s.lvfilter(c)
    return c:IsFaceup() and c:GetLevel()>0 and c:GetLevel()<=4
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(5-tc:GetLevel())
        e1:SetReset(RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetHandler():GetReasonCard()
    return r==REASON_SYNCHRO and (rc:IsAttribute(ATTRIBUTE_DARK) or rc:IsAttribute(ATTRIBUTE_EARTH) or rc:IsAttribute(ATTRIBUTE_WATER))
end

function s.synchrofilter(c)
    return c:IsFaceup() and c:IsOnField()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.synchrofilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.synchrofilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.synchrofilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end