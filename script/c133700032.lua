-- Aeris (Kasinao)
local s, id = GetID()
function s.initial_effect(c)
    -- Declare 2 Attributes, opponent chooses 1 at the start of the Battle Phase
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.attrcon)
    e1:SetOperation(s.attrop)
    c:RegisterEffect(e1)
    -- Destroy the attacked monster if it shares the same Attribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
function s.attrcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer() == tp
end
function s.attrop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTRIBUTE)
    local atts = Duel.AnnounceAttribute(tp, 2, ATTRIBUTE_ALL)
    Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_ATTRIBUTE)
    local att = Duel.AnnounceAttribute(1-tp, 1, atts)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(att)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsAttackPos()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc = e:GetHandler():GetBattleTarget()
    if chk==0 then return tc and tc:IsFaceup() and tc:IsAttribute(e:GetHandler():GetAttribute()) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc = e:GetHandler():GetBattleTarget()
    if tc and tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsAttribute(e:GetHandler():GetAttribute()) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end