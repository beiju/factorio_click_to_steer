data:extend({
  {
    type = "capsule",
    name = "steering-remote",
    icon = "__ClickToSteer__/graphics/steering-wheel-icon.png",
    icon_size = 32,
    flags = {"goes-to-quickbar"},
    -- Can't have a capsule action that just raises a script event, so I
    -- do a no-effect action and catch all capsule events in control.lua,
    -- where I also give the player back the capsule they used up. Yes,
    -- it's dumb. Submit a pull request if you have a better way!
    capsule_action =
    {
      type = "use-on-self",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 0.1,
        range = 0,
        ammo_type =
        {
          category = "capsule",
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = {type = "physical", amount = 0}
              }
            }
          }
        }
      }
    },
    subgroup = "transport",
    order = "c[personal-transport-accessories]-a[steering-remote]",
    stack_size = 1
  },
})