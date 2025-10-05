--Delta Reactor (K)
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    -- GY Protection
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetCountLimit(1,id+1)
    c:RegisterEffect(e2)
end
-- Reactor Codes
local REACTORS={89493368,15175429,52286175} -- SK, RE, Y FI
local SKYFIRE=16898077
-- Cost Filter
function s.spcfilter(c,code)
    return c:IsCode(code) and c:IsAbleToGraveAsCost()
end
-- Resource Condition
function s.rescon(sg,e,tp,mg)
    return aux.ChkfMMZ(1)(sg,e,tp,mg) 
        and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),table.unpack(REACTORS))
end
-- Helper for checking codes
function s.chk(c,sg,g,code,...)
    if not c:IsCode(code) then return false end
    local res
    if ... then
        g:AddCard(c)
        res=sg:IsExists(s.chk,1,g,sg,g,...)
        g:RemoveCard(c)
    else
        res=true
    end
    return res
end
-- Target/Activation
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>-3
        and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,REACTORS[1])
        and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,REACTORS[2])
        and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,REACTORS[3])
        and Duel.IsExistingMatchingCard(s.skyfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
    local b2=s.reactor_check(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        op=0
    else
        op=1
    end
    e:SetLabel(op)
    if op==0 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
        local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,3,0,0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
    else
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
    end
end
function s.activate(e,tp)
    local op=e:GetLabel()
    -- Effect 1: Summon SKY FIRE
    if op==0 then
        local g1=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,REACTORS[1])
        local g2=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,REACTORS[2])
        local g3=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,REACTORS[3])
        local g=g1:Clone()
        g:Merge(g2)
        g:Merge(g3)
        local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TOGRAVE)
        if #sg==3 and Duel.SendtoGrave(sg,REASON_COST)==3 then
            local g=Duel.SelectMatchingCard(tp,s.skyfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
			end
        end
    -- Effect 2: Summon Reactors
    else
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
        local sg=Group.CreateGroup()
        local zones=LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
        -- Collect available Reactors
        local available={}
        for _,code in ipairs(REACTORS) do
            available[code]=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,zones,0,nil,e,tp,code)
        end
        -- Select one of each
        for _,code in ipairs(REACTORS) do
            if #available[code]==0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=available[code]:Select(tp,1,1,nil)
            if #g==0 then return end
            sg:Merge(g)
            -- Remove selected card from available options
            for _,c in ipairs(g) do
                for k,v in pairs(available) do
                    available[k]:RemoveCard(c)
                end
            end
        end
        if #sg==3 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
-- Sky Fire Filter
function s.skyfilter(c,e,tp)
    return c:IsCode(SKYFIRE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.spfilter(c,e,tp,code)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.reactor_check(tp)
    for _,code in ipairs(REACTORS) do
        if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,code) then
            return false
        end
    end
    return true
end
-- GY Protection
function s.repfilter(c,tp)
    return c:IsFaceup() and (c:IsCode(SKYFIRE) or c:IsSetCard(0x63))
        and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
        and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
        return true
    end
    return false
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end