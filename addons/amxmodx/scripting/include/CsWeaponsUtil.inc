#if defined _CsWeaponsUtil_included
  #endinput
#endif
#define _CsWeaponsUtil_included

#include <fun>
#include <VexdUM>
#include <cstrike>



/*
	@Drop user current weapon

	Index - Player Id
	WeaponId - Weapon Id to drop, If weaponId is '0' then will drop the current weapon from hand.

	#Return: NO RETURN
*/
stock drop_user_weapon( index, WeaponId=0 )
{
	if( is_user_alive(index) )
	{
		new szWeaponName[20];
		get_weaponname( WeaponId, szWeaponName, charsmax(szWeaponName) );

		new szWpIdszWeaponName[20];
		new iAmmo,iBpAmmo;
		new CurrentWeaponId = get_user_weapon( index, iAmmo, iBpAmmo );
		get_weaponname( CurrentWeaponId, szWpIdszWeaponName, charsmax(szWpIdszWeaponName) );

		engclient_cmd( index, "drop", WeaponId > 0 ? szWeaponName : szWpIdszWeaponName );			
	}
}

/*
	@Give to user a weapon, pro-variant of native give_imte()

	index - Player Id
	iWeaponTypeId - CSW_weapon index ( exmp: CSW_M4A1 )
	iClip - The bullets of weapon
	iBPAmmo - Back Pack Ammo of the weapon ( realoading bullets )
	szWeaponName - copy-output of the weapon name without the weapon_* prefix.
	maxchars - maximum characters allowed to be copied in the szWeaponName output.

	#Return: WeaponEntity Id
*/
stock give_user_weapon( index , iWeaponTypeID , iClip=0 , iBPAmmo=0 , szWeapon[]="" , maxchars=0 )
{
	if ( !( CSW_P228 <= iWeaponTypeID <= CSW_P90 ) || ( iClip < 0 ) || ( iBPAmmo < 0 ) || !is_user_alive( index ) )    
		return -1;
    
	new szWeaponName[ 20 ] , iWeaponEntity = - 1 , bool:bIsGrenade;
    
	const GrenadeBits = ( ( 1 << CSW_HEGRENADE ) | ( 1 << CSW_FLASHBANG ) | ( 1 << CSW_SMOKEGRENADE ) | ( 1 << CSW_C4 ) );
    
	if ( ( bIsGrenade = bool:!!( GrenadeBits & ( 1 << iWeaponTypeID ) ) ) )
		iClip = clamp( iClip ? iClip : iBPAmmo , 1 );
    
	get_weaponname( iWeaponTypeID , szWeaponName , charsmax( szWeaponName ) );

	if( !has_user_weapon( index, iWeaponTypeID ) )
		give_item( index, szWeaponName );


	while ( ( iWeaponEntity = find_entity( iWeaponEntity, szWeaponName ) ) > 0 ) 
	{
		if( entity_get_edict( iWeaponEntity, EV_ENT_owner ) == index ) 
		{
			if( iWeaponEntity > 0 ) 
			{
				if ( iClip && !bIsGrenade )
					cs_set_weapon_ammo( iWeaponEntity , iClip );
		
				if ( iWeaponTypeID == CSW_C4 ) 
					cs_set_user_plant( index , 1 , 1 );
				else
					cs_set_user_bpammo( index , iWeaponTypeID , bIsGrenade ? iClip : iBPAmmo ); 
            
				if ( maxchars > 0 )
					copy( szWeapon , maxchars , szWeaponName[7] );
			}
		}
	}

	return iWeaponEntity;
}

/*
	@Get the current weapon speed user is holding in hand.
	id - Player Id

	#Return: Integer Weapon Speed
*/
stock get_curweapon_speed( id ) 
{ 
	new iSpeed = 0;
	new iUnused;

	switch( get_user_weapon( id, iUnused, iUnused ) ) 
	{ 
		case CSW_KNIFE: iSpeed = 250; 
        	case CSW_SCOUT: iSpeed = 260; 
        	case CSW_USP: iSpeed = 250; 
        	case CSW_P228: iSpeed = 250; 
        	case CSW_HEGRENADE: iSpeed = 250; 
        	case CSW_XM1014: iSpeed = 240; 
       		case CSW_C4: iSpeed = 250; 
       		case CSW_AUG: iSpeed = 240; 
        	case CSW_SMOKEGRENADE: iSpeed = 250; 
        	case CSW_ELITE: iSpeed = 250; 
        	case CSW_FIVESEVEN: iSpeed = 250; 
        	case CSW_UMP45: iSpeed = 250; 
        	case CSW_SG550: iSpeed = 210; 
        	case CSW_GALIL: iSpeed = 240; 
        	case CSW_FAMAS: iSpeed = 240; 
       		case CSW_GLOCK18: iSpeed = 250; 
        	case CSW_AWP: iSpeed = 210; 
        	case CSW_MP5NAVY: iSpeed = 250; 
        	case CSW_M249: iSpeed = 220; 
        	case CSW_M3: iSpeed = 230; 
       		case CSW_M4A1: iSpeed = 230; 
        	case CSW_TMP: iSpeed = 250; 
        	case CSW_G3SG1: iSpeed = 210; 
        	case CSW_FLASHBANG: iSpeed = 250; 
        	case CSW_DEAGLE: iSpeed = 250; 
        	case CSW_SG552: iSpeed = 235; 
        	case CSW_AK47: iSpeed = 221; 
        	case CSW_P90: iSpeed = 245 
	} 	
	return iSpeed; 
}
 