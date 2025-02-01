--Elemental HERO Clay Guardsman (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
	--fusion material (2 clayman)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,false,false,84327329,2)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
    --destroy self and opponent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		--Metamorphosis
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCondition(s.con)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x3008}
s.material_setcode={0x8,0x3008}
--Damage effect
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	Duel.Damage(p,ct*500,REASON_EFFECT)
end
--Destroy effect
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	rc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToEffect(e) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
--Metamorphosis Handling
function s.filter(c)
	return c:GetOriginalCode()==46411259 --Metamorphosis
end
function s.con(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,0xff,0xff,1,nil)
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0xff,0xff,nil)
	g:ForEach(function(c)
		local acte=c:GetActivateEffect()
		acte:SetTarget(s.metatarget)
		acte:SetOperation(s.metaactivate)
	end)
end
--Updated Target & Operation for Metamorphosis
function s.metatarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,s.filter1,1,nil,e,tp)
	end
	local rg=Duel.SelectReleaseGroup(tp,s.filter1,1,1,nil,e,tp)
	e:SetLabelObject(rg:GetFirst())
	e:SetLabel(rg:GetFirst():GetLevel())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
--Filter for Clayman specifically
function s.filter1(c,e,tp)
	return c:IsCode(84327329) -- Must be Clayman
end
--Filter for Clay Guardsman in Extra Deck
function s.filter2(c,lv,e,tp,tc)
	return c:IsType(TYPE_FUSION) and c:GetLevel()==lv
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,tc:IsCode(84327329) and c:GetOriginalCode()==id,false)
end
--Activate Metamorphosis
function s.metaactivate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,tc):GetFirst()
	if sc then
		local isClaymanSummon = tc:IsCode(84327329) and sc:GetOriginalCode()==id
		if Duel.SpecialSummon(sc,0,tp,tp,isClaymanSummon,false,POS_FACEUP)>0 and isClaymanSummon then
			sc:CompleteProcedure()
		end
	end
end
--Filter for Clay Guardsman in Extra Deck (for activation)
function s.filter3(c,lv,e,tp,tc)
	return c:IsType(TYPE_FUSION) and c:GetLevel()==lv
		and c:IsCanBeSpecialSummoned(e,0,tp,tc:IsCode(84327329) and c:GetOriginalCode()==id,false)
end