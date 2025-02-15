--Last Tusk Mammoth
local s,id=GetID()
function s.initial_effect(c)
    -- Gemini Status
    Gemini.AddProcedure(c)
    
    -- (1) Switch ATK/DEF when Gemini summoned
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_SWAP_AD)
    e1:SetCondition(Gemini.EffectStatusCondition)
    c:RegisterEffect(e1)
    
    -- (2) Become EARTH attribute
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetValue(ATTRIBUTE_EARTH)
    e2:SetCondition(Gemini.EffectStatusCondition)
    c:RegisterEffect(e2)
    
    -- (3) Add counter each End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_COUNTER)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.ctcon)
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)
    
    -- (4) ATK reduction effect
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0,LOCATION_MZONE)
    e4:SetValue(s.atkval)
    e4:SetCondition(Gemini.EffectStatusCondition)
    c:RegisterEffect(e4)
end

-- Counter condition (must be active Gemini)
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Gemini.EffectStatusCondition(e)
end

-- Add counter operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:AddCounter(0x1950,1) -- Use your preferred counter ID
    end
end

-- ATK reduction calculation
function s.atkval(e,c)
    return e:GetHandler():GetCounter(0x1950)*-500
end