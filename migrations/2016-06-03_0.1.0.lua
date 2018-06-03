-- On first install, this unlocks the steering remote for any force
-- that has already researched automobilism 
for _, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()

  -- create tech/recipe table once
  local techs = force.technologies
  local recipes = force.recipes
  if techs["automobilism"].researched then
    recipes["steering-remote"].enabled = true
  end
end