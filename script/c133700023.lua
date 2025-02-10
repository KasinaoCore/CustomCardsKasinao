--Ancient Tome (Kasinao)
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Swap/Draw
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
s.listed_names={133700024,133700025,133700022} --Ancient Gate, Ancient Key, Ancient City
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsPlayerCanDraw(tp,1)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Send to Deck cost
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
    if #g==0 then return end
    if Duel.SendtoDeck(g,nil,1,REASON_EFFECT)==0 then return end
    -- Draw and check
    local dc=Duel.Draw(tp,1,REASON_EFFECT)
    if dc==0 then return end
    -- Ancient Card Check
    local og=Duel.GetOperatedGroup()
    local tc=og:GetFirst()
    if tc:IsCode(133700021,133700025) then
        -- Reveal Ancient Card
        if Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
            Duel.ConfirmCards(1-tp,tc)
            -- Search Ancient City
            local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
end
function s.thfilter(c)
    return c:IsCode(133700022) and c:IsAbleToHand()
end