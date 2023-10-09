local menu = require("oop_menu")

local AnimatedMat       = nil
local SpaceMaterial     = nil
local MetallicMaterial  = nil
local FlatMaterial      = nil
local SolidMaterial     = nil

local LocalChamPath = "visuals>models>local"
local ChamOptions = {"Off", "Space", "Animated", "Metallic"}

local WeaponOptions     = menu.add_combo("Viewmodel weapon", LocalChamPath, ChamOptions)
local WeaponColor       = menu.add_colorpicker(WeaponOptions, true, render.color("#000000"))
local WeaponColor2      = menu.add_colorpicker(WeaponOptions, true, render.color("#3236B8"))
local WeaponWireframe   = menu.add_checkbox("Wireframe", LocalChamPath)
local WeaponOverlay     = menu.add_checkbox("Overlay", LocalChamPath)
local WeaponMetallicOverlay = menu.add_checkbox("Metallic overlay", LocalChamPath)
local WeaponColor3      = menu.add_colorpicker(WeaponMetallicOverlay, true, render.color("#383838"))

WeaponOptions:add_callback(function (Type)
    WeaponWireframe:set_visible(Type > 1)
    WeaponOverlay:set_visible(Type ~= 0)
    WeaponMetallicOverlay:set_visible(Type ~= 0 and Type ~= 3)
end, true)

local ArmOptions     = menu.add_combo("Viewmodel arm", LocalChamPath, ChamOptions)
local ArmColor       = menu.add_colorpicker(ArmOptions, true, render.color("#000000"))
local ArmColor2      = menu.add_colorpicker(ArmOptions, true, render.color("#3236B8"))
local ArmWireframe   = menu.add_checkbox("Wireframe ", LocalChamPath)
local ArmOverlay     = menu.add_checkbox("Overlay ", LocalChamPath)
local ArmMetallicOverlay = menu.add_checkbox("Metallic overlay ", LocalChamPath)
local ArmColor3      = menu.add_colorpicker(ArmMetallicOverlay, true, render.color("#383838"))

ArmOptions:add_callback(function (Type)
    ArmWireframe:set_visible(Type > 1)
    ArmOverlay:set_visible(Type ~= 0)
    ArmMetallicOverlay:set_visible(Type ~= 0 and Type ~= 3)
end, true)

function on_draw_model_execute(dme, index, model_name)
    if not model_name then
        return
    end

    local IsArm = model_name:find("arm")
    local IsWeapon = not IsArm and model_name:find("models/weapons/v_")

    if not AnimatedMat then
        AnimatedMat = mat.create("jewls_animated", "VertexLitGeneric",
        [[
            "VertexLitGeneric"
            {
                "$basetexture"	"models/inventory_items/dogtags/dogtags_lightray"
                "$additive"		"1"
                "$vertexcolor"	"1"
                "$vertexalpha"	"1"
                "$translucent"	"1"
                proxies
                {
                    texturescroll
                    {
                        "texturescrollvar"		"$basetexturetransform"
                        "texturescrollrate"		"0.8"
                        "texturescrollangle"	"130"
                    }
                }
            }   
        ]])
        return
    end
    
    if not SpaceMaterial then
        SpaceMaterial = mat.create("jewls_space", "VertexLitGeneric",
        [[
            "VertexLitGeneric"
            {
                "$basetexture"	"dev/snowfield"
                "$basetexturetransform" "center .5 .5 scale 0.1 1 rotate 0 translate 0 0"
                "$additive"		"1"
                "$vertexcolor"	"1"
                "$vertexalpha"	"1"
                "$translucent"	"1"
                proxies
                {
                    texturescroll
                    {
                        "texturescrollvar"		"$basetexturetransform"
                        "texturescrollrate"		"0.05"
                        "texturescrollangle"	"-180"
                    }
                }
            }
        ]])
        return
    end

    if not MetallicMaterial then
        MetallicMaterial = mat.create("jewls_metallic", "VertexLitGeneric",
        [[
            "VertexLitGeneric"
            {
                "$baseTexture" 			"black"
                "$bumpmap"				"models\inventory_items\trophy_majors\matte_metal_normal"
                "$additive" 1
                "$envmap"		"Editor\cube_vertigo"
                "$envmapcontrast" "16"
                "$envmaptint" "[.2 .2 .2]"
                "$envmapsaturation" "[.5 .5 .5]"
                "$envmapfresnel" "1"
                "$normalmapalphaenvmapmask" 1
                "$phong" "1"
                "$phongfresnelranges" "[.1 .4 1]"
                "$phongboost" "20"
                "$phongtint" "[.8 .9 1]"
                "$phongexponent" 3000
                "$phongdisablehalflambert" "1"
            }
        ]])
        return
    end

    if not FlatMaterial then
        FlatMaterial = mat.find("debug/debugdrawflat", "")
        return
    end

    if not SolidMaterial then
        SolidMaterial = mat.find("debug/debugambientcube", "")
        return
    end

    local function DoChams(Type, Color1, Color2, Color3, Overlay, Wireframe, MetallicOverlay)
        if Type == 1 then
            if not Overlay then
                FlatMaterial:modulate(Color1)
                mat.override_material(FlatMaterial)
            end
            dme()

            SpaceMaterial:modulate(Color2)
            SpaceMaterial:set_flag(mat.var_wireframe, true)
            mat.override_material(SpaceMaterial)
        elseif Type == 2 then
            if not Overlay then
                SolidMaterial:modulate(Color1)
                mat.override_material(SolidMaterial)
            end
            dme()

            AnimatedMat:modulate(Color2)
            AnimatedMat:set_flag(mat.var_wireframe, Wireframe)
            mat.override_material(AnimatedMat)
        elseif Type == 3 then
            if not Overlay then
                SolidMaterial:modulate(Color1)
                mat.override_material(SolidMaterial)
            end
            dme()

            MetallicMaterial["$envmaptint"]:set_vector(Color2.r / 255, Color2.g / 255, Color2.b / 255)
            MetallicMaterial:set_flag(mat.var_wireframe, Wireframe)
            MetallicMaterial:modulate(Color2)
            mat.override_material(MetallicMaterial)
        end

        if Type ~= 0 and Type ~= 3 and MetallicOverlay then
            dme()
            MetallicMaterial["$envmaptint"]:set_vector(Color3.r / 255, Color3.g / 255, Color3.b / 255)
            MetallicMaterial:modulate(Color3) -- this is purley for alpha
            mat.override_material(MetallicMaterial)
        end
    end
    
    if IsArm then
        DoChams(ArmOptions:get(), ArmColor:get(), ArmColor2:get(), ArmColor3:get(), ArmOverlay:get(), ArmWireframe:get(), ArmMetallicOverlay:get())
    elseif IsWeapon then
        DoChams(WeaponOptions:get(), WeaponColor:get(), WeaponColor2:get(), WeaponColor3:get(), WeaponOverlay:get(), WeaponWireframe:get(), WeaponMetallicOverlay:get())
    end
end