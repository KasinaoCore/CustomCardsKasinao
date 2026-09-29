--Magnet Warrior Omega Minus (K)
local s,id=GetID()
function s.initial_effect(c)
	--Negate an attack involving 2 Level 5 or higher monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atknegcon)
	e1:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e1)
	-- Gain Levels equal to the number of "Magnet Warriors" in your GY with different names until the End Phase.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.lvop)
	e2:SetTarget(s.lvtg)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MAGNET_WARRIOR}
function s.atknegcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1=Duel.GetAttacker()
	local bc2=Duel.GetAttackTarget()
	return bc1:IsLevelAbove(5) and bc2 and bc2:IsLevelAbove(5) and bc2:IsFaceup()
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_MAGNET_WARRIOR)
        return g:GetClassCount(Card.GetCode)>0 and e:GetHandler():HasLevel()
    end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_MAGNET_WARRIOR)
        local ct=g:GetClassCount(Card.GetCode)
        if ct>0 then
            c:UpdateLevel(ct,RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
        end
    end
end