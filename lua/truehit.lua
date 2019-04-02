--[[
Fire Emblem 7 (as with most of the games in the series) use a mechanic called "True Hit"
When attacking enemies, the game has a displayed hit rate %, which isn't actually used to determine if the attack hits or misses.
True Hit's name is derived from the fact that the game consumes two random numbers instead of one. 
If only one random number was used, then the displayed hit rate would be accurate. 
However, the game actually uses two random numbers and averages them. 

In short, if your hit rate is displayed at 50 and above, the unit is more likely to hit.
And also, if your hit rate is displayed at 49 and below, the unit is more likely to miss.

Source for a visual representation: https://serenesforest.net/general/true-hit/
--]]

function GetTrueHit(Displayed_Hit)
    if(Displayed_Hit < 51)
    then
        return(2 * Displayed_Hit * (2 * Displayed_Hit + 1) / 200)
    else
        Displayed_Miss = 100 - Displayed_Hit
        return(100 - (2 * Displayed_Miss * (2 * Displayed_Miss - 1) / 200))
    end
end

--If you want to see the conversion table from displayed hit to true hit in the console
function DisplayAllHits()
    for i=0, 100, 1 
    do
        print(GetTrueHit(i))
    end
end