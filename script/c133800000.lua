--New Order 4: Etheric Anubis (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Xyz summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),4,2)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROY,EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED))
			and chkc:IsControler(tp)
			and chkc:IsType(TYPE_TRAP)
			and chkc:IsSSetable()
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and eg:IsExists(function(c)
				return c:IsPreviousControler(tp)
					and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
					and c:IsType(TYPE_TRAP)
					and c:IsSSetable()
			end,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=eg:Filter(function(c)
		return c:IsPreviousControler(tp)
			and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
			and c:IsType(TYPE_TRAP)
			and c:IsSSetable()
	end,nil)
	local tg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tg)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SSet(tp,tc)>0 then
		-- Allow activation this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end