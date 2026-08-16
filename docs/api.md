# Contrat API MiamAI

Base URL locale: `http://localhost:8080/api`

## Chat

`POST /assistant/chat`

```json
{
  "sessionId": null,
  "message": "Je veux manger asiatique ce soir, pour 3 personnes"
}
```

Retourne un `sessionId`, un message assistant, des propositions de recettes, et parfois une recette ou un panier recalculés.

Commandes simulées gérées :

- `Prends moins cher`
- `On sera finalement 4`
- `Remplace le poulet par de la dinde`
- `Enlève les champignons`

## Recettes

`POST /recipes/select`

```json
{
  "recipeId": "poulet-yakitori",
  "servings": 3
}
```

`PATCH /recipes/selected`

```json
{
  "servings": 4,
  "removeIngredients": [],
  "replacements": {
    "poulet": "Dinde"
  }
}
```

## Panier

`POST /baskets/build`

```json
{
  "recipeId": "poulet-yakitori",
  "servings": 3
}
```

`POST /baskets/{basketId}/lines/{ingredientKey}/select`

```json
{
  "productRef": "LEC-DIN-600"
}
```

`POST /baskets/{basketId}/cheapest`

Sélectionne les alternatives disponibles les moins chères.

`POST /baskets/{basketId}/handoff`

Retourne un état d'envoi vers Leclerc. En mode simulation, l'insertion automatique Leclerc est volontairement indisponible.

## Préférences

`GET /preferences`

`PUT /preferences`

Le profil contient le Drive préféré, le nombre de personnes, le budget hebdomadaire, le régime par défaut, les restrictions, les ingrédients exclus, les équipements, les rappels et les promotions.

## Mes Repas

`GET /meals`

Retourne une surface compatible avec la maquette `Ma semaine`. `weeklyPlanningEnabled` vaut `false` tant que l'optimisation multi-recettes n'est pas implémentée.
