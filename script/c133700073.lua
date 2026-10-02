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
	--Add to hand 1 "Magnet Warrior" or "Magna Warrior" Monster from your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
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
s.listed_series={SET_MAGNET_WARRIOR, SET_MAGNA_WARRIOR}
function s.thfilter(c)
	return (c:IsSetCard(SET_MAGNET_WARRIOR) or c:IsSetCard(SET_MAGNA_WARRIOR)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end