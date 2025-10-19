--Magnet Fusion (K)
Duel.LoadScript("c1337.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff
	{handler=c,fusfilter=s.fusfilter,matfilter=s.matfilter,extrafil=s.fextra,extraop=Fusion.ReleaseMaterial,extratg=s.extratg}
	c:RegisterEffect(e1)
end
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION)
end
function s.matfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsReleasableByEffect()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsReleasableByEffect),tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
