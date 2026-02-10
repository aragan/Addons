--Include Job ability info
function recast_buffs(job)
	local playermp = windower.ffxi.get_player().vitals.mp
	local recasts = windower.ffxi.get_ability_recasts()
	local spell_recasts = windower.ffxi.get_spell_recasts()
	local player = windower.ffxi.get_player()
	if job == 'WAR' and player.status == 'Engaged' then
		if not isBuffActive(56) and recasts[1] == 0 then	--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'SAM' and not isBuffActive(353) and recasts[138] == 0 then		--Hasso
			useJA('Hasso', '<me>')
		elseif not isBuffActive(68) and recasts[2] == 0 then									--Warcry
			useJA('Warcry', '<me>')
		elseif player.sub_job == 'SAM' and recasts[134] == 0 then								--Meditate
			useJA('Meditate', '<me>')
		elseif not isBuffActive(405) and recasts[8] == 0 then									--Retaliation
			useJA('Retaliation', '<me>')
		end
	elseif job == 'MNK' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		--elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			--useJA('Warcry', '<me>')
		elseif not isBuffActive(461) and recasts[31] == 0 then		--Impetus
			useJA('Impetus', '<me>')
		elseif not isBuffActive(406) and recasts[21] == 0 then		--Footwork
			useJA('Footwork', '<me>')
		end
		if player.vitals.hpp <= 30 and recasts[15] == 0 then
			useJA('Chakra', '<me>')
		end
	elseif job == 'WHM' then

	elseif job == 'BLM' then

	elseif job == 'RDM' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		elseif not isBuffActive(419) and recasts[50] and recasts[50] == 0 then					--Composure
			useJA('Composure', '<me>')
		elseif not isBuffActive(33) and spell_recasts[511] and spell_recasts[511] == 0 then		--Haste II
			useMA('Haste II', '<me>')
		-- elseif not isBuffActive(98) and spell_recasts[104] and spell_recasts[104] == 0 then		--Enthunder
		-- 	useMA('Enthunder', '<me>')
		elseif not isBuffActive(116) and spell_recasts[107] and spell_recasts[106] == 0 then	--Phalanx
			useMA('Phalanx II', '<me>')
		elseif player.job_points['rdm'].jp_spent >= 1200 then									--If we have more than 1200 jp spent
			if not isBuffActive(43) and spell_recasts[894] and spell_recasts[894] == 0 then		--Refresh III
				useMA('Refresh III', '<me>')
			elseif not isBuffActive(432) and spell_recasts[895] and spell_recasts[895] == 0 then	--Temper II
				useMA('Temper II', '<me>')
			end
		elseif player.job_points['rdm'].jp_spent < 1200 then									--If we have less than 1200 jp spent
			if not isBuffActive(43) and spell_recasts[473] and spell_recasts[473] == 0 then		--Refresh II
				useMA('Refresh II', '<me>')
			elseif not isBuffActive(432) and spell_recasts[493] and spell_recasts[493] == 0 then	--Temper
				useMA('Temper', '<me>')
			end
		end
	elseif job == 'THF' and player.status == 'Engaged' then
		if not isBuffActive(462) and recasts[40] == 0  then                						--Conspirator
			useJA('Conspirator', '<me>')
		elseif recasts[60] == 0 and player.status == 1 then                          			--Steal
			useJA('Steal', '<t>')
		elseif recasts[61] == 0 and player.status == 1 then                           			--Despoil
			useJA('Despoil', '<t>')
		elseif recasts[65] == 0 and player.status == 1 then                                		--Mug
			useJA('Mug', '<t>')
		elseif not isBuffActive(343) and recasts[68] == 0 then                    				--Feint
			useJA('Feint', '<me>')
		elseif recasts[240] == 0 and player.status == 1 then                       				--Bully
			useJA('Bully', '<t>')
		end
		if windower.ffxi.get_player().sub_job == 'WAR' then
			if not isBuffActive(56) and recasts[1] == 0 then                                    --Berserk
				useJA('Berserk', '<me>')
			elseif not isBuffActive(68) and recasts[2] == 0 then                         		--Warcry
				useJA('Warcry', '<me>')
			end
		elseif player.sub_job ~= 'DNC' then                                           			--Curing Waltz
			for i, v in pairs(party) do
				if string.match(i, 'p[0-5]') and v.hpp <= 70 and recasts [217] == 0 and player.vitals.tp >= 500 and math.sqrt(v.distance) <= 20 then
					useJA('Curing Waltz III', v.name)
					return
				end
			end
			if not isBuffActive(368) and recasts[216] == 0 and player.vitals.tp >= 500 then                            --Drain Samba II
				useJA('Haste Samba', '<me>')
			--elseif isBuffActive(385) and recasts[222] == 0 and player.vitals.tp < 2000 then                            --Reverse Flourish
				--useJA('Reverse Flourish', '<me>')
			--elseif isBuffActive(385) and recasts[221] == 0 and player.vitals.tp >= 2000 and player.status == 1 then    --Violent Flourish
				--useJA('Violent Flourish', '<t>')
			--elseif recasts[220] == 0 and player.vitals.tp >= 2000 and player.status == 1  then                        --Box Step
				--useJA('Box Step', '<t>')
			end
		end
	elseif job == 'PLD' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'DRK' and player.status == 'Engaged' then
		if not isBuffActive(64) and recasts[87] == 0 then											--Last Resort
			useJA('Last Resort', '<me>')
		elseif not isBuffActive(288) and playermp >= 36 and spell_recasts[856] == 0 and not isBuffActive(439) and not isBuffActive(345) then	--endark II
			useMA('Endark II', '<me>')
		elseif not isBuffActive(173) and playermp >= 78 and spell_recasts[277] == 0 and not isBuffActive(439) and not isBuffActive(345) then	--dread spikes
			useMA('Dread Spikes', '<me>')
		elseif not isBuffActive(88) and playermp >= 53 then
			if not isBuffActive(439) and recasts[91] == 0 then
				useJA('Nether Void', '<me>')
			elseif not isBuffActive(345) and recasts[89] == 0 then
				useJA('Dark Seal', '<me>')
			elseif isBuffActive(345) and isBuffActive(439) and spell_recasts[880] == 0 then
				useMA('Drain III', '<bt>')
			end
		elseif player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then		--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		elseif player.sub_job == 'SAM' and not isBuffActive(353) and recasts[138] == 0 then		--Hasso
			useJA('Hasso', '<me>')
		end
	elseif job == 'BST' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'BRD' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'RNG' then
		if not isBuffActive(224) and recasts[129] == 0 then										--Velocity Shot
			useJA('Velocity Shot', '<me>')
		elseif not isBuffActive(59) and recasts[124] == 0 then									--Sharpshot
			useJA('Sharpshot', '<me>')
		elseif not isBuffActive(60) and recasts[125] == 0 then									--Barrage
			useJA('Barrage', '<me>')
		elseif not isBuffActive(257) and recasts[126] == 0 then									--Double Shot
			useJA('Double Shot', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then		--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'SAM' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		elseif not isBuffActive(353) and recasts[138] == 0 then														--Hasso
			useJA('Hasso', '<me>')
		elseif recasts[134] == 0 then																				--Meditate
			useJA('Meditate', '<me>')
		end
	elseif job == 'NIN' then
	
	elseif job == 'DRG' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'SAM' and not isBuffActive(353) and recasts[138] == 0 then		--Hasso
			useJA('Hasso', '<me>')
		elseif not windower.ffxi.get_mob_by_target('pet') and recasts[163] and recasts[163] == 0 then		--Call Wyvern
			useJA('Call Wyvern', '<me>')
		elseif windower.ffxi.get_mob_by_target('pet') and recasts[162] and recasts[162] == 0 then				--Spirit Link
			useJA('Spirit Link', '<me>')
		elseif player.vitals.tp < 800 and player.vitals.tp > 300 and recasts[166] == 0 and windower.ffxi.get_mob_by_target('t') and player.status == 1 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) < 9.5 then	--Spirit Jump
			useJA('Spirit Jump', '<t>')
		elseif player.vitals.tp < 500 and recasts[167] == 0 and windower.ffxi.get_mob_by_target('t') and player.status == 1 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) < 9.5 then	--Soul Jump
			useJA('Soul Jump', '<t>')
		elseif player.vitals.tp < 1000 and player.vitals.tp > 700 and recasts[158] == 0 and windower.ffxi.get_mob_by_target('t') and player.status == 1 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) < 9.5 then	--Jump
			useJA('Jump', '<t>')
		elseif player.vitals.tp < 1000 and player.vitals.tp > 500 and recasts[159] == 0 and windower.ffxi.get_mob_by_target('t') and player.status == 1 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) < 9.5 then	--High Jump
			useJA('High Jump', '<t>')
		--elseif windower.ffxi.get_mob_by_target('pet') and recasts[239] and recasts[239] == 0 and player.vitals.hpp < 50 then
			--usePet('Restoring Breath', '<me>')
		end
	elseif job == 'SMN' then
	
	elseif job == 'BLU' then
		if getEquippedItemId('main') == 20688 then	--Tizona AG
			AM_flag_self = 1
			AM_WS_self = 'Expiacion'
		else
			AM_flag_self = 0
		end
		if player.vitals.hp < 800 and spell_recasts[593] and spell_recasts[593] == 0 then	--Magic Fruit
			useMA('Magic Fruit', '<me>')
		end
		if not isBuffActive(33) and playermp >= 92 and not isBuffActive(356) then			--Erratic Flutter
			useMA('Erratic Flutter', '<me>')
		elseif not isBuffActive(43) and spell_recasts[662] and spell_recasts[662] == 0 then
			useMA('Battery Charge', '<me>')
		elseif spell_recasts[646] and spell_recasts[646] == 0 and playermp < 600 and windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').name == 'Apex Crab' then
			useMA('Magic Hammer', '<t>')
		elseif not isBuffActive(36) and playermp >= 138 and not isBuffActive(356) then		--Occultation
			useMA('Occultation', '<me>')
		elseif not isBuffActive(91) and not isBuffActive(147) and playermp >= 38 and not isBuffActive(356) then		--Nat. Meditation
            useMA('Nat. Meditation', '<me>')
		elseif not isBuffActive(604) and playermp >= 300 then								--Mighty Guard
			if recasts[81] == 0 or isBuffActive(485) then
				useJA('Unbridled Learning', '<me>')
				if recasts[184] == 0 then
					useJA('Diffusion', '<me>')
				end
				useMA('Mighty Guard', '<me>')
			end
		elseif player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then		--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'COR' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'PUP' then
		if windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').status == 0 and recasts[207] == 0 and windower.ffxi.get_mob_by_target('t') and player.status == 1 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) < 7 then	--Deploy
			usePet('Deploy', '<t>')
		end
		
	elseif job == 'DNC' and player.status == 'Engaged' then
		if player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then			--Berserk
			useJA('Berserk', '<me>')
		elseif recasts[219] == 0 then															--Saber Dance
			useJA('Saber Dance', '<me>')
		elseif not isBuffActive(370) and recasts[216] == 0 and player.vitals.tp >= 350 then		--Haste Samba
			useJA('Haste Samba', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(68) and recasts[2] == 0 then		--Warcry
			useJA('Warcry', '<me>')
		end
	elseif job == 'SCH' then
	
	elseif job == 'GEO' then
	
	elseif job == 'RUN' then
		if not isBuffActive(432) and playermp >= 36 and spell_recasts[493] == 0 then			--Temper
			useMA('Temper', '<me>')
		elseif player.sub_job == 'WAR' and not isBuffActive(56) and recasts[1] == 0 then		--Berserk
			useJA('Berserk', '<me>')
		elseif player.sub_job == 'DRK' and not isBuffActive(64) and recasts[87] == 0 then		--Last Resort
			useJA('Last Resort', '<me>')
		elseif player.sub_job == 'SAM' and not isBuffActive(353) and recasts[138] == 0 then		--Hasso
			useJA('Hasso', '<me>')
		elseif not isBuffActive(570) and recasts[120] and recasts[120] == 0 and (isBuffActive(523) or isBuffActive(524) or isBuffActive(525) or isBuffActive(526) or isBuffActive(527) or isBuffActive(528) or isBuffActive(529) or isBuffActive(530)) and player.status == 1 then				--Battuta
			useJA('Battuta', '<me>')
		elseif not isBuffActive(535) and (isBuffActive(523) or isBuffActive(524) or isBuffActive(525) or isBuffActive(526) or isBuffActive(527) or isBuffActive(528) or isBuffActive(529) or isBuffActive(530)) and player.status == 1 and recasts[113] and recasts[113] == 0 then				--Valiance
			useJA('Valiance', '<me>')
		elseif not isBuffActive(528) and player.status == 1 then
			delay = 17
			-- windower.send_command('wait 2;input /ja "Unda" <me>;wait 6;input /ja "Unda" <me>;wait 6;input /ja "Unda" <me>')
		end
	end
	
	
	--Custom Shit
	--[[if windower.ffxi.get_party().party1_count > 1 and windower.ffxi.get_party().p1.zone == windower.ffxi.get_info().zone and windower.ffxi.get_party().p1.mob and windower.ffxi.get_party().p1.mob and windower.ffxi.get_party().p1.mob.is_npc == false then
		if windower.ffxi.get_party().p1.name == 'Ziasquinn' and pm_job == 'BLU' then
			AM_flag_other = 1
			AM_WS_other = 'Expiacion'
		else
			AM_flag_other = 0
		end
	end
	]]
end

--Use a job ability
function useJA(ja_name, target)
	windower.send_command('input /ja "'..ja_name..'" '..target)
	delay = 1.2
	return
end

--Use magic
function useMA(ma_name, target)
	windower.send_command('input /ma "'..ma_name..'" '..target)
	delay = 4.2
	return
end

--Use weaponskill
function useWS(ws_name, target)
	windower.send_command('input /ws "'..ws_name..'" '..target)
	delay = 2
	return
end

function usePet(pet_ability, target)
	windower.send_command('input /pet "'..pet_ability..'" '..target)
	delay = 1.2
	return
end

function useRA(target)
	windower.send_command('input /shoot '..target)
	delay = 4
	return
end



--Job list
job_list = {
    [0] = {id=0,en="None",ens="NON"},
    [1] = {id=1,en="Warrior",ens="WAR"},
    [2] = {id=2,en="Monk",ens="MNK"},
    [3] = {id=3,en="White Mage",ens="WHM"},
    [4] = {id=4,en="Black Mage",ens="BLM"},
    [5] = {id=5,en="Red Mage",ens="RDM"},
    [6] = {id=6,en="Thief",ens="THF"},
    [7] = {id=7,en="Paladin",ens="PLD"},
    [8] = {id=8,en="Dark Knight",ens="DRK"},
    [9] = {id=9,en="Beastmaster",ens="BST"},
    [10] = {id=10,en="Bard",ens="BRD"},
    [11] = {id=11,en="Ranger",ens="RNG"},
    [12] = {id=12,en="Samurai",ja="?",ens="SAM"},
    [13] = {id=13,en="Ninja",ens="NIN"},
    [14] = {id=14,en="Dragoon",ens="DRG"},
    [15] = {id=15,en="Summoner",ens="SMN"},
    [16] = {id=16,en="Blue Mage",ens="BLU"},
    [17] = {id=17,en="Corsair",ens="COR"},
    [18] = {id=18,en="Puppetmaster",ens="PUP"},
    [19] = {id=19,en="Dancer",ens="DNC"},
    [20] = {id=20,en="Scholar",ens="SCH"},
    [21] = {id=21,en="Geomancer",ens="GEO"},
    [22] = {id=22,en="Rune Fencer",ens="RUN"},
}

--Return the weaponskill for the current self skillchain step
function self_sc(job, step)
	local weaponskill = nil
	for i, v in pairs(selfSC_WS) do
		if v.job == job and tonumber(v.step) == step then
			weaponskill = v.ws
		end
	end
	if weaponskill then
		return weaponskill
	end
	ws_turn = 1
	showBox()
	return 0
end

--List of towns/cities so we can disable the addon while in these zones
areas_Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
    "Tavanazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
    "Norg",
    "Eastern Adoulin",
    "Western Adoulin",
    "Kazham",
	"Rabao"
}


--Check if job is valid
function check_job(j)
	for i, v in ipairs(jobs) do
		if v == j then
			return true
		end
	end
	return false
end


--Check if a buff is active, by ID
function isBuffActive(id)
	local player = windower.ffxi.get_player()
	for k,v in pairs(player.buffs) do
		if (v == id) then -- check for buff
			return true;
		end	
	end
	return false;
end

function isInParty(name)
	local party = windower.ffxi.get_party()
	if party.p1 and party.p1.name == name then
		return true
	elseif party.p2 and party.p2.name == name then
		return true
	elseif party.p3 and party.p3.name == name then
		return true
	elseif party.p4 and party.p4.name == name then
		return true
	elseif party.p5 and party.p5.name == name then
		return true
	end
	return false
end

