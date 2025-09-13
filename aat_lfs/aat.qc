$modelname "blu/aat.mdl"

$scale "0.85"

$bodygroup "body"
{
	studio "ref.smd"
}

$cdmaterials "models\blu\aat\"

$surfaceprop "metal"
$contents "solid"
$collisionmodel "phys.smd"
{
	$masscenter 75 0 15
	$mass 2500
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

$texturegroup "skinfamilies"
{
	{
		"main.vmt"
		"gun.vmt"
	}
	{
		"main_cis.vmt"
		"gun_cis.vmt"
	}
}

$mostlyopaque

$sequence "idle" "ref.smd" { fps 1 }
$animation "neutral" "ref.smd" frames 0 0
$sequence "fire" "fire_cannon.smd" fps 35.00


$poseparameter "cannon_left_pitch" -30 20
$poseparameter "cannon_left_yaw" -30 30

$weightlist cannon_left { "cannon_left_pitch" 1.0 "cannon_left_yaw" 1.0 }

$animation cl_p_min "poseparameters.smd" frame 6 6 subtract neutral 0 weightlist cannon_left
$animation cl_p_max "poseparameters.smd" frame 5 5 subtract neutral 0 weightlist cannon_left
$sequence cannon_left_pitch { cl_p_min cl_p_max blendwidth 2 blend "cannon_left_pitch" -30 20 } weightlist cannon_left delta autoplay

$animation cl_y_min "poseparameters.smd" frame 3 3 subtract neutral 0 weightlist cannon_left
$animation cl_y_max "poseparameters.smd" frame 2 2 subtract neutral 0 weightlist cannon_left
$sequence cannon_left_yaw { cl_y_min cl_y_max blendwidth 2 blend "cannon_left_yaw" -30 30 } weightlist cannon_left delta autoplay



$poseparameter "cannon_right_pitch" -30 20
$poseparameter "cannon_right_yaw" -30 30

$weightlist cannon_right { "cannon_right_pitch" 1.0 "cannon_right_yaw" 1.0 }

$animation cr_p_min "poseparameters.smd" frame 6 6 subtract neutral 0 weightlist cannon_right
$animation cr_p_max "poseparameters.smd" frame 5 5 subtract neutral 0 weightlist cannon_right
$sequence cannon_right_pitch { cr_p_min cr_p_max blendwidth 2 blend "cannon_right_pitch" -30 20 } weightlist cannon_right delta autoplay

$animation cr_y_min "poseparameters.smd" frame 3 3 subtract neutral 0 weightlist cannon_right
$animation cr_y_max "poseparameters.smd" frame 2 2 subtract neutral 0 weightlist cannon_right
$sequence cannon_right_yaw { cr_y_min cr_y_max blendwidth 2 blend "cannon_right_yaw" -30 30 } weightlist cannon_right delta autoplay




$poseparameter "turret_pitch" -20 10
$poseparameter "turret_yaw" 0 360 wrap

$weightlist turret { "turret_yaw" 1.0 "turret_pitch" 1.0 "turret_recoil" 1.0 }

$animation t_p_min "poseparameters.smd" frame 6 6 subtract neutral 0 weightlist turret
$animation t_p_max "poseparameters.smd" frame 5 5 subtract neutral 0 weightlist turret
$sequence turret_pitch { t_p_min t_p_max blendwidth 2 blend "turret_pitch" -20 10 } weightlist turret delta autoplay


$animation t_y_0 "poseparameters.smd" frame 1 1 subtract neutral 0 weightlist turret
$animation t_y_120 "poseparameters.smd" frame 2 2 subtract neutral 0 weightlist turret
$animation t_y_240 "poseparameters.smd" frame 3 3 subtract neutral 0 weightlist turret

$sequence turret_yaw { t_y_0 t_y_120 t_y_240 t_y_0 blendwidth 4 blend "turret_yaw" 0 360 } weightlist turret delta autoplay




$attachment "muzzle_right" "muzzle_right" 0 0 0
$attachment "muzzle_left" "muzzle_left" 0 0 0

$attachment "missile_1l" "missile_left_1" 0 0 0
$attachment "missile_2l" "missile_left_2" 0 0 0
$attachment "missile_3l" "missile_left_3" 0 0 0

$attachment "missile_1r" "missile_right_1" 0 0 0
$attachment "missile_2r" "missile_right_2" 0 0 0
$attachment "missile_3r" "missile_right_3" 0 0 0

$attachment "muzzle" "turret_muzzle" 0 0 0

$attachment "turret_view" "turret_pitch" 0 0 0