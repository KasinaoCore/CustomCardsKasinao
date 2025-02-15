--Last Tusk Mammoth
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x1950)
    c:SetCounterLimit(0x1950,3)
    Gemini.AddProcedure(c)
	--Original DEF becomes 800
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SET_BASE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(Gemini.EffectStatusCondition)
	e0:SetValue(1200)
	c:RegisterEffect(e0)
    local e1=e0:Clone()
	e1:SetCode(EFFECT_SET_BASE_DEFENSE)
	e1:SetValue(800)
    c:RegisterEffect(e1)
    --Become EARTH attribute
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetValue(ATTRIBUTE_EARTH)
    e2:SetCondition(Gemini.EffectStatusCondition)
    c:RegisterEffect(e2)
    --Add counter each End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_COUNTER)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.ctcon)
    e3:SetTarget(s.cttg) 
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)
    --ATK reduction effect
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0,LOCATION_MZONE)
    e4:SetValue(s.atkval)
    e4:SetCondition(Gemini.EffectStatusCondition)
    c:RegisterEffect(e4)
	--Decay counter destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
    e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	c:RegisterEffect(e5)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetCounter(0x1950) < 3 end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Gemini.EffectStatusCondition(e)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:AddCounter(0x1950,1) -- Decay Counter
    end
end
function s.atkval(e,c)
    return e:GetHandler():GetCounter(0x1950)*-500   
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
		and e:GetHandler():IsCanRemoveCounter(tp,0x1950,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1950,1,REASON_EFFECT)
	return true
end
