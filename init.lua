local rpg_guns = {}
rpg_guns.frozen_time = 7

rpg_guns.frozen = {}
rpg_guns.physics = {}

minetest.register_on_joinplayer(function(obj)
    rpg_guns.physics[obj] = obj:get_physics_override()
end)
minetest.register_on_leaveplayer(function(obj, timed_out)
    if rpg_guns.frozen[obj] then
        rpg_guns.frozen[obj] = nil
    end
end)

minetest.register_globalstep(function(dtime)
    local current = minetest.get_us_time() / 1000000
    
    for user, tbl in pairs(rpg_guns.frozen) do
        if current - tbl.time > rpg_guns.frozen_time then
            user:set_physics_override({speed = rpg_guns.physics[user].speed, jump = rpg_guns.physics[user].jump})
            user:set_properties({textures = rpg_guns.frozen[user].texture})
            rpg_guns.frozen[user] = nil
        end
    end
end)

local function freeze(itemstack, user, obj)
    if obj:is_player() and obj ~= user then
        obj:set_physics_override({speed = 0, jump = 0})
        rpg_guns.frozen[obj] = {time = minetest.get_us_time() / 1000000, texture = obj:get_properties().textures}
        obj:set_properties({textures = {"default_ice.png"}})
    end
    return false
end

gunkit.register_firearm("rpg_guns:smg_ice", {
    description = "Ice Smgay",
    inventory_image = "smgay.png",
    wield_scale = {x = 2, y = 2, z = 1},
    mag_type = "smg",

    callbacks = {alt_fire = {hit = freeze}},

    fire = {
        bullet_texture = "bullet.png",
        bullet_sound = "gunfire",
        bullet_shell_sound = "bullet_shell",

        range = 60,
        speed = 300,
        spread = 4,
        dmg = 2,
        shots = 1,
        interval = 0.1,
        zoom = 1.5,
    },
    alt_fire = {
        bullet_texture = "default_ice.png",
        bullet_sound = "gunfire",
        bullet_shell_sound = "bullet_shell",

        range = 30,
        speed = 300,
        spread = 6,
        dmg = 0,
        shots = 9,
        interval = 5,
    },
})

gunkit.register_mag("rpg_guns:smg_mag", {
    description = "Smg Mag",
    inventory_image = "smg_mag.png",
    type = "smg",
    ammo = "rpg_guns:bullet",
    max_ammo = 100,
})

minetest.register_craftitem("rpg_guns:bullet", {
    description = "Bullet",
    inventory_image = "bullet_shell.png",
})

minetest.register_craft({
    output = "rpg_guns:smg_ice",
    recipe = {
        {"default:ice", "default:ice", "default:ice"},
        {"default:steel_ingot", "tnt:gunpowder", "default:steel_indot"},
        {"default:steel_ingot", "", ""},
    }
})

minetest.register_craft({
    output = "rpg_guns:smg_mag",
    type = "shapeless",
    recipe = {"default:steel_ingot", "default:steel_ingot"}
})

minetest.register_craft({
    output = "rpg_guns:bullet",
    type = "shapeless",
    recipe = {"default:gold_ingot", "default:gold_ingot"}
})