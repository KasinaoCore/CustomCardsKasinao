--Dark Flare Summoning
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsCode,13722870),Card.IsAbleToDeck,s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
end
s.listed_names={13722870,CARD_FLAME_SWORDSMAN,CARD_DARK_MAGICIAN}
function s.matfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,CARD_FLAME_SWORDSMAN,CARD_DARK_MAGICIAN) and c:IsAbleToDeck()
end
function s.frec(c,tp,sg,g,code,...)
	if not c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) then return false end
	if ... then
		g:AddCard(c)
		local res=sg:IsExists(s.frec,1,g,tp,sg,g,...)
		g:RemoveCard(c)
		return res
	else return true end
end
function s.fcheck(tp,sg,fc,mg)
	return #sg==2 and sg:IsExists(s.frec,1,nil,tp,sg,Group.CreateGroup(),CARD_FLAME_SWORDSMAN,CARD_DARK_MAGICIAN)
end
function s.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g,s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
