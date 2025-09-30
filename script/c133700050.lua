-- Alchemic Kettle (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- banish your cards (except light/pyro)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
    e2:SetTarget(s.reptg1)
    e2:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e2)
    -- atk boost for each w/ different name
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x501))
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)
    -- banish op cards
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
    e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(0,LOCATION_ONFIELD)
    e4:SetTarget(s.reptg2)
    e4:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e4)
end
function s.reptg1(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x501),tp,LOCATION_MZONE,0,nil)
    return c:IsControler(tp) 
        and g:GetClassCount(Card.GetCode)>=1
        and not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PYRO))
end
function s.atkval(e,c)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x501),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
    local unique=g:GetClassCount(Card.GetCode)
    return unique>=2 and (unique*100) or 0 
end
function s.reptg2(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x501),tp,LOCATION_MZONE,0,nil)
    return c:IsControler(1-tp) 
        and g:GetClassCount(Card.GetCode)>=3
end

function s.rmtarget1(e,c)
	return c:GetOwner()==e:GetHandlerPlayer()
end

function s.rmtarget2(e,c)
	return c:GetOwner()==e:GetHandlerPlayer()
end