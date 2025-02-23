--Nightmare Mirror
local s,id=GetID()
function s.initial_effect(c)
    --Activate (trap)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Direct attack check (no monsters on field)
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
        and Duel.GetAttacker():IsCanBeEffectTarget(e)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local tc=Duel.GetAttacker()
    if chkc then return chkc==tc end
    if chk==0 then return true end
    Duel.SetTargetCard(tc)
    --Store CURRENT ATK at activation
    e:SetLabel(tc:GetAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.NegateAttack() then
        local atk=e:GetLabel()
        local disc=math.floor(atk/1000)
        if disc>=1 then
            --Check hand size
            local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            if #g<disc then return end
            --Discard prompt
            if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                local discarded=Duel.DiscardHand(tp,aux.TRUE,disc,disc,REASON_EFFECT+REASON_DISCARD)
                if discarded>0 then
                    Duel.Damage(1-tp,discarded*1000,REASON_EFFECT)
                end
            end
        end
    end
end