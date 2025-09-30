--Alchemy Beast - Leon the Lead
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
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
    --attack storage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(aux.bdcon)
	e3:SetOperation(s.bdop)
	c:RegisterEffect(e3)
    --banish your deck (3) if destroys
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.bcon)
	e4:SetTarget(s.btg)
	e4:SetOperation(s.bop)
	c:RegisterEffect(e4)
end
s.listed_names={133700050,6500778}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(133700050) or c:IsCode(6500778)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) 
end
function s.condition(e)
	local phase=Duel.GetCurrentPhase()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL)
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.bcon(e,tp,eg,ep,ev,re,r,rp)
    -- Check if this card destroyed a monster by battle this turn
    -- AND there are at least 3 cards in your Deck
    return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
        and e:GetHandler():GetFlagEffect(id)>0
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,3)
    if #g==3 then
        Duel.DisableShuffleCheck()
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end