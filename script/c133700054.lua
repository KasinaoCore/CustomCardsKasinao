--Alchemy Beast - Moonface the Silver
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --special summon rule
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)
    --direct attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e1)
    --destruction replacement
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end
s.listed_names={133700050,6500778}
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(133700050) or c:IsCode(6500778))
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) 
end
function s.repfilter(c,tp,e)
    return c:IsControler(tp) and c:IsFaceup() 
        and c:IsSetCard(0x501) and c:IsLocation(LOCATION_ONFIELD)
        and c:IsReason(REASON_EFFECT+REASON_BATTLE) 
        and not c:IsReason(REASON_REPLACE)
        and c~=e:GetHandler() -- Critical fix: Exclude itself
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp,e) -- Pass 'e' to filter
        and c:IsDestructable() end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer(),e) -- Pass 'e' to filter
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end