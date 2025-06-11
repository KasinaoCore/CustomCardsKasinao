--Beckon to the Dark (K)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local player_ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local opp_total=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
	local opp_main=Duel.GetMatchingGroupCount(s.filter,1-tp,LOCATION_MZONE,0,nil)
	return (player_ct==0 or player_ct<opp_total) and opp_main>=2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    return Duel.IsExistingMatchingCard(s.filter,1-tp,LOCATION_MZONE,0,1,nil)
  end
  Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SetTargetCard(g)
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and s.filter(tc) then
    Duel.SendtoGrave(tc,REASON_EFFECT)
  end
end
function s.filter(c)
  return c:IsAbleToGrave()
end
