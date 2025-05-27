--New Order 10: Etheric Horus (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),10,2,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	c:EnableReviveLimit()
	--Destroy cards equal to field card difference
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetCost(Cost.Detach(1))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_names={133800002} --NO. 8: Etheric Sebek
s.listed_series={SET_RANK_UP_MAGIC,0x801,0x802}
function s.cfilter(c)
	return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsSpell() and c:IsDiscardable()
end
function s.ovfilter(c,tp,lc)
	return c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,133800002) and c:IsFaceup()
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if tc then
		Duel.SendtoGrave(tc,REASON_DISCARD|REASON_COST)
		return true
	else return false end
end
--Opponent has to destroy cards equal to difference lololol
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD) > Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local diff = Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD) - Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if chk==0 then return diff > 0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,diff,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct = Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD) - Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if ct <= 0 then return end
	local g = Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	if #g >= ct then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
		local sg = g:Select(1-tp,ct,ct,nil)
		if #sg > 0 then
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end