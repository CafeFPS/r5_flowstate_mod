globalize_all_functions

global const NO_CHOICES = 2
global const HACKERS_VS_PRO_MAX_KILLS = 15
global const int NUMBER_OF_MAP_SLOTS_FSDM = 4

global const ODDBALL_POINTS_TO_WIN = 150

global enum eTDMAnnounce
{
	NONE = 0
	WAITING_FOR_PLAYERS = 1
	ROUND_START = 2
	VOTING_PHASE = 3
	MAP_FLYOVER = 4
	IN_PROGRESS = 5
}

global enum eTDMState
{
	IN_PROGRESS = 0
	NEXT_ROUND_NOW = 1
}

global struct LocationSettings
{
    string name
    array<LocPair> spawns
    vector cinematicCameraOffset
	LocPair &victorypos
	asset locationAsset
	int index = -1
}

// Screen IDS
global enum eFSDMScreen
{
	WinnerScreen = 0
	VoteScreen = 1
	TiedScreen = 2
	SelectedScreen = 3
	NextRoundScreen = 4
	ScoreboardUI = 5
    NotUsed = 230
}

global struct PlayerInfo
{
	string name
	int eHandle
	int team
	int score
	int deaths
	float kd
	int damage
	int lastLatency
}

struct {
    LocationSettings &selectedLocation
    array choices
    array<LocationSettings> locationSettings
    var scoreRui
} file

int function ComparePlayerInfo(PlayerInfo a, PlayerInfo b)
{
	if(a.score < b.score) return 1;
	else if(a.score > b.score) return -1;
	return 0;
}

void function Sh_CustomTDM_Init()
{
	
    // Map locations
    switch( MapName() )
    {
	case eMaps.mp_rr_arena_empty:
		if (Flowstate_Is4DMode())
		{
			Shared_RegisterLocation(
				NewLocationSettings(
				"4D4Room",
					[
						NewLocPair( < -15400, -816, 384 >, < 0, 45, 0 > )
						NewLocPair( < 14600, -816, 384 >, < 0, 45, 0 > )
						NewLocPair( < -14872, -304, 384 >, < 0, -135, 0 > )
						NewLocPair( < 15128, -304, 384 >, < 0, -135, 0 > )
						NewLocPair( < -14632, -48, 384 >, < 0, -135, 0 > )
						NewLocPair( < 15368, -48, 384 >, < 0, -135, 0 > )
						NewLocPair( < -16680, -1840, 384 >, < 0, 0, 0 > )
						NewLocPair( < 13320, -1840, 384 >, < 0, 0, 0 > )
						NewLocPair( < -16664, -304, 384 >, < 0, -89.9998, 0 > )
						NewLocPair( < 13336, -304, 384 >, < 0, -89.9998, 0 > )
						NewLocPair( < -17192, -2608, 128 >, < 0, 89.9998, 0 > )
						NewLocPair( < 12808, -2608, 128 >, < 0, 89.9998, 0 > )
						NewLocPair( < -16424, -2096, 384 >, < 0, -179.9997, 0 > )
						NewLocPair( < 13576, -2096, 384 >, < 0, -179.9997, 0 > )
						NewLocPair( < -17192, -1568, 128 >, < 0, -89.9998, 0 > )
						NewLocPair( < 12808, -1568, 128 >, < 0, -89.9998, 0 > )
						NewLocPair( < -16936, -560, 384 >, < 0, 0, 0 > )
						NewLocPair( < 13064, -560, 384 >, < 0, 0, 0 > )
						NewLocPair( < -15656, -1072, 384 >, < 0, 45, 0 > )
						NewLocPair( < 14344, -1072, 384 >, < 0, 45, 0 > )
						NewLocPair( < -14632, -1072, 384 >, < 0, 135, 0 > )
						NewLocPair( < 15368, -1072, 384 >, < 0, 135, 0 > )
						NewLocPair( < -15656, -48, 384 >, < 0, -44.9999, 0 > )
						NewLocPair( < 14344, -48, 384 >, < 0, -44.9999, 0 > )
						NewLocPair( < -15400, -304, 384 >, < 0, -44.9999, 0 > )
						NewLocPair( < 14600, -304, 384 >, < 0, -44.9999, 0 > )
						NewLocPair( < -14872, -816, 384 >, < 0, 135, 0 > )
						NewLocPair( < 15128, -816, 384 >, < 0, 135, 0 > )
					],
					<0, 0, 3000>
				)
			)
		}
		break
	case eMaps.mp_rr_olympus:
	case eMaps.mp_rr_olympus_tt:
        Shared_RegisterLocation(
            NewLocationSettings(
               "Olympus Test Location",
                [
                    NewLocPair(<1769.48132, 6416.47363, -5323.96875> , <0, 161.619949, 0>),
                    NewLocPair(<944.609436, 7768.79688, -5127.98193> , <0, 26.7121983, 0>),
                    NewLocPair(<1672.01257, 9753.1709, -5127.98438> , <0, -107.021523, 0>),
                    NewLocPair(<3604.0752, 9955.06445, -5325.9375> , <0, 156.444427, 0>)
                ],
                <0, 0, 3000>
            )
        )
	break
	case eMaps.mp_rr_arena_phase_runner:
        Shared_RegisterLocation(
            NewLocationSettings(
               "Phase Runner",
                [
                    NewLocPair(<26118.4551, 16751.2969, -1279.96875> , <0, 89.4115295, 0>),
                    NewLocPair(<23497.5859, 20112.5137, -1151.96875> , <0, -45.1068459, 0>),
                    NewLocPair(<25032.3184, 21795.0313, -927.96875> , <0, -13.0043278, 0>),
                    NewLocPair(<27145.8184, 21711.4082, -927.96875> , <0, -155.027145, 0>),
					NewLocPair(<30564.7754, 17781.6094, -895.97345> , <0, -154.644897, 0>),
					NewLocPair(<24197.9258, 14329.3359, -1027.36292> , <0, -5.09298944, 0>),
					NewLocPair(<26418.9688, 13381.127, -1023.96875> , <0, 41.6298714, 0>),
					NewLocPair(<28780.25, 16014.9004, -1033.47864> , <0, 171.618332, 0>),
					NewLocPair(<30562.041, 13306.3379, -906.315552> , <0, 115.207245, 0>),
					NewLocPair(<21345.25, 13560.7031, -448.967621> , <0, 40.8450966, 0>),
					NewLocPair(<20491.3262, 17548.2148, -882.265808> , <0, 0.0175942089, 0>)
                ],
                <0, 0, 3000>
            )
        )
	break
   case eMaps.mp_rr_aqueduct:
   //case eMaps.mp_rr_aqueduct_night:
        Shared_RegisterLocation(
            NewLocationSettings(
               "Overflow",
                [
                    NewLocPair(<3863.79321, -3262.95703, 282.03125>, <0, -135.066055, 0>),
                    NewLocPair(<4169.18262, -5555.22119, 410.03125>, <0, 146.240646, 0>),
                    NewLocPair(<-620.375977, -6611.72803, 410.03125>, <0, 29.9391613, 0>),
                    NewLocPair(<-1859.04651, -3355.55103, 282.03125>, <0, -51.3485374, 0>),
                    NewLocPair(<817.221375, -3503.38354, 482.03125>, <0, 44.7887459, 0>)
                ],
                <0, 0, 3000>
            )
        )
        break
   case eMaps.mp_rr_canyonlands_staging:
        Shared_RegisterLocation(
            NewLocationSettings(
               "Deathbox by Ayezee",
                [
                    //Top Floor
                    NewLocPair(<29351, -8106, -15794>, <4, 45, 0>),
                    NewLocPair(<32678, -8106, -15794>, <4, 135, 0>),
                    NewLocPair(<29351, -4780, -15794>, <4, -45, 0>),
                    NewLocPair(<32678, -4780, -15794>, <4, -135, 0>),

                    //Bottom Floor
                    NewLocPair(<29351, -8106, -16073>, <4, 45, 0>),
                    NewLocPair(<32678, -8106, -16073>, <4, 135, 0>),
                    NewLocPair(<29351, -4780, -16073>, <4, -45, 0>),
                    NewLocPair(<32678, -4780, -16073>, <4, -135, 0>),

                    //Other
                    NewLocPair(<32682, -6574, -15794>, <0, 180, 0>),
                    NewLocPair(<29340, -6318, -15794>, <0, 0, 0>),
                    NewLocPair(<31138, -4778, -15794>, <0, -90, 0>),
                    NewLocPair(<30882, -8116, -15794>, <0, 90, 0>)
                ],
                <0, 0, 3000>
            )
        )
        break
/*     case eMaps.mp_rr_ashs_redemption:
        Shared_RegisterLocation(
            NewLocationSettings(
                "Ash's Redemption",
                [
                    NewLocPair(<-22104, 6009, -26529>, <0, 0, 0>),
					NewLocPair(<-21372, 3709, -26555>, <-5, 55, 0>),
                    NewLocPair(<-19356, 6397, -26461>, <-4, -166, 0>),
					NewLocPair(<-20713, 7409, -26442>, <-4, -114, 0>)
                ],
                <0, 0, 1000>
            )
        )

        break */
    case eMaps.mp_rr_arena_composite:
        Shared_RegisterLocation(
            NewLocationSettings(
                "Drop-Off",
                [
                    NewLocPair(<-3592, 1081, 258>, <0, 37, 0>),
                    NewLocPair(<3592, 1081, 258>, <0, 142, 0>),
                    NewLocPair(<-1315, 4113, 71>, <0, -43, 0>),
                    NewLocPair(<1315, 4113, 71>, <0, -136, 0>),
                    NewLocPair(<-1374, 1, 259>, <0, 35, 0>),
                    NewLocPair(<1374, 1, 259>, <0, 140, 0>),
                    NewLocPair(<-12.9539881, 3344.23584, -34>,<0, -92.351532, 0>),
                    NewLocPair(<1705.29504, 3284.08252, 210>,<0, -142.564148, 0>),
                    NewLocPair(<692.371887, 1771.11829, -50>,<0, 51.6300087, 0>),
                    NewLocPair(<-358.171814, 1723.92322, -50>,<0, 45.0872917, 0>),
                    NewLocPair(<-912.219482, 2789.4751, 10>,<0, -53.7381134, 0>),
                    NewLocPair(<3556, 916, 258>, <8, 76, 0>),
                    NewLocPair(<3765, 1115, 258>, <8, 171, 0>),
                    NewLocPair(<-2388, 2758, 259>,<0, -102.007385, 0>),
                    NewLocPair(<-1282, 1750, 259>,<16, 50, 0>)
                ],
                <0, 0, 1000>
            )
        )
        break
		
	case eMaps.mp_rr_party_crasher:
	Shared_RegisterLocation(
		NewLocationSettings(
				"Party Crasher",
				[
					NewLocPair(<1729.17407, -3585.65137, 601.736206>, <0, 103.168709, 0>),
					NewLocPair(<345.111481, -3769.65674, 583.285156>, <0, 78.5349045, 0>),
					NewLocPair(<-1315.06567, -2856.39771, 999.132568>,<0, 39.8982162, 0>),
					NewLocPair(<-2242.99829, -1911.60974, 1231.47437>, <0, 35.2527733, 0>),
					NewLocPair(<-2805.87012, -650.600647, 1272.09473>, <0, 32.1970596, 0>),
					NewLocPair(<262.267334, 2781.46118, 710.572449>, <0, -139.138306, 0>),
					NewLocPair(<-3970.97266, 2639.4585, 583.285156>, <0, -35.2144508, 0>),
					NewLocPair(<-2711.53491, 4067.46069, 601.736206>, <0, -46.8964882, 0>),
					NewLocPair(<-934.579468, 4998.19189, 583.281555>, <0, -90.8201675, 0>),
					NewLocPair(<1259.38, 3572.83008, 633.238098>, <0, -112.696632, 0>),
					NewLocPair(<2623.1499, 2661.17822, 940.03125>, <0, -99.6138458, 0>),
					NewLocPair(<1981.64294, 2721.13745, 723.03125>, <0, -146.273544, 0>),
					NewLocPair(<3116.81201, 1577.45361, 940.03125>, <0, 169.12117, 0>),
					NewLocPair(<3843.68774, -595.504456, 583.002197>, <0, 172.503952, 0>),
					NewLocPair(<1670.724, -768.35498, 720.573608>, <0, 107.206459, 0>)
				],
				<0, 0, 1000>
			)
		)
		break
		
	/*case eMaps.mp_rr_arena_skygarden:
	//This location sucks, disable until map is fixed.. Cafe
	if(FlowState_EnableEncore()){
	Shared_RegisterLocation(
		NewLocationSettings(
				"Encore",
				[
					NewLocPair(<4284.88037, -102.993355, 2680.03125>, <0, -179.447098, 0>),
					NewLocPair(<-4282.63086, -94.0586777, 2680.03125>, <0, -1.49068689, 0>),
					NewLocPair(<-4016.35449, -2984.96777, 2723.82983>, <0, 97.363739, 0>),
					NewLocPair(<-3202.32129, -3163.42432, 2863.03125>, <0, 91.0571976, 0>),
					NewLocPair(<11.4232283, -3441.22241, 2836.03125>, <0, 92.0147095, 0>),					
					NewLocPair(<2008.17126, -3265.22412, 2863.03125>, <0, 114.795891, 0>),					
					NewLocPair(<4112.67383, -2757.43213, 2717.97461>, <0, 108.537872, 0>),					
					NewLocPair(<2756.42676, 2774.64746, 2664.18604>, <0, -106.51664, 0>),					
					NewLocPair(<1610.47034, 3414.86646, 2786.24658>, <0, -85.7662277, 0>),					
					NewLocPair(<-799.999512, 3280.4292, 2930.03125>, <0, -77.9509888, 0>),
					NewLocPair(<-1641.51526, 3283.95166, 2785.31738>, <0, -90.7040482, 0>),					
					NewLocPair(<2215.3208, -131.611176, 2599.72876>, <0, 175.527969, 0>),					
					NewLocPair(<-2034.16443, -41.9182587, 2599.34814>, <0, -0.69002372, 0>),					
					NewLocPair(<3.56009603, 2732.36084, 2930.03125>, <0, -86.8429184, 0>),
					NewLocPair(<3.75123262, -2400.2561, 2829.96875>, <0, 92.3833466, 0>)
				],
				<0, 0, 1000>
			)
		)
	}*/
	
	///////////////////////////////////////
	//////////////DEAFPS Maps//////////////
	///////////////////////////////////////

	if(FlowState_EnableRustByDEAFPS()){
            vector ruststartingorg = <0,0,0>
            Shared_RegisterLocation(
			NewLocationSettings(
				"Rust By DEAFPS",
				[
					NewLocPair(< 312.3676, -17810.7000, 2924 > + ruststartingorg, < 0, 132.3256, 0 >),
					NewLocPair(< 817.0059, -17817.7700, 2888 > + ruststartingorg, < 0, -2.6741, 0 >),
					NewLocPair(< 211.9941, -18011.2300, 2923 > + ruststartingorg, < 0, 177.3262, 0 >),
					NewLocPair(< 353.9973, -18534.2300, 2900 > + ruststartingorg, < 0, 177.3262, 0 >),
					NewLocPair(< 632.0059, -18551.7700, 2878 > + ruststartingorg, < 0, -2.6741, 0 >),
					NewLocPair(< 806.7667, -19414.9900, 2889 > + ruststartingorg, < 0, 87.3257, 0 >),
					NewLocPair(< 180.0672, -19385.8800, 2914 > + ruststartingorg, < 0, 102.3257, 0 >),
					NewLocPair(< -521.8843, -19393.0700, 2958 > + ruststartingorg, < 0, 12.3258, 0 >),
					NewLocPair(< -547.8843, -18296.0700, 2931 > + ruststartingorg, < 0, 12.3258, 0 >),
					NewLocPair(< -499.7668, -17120.0100, 2924 > + ruststartingorg, < 0, -92.6740, 0 >),
					NewLocPair(< 103.2332, -17120.0100, 2914 > + ruststartingorg, < 0, -92.6740, 0 >),
					NewLocPair(< 669.2332, -17164.0100, 2919 > + ruststartingorg, < 0, -92.6740, 0 >),
					NewLocPair(< 1118.2330, -17189.0100, 2901 > + ruststartingorg, < 0, -92.6740, 0 >),
					NewLocPair(< 1719.9930, -17217.2600, 2853 > + ruststartingorg, < 0, 176.9944, 0 >),
					NewLocPair(< 1689.9930, -17868.2600, 2816 > + ruststartingorg, < 0, 176.9944, 0 >),
					NewLocPair(< 1658.2490, -18422.3600, 2841 > + ruststartingorg, < 0, -148.4781, 0 >),
					NewLocPair(< 1659.9820, -18918.3800, 2823 > + ruststartingorg, < 0, 175.4201, 0 >),
					NewLocPair(< 1560.3300, -19434.5000, 2832 > + ruststartingorg, < 0, 149.9997, 0 >),
				],
				<0, 0, 3000>
			)
		)
        }
	
	if(FlowState_EnableShoothouseByDEAFPS()){
	vector shoothousestartingorg = <-19200,14000,2700> - < 4709.2950, -4616.6060, -1400 >
	Shared_RegisterLocation(
			NewLocationSettings(
				"Shoothouse by DEAFPS",
			[
				NewLocPair(< 6506.3960, -3044.9840, 149 > + shoothousestartingorg, < 0, 94.5356, 0 >)
				NewLocPair(< 6428.3960, -3610.9840, 149 > + shoothousestartingorg, < 0, 94.5356, 0 >)
				NewLocPair(< 6840.6740, -3927.4940, 149 > + shoothousestartingorg, < 0, -30.0804, 0 >)
				NewLocPair(< 6846.3960, -4554.9840, 149 > + shoothousestartingorg, < 0, 94.5356, 0 >)
				NewLocPair(< 7635.5880, -3918.6480, 149 > + shoothousestartingorg, < 0, -28.0562, 0 >)
				NewLocPair(< 8147.9290, -4257.8400, 149 > + shoothousestartingorg, < 0, 170.3281, 0 >)
				NewLocPair(< 8433.9280, -3560.8390, 149 > + shoothousestartingorg, < 0, 170.3281, 0 >)
				NewLocPair(< 8419.8910, -3160.9640, 149 > + shoothousestartingorg, < 0, -168.0417, 0 >)
				NewLocPair(< 7866.7090, -2320.1700, 149 > + shoothousestartingorg, < 0, -75.0357, 0 >)
				NewLocPair(< 8296.8910, -2400.9660, 149 > + shoothousestartingorg, < 0, -168.0417, 0 >)
				NewLocPair(< 6897.2020, -3054.6000, 149 > + shoothousestartingorg, < 0, -16.2518, 0 >)
				NewLocPair(< 7442.1790, -2338.0680, 149 > + shoothousestartingorg, < 0, -80.5481, 0 >)
				NewLocPair(< 6868.1790, -2334.0680, 149 > + shoothousestartingorg, < 0, -80.5481, 0 >)
				NewLocPair(< 6203.1790, -2342.0680, 149 > + shoothousestartingorg, < 0, -80.5481, 0 >)
				NewLocPair(< 5454.1790, -2387.0680, 149 > + shoothousestartingorg, < 0, -80.5481, 0 >)
				NewLocPair(< 5252.0010, -3192.1150, 149 > + shoothousestartingorg, < 0, 1.3270, 0 >)
				NewLocPair(< 5260.0310, -3489.4500, 149 > + shoothousestartingorg, < 0, -6.3157, 0 >)
				NewLocPair(< 5610.0310, -3828.4500, 149 > + shoothousestartingorg, < 0, -6.3157, 0 >)
				NewLocPair(< 5850.4520, -4296.0760, 149 > + shoothousestartingorg, < 0, 24.5247, 0 >)
			],
				<0, 0, 3000>
			)
		)
	}
	
	if(FlowState_EnableNCanalsByDEAFPS()){
		vector ncanalsstartingorg = <0, 0, 0 >
		Shared_RegisterLocation(
				NewLocationSettings(
					"Noshahr Canals by DEAFPS",
					[
						NewLocPair(< 12312.5600, 25185.9200, 6160.8440 > + ncanalsstartingorg, < 0, 95.4418, 0 >)
						NewLocPair(< 11320.5600, 25635.9200, 6160.8440 > + ncanalsstartingorg, < 0, 95.4418, 0 >)
						NewLocPair(< 10571.5600, 25095.9200, 6160.8440 > + ncanalsstartingorg, < 0, -84.5582, 0 >)
						NewLocPair(< 11764.6000, 23894.6400, 6160.8440 > + ncanalsstartingorg, < 0, 155.4418, 0 >)
						NewLocPair(< 11110.5600, 24478.9200, 6160.8440 > + ncanalsstartingorg, < 0, -84.5582, 0 >)
						NewLocPair(< 10671.5600, 23793.9200, 6160.8440 > + ncanalsstartingorg, < 0, -174.5582, 0 >)
						NewLocPair(< 9996.5630, 24275.9200, 6160.8440 > + ncanalsstartingorg, < 0, -84.5582, 0 >)
						NewLocPair(< 8859.5630, 23079.9200, 6160.8440 > + ncanalsstartingorg, < 0, 50.4418, 0 >)
						NewLocPair(< 9535.5630, 23275.9200, 6160.8440 > + ncanalsstartingorg, < 0, 50.4418, 0 >)
						NewLocPair(< 10200.5600, 23106.9200, 6160.8440 > + ncanalsstartingorg, < 0, 50.4418, 0 >)
						NewLocPair(< 10385.3700, 21808.5900, 6085.4440 > + ncanalsstartingorg, < 0, 50.4418, 0 >)
						NewLocPair(< 11289.5600, 23004.9200, 6085.4440 > + ncanalsstartingorg, < 0, -129.5583, 0 >)
						NewLocPair(< 12278.5600, 24302.9200, 6085.4440 > + ncanalsstartingorg, < 0, -129.5583, 0 >)
						NewLocPair(< 12849.5600, 25428.9200, 6160.8440 > + ncanalsstartingorg, < 0, -129.5583, 0 >)
						NewLocPair(< 11969.8200, 26110, 6160.8440 > + ncanalsstartingorg, < 0, -129.5583, 0 >)
						NewLocPair(< 11011.5600, 26778.9200, 6160.8440 > + ncanalsstartingorg, < 0, -39.5583, 0 >)
						NewLocPair(< 10593.5600, 25927.9200, 6160.8440 > + ncanalsstartingorg, < 0, 170.4417, 0 >)
						NewLocPair(< 9943.2340, 24646.4200, 6160.8440 > + ncanalsstartingorg, < 0, 170.4417, 0 >)
						NewLocPair(< 8946.5630, 24294.9200, 6160.8440 > + ncanalsstartingorg, < 0, 13.2422, 0 >)
						NewLocPair(< 8983.5630, 25049.8500, 6160.8440 > + ncanalsstartingorg, < 0, -60, 0 >)
						NewLocPair(< 8095.5630, 23940.9200, 6160.8440 > + ncanalsstartingorg, < 0, 0, 0 >)
					],
					<0, 0, 3000>
				)
			)
		}
	
	
	if(FlowState_EnableDustmentByDEAFPS()){
		vector dustmentstartingorg = <-19200,14000,2700> - < 4709.2950, -4616.6060, 0 >
		Shared_RegisterLocation(
				NewLocationSettings(
					"Dustment by DEAFPS",
					[
						NewLocPair(< 6541, -4748, 131 > + dustmentstartingorg, < 0, 140.8409, 0 >)
						NewLocPair(< 5124, -3752, 83.6000 > + dustmentstartingorg, < 0, 0, 0 >)
						NewLocPair(< 5846.4580, -4562.9770, 99.9000 > + dustmentstartingorg, < 0, 84.7281, 0 >)
						NewLocPair(< 5859.0870, -4095.1910, 99.9000 > + dustmentstartingorg, < 0, -90.9838, 0 >)
						NewLocPair(< 5563.0020, -4311.8350, 99.9000 > + dustmentstartingorg, < 0, -2.1733, 0 >)
						NewLocPair(< 6127.7570, -4319.4450, 99.9000 > + dustmentstartingorg, < 0, -179.7940, 0 >)
						NewLocPair(< 6569.8020, -3862.2190, 99.9000 > + dustmentstartingorg, < 0, -116.5770, 0 >)
						NewLocPair(< 4750.1250, -4088.1680, 129 > + dustmentstartingorg, < 0, 40.1670, 0 >)
						NewLocPair(< 4763, -4508, 99.9000 > + dustmentstartingorg, < 0, -38.7503, 0 >)
						NewLocPair(< 5621, -5041, 119 > + dustmentstartingorg, < 0, 178.2353, 0 >)
						NewLocPair(< 5666.8980, -3541.5550, 99.9000 > + dustmentstartingorg, < 0, 178.2353, 0 >)
						NewLocPair(< 6902.2780, -4062.3870, 99.9000 > + dustmentstartingorg, < 0, 152.5185, 0 >)
						NewLocPair(< 6898.7000, -4523.7000, 99.9000 > + dustmentstartingorg, < 0, -167.7632, 0 >)
						NewLocPair(< 6886.6280, -5163.9330, 131 > + dustmentstartingorg, < 0, 140.8409, 0 >)
						NewLocPair(< 4765.2000, -3380.5000, 146 > + dustmentstartingorg, < 0, -47.3245, 0 >)
						NewLocPair(< 4750.8930, -5191.4390, 166.2000 > + dustmentstartingorg, < 0, 51.7723, 0 >)
						NewLocPair(< 6848.7000, -3415.7000, 152 > + dustmentstartingorg, < 0, -135.0003, 0 >)
						NewLocPair(< 5069.0800, -4692.0670, 83.6000 > + dustmentstartingorg, < 0, 0, 0 >)
					],
					<0, 0, 3000>
				)
			)
		}

	if(FlowState_EnableKillyardByDEAFPS()){
            vector killhouselongstartingorg = <-2961,-13240,43000>
            Shared_RegisterLocation(
			NewLocationSettings(
				"Killyard",
				[
					NewLocPair( < -1069, -822, 9.4000 > + killhouselongstartingorg, < 0, 7.0074, 0 >),
					NewLocPair( < -1128, -343, 9.4000 > + killhouselongstartingorg, < 0, 7.0074, 0 >),
					NewLocPair( < -218, -1414, 9.4000 > + killhouselongstartingorg, < 0, 73.6881, 0 >),
					NewLocPair( < -507.5095, -1407.2130, 9.4000 > + killhouselongstartingorg, < 0, 73.6881, 0 >),
					NewLocPair( < -1160.2740, -1138.5530, 9.4000 > + killhouselongstartingorg, < 0, -29.9629, 0 >),
					NewLocPair( < 442, -909, 9.4000 > + killhouselongstartingorg, < 0, 178.6360, 0 >),
					NewLocPair( < 457, -271, 9.4000 > + killhouselongstartingorg, < 0, 178.6360, 0 >),
					NewLocPair( < 450, -569, 9.4000 > + killhouselongstartingorg, < 0, 178.6360, 0 >),
					NewLocPair( < -316.3000, 920.9000, 9.4000 > + killhouselongstartingorg, < 0, -147.1917, 0 >),
					NewLocPair( < -1446.8000, 616.2000, 9.4000 > + killhouselongstartingorg, < 0, 2.9566, 0 >),
					NewLocPair( < -1443.5000, 1.9000, 9.4000 > + killhouselongstartingorg, < 0, 7.0074, 0 >),
					NewLocPair( < -1171.6520, 7.8723, 9.4000 > + killhouselongstartingorg, < 0, 7.0074, 0 >),
					NewLocPair( < 208.7000, 707.6936, 9.4000 > + killhouselongstartingorg, < 0, -147.0432, 0 >),
					NewLocPair( < -1164.7130, 702.9291, 9.4000 > + killhouselongstartingorg, < 0, 2.9566, 0 >),
					NewLocPair( < -1162.3790, 980.8486, 9.4000 > + killhouselongstartingorg, < 0, -45.0161, 0 >),
					NewLocPair( < 200.7263, 979.5248, 9.4000 > + killhouselongstartingorg, < 0, -147.1917, 0 >),
					NewLocPair( < 217.9963, -563, 9.4000 > + killhouselongstartingorg, < 0, 178.6360, 0 >),
					NewLocPair( < 217.9963, -1035.2670, 9.4000 > + killhouselongstartingorg, < 0, 178.6360, 0 >),
					NewLocPair( < -1170.2510, -996.2968, 9.4000 > + killhouselongstartingorg, < 0, -0.5495, 0 >),
					NewLocPair( < -1167.9380, -1466.3340, 9.4000 > + killhouselongstartingorg, < 0, 44.6976, 0 >),
					NewLocPair( < 156.6777, -1466.7410, 9.4000 > + killhouselongstartingorg, < 0, 131.0375, 0 >),
				],
				<0, 0, 3000>
			)
		)
        }	

	///////////////////////////////////////
	//////////////AyeZee Maps//////////////
	///////////////////////////////////////

        if(FlowState_EnableEncoreNuketownByAyeZee()){
            vector nuketownstartingorg = <28524,23022,43000>
            Shared_RegisterLocation(
			NewLocationSettings(
				"Nuketown By AyeZee",
				[
					NewLocPair(< 381.3000, -859.9000, -502.4000 > + nuketownstartingorg, < 0, 131.6921, 0 >),
					NewLocPair(< -213.7000, -852.2000, -502.4000 > + nuketownstartingorg, < 0, 50.3080, 0 >),
					NewLocPair(< 608.7227, 945.4185, -497.5000 > + nuketownstartingorg, < 0, -85.3474, 0 >),
					NewLocPair(< -379.8000, 952.1000, -497.5000 > + nuketownstartingorg, < 0, -109.8191, 0 >),
					NewLocPair(< -688.5317, -611.3459, -497.5000 > + nuketownstartingorg, < 0, 121.5057, 0 >),
					NewLocPair(< -2298, -23, -497.5000 > + nuketownstartingorg, < 0, 17.9921, 0 >),
					NewLocPair(< -1919, 777, -497.5000 > + nuketownstartingorg, < 0, 17.9921, 0 >),
					NewLocPair(< 1807.1000, 1124.8000, -497.5000 > + nuketownstartingorg, < 0, -106.9288, 0 >),
					NewLocPair(< 1285, 970, -497.5000 > + nuketownstartingorg, < 0, -106.9288, 0 >),
					NewLocPair(< 2326.3580, -65.8636, -497.5000 > + nuketownstartingorg, < 0, 163.9604, 0 >)
				],
				<0, 0, 3000>
			)
		)
        }		
	
	break
		
	case eMaps.mp_rr_canyonlands_mu1_night:	
	case eMaps.mp_rr_canyonlands_mu1:
		Shared_RegisterLocation(
            NewLocationSettings(
                "Skull Town",
                [
                    NewLocPair(<-9320, -13528, 3167>, <0, -100, 0>),
                    NewLocPair(<-7544, -13240, 3161>, <0, -115, 0>),
                    NewLocPair(<-10250, -18320, 3323>, <0, 100, 0>),
                    NewLocPair(<-13261, -18100, 3337>, <0, 20, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/skulltown"
            )
        )
		Shared_RegisterLocation(
            NewLocationSettings(
                "Hillside Outspot",
                [
                    NewLocPair(<-19300, 4678, 3230>, <0, -100, 0>),
                    NewLocPair(<-16763, 4465, 3020>, <1, 18, 0>),
                    NewLocPair(<-20153, 1127, 3060>, <11, 170, 0>),
					NewLocPair(<-16787, 3540, 3075>, <0, 86, 0>),
					NewLocPair(<-19026, 3749, 4460>, <0, 2, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/hillside"
            )
        )
		Shared_RegisterLocation(
            NewLocationSettings(
                "Containment",
                [
                    NewLocPair(<-7291, 19547, 2978>, <0, -65, 0>),
                    NewLocPair(<-3906, 19557, 2733>, <0, -123, 0>),
                    NewLocPair(<-3084, 16315, 2566>, <0, 144, 0>),
                    NewLocPair(<-6517, 15833, 2911>, <0, 51, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/containment"
            )
        )
		Shared_RegisterLocation(
            NewLocationSettings(
                "Gaunlet",
                [
                    NewLocPair(<-21271, -15275, 2781>, <0, 90, 0>),
                    NewLocPair(<-22952, -13304, 2718>, <0, 5, 0>),
                    NewLocPair(<-22467, -9567, 2949>, <0, -85, 0>),
                    NewLocPair(<-18494, -10427, 2825>, <0, -155, 0>),
					NewLocPair(<-22590, -7534, 3103>, <0, 0, 0>)
                ],
                <0, 0, 4000>,$"rui/flowstatelocations/gaunlet"
            )
        )
		Shared_RegisterLocation(
            NewLocationSettings(
                "Market",
                [
                    NewLocPair(<-110, -9977, 2987>, <0, 0, 0>),
                    NewLocPair(<-1605, -10300, 3053>, <0, -100, 0>),
                    NewLocPair(<4600, -11450, 2950>, <0, 180, 0>),
                    NewLocPair(<3150, -11153, 3053>, <0, 100, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/market"
            )
        )
		Shared_RegisterLocation(
            NewLocationSettings(
                "Labs",
                [
                    NewLocPair(<27576, 8062, 2910>, <0, -115, 0>),
					NewLocPair(<24545, 2387, 4100>, <0, -7, 0>),
                    NewLocPair(<25924, 2161, 3848>, <0, -9, 0>),
                    NewLocPair(<28818, 2590, 3798>, <0, 117, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/labs"
            )
        )
		Shared_RegisterLocation(
            NewLocationSettings(
                "Repulsor",
                [
                    NewLocPair(<28095, -16983, 4786>, <0, 140, 0>),
                    NewLocPair(<29475, -12237, 5769>, <0, -157, 0>),
                    NewLocPair(<20567, -13551, 4821>, <0, -39, 0>),
                    NewLocPair(<22026, -17661, 5789>, <0, 21, 0>),
					NewLocPair(<26036, -17590, 5694>, <0, 90, 0>),
                    NewLocPair(<26670, -16729, 4926>, <0, -180, 0>),
                    NewLocPair(<27784, -16166, 5046>, <0, -180, 0>),
                    NewLocPair(<27133, -16074, 5414>, <0, -90, 0>),
                    NewLocPair(<27051, -14200, 5582>, <0, -90, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/repulsor"
            )
        )

		Shared_RegisterLocation(
			NewLocationSettings(
                "Cage",
                [
                    NewLocPair(<15604, -1068, 5833>, <0, -126, 0>),
                    NewLocPair(<18826, -4314, 5032>, <0, 173, 0>),
                    NewLocPair(<19946, 32, 4960>, <0, -168, 0>),
                    NewLocPair(<12335, -1446, 3984>, <0, 2, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/cage"
            )
        )

		Shared_RegisterLocation(
            NewLocationSettings(
                "Swamps",
                [
                    NewLocPair(<37886, -4012, 3300>, <0, 167, 0>),
                    NewLocPair(<34392, -5974, 3017>, <0, 51, 0>),
                    NewLocPair(<29457, -2989, 2895>, <0, -17, 0>),
                    NewLocPair(<34582, 2300, 2998>, <0, -92, 0>),
					NewLocPair(<35757, 3256, 3290>, <0, -90, 0>),
                    NewLocPair(<36422, 3109, 3500>, <0, -165, 0>),
                    NewLocPair(<34965, 1718, 3529>, <0, 45, 0>),
                    NewLocPair(<32654, -1552, 3228>, <0, -90, 0>)

                ],
                <0, 0, 3000>,$"rui/flowstatelocations/swamps"
            )
        )

		Shared_RegisterLocation(
            NewLocationSettings(
                "Interstellar Relay",
                [
                    NewLocPair(<26420, 31700, 4790>, <0, -90, 0>),
                    NewLocPair(<29260, 26245, 4210>, <0, 45, 0>),
                    NewLocPair(<29255, 24360, 4210>, <0, 0, 0>),
                    NewLocPair(<24445, 28970, 4340>, <0, -90, 0>),
                    NewLocPair(<27735, 27880, 4370>, <0, 180, 0>),
                    NewLocPair(<25325, 25725, 4270>, <0, 0, 0>),
                    NewLocPair(<27675, 25745, 4370>, <0, 0, 0>),
                    NewLocPair(<24375, 27050, 4325>, <0, 180, 0>),
                    NewLocPair(<24000, 23650, 4050>, <0, 135, 0>),
                    NewLocPair(<23935, 22080, 4200>, <0, 15, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/relay"
            )
        )
		
        Shared_RegisterLocation(
            NewLocationSettings(
                "Slum Lakes",
                [
                    NewLocPair(<-20060, 23800, 2655>, <0, 110, 0>),
                    NewLocPair(<-20245, 24475, 2810>, <0, -160, 0>),
                    NewLocPair(<-25650, 22025, 2270>, <0, 20, 0>),
                    NewLocPair(<-25550, 21635, 2590>, <0, 20, 0>),
                    NewLocPair(<-25030, 24670, 2410>, <0, -75, 0>),
                    NewLocPair(<-23125, 25320, 2410>, <0, -20, 0>),
                    NewLocPair(<-21925, 21120, 2390>, <0, 180, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/slumlakes"
            )
        )
		
        Shared_RegisterLocation(
            NewLocationSettings(
                "Little Town",
                [
                    NewLocPair(<-30190, 12473, 3186>, <0, -90, 0>),
                    NewLocPair(<-28773, 11228, 3210>, <0, 180, 0>),
                    NewLocPair(<-29802, 9886, 3217>, <0, 90, 0>),
                    NewLocPair(<-30895, 10733, 3202>, <0, 0, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/kclittletown"
            )
        )

        Shared_RegisterLocation(
            NewLocationSettings(
                "Runoff",
                [
                    NewLocPair(<-23380, 9634, 3371>, <0, 90, 0>),
                    NewLocPair(<-24917, 11273, 3085>, <0, 0, 0>),
                    NewLocPair(<-23614, 13605, 3347>, <0, -90, 0>),
                    NewLocPair(<-24697, 12631, 3085>, <0, 0, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/runoff"
            )
        )
		
		Shared_RegisterLocation(
            NewLocationSettings(
                "The Farm",
                [
                    NewLocPair(<11242, 8591, 4630>, <0, 0, 0>),
                    NewLocPair(<6657, 12189, 5066>, <0, -90, 0>),
                    NewLocPair(<7540, 8620, 5374>, <0, 89, 0>),
                    NewLocPair(<13599, 7838, 4944>, <0, 150, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/thefarm"
            )
        )
		
        Shared_RegisterLocation(
            NewLocationSettings(
                "Thunderdome",
                [
                    NewLocPair(<-20216, -21612, 3191>, <0, -67, 0>),
                    NewLocPair(<-16035, -20591, 3232>, <0, -133, 0>),
                    NewLocPair(<-16584, -24859, 2642>, <0, 165, 0>),
                    NewLocPair(<-19019, -26209, 2640>, <0, 65, 0>)
                ],
                <0, 0, 2000>,$"rui/flowstatelocations/thunderdome"
            )
        )
        Shared_RegisterLocation(
            NewLocationSettings(
                "Water Treatment",
                [
                    NewLocPair(<5583, -30000, 3070>, <0, 0, 0>),
                    NewLocPair(<7544, -29035, 3061>, <0, 130, 0>),
                    NewLocPair(<10091, -30000, 3070>, <0, 180, 0>),
                    NewLocPair(<8487, -28838, 3061>, <0, -45, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/watert"
            )
        )
		
        Shared_RegisterLocation(
            NewLocationSettings(
                "The Pit KC",
                [
                    NewLocPair(<-18558, 13823, 3605>, <0, 20, 0>),
                    NewLocPair(<-16514, 16184, 3772>, <0, -77, 0>),
                    NewLocPair(<-13826, 15325, 3749>, <0, 160, 0>),
                    NewLocPair(<-16160, 14273, 3770>, <0, 101, 0>)
                ],
                <0, 0, 7000>,$"rui/flowstatelocations/pit"
            )
        )
		
        Shared_RegisterLocation(
            NewLocationSettings(
                "Airbase",
                [
                    NewLocPair(<-24140, -4510, 2583>, <0, 90, 0>),
                    NewLocPair(<-28675, 612, 2600>, <0, 18, 0>),
                    NewLocPair(<-24688, 1316, 2583>, <0, 180, 0>),
                    NewLocPair(<-26492, -5197, 2574>, <0, 50, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/airbase"
            )
        )		

	break
	case eMaps.mp_rr_canyonlands_mu2: //todo add more
		Shared_RegisterLocation(
				NewLocationSettings(
					"Slum Lakes",
					[
						NewLocPair(<-20060, 23800, 2655>, <0, 110, 0>),
						NewLocPair(<-20245, 24475, 2810>, <0, -160, 0>),
						NewLocPair(<-25650, 22025, 2270>, <0, 20, 0>),
						NewLocPair(<-25550, 21635, 2590>, <0, 20, 0>),
						NewLocPair(<-25030, 24670, 2410>, <0, -75, 0>),
						NewLocPair(<-23125, 25320, 2410>, <0, -20, 0>),
						NewLocPair(<-21925, 21120, 2390>, <0, 180, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/slumlakes"
				)
			)
        Shared_RegisterLocation(
            NewLocationSettings(
                "Airbase",
                [
                    NewLocPair(<-24140, -4510, 2583>, <0, 90, 0>),
                    NewLocPair(<-28675, 612, 2600>, <0, 18, 0>),
                    NewLocPair(<-24688, 1316, 2583>, <0, 180, 0>),
                    NewLocPair(<-26492, -5197, 2574>, <0, 50, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/airbase"
            )
        )
	break
	case eMaps.mp_rr_canyonlands_64k_x_64k:
		Shared_RegisterLocation(
				NewLocationSettings(
					"Skull Town",
					[
						NewLocPair(<-9320, -13528, 3167>, <0, -100, 0>),
						NewLocPair(<-7544, -13240, 3161>, <0, -115, 0>),
						NewLocPair(<-10250, -18320, 3323>, <0, 100, 0>),
						NewLocPair(<-13261, -18100, 3337>, <0, 20, 0>),
						NewLocPair(<-9494.28223, -15102.4033, 3682.01245> , <0, 46.8770065, 0>),
						NewLocPair(<-8576.70215, -14699.4404, 3106.05249> , <0, -156.390549, 0>),
						NewLocPair(<-6252.36279, -14442.0283, 3134.03125> , <0, 107.969574, 0>),
						NewLocPair(<-12867.5625, -14665.5371, 3267.03125> , <0, 142.490356, 0>),
						NewLocPair(<-14145.9111, -13601.1631, 3104.80249> , <0, -46.4598045, 0>),
						NewLocPair(<-12875.3711, -13606.7939, 3431.03125> , <0, -63.7539482, 0>),
						NewLocPair(<-11486.4541, -15138.4053, 3682.01245> , <0, 139.321243, 0>),
						NewLocPair(<-8695.05176, -18303.8809, 3417.03125> , <0, 127.273163, 0>),
						NewLocPair(<-10056.2627, -12608.7393, 3177.77124> , <0, -108.74192, 0>),
						NewLocPair(<-6751.12842, -16505.6289, 3300.2373> , <0, -163.484482, 0>),
						NewLocPair(<-11051.5527, -19585.7539, 3373.20483> , <0, 40.5761757, 0>),
						NewLocPair(<-13583.2783, -15975.5498, 3994.18335> , <0, 43.9581413, 0>)

					],
					<0, 0, 3000>,$"rui/flowstatelocations/skulltown"
				)
			)

		Shared_RegisterLocation(
				NewLocationSettings(
					"Relay",
					[
						NewLocPair(<26420, 31700, 4790>, <0, -90, 0>),
						NewLocPair(<29260, 26245, 4210>, <0, 45, 0>),
						NewLocPair(<29255, 24360, 4210>, <0, 0, 0>),
						NewLocPair(<24445, 28970, 4340>, <0, -90, 0>),
						NewLocPair(<27735, 27880, 4370>, <0, 180, 0>),
						NewLocPair(<25325, 25725, 4270>, <0, 0, 0>),
						NewLocPair(<27675, 25745, 4370>, <0, 0, 0>),
						NewLocPair(<24375, 27050, 4325>, <0, 180, 0>),
						NewLocPair(<24000, 23650, 4050>, <0, 135, 0>),
						NewLocPair(<23935, 22080, 4200>, <0, 15, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/relay"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Slum Lakes",
					[
						NewLocPair(<-20060, 23800, 2655>, <0, 110, 0>),
						NewLocPair(<-20245, 24475, 2810>, <0, -160, 0>),
						NewLocPair(<-25650, 22025, 2270>, <0, 20, 0>),
						NewLocPair(<-25550, 21635, 2590>, <0, 20, 0>),
						NewLocPair(<-25030, 24670, 2410>, <0, -75, 0>),
						NewLocPair(<-23125, 25320, 2410>, <0, -20, 0>),
						NewLocPair(<-21925, 21120, 2390>, <0, 180, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/slumlakes"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Little Town",
					[
						NewLocPair(<-30190, 12473, 3186>, <0, -90, 0>),
						NewLocPair(<-28773, 11228, 3210>, <0, 180, 0>),
						NewLocPair(<-29802, 9886, 3217>, <0, 90, 0>),
						NewLocPair(<-30895, 10733, 3202>, <0, 0, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/kclittletown"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Runoff",
					[
						NewLocPair(<-23380, 9634, 3371>, <0, 90, 0>),
						NewLocPair(<-24917, 11273, 3085>, <0, 0, 0>),
						NewLocPair(<-23614, 13605, 3347>, <0, -90, 0>),
						NewLocPair(<-24697, 12631, 3085>, <0, 0, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/runoff"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Thunderdome",
					[
						NewLocPair(<-20216, -21612, 3191>, <0, -67, 0>),
						NewLocPair(<-16035, -20591, 3232>, <0, -133, 0>),
						NewLocPair(<-16584, -24859, 2642>, <0, 165, 0>),
						NewLocPair(<-19019, -26209, 2640>, <0, 65, 0>)
					],
					<0, 0, 2000>,$"rui/flowstatelocations/thunderdome"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Water Treatment",
					[
						NewLocPair(<5583, -30000, 3070>, <0, 0, 0>),
						NewLocPair(<7544, -29035, 3061>, <0, 130, 0>),
						NewLocPair(<10091, -30000, 3070>, <0, 180, 0>),
						NewLocPair(<8487, -28838, 3061>, <0, -45, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/watert"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"The Pit KC",
					[
						NewLocPair(<-18558, 13823, 3605>, <0, 20, 0>),
						NewLocPair(<-16514, 16184, 3772>, <0, -77, 0>),
						NewLocPair(<-13826, 15325, 3749>, <0, 160, 0>),
						NewLocPair(<-16160, 14273, 3770>, <0, 101, 0>)
					],
					<0, 0, 7000>,$"rui/flowstatelocations/pit"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Airbase",
					[
						NewLocPair(<-24140, -4510, 2583>, <0, 90, 0>),
						NewLocPair(<-28675, 612, 2600>, <0, 18, 0>),
						NewLocPair(<-24688, 1316, 2583>, <0, 180, 0>),
						NewLocPair(<-26492, -5197, 2574>, <0, 50, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/airbase"
				)
			)

		Shared_RegisterLocation(
				NewLocationSettings(
					"Repulsor",
					[
						NewLocPair(<28095, -16983, 4786>, <0, 140, 0>),
						NewLocPair(<29475, -12237, 5769>, <0, -157, 0>),
						NewLocPair(<20567, -13551, 4821>, <0, -39, 0>),
						NewLocPair(<22026, -17661, 5789>, <0, 21, 0>),
						NewLocPair(<26036, -17590, 5694>, <0, 90, 0>),
						  NewLocPair(<26670, -16729, 4926>, <0, -180, 0>),
						  NewLocPair(<27784, -16166, 5046>, <0, -180, 0>),
						  NewLocPair(<27133, -16074, 5414>, <0, -90, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/repulsor"
				)
			)

		Shared_RegisterLocation(
				NewLocationSettings(
					"Swamps",
					[
						NewLocPair(<37886, -4012, 3300>, <0, 167, 0>),
						NewLocPair(<34392, -5974, 3017>, <0, 51, 0>),
						NewLocPair(<29457, -2989, 2895>, <0, -17, 0>),
						NewLocPair(<34582, 2300, 2998>, <0, -92, 0>),
						NewLocPair(<35757, 3256, 3290>, <0, -90, 0>),
						NewLocPair(<36422, 3109, 3500>, <0, -165, 0>),
						NewLocPair(<34965, 1718, 3529>, <0, 45, 0>),
						NewLocPair(<32654, -1552, 3500>, <0, -90, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/swamps"
				)
			)
		Shared_RegisterLocation(
				NewLocationSettings(
					"Market",
					[
						NewLocPair(<-110, -9977, 2987>, <0, 0, 0>),
						NewLocPair(<-1605, -10300, 3053>, <0, -100, 0>),
						NewLocPair(<4600, -11450, 2950>, <0, 180, 0>),
						NewLocPair(<3150, -11153, 3053>, <0, 100, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/market"
				)
			)
			
		// Shared_RegisterLocation(
				// NewLocationSettings(
					// "Custom map by Biscutz",
					// [
						// NewLocPair(<-2768,15163,6469>, <0, -180, 0>),
						// NewLocPair(<-5800,16008,6706>, <0, -48, 0>),
						// NewLocPair(<-5297,13404,6040>, <0, 0, 0>),
						// NewLocPair(<-2348,11823,6194>, <0, 0, 0>),
						// NewLocPair(<-5256,14392,5800>, <0, 0, 0>),
						// NewLocPair(<-3659,13700,6600>, <0, 0, 0>),
						// NewLocPair(<-1514,11165,7730>, <0, 0, 0>)
					// ],
					// <0, 0, 3000>
				// )
			// )
		
		// Shared_RegisterLocation(
			// NewLocationSettings(
				// "White Forest By Zer0Bytes",
				// [
					// //Side A
					// NewLocPair( <-33024,17408,3328>, <0,90,0>),
					// NewLocPair( <-33024,16960,3328>, <0,90,0>),
					// NewLocPair( <-33280,16128,3264>, <0,90,0>),
					// NewLocPair( <-32448,16256,3328>, <0,90,0>),
					// NewLocPair( <-32192,16960,3328>, <0,90,0>),
					// NewLocPair( <-32256,16256,3328>, <0,90,0>),
					// NewLocPair( <-32128,17536,3328>, <0,90,0>),
					// NewLocPair( <-32512,17536,3328>, <0,90,0>),
					// NewLocPair( <-32960,17600,3328>, <0,90,0>),
					// NewLocPair( <-33536,17600,3328>, <0,90,0>),
					// NewLocPair( <-33728,17088,3328>, <0,90,0>),
					// NewLocPair( <-33856,16896,3200>, <0,90,0>),
					// NewLocPair( <-33920,17600,3200>, <0,90,0>),
					// NewLocPair( <-34368,18048,3072>, <0,0,0>),
					// NewLocPair( <-34352,18038,3151>, <0,0,0>),
					// NewLocPair( <-36696,19010,3021>, <0,0,0>),
					// NewLocPair( <-37079,19432,3120>, <0,90,0>),
					// NewLocPair( <-37335,19812,3053>, <0,0,0>),
					// NewLocPair( <-37371,19308,3033>, <0,0,0>),
					// NewLocPair( <-37106,19616,3152>, <0,0,0>),


					// // side B
					// NewLocPair( <-35442,24433,4112>, <0,-90,0>),
					// NewLocPair( <-35467,24668,4112>, <0,-90,0>),
					// NewLocPair( <-35454,24954,4135>, <0,-90,0>),
					// NewLocPair( <-34738,24934,4145>, <0,-90,0>),
					// NewLocPair( <-33453,24955,4152>, <0,-90,0>),
					// NewLocPair( <-33380,24704,4173>, <0,-90,0>),
					// NewLocPair( <-33498,24455,4148>, <0,-90,0>),
					// NewLocPair( <-34195,24456,4128>, <0,-90,0>),
					// NewLocPair( <-33745,24188,4093>, <0,-90,0>),
					// NewLocPair( <-33319,24002,3955>, <0,-90,0>),
					// NewLocPair( <-32764,23897,3382>, <0,-90,0>),
					// NewLocPair( <-32317,23278,2779>, <0,-90,0>),
					// NewLocPair( <-32100,22750,2647>, <0,180,0>),
					// NewLocPair( <-35148,24427,4147>, <0,-90,0>),

					// //forest
					// NewLocPair( <-33511,22657,2239>, <0,-90,0>),
					// NewLocPair( <-33813,21797,2178>, <0,-90,0>),
					// NewLocPair( <-34937,22312,2195>, <0,-90,0>),
					// NewLocPair( <-35843,23339,2172>, <0,0,0> ),
					// NewLocPair( <-36700,23252,2237>, <0,0,0> ),
					// NewLocPair( <-36374,21910,2204>, <0,0,0> ),
					// NewLocPair( <-35239,22024,2154>, <0,180,0>),
					// NewLocPair( <-34463,20783,2182>, <0,90,0>),
					// NewLocPair( <-32753,20853,2085>, <0,90,0>),
					// NewLocPair( <-31809,21230,2015>, <0,-90,0>),
					// NewLocPair( <-33549,18878,2129>, <0,90,0>),
					// NewLocPair( <-34726,19371,2106>, <0,90,0>),
					// NewLocPair( <-34295,20018,2134>, <0,90,0>),
					// NewLocPair( <-31263,21107,2019>, <0,180,0>),
					// NewLocPair( <-36806,22295,2261>, <0,0,0> ),
					// NewLocPair( <-36226,20102,2105>, <0,0,0>),
					// NewLocPair( <-32764,19415,2048>, <0,180,0>),
					// NewLocPair( <-32402,22605,2328>, <0,-90,0>),
					// NewLocPair( <-33082,23773,2363>, <0,-90,0>)

				// ],
				// <0, 0, 3000>
			// )
		// )
	
		break

		case eMaps.mp_rr_desertlands_64k_x_64k_tt:
        Shared_RegisterLocation(
            NewLocationSettings(
                "Mirage Voyage",
                [
					NewLocPair(<-25930, -3790, -2442>, <0, -37, 0>),
                    NewLocPair(<-22928, -5785, -2396>, <0, 147, 0>),
                    NewLocPair(<-27364, -4969, -2681>, <0, -32, 0>),
                    NewLocPair(<-23150, -6776, -2879>, <0, 122, 0>),
					NewLocPair(<-26373, -3504, -2560>, <0, -36, 0>),
					NewLocPair(<-24183, -3713, -3445>, <0, -126, 0>),
					NewLocPair(<-28862, -3875, -2918>, <0, -19.91, 0>),
					NewLocPair(<-28047, -5494, -2806>, <0, 19.97, 0>),
					NewLocPair(<-26716, -8446, -2733>, <0, 87, 0>),
					NewLocPair(<-22701, -7660, -2898>, <0, 105, 0>)
                ],
                <0, 0, 3000>,$"rui/flowstatelocations/miragevoyage"
            )
        )
        //break
		case eMaps.mp_rr_arena_empty:
		if( GetCurrentPlaylistVarBool( "is_halo_gamemode", false ) )
		{
			//Disabled for now until it's fixed. Cafe
			
			// Shared_RegisterLocation(
				// NewLocationSettings(
					// "Beaver Creek",
					// [
						// NewLocPair( <42468.5938, -11602.749, -26018.1563> , <0, 148.029556, 0> ),
						// NewLocPair( <42093.25, -11919.8389, -26018.1563> , <0, 83.9781113, 0> ),
						// NewLocPair( <41587.5195, -11214.3027, -26018.1504> , <0, -171.320343, 0> ),
						// NewLocPair( <41714.4492, -11410.1641, -26018.1563> , <0, 31.5085945, 0> ),
						
						// NewLocPair( <42569.3281, -10359.9609, -26018.1563> , <0, 167.226318, 0> ),
						// NewLocPair( <41510.5703, -9849.14453, -26018.1367> , <0, -12.629365, 0> ),
						// NewLocPair( <42391.5508, -8908.30469, -26018.1563> , <0, 2.57079864, 0> ),
						// NewLocPair( <42301.0273, -8916.37109, -26018.1563> , <0, -104.546555, 0> )
					// ],
					// <0, 0, 3000>
				// )
			// )

			Shared_RegisterLocation(
				NewLocationSettings(
					"Lockout",
					[
						NewLocPair(<41543.8711, -9008.27539, -20890.7383> , <0, -35.8867874, 0>),
						NewLocPair(<41369.6289, -8793.39746, -20764.0371> , <0, -62.614399, 0>),
						NewLocPair(<41649.9414, -9338.88477, -20592.8379> , <0, -87.7791977, 0>),
						NewLocPair(<41318.5234, -11336.6641, -20704.9375> , <0, 44.4568977, 0>),
						NewLocPair(<41974.5977, -10676.3115, -20795.6367> , <0, -141.929703, 0>),
						NewLocPair(<42184.8945, -11325.4092, -20704.9375> , <0, 110.566208, 0>),
						NewLocPair(<41919.082, -11060.9668, -20528.5371> , <0, 129.327072, 0>),
						NewLocPair(<41910.6367, -9918.69629, -21009.1367> , <0, 122.589836, 0>),
						NewLocPair(<42701.9297, -9711.44824, -21169.2617> , <0, -61.6680984, 0>),
						NewLocPair(<41733.707, -9838.34668, -21368.4609> , <0, 1.02161503, 0>),
						NewLocPair(<43069.2578, -9967.16016, -20763.8594> , <0, 89.3030472, 0>),
						NewLocPair(<41170.4883, -10825.1191, -21136.7383> , <0, 39.0051041, 0>),
						NewLocPair(<41951.875, -10721.0967, -21030.5371> , <0, -147.949905, 0>),
						NewLocPair(<41230.1133, -10046.1729, -20795.8379> , <0, -91.0725632, 0>),
						NewLocPair(<41946.5195, -9054.60156, -20763.9609> , <0, -179.685928, 0>)
					],
					<0, 0, 3000>
				)
			)

		
			Shared_RegisterLocation(
				NewLocationSettings(
					"The Pit",
					[
						NewLocPair( <40595.6406, -9405.83203, -19682.0371> , <0, 168.875229, 0> ),
						NewLocPair( <40457.9844, -10337.167, -19928.1563> , <0, -128.833832, 0> ),
						NewLocPair( <40228.3242, -11431.1162, -19776.1563> , <0, 0.608541489, 0> ),
						NewLocPair( <41253.0508, -11386.7236, -19756.6738> , <0, 170.002029, 0> ),
						NewLocPair( <41500.2109, -9852.54004, -19775.1563> , <0, -38.9899902, 0> )						
						NewLocPair( <42007.3086, -10576.4512, -19726.1563> , <0, -0.443716526, 0> ),
						NewLocPair( <42778.3945, -11427.3486, -19773.918> , <0, -3.03944969, 0> ),
						NewLocPair( <43738.7305, -11488.7549, -19776.1563> , <0, 176.17157, 0> ),
						NewLocPair( <43547.082, -10703.1445, -19928.1563> , <0, 57.0178871, 0> ),
						NewLocPair( <43632.8711, -9161.77832, -19775.8379> , <0, 178.778931, 0> )
						NewLocPair( <42038, -8746.55273, -20156.1563> , <0, -94.6983109, 0> ),
						NewLocPair( <42025.793, -8780.33887, -19852.9375> , <0, 93.6029053, 0> )
					],
					<0, 0, 3000>
				)
			)
			Shared_RegisterLocation(
				NewLocationSettings(
					"Narrows",
					[
						//a
						NewLocPair(<44283.6914, -10554.7461, -20494.6563> , <0, 180, 0>),
						NewLocPair(<44034.75, -9440.18555, -20431.0566> , <0, 180, 0>),
						NewLocPair(<44469.0195, -9811.23828, -20430.7383> , <0, -91.0291061, 0>),
						NewLocPair(<44497.0703, -10197.3779, -20430.7383> , <0, 179.358093, 0>),
						NewLocPair(<43554.4102, -9356.09473, -20431.0566> , <0, -90.3312912, 0>),
						NewLocPair(<42847.043, -10011.834, -20633.3379> , <0, 178.665939, 0>),

						//b
						NewLocPair(<39965.9688, -9465.57813, -20431.0566> , <0, 0, 0>),
						NewLocPair(<39809.4609, -10554.8604, -20494.6563> , <0, 0, 0>),
						NewLocPair(<41153.8398, -10001.6357, -20633.3379> , <0, -1.70678377, 0>),
						NewLocPair(<39527.4453, -9794.68555, -20430.7383> , <0, -89.4788055, 0>),
						NewLocPair(<39524.668, -10252.6455, -20430.7539> , <0, 1.91500413, 0>),
						NewLocPair(<40437.6484, -9336.84375, -20431.0566> , <0, -90.8777695, 0>)
					],
					<0, 0, 3000>
				)
			)		

			return
		}
		break
        case eMaps.mp_rr_desertlands_64k_x_64k:
        case eMaps.mp_rr_desertlands_64k_x_64k_nx:
		    
		if(FlowState_EnableMovementGym()){
		
			Shared_RegisterLocation(
			NewLocationSettings(
				"Movement Gym",
				[
					NewLocPair(< 10726.9000, 10287, -4283 >, < 0, -90.0001, 0 >),
				],
				<0, 0, 3000>
					)
				)
			
			return
		}
		if( Flowstate_IsFastInstaGib() )
		{
			vector shipmentstartingorg = <6779,9016,11687>
			Shared_RegisterLocation(
				NewLocationSettings(
					"Shipment By AyeZee",
					[
						NewLocPair(< 6848.7000, -3415.7000, 99.9000 > + shipmentstartingorg, < 0, -135.0003, 0 >),
						NewLocPair(< 4750.8930, -5191.4390, 99.9000 > + shipmentstartingorg, < 0, 51.7723, 0 >),
						NewLocPair(< 4765.2000, -3380.5000, 99.9000 > + shipmentstartingorg, < 0, -47.3245, 0 >),
						NewLocPair(< 6886.6280, -5163.9330, 99.9000 > + shipmentstartingorg, < 0, 140.8409, 0 >),
						NewLocPair(< 6898.7000, -4523.7000, 99.9000 > + shipmentstartingorg, < 0, -167.7632, 0 >),
						NewLocPair(< 6902.2780, -4062.3870, 99.9000 > + shipmentstartingorg, < 0, 152.5185, 0 >),
						NewLocPair(< 5666.8980, -3541.5550, 99.9000 > + shipmentstartingorg, < 0, 178.2353, 0 >),
						NewLocPair(< 5621, -5041, 99.9000 > + shipmentstartingorg, < 0, 178.2353, 0 >),
						NewLocPair(< 4763, -4508, 99.9000 > + shipmentstartingorg, < 0, -38.7503, 0 >),
						NewLocPair(< 4750.1250, -4088.1680, 99.9000 > + shipmentstartingorg, < 0, 40.1670, 0 >)
					],
					<0, 0, 3000>
				)
			)
			
			vector killhousestartingorg = <-2961,-13240,-2810>
			Shared_RegisterLocation(
			NewLocationSettings(
					"Killhouse By AyeZee",
					[
						NewLocPair(< 156.6777, -1466.7410, 9.4000 > + killhousestartingorg,< 0, 131.0375, 0 >),
						NewLocPair(< -1167.9380, -1466.3340, 9.4000 > + killhousestartingorg,< 0, 44.6976, 0 >),
						NewLocPair(< -1170.2510, -996.2968, 9.4000 > + killhousestartingorg,< 0, -0.5495, 0 >),
						NewLocPair(< 217.9963, -1035.2670, 9.4000 > + killhousestartingorg,< 0, 178.6360, 0 >),
						NewLocPair(< 217.9963, -563, 9.4000 > + killhousestartingorg,< 0, 178.6360, 0 >),
						NewLocPair(< 200.7263, 979.5248, 9.4000 > + killhousestartingorg,< 0, -147.1917, 0 >),
						NewLocPair(< -1162.3790, 980.8486, 9.4000 > + killhousestartingorg,< 0, -45.0161, 0 >),
						NewLocPair(< -1164.7130, 702.9291, 9.4000 > + killhousestartingorg,< 0, 2.9566, 0 >),
						NewLocPair(< 208.7000, 707.6936, 9.4000 > + killhousestartingorg,< 0, -147.0432, 0 >),
						NewLocPair(< -1171.6520, 7.8723, 9.4000 > + killhousestartingorg,< 0, 7.0074, 0 >),
					],
					<0, 0, 3000>
				)
			)
			
			vector nuketownstartingorg = <28524,23022,-3375>
			Shared_RegisterLocation(
			NewLocationSettings(
					"Nuketown By AyeZee",
					[
						NewLocPair(< 381.3000, -859.9000, -502.4000 > + nuketownstartingorg, < 0, 131.6921, 0 >),
						NewLocPair(< -213.7000, -852.2000, -502.4000 > + nuketownstartingorg, < 0, 50.3080, 0 >),
						NewLocPair(< 608.7227, 945.4185, -497.5000 > + nuketownstartingorg, < 0, -85.3474, 0 >),
						NewLocPair(< -379.8000, 952.1000, -497.5000 > + nuketownstartingorg, < 0, -109.8191, 0 >),
						NewLocPair(< -688.5317, -611.3459, -497.5000 > + nuketownstartingorg, < 0, 121.5057, 0 >),
						NewLocPair(< -2298, -23, -497.5000 > + nuketownstartingorg, < 0, 17.9921, 0 >),
						NewLocPair(< -1919, 777, -497.5000 > + nuketownstartingorg, < 0, 17.9921, 0 >),
						NewLocPair(< 1807.1000, 1124.8000, -497.5000 > + nuketownstartingorg, < 0, -106.9288, 0 >),
						NewLocPair(< 1285, 970, -497.5000 > + nuketownstartingorg, < 0, -106.9288, 0 >),
						NewLocPair(< 2326.3580, -65.8636, -497.5000 > + nuketownstartingorg, < 0, 163.9604, 0 >)
					],
					<0, 0, 3000>
				)
			)
			
			Shared_RegisterLocation(
			NewLocationSettings(
					"Skill trainer By CafeFPS",
						[
						   NewLocPair(<15008, 30040, -680>, <20, 50, 0>),
						   NewLocPair(<19265, 30022, -680>, <11, 132, 0>),
						   NewLocPair(<19267, 33522, -680>, <10, -138, 0>),
						   NewLocPair(<14995, 33566, -680>, <16, -45, 0>)
						],
					   <0, 0, 3000>,$"rui/flowstatelocations/skilltrainer"
					)
				)
			
			return
		}
		if( GetCurrentPlaylistVarBool( "is_halo_gamemode", false ) )
		{
			Shared_RegisterLocation(
				NewLocationSettings(
					"TTV Building",
					[
							NewLocPair(<11360, 6151, -4079>, <0, 102, 0>),
							NewLocPair(<11407, 6778, -4295>, <0, 88, 0>),
							NewLocPair(<11973, 4158, -4220>, <0, 82, 0>),
							NewLocPair(<9956, 3435, -4239>, <0, 0, 0>),
							NewLocPair(<9038, 3800, -4120>, <0, -88, 0>),
							NewLocPair(<7933, 6692, -4250>, <0, 76, 0>),
							NewLocPair(<8990, 5380, -4250>, <0, 145, 0>),
							NewLocPair(<8200, 5463, -3815>, <0, 0, 0>),
							NewLocPair(<9789, 5363, -3480>, <0, 174, 0>),
							NewLocPair(<9448, 5804, -4000>, <0, 0, 0>),
							NewLocPair(<8135, 4087, -4233>, <0, 90, 0>),
							NewLocPair(<9761, 5980, -4250>, <0, 135, 0>)
							NewLocPair(<11393, 5477, -4289>, <0, 90, 0>),
							NewLocPair(<12027, 7121, -4290>, <0, -120, 0>),
							NewLocPair(<8105, 6156, -4300>, <0, -45, 0>),
							NewLocPair(<9420, 5528, -4236>, <0, 90, 0>),
							NewLocPair(<8277, 6304, -3940>, <0, 0, 0>),
							NewLocPair(<8186, 5513, -3828>, <0, 0, 0>),
							NewLocPair(<8243, 4537, -4235>, <-13, 32, 0>),
							NewLocPair(<11700, 6207, -4435>, <-10, 90, 0>),
							NewLocPair(<11181, 5862, -3900>, <0, -180, 0>),
							NewLocPair(<9043, 5866, -4171>, <0, 90, 0>),
							NewLocPair(<11210, 4164, -4235>, <0, 90, 0>),
							NewLocPair(<12775, 4446, -4235>, <0, 150, 0>),
							NewLocPair(<9012, 5386, -4242>, <0, 90, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/ttvbuilding"
				)
			)
			// return
		}
		
		if(!GetCurrentPlaylistVarBool("flowstateCapitolCityReplacesTTVLocation", false ))
		{
			Shared_RegisterLocation(
				NewLocationSettings(
					"TTV Building",
					[
							NewLocPair(<11360, 6151, -4079>, <0, 102, 0>),
							NewLocPair(<11407, 6778, -4295>, <0, 88, 0>),
							NewLocPair(<11973, 4158, -4220>, <0, 82, 0>),
							NewLocPair(<9956, 3435, -4239>, <0, 0, 0>),
							NewLocPair(<9038, 3800, -4120>, <0, -88, 0>),
							NewLocPair(<7933, 6692, -4250>, <0, 76, 0>),
							NewLocPair(<8990, 5380, -4250>, <0, 145, 0>),
							NewLocPair(<8200, 5463, -3815>, <0, 0, 0>),
							NewLocPair(<9789, 5363, -3480>, <0, 174, 0>),
							NewLocPair(<9448, 5804, -4000>, <0, 0, 0>),
							NewLocPair(<8135, 4087, -4233>, <0, 90, 0>),
							NewLocPair(<9761, 5980, -4250>, <0, 135, 0>)
							NewLocPair(<11393, 5477, -4289>, <0, 90, 0>),
							NewLocPair(<12027, 7121, -4290>, <0, -120, 0>),
							NewLocPair(<8105, 6156, -4300>, <0, -45, 0>),
							NewLocPair(<9420, 5528, -4236>, <0, 90, 0>),
							NewLocPair(<8277, 6304, -3940>, <0, 0, 0>),
							NewLocPair(<8186, 5513, -3828>, <0, 0, 0>),
							NewLocPair(<8243, 4537, -4235>, <-13, 32, 0>),
							NewLocPair(<11700, 6207, -4435>, <-10, 90, 0>),
							NewLocPair(<11181, 5862, -3900>, <0, -180, 0>),
							NewLocPair(<9043, 5866, -4171>, <0, 90, 0>),
							NewLocPair(<11210, 4164, -4235>, <0, 90, 0>),
							NewLocPair(<12775, 4446, -4235>, <0, 150, 0>),
							NewLocPair(<9012, 5386, -4242>, <0, 90, 0>)
					],
					<0, 0, 3000>,$"rui/flowstatelocations/ttvbuilding"
				)
			)
		}
		else{
		Shared_RegisterLocation(
			NewLocationSettings(
				"Capitol City",
				[
					NewLocPair(<1142, 5067, -3351>, <16, 18, 0>),
					NewLocPair(<1155, 5460, -3552>, <5, -62, 0>),
					NewLocPair(<1552, 5547, -3151>, <20, -166, 0>),
					NewLocPair(<1168, 4657, -4167>, <9, 58, 0>),
					NewLocPair(<1233, 5027, -3152>, <13, 55, 0>),
					NewLocPair(<2196, 3038, -4083>, <1, 1, 0>),
					NewLocPair(<2262, 4710, -3552>, <12, 60, 0>),
					NewLocPair(<2364, 5634, -3967>, <20, 171, 0>),
					NewLocPair(<2911, 9488, -3863>, <11, 50, 0>),
					NewLocPair(<5258, 12129, -4024>, <8, 16, 0>),
					NewLocPair(<5316, 3324, -3848>, <10, 125, 0>),
					NewLocPair(<5897, 10028, -4015>, <10, 60, 0>),
					NewLocPair(<6756, 4952, -3448>, <8, 7, 0>),
					NewLocPair(<7299, 7471, -4222>, <0, -90, 0>),
					NewLocPair(<7307, 6964, -4503>, <2, 88, 0>),
					NewLocPair(<7372, 3885, -4219>, <0, 55, 0>)
					NewLocPair(<7825, 3225, -4239>, <0, 6, 0>),
					NewLocPair(<7965, 5976, -4266>, <0, -135, 0>),
					NewLocPair(<8105, 6156, -4300>, <0, -45, 0>),
					NewLocPair(<8186, 5513, -3828>, <0, 0, 0>),
					NewLocPair(<8277, 6304, -3940>, <0, 0, 0>),
					NewLocPair(<9012, 5386, -4242>, <0, 90, 0>),
					NewLocPair(<9043, 5866, -4171>, <0, 90, 0>),
					NewLocPair(<9420, 5528, -4236>, <0, 90, 0>),
					NewLocPair(<9800, 5347, -3507>, <0, 134, 0>),
					NewLocPair(<9862, 5561, -3832>, <0, 180, 0>),
					NewLocPair(<9976, 8539, -4207>, <0, -90, 0>),
					NewLocPair(<10058, 2071, -3827>, <0, -90, 0>),
					NewLocPair(<10107, 3843, -4000>, <0, 90, 0>),
					NewLocPair(<10176, 4245, -4300>, <0, 100, 0>),
					NewLocPair(<11181, 5862, -3900>, <0, -180, 0>),
					NewLocPair(<11210, 4164, -4235>, <0, 90, 0>),
					NewLocPair(<11700, 6207, -4435>, <-10, 90, 0>)
				],
				<0, 0, 3000>,$"rui/flowstatelocations/capitolcity"
			)
		)
		}
		
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Lava Fissure",
                    [
                        NewLocPair(<-26550, 13746, -3048>, <0, -134, 0>),
                        NewLocPair(<-28877, 12943, -3109>, <0, -88.70, 0>),
                        NewLocPair(<-29881, 9168, -2905>, <-1.87, -2.11, 0>),
                        NewLocPair(<-27590, 9279, -3109>, <0, 90, 0>),
                        NewLocPair(<-27585, 9191, -3080>, <0, 89, 0>),
                        NewLocPair(<-26469, 9825, -2810>, <0, 87, 0>),
                        NewLocPair(<-27623, 10210, -3290>, <0, 87, 0>),
                        NewLocPair(<-25717, 13034, -3047>, <0, -176, 0>),
                        NewLocPair(<-26433, 13360, -3000>, <0, 68, 0>),
                        NewLocPair(<-26463, 13766, -3080>, <0, -95, 0>),
                        NewLocPair(<-28781, 13266, -3080>, <0, 80, 0>),
                        NewLocPair(<-27535, 10922, -3280>, <0, -94, 0>),
                        NewLocPair(<-29879, 9151, -2860>, <0, 0, 0>)
                    ],
                    <0, 0, 2500>,$"rui/flowstatelocations/lavafissure"
                )
            )
			
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Space Elevator",
                    [
                        NewLocPair(<-12286, 26037, -4012>, <0, -116, 0>),
                        NewLocPair(<-12318, 28447, -3975>, <0, -122, 0>),
                        NewLocPair(<-14373, 27785, -3961>, <0, -25, 0>),
                        NewLocPair(<-11638, 26123, -3983>, <0, 137, 0>),
						NewLocPair(<-13348, 27630, -3535>, <3.01, 57.17, 0>),
						NewLocPair(<-13772, 26473, -4000>, <0, 169, 0>),
                        NewLocPair(<-12366, 26209, -4000>, <0, -90, 0>),
                        NewLocPair(<-12063, 27640, -4000>, <0, -3, 0>),
                        NewLocPair(<-13732, 27577, -3500>, <0, -83, 0>),
                        NewLocPair(<-13732, 27577, -3500>, <0, -83, 0>),
                        NewLocPair(<-12350, 26227, -3500>, <0, 148, 0>),
                        NewLocPair(<-13765, 27654, -2850>, <0, -65, 0>),
                        NewLocPair(<-12121, 26517, -2850>, <0, 124, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/spaceelevator"
                )
            )
			
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Little Town",
                    [
                        NewLocPair(<22857, 3449, -4050>, <0, -157, 0>),
                        NewLocPair(<19559, 232, -4035>, <0, 33, 0>),
                        NewLocPair(<19400, 4384, -4027>, <0, -35, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/littletown"
                )
            )

		Shared_RegisterLocation(
                NewLocationSettings(
                    "TTV Building 2",
                    [
                        NewLocPair(<1313, 4450, -2990>, <0, 50, 0>),
                        NewLocPair(<2300, 6571, -4490>, <0, -96, 0>),
						NewLocPair(<2617, 4668, -4250>, <0, 85, 0>),
                        NewLocPair(<1200, 4471, -4150>, <0, 50, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/ttvbuilding2"
                )
            )

		Shared_RegisterLocation(
                NewLocationSettings(
                    "Little Town 2",
                    [
                        NewLocPair(<-27219, -24393, -4497>, <0, 87, 0>),
                        NewLocPair(<-26483, -28042, -4209>, <0, 122, 0>),
                        NewLocPair(<-25174, -26091, -4550>, <0, 177, 0>),
						NewLocPair(<-29512, -25863, -4462>, <0, 3, 0>),
						NewLocPair(<-28380, -28984, -4102>, <0, 54, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/littletown2"
                )
            )

	    Shared_RegisterLocation(
                NewLocationSettings(
                    "Dome",
                    [
                        NewLocPair(<19351, -41456, -2192>, <0, 96, 0>),
                        NewLocPair(<22925, -37060, -2169>, <0, -156, 0>),
                        NewLocPair(<19772, -34549, -2232>, <0, -137, 0>),
						NewLocPair(<17010, -37125, -2129>, <0, 81, 0>),
						NewLocPair(<15223, -40222, -1998>, <0, 86, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/dome"
                )
            )

		Shared_RegisterLocation(
                NewLocationSettings(
                    "Refinery",
                    [
                        NewLocPair(<22970, 27159, -4612>, <0, 135, 0>),
                        NewLocPair(<20430, 26481, -4200>, <0, 135, 0>),
                        NewLocPair(<19142, 30982, -4612>, <0, -45, 0>),
                        NewLocPair(<18285, 28602, -4200>, <0, -45, 0>),
                        NewLocPair(<19228, 25592, -4821>, <0, 135, 0>),
                        NewLocPair(<19495, 29283, -4821>, <0, -45, 0>),
                        NewLocPair(<18470, 28330, -4370>, <0, 135, 0>),
                        NewLocPair(<18461, 28405, -4199>, <0, 45, 0>),
                        NewLocPair(<18284, 28492, -3992>, <0, -45, 0>),
                        NewLocPair(<19428, 27190, -4140>, <0, -45, 0>),
                        NewLocPair(<20435, 26254, -4139>, <0, -175, 0>),
                        NewLocPair(<20222, 26549, -4316>, <0, 135, 0>),
                        NewLocPair(<19444, 25605, -4602>, <0, 45, 0>),
                        NewLocPair(<21751, 29980, -4226>, <0, -135, 0>),
                        NewLocPair(<17570, 26915, -4637>, <0, -90, 0>),
                        NewLocPair(<16715, 28017, -4650>, <0, -45, 0>)
                    ],
                    <0, 0, 6500>,$"rui/flowstatelocations/refinery"
                )
            )
			
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Factory",
                    [
                        NewLocPair(<495.42, -26649.92, -3038.36>, <10.60, 44.95, -0>),
                        NewLocPair(<648.07, -26450.72, -3547.97>, <10.20, 57.48, -0>),
                        NewLocPair(<1653.03, -22939.29, -3571.97>, <12.00, -1.80, -0>),
                        NewLocPair(<1722.22, -20823.69, -3719.31>, <7.45, -0.78, -0>),
                        NewLocPair(<2193.69, -25349.72, -3443.97>, <3.69, 15.20, -0>),
                        NewLocPair(<2557.95, -25035.46, -2971.97>, <2.00, 31.20, -0>),
                        NewLocPair(<2608.53, -21670.90, -3707.97>, <11.75, 89.78, -0>),
                        NewLocPair(<2240.71, -23184.89, -3187.97>, <-5.40, -87.58, -0>),
                        NewLocPair(<3507.99, -24980.33, -3571.97>, <-6.62, -36.62, -0>),
                        NewLocPair(<3954.13, -18102.04, -3582.36>, <-8.11, -29.47, 0>),
                        NewLocPair(<4450.69, -20891.45, -3507.85>, <11.16, -44.58, -0.00>),
                        NewLocPair(<6090.35, -25075.12, -3563.97>, <2.47, -0.46, -0>),
                        NewLocPair(<7415.33, -20497.42, -3631.94>, <8.72, 84.13, -0>),
                        NewLocPair(<7422.97, -17985.25, -3507.97>, <8.41, -45.65, -0>),
                        NewLocPair(<8240.16, -24245.68, -3547.97>, <8.23, 50.62, -0>),
                        NewLocPair(<9259.17, -22461.68, -3283.97>, <9.92, -28.07, -0>),
                        NewLocPair(<9534.27, -19869.87, -3331.97>, <3.73, -91.33, -0>),
                        NewLocPair(<10111.38, -20003.82, -2752.97>, <18.04, 84.92, -0>),
                        NewLocPair(<11252.87, -16981.14, -2752.97>, <17.64, -104.16, 0>),
                        NewLocPair(<11720.60, -19655.80, -3331.97>, <1.44, -116.68, -0>),
                        NewLocPair(<12233.26, -18075.12, -2581.72>, <4.60, -134.70, 0>),
                    ],
                    <0, 0, 3000>,$"rui/flowstatelocations/factory"
                )
            )

        Shared_RegisterLocation(
                NewLocationSettings(
                    "Lava City",
                    [
                        NewLocPair(<22663, -28134, -2706>, <0, 40, 0>),
                        NewLocPair(<22844, -28222, -3030>, <0, 90, 0>),
                        NewLocPair(<22687, -27605, -3434>, <0, -90, 0>),
                        NewLocPair(<22610, -26999, -2949>, <0, 90, 0>),
                        NewLocPair(<22607, -26018, -2749>, <0, -90, 0>),
                        NewLocPair(<22925, -25792, -3500>, <0, -120, 0>),
                        NewLocPair(<24235, -27378, -3305>, <0, -100, 0>),
                        NewLocPair(<24345, -28872, -3433>, <0, -144, 0>),
                        NewLocPair(<24446, -28628, -3252>, <13, 0, 0>),
                        NewLocPair(<23931, -28043, -3265>, <0, 0, 0>),
                        NewLocPair(<27399, -28588, -3721>, <0, 130, 0>),
                        NewLocPair(<26610, -25784, -3400>, <0, -90, 0>),
                        NewLocPair(<26757, -26639, -3673>, <-10, 90, 0>),
                        NewLocPair(<26750, -26202, -3929>, <-10, -90, 0>)
                    ],
                    <0, 0, 3000>,$"rui/flowstatelocations/lavacity"
                )
            )
			
        Shared_RegisterLocation(
                NewLocationSettings(
                    "Thermal Station",
                    [
                        NewLocPair(<-20091, -17683, -3984>, <0, -90, 0>),
						NewLocPair(<-22919, -20528, -4010>, <0, 0, 0>),
						NewLocPair(<-17140, -20710, -3973>, <0, -180, 0>),
                        NewLocPair(<-21054, -23399, -3850>, <0, 90, 0>),
                        NewLocPair(<-20938, -23039, -4252>, <0, 90, 0>),
                        NewLocPair(<-19361, -23083, -4252>, <0, 100, 0>),
                        NewLocPair(<-19264, -23395, -3850>, <0, 100, 0>),
                        NewLocPair(<-16756, -20711, -3982>, <0, 180, 0>),
                        NewLocPair(<-17066, -20746, -4233>, <0, 180, 0>),
                        NewLocPair(<-17113, -19622, -4269>, <10, -170, 0>),
                        NewLocPair(<-20092, -17684, -4252>, <0, -90, 0>),
                        NewLocPair(<-23069, -20567, -4214>, <-11, 146, 0>),
                        NewLocPair(<-20109, -20675, -4252>, <0, -90, 0>)
                    ],
                    <0, 0, 11000>,$"rui/flowstatelocations/thermalstation"
                )
            )
			
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Epicenter",
                    [
                        NewLocPair(<8712, 23164, -3944>, <0, -49, 0>),
                        NewLocPair(<14000, 21690, -3969>, <0, -130, 0>),
                        NewLocPair(<10377, 17994, -4236>, <0, -120, 0>),
						NewLocPair(<13100, 18138, -4856>, <0, 120, 0>)

                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/epicenter"
                )
            )
			
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Overlook",
                    [
                        NewLocPair(<32774, 6031, -3239>, <0, 117, 0>),
                        NewLocPair(<28381, 8963, -3224>, <0, 48, 0>),
                        NewLocPair(<26327, 11857, -2477>, <0, -43, 0>),
						NewLocPair(<27303, 14528, -3047>, <0, -42, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/overlook"
                )
            )	
			
		Shared_RegisterLocation(
                NewLocationSettings(
                    "Train yard",
                    [
                        NewLocPair(<-11956,3021,-2988>, <0, 87, 0>),
                        NewLocPair(<-13829,2836,-3037>, <0, 122, 0>),
                        NewLocPair(<-12883,4502,-3340>, <0, 177, 0>),
						NewLocPair(<-11412,3692,-3405>, <0, 3, 0>),
						NewLocPair(<-14930,2065,-3140>, <0, 3, 0>)
                    ],
                    <0, 0, 2000>,$"rui/flowstatelocations/trainyard"
                )
            )
					
			
		Shared_RegisterLocation(
                NewLocationSettings(
                   "Skill trainer By CafeFPS",
                    [
                       NewLocPair(<15008, 30040, -680>, <20, 50, 0>),
                       NewLocPair(<19265, 30022, -680>, <11, 132, 0>),
                       NewLocPair(<19267, 33522, -680>, <10, -138, 0>),
                       NewLocPair(<14995, 33566, -680>, <16, -45, 0>)
                    ],
                   <0, 0, 3000>,$"rui/flowstatelocations/skilltrainer"
                )
            )
		
		// Shared_RegisterLocation(
                // NewLocationSettings(
                    // "Cave By BlessedSeal",
                    // [
						// NewLocPair(<-8742, -11843, -3185>, <0, 40, 0>),
                        // NewLocPair(<-1897, -9707, -3841>, <0, 40, 0>),
                        // NewLocPair(<-5005, -11170, -213>, <0, -40, 0>),
                        // NewLocPair(<-1086, -9685, -3790>, <5, -120, 0>)
                    // ],
                    // <0, 0, 2000>,$"rui/flowstatelocations/cave"
                // )
            // )
		
		// Shared_RegisterLocation(
			// NewLocationSettings(
				// "Brightwater By Zer0bytes",
				// [
					// // SIde A
					// NewLocPair(<-34368,35904,-3776>, <0,0,0>),
					// NewLocPair(<-34496,35648,-3776>, <0,0,0>),
					// NewLocPair(<-35392,35136,-3776>, <0,90,0>),
					// NewLocPair(<-35456,35776,-3712>, <0,0,0>),
					// NewLocPair(<-35456,36160,-3712>, <0,0,0>),
					// NewLocPair(<-33088,37888,-3776>, <0,0,0>),
					// NewLocPair(<-32960,37440,-3776>, <0,0,0>),
					// NewLocPair(<-32576,35136,-3648>, <0,0,0>),
					// NewLocPair(<-32576,34880,-3648>, <0,0,0>),
					// NewLocPair(<-31488,34432,-3648>, <0,90,0>),
					// NewLocPair(<-31296,34496,-3712>, <0,0,0>),
					// NewLocPair(<-31232,34496,-3648>, <0,0,0>),
					// NewLocPair(<-30976,34432,-3648>, <0,0,0>),
					// NewLocPair(<-31232,35200,-3648>, <0,0,0>),
					// NewLocPair(<-31424,35776,-3648>, <0,0,0>),
					// NewLocPair(<-32384,37056,-3776>, <0,0,0>),
					// NewLocPair(<-32000,36672,-3776>, <0,0,0>),
					// NewLocPair(<-31680,38016,-3776>, <0,0,0>),
					// NewLocPair(<-31104,37824,-3776>, <0,0,0>),
					// NewLocPair(<-31680,39296,-3648>, <0,0,0>),
					// NewLocPair(<-31680,39616,-3648>, <0,0,0>)

				   // //Side A
				   // NewLocPair(<-24640,40000,-3648>, <0,180,0>),
				   // NewLocPair(<-24640,39744,-3648>, <0,180,0>),
				   // NewLocPair(<-24941,39665,-3470>, <0,180,0>),
				   // NewLocPair(<-23936,37888,-3712>, <0,180,0>),
				   // NewLocPair(<-25088,37376,-3712>, <0,180,0>),
				   // NewLocPair(<-25600,40832,-3712>, <0,180,0>),
				   // NewLocPair(<-26752,39296,-3712>, <0,180,0>),
				   // NewLocPair(<-26880,37248,-3584>, <0,180,0>),
				   // NewLocPair(<-26880,37888,-3584>, <0,180,0>),
				   // NewLocPair(<-26880,38528,-3584>, <0,180,0>),
				   // NewLocPair(<-26368,35968,-3712>, <0,180,0>),
				   // NewLocPair(<-26496,35584,-3712>, <0,180,0>),
				   // NewLocPair(<-26368,36224,-3712>, <0,180,0>),
				   // NewLocPair(<-26752,35968,-3200>, <0,180,0>),
				   // NewLocPair(<-25728,40448,-3712>, <0,180,0>),
				   // NewLocPair(<-26496,40704,-3712>, <0,-90,0>),
				   // NewLocPair(<-27520,39808,-3840>, <0,180,0>),
				   // NewLocPair(<-24832,36480,-3712>, <0,180,0>),
				   // NewLocPair(<-23808,37504,-3712>, <0,180,0>),
				   // NewLocPair(<-23680,36992,-3584>, <0,180,0>),
				   // NewLocPair(<-25344,40704,-3584>, <0,180,0>),
				   // NewLocPair(<-25344,41344,-3584>, <0,180,0>),

				   // //others
				   // NewLocPair(<-27136,41920,1036>, <0,180,0>),
				   // NewLocPair(<-29364,42940,1040>, <0,180,0>),
				   // NewLocPair(<-31304,42044,1036>, <0,0,0>),
				   // NewLocPair(<-33520,42044,1204>, <0,0,0>),
				   // NewLocPair(<-33800,41756,1252>, <0,0,0>),
				   // NewLocPair(<-29268,41712,1084>, <0,0,0>),
				   // NewLocPair(<-25776,42168,1216>, <0,180,0>),
				   // NewLocPair(<-25724,41724,1204>, <0,180,0>),
				   // NewLocPair(<-28196,38564,-676>, <0,-90,0>),
				   // NewLocPair(<-26324,40476,-2756>, <0,180,0>),
				   // NewLocPair(<-31000,39452,-2752>, <0,0,0>), 
				   // NewLocPair(<-27192,35676,-3284>, <0,90,0>),
				   // NewLocPair(<-28108,35740,-3284>, <0,180,0>),
				   // NewLocPair(<-27376,35880,-2732>, <0,90,0>),
				   // NewLocPair(<-27204,35764,-3628>, <0,90,0>),
				   // NewLocPair(<-27908,36328,-3644>, <0,-90,0>),
				   // NewLocPair(<-28332,37500,-3676>, <0,0,0>), 
				   // NewLocPair(<-27828,37996,-3676>, <0,180,0>),
				   // NewLocPair(<-27960,37448,-3400>, <0,90,0>),
				   // NewLocPair(<-28396,38072,-3344>, <0,0,0>), 
				   // NewLocPair(<-27976,37960,2608>, <0,180,0>),
				   // NewLocPair(<-29348,39856,2668>, <0,-90,0>),
				   // NewLocPair(<-28936,39308,1916>, <0,0,0>),
				   // NewLocPair(<-27420,38688,2112>, <0,0,0>),
				   // NewLocPair(<-23648,35384,-3564>, <0,180,0>),
				   // NewLocPair(<-23972,35136,-3748>, <0,90,0>),
				   // NewLocPair(<-26220,35644,-3692>, <0,90,0>),
				   // NewLocPair(<-26320,36392,-3748>, <0,90,0>),
				// ],
				// <0, 0, 7450>,$"rui/flowstatelocations/brightwater"
			// )
		// )

        if(FlowState_EnableShipmentByAyeZee()){
            vector shipmentstartingorg = <6779,9016,11687>
            Shared_RegisterLocation(
			NewLocationSettings(
				"Shipment By AyeZee",
				[
					NewLocPair(< 6848.7000, -3415.7000, 99.9000 > + shipmentstartingorg, < 0, -135.0003, 0 >),
                    NewLocPair(< 4750.8930, -5191.4390, 99.9000 > + shipmentstartingorg, < 0, 51.7723, 0 >),
                    NewLocPair(< 4765.2000, -3380.5000, 99.9000 > + shipmentstartingorg, < 0, -47.3245, 0 >),
                    NewLocPair(< 6886.6280, -5163.9330, 99.9000 > + shipmentstartingorg, < 0, 140.8409, 0 >),
                    NewLocPair(< 6898.7000, -4523.7000, 99.9000 > + shipmentstartingorg, < 0, -167.7632, 0 >),
                    NewLocPair(< 6902.2780, -4062.3870, 99.9000 > + shipmentstartingorg, < 0, 152.5185, 0 >),
                    NewLocPair(< 5666.8980, -3541.5550, 99.9000 > + shipmentstartingorg, < 0, 178.2353, 0 >),
                    NewLocPair(< 5621, -5041, 99.9000 > + shipmentstartingorg, < 0, 178.2353, 0 >),
                    NewLocPair(< 4763, -4508, 99.9000 > + shipmentstartingorg, < 0, -38.7503, 0 >),
                    NewLocPair(< 4750.1250, -4088.1680, 99.9000 > + shipmentstartingorg, < 0, 40.1670, 0 >)
				],
				<0, 0, 3000>
			)
		)
        }

        if(FlowState_EnableKillhouseByAyeZee()){
            vector killhousestartingorg = <-2961,-13240,-2810>
            Shared_RegisterLocation(
			NewLocationSettings(
				"Killhouse By AyeZee",
				[
					NewLocPair(< 156.6777, -1466.7410, 9.4000 > + killhousestartingorg,< 0, 131.0375, 0 >),
                    NewLocPair(< -1167.9380, -1466.3340, 9.4000 > + killhousestartingorg,< 0, 44.6976, 0 >),
                    NewLocPair(< -1170.2510, -996.2968, 9.4000 > + killhousestartingorg,< 0, -0.5495, 0 >),
                    NewLocPair(< 217.9963, -1035.2670, 9.4000 > + killhousestartingorg,< 0, 178.6360, 0 >),
                    NewLocPair(< 217.9963, -563, 9.4000 > + killhousestartingorg,< 0, 178.6360, 0 >),
                    NewLocPair(< 200.7263, 979.5248, 9.4000 > + killhousestartingorg,< 0, -147.1917, 0 >),
                    NewLocPair(< -1162.3790, 980.8486, 9.4000 > + killhousestartingorg,< 0, -45.0161, 0 >),
                    NewLocPair(< -1164.7130, 702.9291, 9.4000 > + killhousestartingorg,< 0, 2.9566, 0 >),
                    NewLocPair(< 208.7000, 707.6936, 9.4000 > + killhousestartingorg,< 0, -147.0432, 0 >),
                    NewLocPair(< -1171.6520, 7.8723, 9.4000 > + killhousestartingorg,< 0, 7.0074, 0 >),
				],
				<0, 0, 3000>
			)
		)
        }

        if(FlowState_EnableNuketownByAyeZee()){
            vector nuketownstartingorg = <28524,23022,-3375>
            Shared_RegisterLocation(
			NewLocationSettings(
				"Nuketown By AyeZee",
				[
					NewLocPair(< 381.3000, -859.9000, -502.4000 > + nuketownstartingorg, < 0, 131.6921, 0 >),
                    NewLocPair(< -213.7000, -852.2000, -502.4000 > + nuketownstartingorg, < 0, 50.3080, 0 >),
                    NewLocPair(< 608.7227, 945.4185, -497.5000 > + nuketownstartingorg, < 0, -85.3474, 0 >),
                    NewLocPair(< -379.8000, 952.1000, -497.5000 > + nuketownstartingorg, < 0, -109.8191, 0 >),
                    NewLocPair(< -688.5317, -611.3459, -497.5000 > + nuketownstartingorg, < 0, 121.5057, 0 >),
                    NewLocPair(< -2298, -23, -497.5000 > + nuketownstartingorg, < 0, 17.9921, 0 >),
                    NewLocPair(< -1919, 777, -497.5000 > + nuketownstartingorg, < 0, 17.9921, 0 >),
                    NewLocPair(< 1807.1000, 1124.8000, -497.5000 > + nuketownstartingorg, < 0, -106.9288, 0 >),
                    NewLocPair(< 1285, 970, -497.5000 > + nuketownstartingorg, < 0, -106.9288, 0 >),
                    NewLocPair(< 2326.3580, -65.8636, -497.5000 > + nuketownstartingorg, < 0, 163.9604, 0 >)
				],
				<0, 0, 3000>
			)
		)
        }

	///////////////////////////////////////////////////
	//EXCLUSIVE SURF LOCATIONS FOR WORLD'S EDGE////////	
	

        default:
            Assert(false, "No TDM locations found for map!")
    }
	
	if( FlowState_SURF() )
	{
		RegisterLocationSURF(
                NewLocationSettings(
                    "surf_purgatory",
                    [
                        NewLocPair(<3225,9084,21476>, <0, -90, 0>)
                    ],
                    <0, 0, 3000>
                )
            )

         RegisterLocationSURF(
                NewLocationSettings(
                    "surf_noname",
                    [
                        NewLocPair(<7799, 11833, 24585>, <0, 180, 0>)
                    ],
                    <0, 0, 3000>
                )
            )
         RegisterLocationSURF(
                NewLocationSettings(
                    "surf_kitsune",
                    [
                        NewLocPair(<14724, 25241, 17271>, <0, 180, 0>)
                    ],
                    <0, 0, 3000>
                )
            )	
	}
    //Client Signals
    RegisterSignal( "CloseScoreRUI" )
}

LocPair function NewLocPair( vector origin, vector angles )
{
    LocPair locPair
	
    locPair.origin = origin
    locPair.angles = angles

    return locPair
}

string function LocPairString( LocPair pair )
{
	return VectorToString( pair.origin ) + VectorToString( pair.angles )
}

LocationSettings function NewLocationSettings(string name, array<LocPair> spawns, vector cinematicCameraOffset, asset Asset = $"rui/menu/maps/map_not_found")
{
    LocationSettings locationSettings
    locationSettings.name = name
    locationSettings.spawns = spawns
    locationSettings.cinematicCameraOffset = cinematicCameraOffset
	locationSettings.locationAsset = Asset
	
    return locationSettings
}

void function Shared_RegisterLocation(LocationSettings locationSettings)
{
    #if SERVER
    _RegisterLocation(locationSettings)
    #endif


    #if CLIENT
    Cl_RegisterLocation(locationSettings)
    #endif
}


void function RegisterLocationSURF(LocationSettings locationSettings)
{
    #if SERVER
    _RegisterLocationSURF(locationSettings)
    #endif

}

#if SERVER

StoredWeapon function Equipment_GetRespawnKit_PrimaryWeapon()
{
    return Equipment_GetRespawnKit_Weapon(
        GetCurrentPlaylistVarString("respawn_kit_primary_weapon", "~~none~~"),
        eStoredWeaponType.main,
        WEAPON_INVENTORY_SLOT_PRIMARY_0
    )
}
StoredWeapon function Equipment_GetRespawnKit_SecondaryWeapon()
{
    return Equipment_GetRespawnKit_Weapon(
        GetCurrentPlaylistVarString("respawn_kit_secondary_weapon", "~~none~~"),
        eStoredWeaponType.main,
        WEAPON_INVENTORY_SLOT_PRIMARY_1
    )
}
StoredWeapon function Equipment_GetRespawnKit_Tactical()
{
    return Equipment_GetRespawnKit_Weapon(
        GetCurrentPlaylistVarString("respawn_kit_tactical", "~~none~~"),
        eStoredWeaponType.offhand,
        OFFHAND_TACTICAL
    )
}
StoredWeapon function Equipment_GetRespawnKit_Ultimate()
{
    return Equipment_GetRespawnKit_Weapon(
        GetCurrentPlaylistVarString("respawn_kit_ultimate", "~~none~~"),
        eStoredWeaponType.offhand,
        OFFHAND_ULTIMATE
    )
}

StoredWeapon function Equipment_GetRespawnKit_Weapon(string input, int type, int index)
{
    StoredWeapon weapon
    if(input == "~~none~~") return weapon

    array<string> args = split(input, " ")

    if(args.len() == 0) return weapon

    weapon.name = args[0]
    weapon.weaponType = type
    weapon.inventoryIndex = index
    weapon.mods = args.slice(1, args.len())

    return weapon
}

#endif

