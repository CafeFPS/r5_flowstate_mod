//Made by @CafeFPS
untyped
#if SERVER
global function FS_Carritos_Track1_Init
#endif

global function Sh_FS_Carritos_Init

void function Sh_FS_Carritos_Init()
{
	
}


//Tracks Data
#if SERVER
void function FS_Carritos_Track1_Init()
{
    PrecacheModel( $"mdl/industrial/traffic_cone_01.rmdl" )
    PrecacheModel( $"mdl/canyonlands/canyonlands_zone_sign_03b.rmdl" )
    PrecacheModel( $"mdl/desertlands/industrial_metal_frame_256x144_02.rmdl" )
    PrecacheModel( $"mdl/desertlands/industrial_drill_01_support_02.rmdl" )
    PrecacheModel( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl" )
    PrecacheModel( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl" )

    AddCallback_EntitiesDidLoad( CarritosTrack1 )
}

void function CarritosTrack1()
{
    //Starting Origin, Change this to a origin in a map 
    vector startingorg = < 0, 0, 3000 >

	array<vector> trackInfotargets
    // Props

	trackInfotargets.append( < -1301, -4063, 24.6 > + startingorg )
    trackInfotargets.append( < -295.7998, -4060.101, 24.6 > + startingorg )
	trackInfotargets.append( < 710, -4053.9, 24.6 > + startingorg )
    trackInfotargets.append( < 1699.2, -3906.9, 24.6 > + startingorg )
    trackInfotargets.append( < 2702.2, -3477.9, 24.6 > + startingorg )
    trackInfotargets.append( < 3767.2, -2563.9, 24.6 > + startingorg )
    trackInfotargets.append( < 4370.2, -1564.9, 24.6 > + startingorg )
    trackInfotargets.append( < 4651.2, -561.9004, 24.6 > + startingorg )
    trackInfotargets.append( < 4672.2, 438.0996, 24.6 > + startingorg )
    trackInfotargets.append( < 4441.2, 1437.1, 24.6 > + startingorg )
    trackInfotargets.append( < 3708.2, 2676.2, 24.6 > + startingorg )
    trackInfotargets.append( < 2701.2, 3524.1, 24.6 > + startingorg )
    trackInfotargets.append( < 1696.2, 3951.1, 24.6 > + startingorg )
    trackInfotargets.append( < 684.2002, 4098.1, 24.6 > + startingorg )
    trackInfotargets.append( < -300.7998, 4093.8, 24.6 > + startingorg )
    trackInfotargets.append( < -1304.8, 4087.1, 24.6 > + startingorg )
    trackInfotargets.append( < -2295.8, 4083, 24.6 > + startingorg )
    trackInfotargets.append( < -3299.8, 4021.1, 24.6 > + startingorg )
    trackInfotargets.append( < -4289.8, 3714.1, 24.6 > + startingorg )
    trackInfotargets.append( < -5297.8, 3065.1, 24.6 > + startingorg )
    trackInfotargets.append( < -5868.8, 2446.1, 24.6 > + startingorg )
    trackInfotargets.append( < -6427.8, 1431.1, 24.6 > + startingorg )
    trackInfotargets.append( < -6658.8, 435.0996, 24.6 > + startingorg )
    trackInfotargets.append( < -6642.8, -563.9004, 24.6 > + startingorg )
    trackInfotargets.append( < -6300.8, -1732.9, 24.6 > + startingorg )
    trackInfotargets.append( < -5299.8, -3054.9, 24.6 > + startingorg )
    trackInfotargets.append( < -4298.8, -3705.9, 24.6 > + startingorg )
    trackInfotargets.append( < -3301.399, -4014.4, 24.6 > + startingorg )
    trackInfotargets.append( < -2298.8, -4063, 24.6 > + startingorg )
	

	trackInfotargets.reverse()
	#if DEVELOPER
	foreach ( i, start in trackInfotargets )
	{
		DebugDrawHemiSphere( start, <0,0,0>, 25.0, 20, 210, 255, false, 100.0 )
		DebugDrawLine( start, trackInfotargets[(i + 1) % trackInfotargets.len()], 255, 0, 0, true, 999.0 )
	}
	#endif

	FS_Carritos_InitTrackData( trackInfotargets, CarritosTrack1_SpawnMap )
}

void function CarritosTrack1_SpawnMap()
{
    //Starting Origin, Change this to a origin in a map 
    vector startingorg = < 0, 0, 3000 >

    entity prop
	prop = MapEditor_CreateProp( $"mdl/canyonlands/canyonlands_zone_sign_03b.rmdl", < -1280.8, -4206.9, 514 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/industrial_metal_frame_256x144_02.rmdl", < -1283.6, -4307.601, 251.3 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/industrial_metal_frame_256x144_02.rmdl", < -1283.6, -4057.9, 251.3 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/industrial_metal_frame_256x144_02.rmdl", < -1283.6, -3807.101, 251.3 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/industrial_drill_01_support_02.rmdl", < -1278.8, -3654.9, 0 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/industrial_drill_01_support_02.rmdl", < -1278.8, -4459.9, 0 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < 366.1494, -4433.801, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -141.5283, -4436.854, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < 112.1514, -4435.328, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1401.82, -4444.429, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -894.1377, -4441.371, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1148.137, -4442.9, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -390.1504, -4438.344, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -640.1475, -4439.851, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1903.808, -4447.439, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1653.817, -4445.94, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -2157.808, -4448.972, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -2411.8, -4450.496, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -2665.492, -4452.021, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1653.817, 3704.656, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -2157.808, 3701.625, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -2665.492, 3698.575, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1903.808, 3703.157, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -640.1475, 3710.746, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1148.137, 3707.696, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -1401.82, 3706.168, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -390.1504, 3712.253, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -894.1377, 3709.225, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < 112.1514, 3715.269, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -141.5283, 3713.743, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < 366.1494, 3716.795, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_straight_256.rmdl", < -2411.8, 3700.1, 0 > + startingorg, < 0, 90.3445, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -6745.541, 1657.1, 0 > + startingorg, < 0, 158.196, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -5797.167, 3113.719, 0 > + startingorg, < 0, 135.696, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -4364.015, 4097.21, 0 > + startingorg, < 0, 113.196, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -4263.001, -4134.172, 0 > + startingorg, < 0, -111.8039, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -6704.123, -1751.652, 0 > + startingorg, < 0, -156.8039, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -2553, -4452.428, 0 > + startingorg, < 0, -89.3039, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -5720.625, -3185.806, 0 > + startingorg, < 0, -134.3039, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < -7063.8, -51.9004, 0 > + startingorg, < 0, -179.304, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 616.2002, 4478.1, 0 > + startingorg, < 0, 90, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 2322.2, 4139.1, 0 > + startingorg, < 0, 67.5, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 3768.2, 3173.1, 0 > + startingorg, < 0, 45, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 4734.2, 1727.1, 0 > + startingorg, < 0, 22.5, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 2323.2, -4092.9, 0 > + startingorg, < 0, -67.5, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 3768.2, -3126.9, 0 > + startingorg, < 0, -45, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 4734.2, -1681.9, 0 > + startingorg, < 0, -22.5, 0 >, true, 50000, -1, 1 )
    prop = MapEditor_CreateProp( $"mdl/desertlands/desertlands_train_track_curve_r4456.rmdl", < 5073.2, 23.0996, 0 > + startingorg, < 0, 0, 0 >, true, 50000, -1, 1 )
} 
#endif
