-- Infernity Zero (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
    -- Summon restrictions
    c:EnableReviveLimit()
    c:EnableUnsummonable()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.selfsum)
    c:RegisterEffect(e0)
    -- Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.damcon)
    e1:SetCost(s.discost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetCondition(s.atkcon)
    c:RegisterEffect(e2)
    -- No battle damage
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET) 
    e3:SetTargetRange(1,0)
    e3:SetValue(1)
    c:RegisterEffect(e3)
	--No effect damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.damval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e5)
    -- Battle indestructible
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e6:SetValue(1)
    e6:SetCondition(s.emptyhand)
    c:RegisterEffect(e6)
    -- Counter system 
    local e7=Effect.CreateEffect(c)
    e7:SetCategory(CATEGORY_COUNTER)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e7:SetCode(EVENT_PHASE+PHASE_END)
    e7:SetTarget(s.cttg) 
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1) 
    e7:SetCondition(s.ctcon) 
    e7:SetOperation(s.ctop)
    c:RegisterEffect(e7)
    -- Destruction and damage trigger
    local e8=Effect.CreateEffect(c)
    e8:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e8:SetCode(EVENT_PHASE+PHASE_END)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCountLimit(1)
    e8:SetCondition(s.descon)
    e8:SetTarget(s.destg)
    e8:SetOperation(s.desop)
    c:RegisterEffect(e8)
    -- Initialize counter
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.selfsum(e,se,sp,st)
    return se:GetHandler()==e:GetHandler()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLP(tp)>2000 then return false end
    local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
    return ex and (cp==tp or cp==PLAYER_ALL)
end
function s.damval(e,re,val,r,rp,rc)
	if rp~=e:GetHandlerPlayer() and (r&REASON_EFFECT)~=0 then return 0
	else return val end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local atker=Duel.GetAttacker()
    return atker and atker:IsControler(1-tp) 
        and not Duel.GetAttackTarget()
        and Duel.GetLP(tp)<=2000
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0) > 1
    end
    
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    g:RemoveCard(c)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
    end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return c:IsCanBeSpecialSummoned(e,0,tp,true,false) 
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
end
function s.emptyhand(e)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetCounter(0x1951) < 3 end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:AddCounter(0x1951,1) -- Add doom counter
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1951)>=3 -- Check for 3+ counters
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
        Duel.Damage(tp,2000,REASON_EFFECT) -- Inflict damage after destruction
    end
end
