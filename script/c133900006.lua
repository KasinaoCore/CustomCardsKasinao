--Beetron-3 Spider Base (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
	--Union procedure
	aux.AddUnionProcedure(c,s.unfilter)
	--atk/def boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--equip Beetleturbo when sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end

function s.unfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.eqfilter(c)
	return c:IsCode(133900004) and c:IsFaceup() --BT-1 Beetletop
end
function s.eqmatfilter(c,ec)
	return c:IsCode(133900005) and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec) --BT-2 Beetleturbo
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqmatfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc)
	local ec=g:GetFirst()
	if ec and Duel.Equip(tp,ec,tc) then
		aux.SetUnionState(ec)
	end
end
