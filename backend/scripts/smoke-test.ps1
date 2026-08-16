$ErrorActionPreference = "Stop"

$body = @{
    sessionId = $null
    message = "Je veux manger asiatique ce soir, pour 3 personnes"
} | ConvertTo-Json

$chat = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/assistant/chat" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

$recipe = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/recipes/select" `
    -Method Post `
    -ContentType "application/json" `
    -Body (@{
        recipeId = $chat.proposals[0].id
        servings = 3
    } | ConvertTo-Json)

$basket = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/baskets/build-selected" `
    -Method Post `
    -ContentType "application/json" `
    -Body "{}"

[PSCustomObject]@{
    sessionId = $chat.sessionId
    proposalCount = $chat.proposals.Count
    selectedRecipe = $recipe.title
    basketLines = $basket.lines.Count
    basketTotal = $basket.totalPrice
    basketValid = $basket.valid
} | ConvertTo-Json
