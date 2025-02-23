local s,id=GetID()
function s.initial_effect(c)
    -- Activate 
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
-- Declare card name and opponent draws 1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local declared=Duel.AnnounceCard(tp)
    e:SetLabel(declared)
    Duel.Draw(1-tp,1,REASON_COST)
    local tc=Duel.GetOperatedGroup():GetFirst()
    if tc then
        Duel.ConfirmCards(tp,tc)
        e:SetLabelObject(tc)
    end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local tc=e:GetLabelObject()
    if tc and tc:IsCode(e:GetLabel()) then
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,1-tp,LOCATION_HAND+LOCATION_ONFIELD)
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local declared=e:GetLabel()
    local tc=e:GetLabelObject()
    if tc and tc:IsCode(declared) then
        local opt=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
        if opt==0 then
            local g=Group.CreateGroup()
            local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
            if #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                g:Merge(hg:RandomSelect(tp,1))
            end
            local mg=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
            if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                g:Merge(mg:Select(tp,1,1,nil))
            end
            local sg=Duel.GetMatchingGroup(nil,1-tp,LOCATION_SZONE,0,nil)
            if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                g:Merge(sg:Select(tp,1,1,nil))
            end
            if #g>0 then
                Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
            end
        else
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
            local g=Duel.GetMatchingGroup(Card.IsCode,1-tp,LOCATION_DECK,0,nil,tc:GetCode())
            if #g>0 then
                Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end