global function OnWeaponActivate_vctblue
global function OnWeaponDeactivate_vctblue

vector function HSVtoRGB( float h, float s, float v )
{
	float c = v * s
	float hPrime = h / 60.0
	float x = c * (1 - fabs(hPrime - 2 * int(hPrime / 2) - 1))
	float m = v - c
	
	vector rgb
	if (h >= 0 && h < 60) {
		rgb = <c, x, 0>
	} else if (h >= 60 && h < 120) {
		rgb = <x, c, 0>
	} else if (h >= 120 && h < 180) {
		rgb = <0, c, x>
	} else if (h >= 180 && h < 240) {
		rgb = <0, x, c>
	} else if (h >= 240 && h < 300) {
		rgb = <x, 0, c>
	} else {
		rgb = <c, 0, x>
	}
	
	return <(rgb.x + m) * 255, (rgb.y + m) * 255, (rgb.z + m) * 255>
}

void function OnWeaponActivate_vctblue( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	
	thread function () : ( weapon, player )
	{
		Signal( weapon, "VCTBlueFX" )
		EndSignal( weapon, "VCTBlueFX" )
		EndSignal( weapon, "OnDestroy" )

		float startTime = Time()
		float hue = 0.0
		float saturation = 1.0
		float value = 1.0
		float hueSpeed = 100.0

		while( IsValid( weapon ) )
		{
			float currentTime = Time()
			float elapsed = (currentTime - startTime) * hueSpeed
			hue = elapsed - 360 * int(elapsed / 360)
	   
			vector rgbColor = HSVtoRGB(hue, saturation, value)
			string colorString = int(rgbColor.x) + " " + int(rgbColor.y) + " " + int(rgbColor.z)
			
			weapon.kv.rendercolor = colorString
			
			WaitFrame()
		}
	}()
}

void function OnWeaponDeactivate_vctblue( entity weapon )
{
	if( IsValid( weapon ) )
		Signal( weapon, "VCTBlueFX" )
}