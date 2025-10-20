--Magnet Fusion (K)
Duel.LoadScript("c1337.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff({handler=c,fusfilter=s.fusfilter,matfilter=s.matfilter,extrafil=s.fextra,extraop=Fusion.ReleaseMaterial,extratg=s.extratg,stage2=s.stage2,checkmat=s.checkmat}))
end
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION)
end
function s.matfilter(c,e,tp)
	return c:IsReleasableByEffect()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsReleasableByEffect),tp,LOCATION_HAND|LOCATION_MZONE,0,nil),s.checkmat
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_ROCK)
end	
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetValue(s.atlimit)
		tc:RegisterEffect(e1)
	end
end
