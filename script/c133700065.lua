--Magnet Fusion (K)
Duel.LoadScript("c1337.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff({handler=c,fusfilter=s.fusfilter,matfilter=s.matfilter,extrafil=s.fextra,extraop=Fusion.ReleaseMaterial,extratg=s.extratg,stage2=s.stage2}))
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
function s.atklimit(e,c)
	return c:IsControler(1-e:GetHandlerPlayer())
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		--Cannot be targeted by opponent's card effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3061)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(aux.tgoval)
		tc:RegisterEffect(e1)
	end
end