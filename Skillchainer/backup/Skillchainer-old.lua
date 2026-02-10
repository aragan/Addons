windower.register_event('load',function ()
	--Addon by: Otamarai
	Print_Settings()
end)

_addon.name = 'Skillchainer'
_addon.author = 'Otamarai'
_addon.commands = {'skillchainer','sc'}
_addon.version = '1.7'
require 'strings'
require 'logger'
config = require('config')
texts = require('texts')
files = require 'files'
res = require('resources')
packets = require('packets')
ws_list = require('weaponskills')
require('skillchainer_functions')

--Default stuff
mob_id = 0
in_combat = false
party_size = 1
job = windower.ffxi.get_player().main_job
party_member = 1
ws_turn = 1
--pm_job = 'MNK'	--That's right, obviously the other member is a monk
p2_name = ''
now = 0
her_fucking_AM = 0
AM_flag_self = 0
AM_WS_self = ''
AM_flag_other = 0
AM_WS_other = ''
AM_override = 'off'
pull = 'off'
current_mob = 0
self_SC = 'off'
nexttime = os.clock()
delay = 0
runtomob = 'off'
use_ws = 'on'
pause = 'off'
voke = 'off'
autoRA = false
autoStopRA = true
autoRATP = 1000
assistTarget = false
assistEnabled = false



sctxt = {}
sctxt.pos = {}
sctxt.pos.x = 180
sctxt.pos.y = 600
sctxt.text = {}
sctxt.text.font = 'Arial'
sctxt.text.size = 10
sctxt.flags = {}
sctxt.flags.right = false
sctxt.padding = 5

settings = config.load(sctxt)
sc_info = texts.new('${value}', settings)




mob_targets_file = files.new('mob_targets.lua')
if mob_targets_file:exists() then
	
else
	mob_targets = {}
	mob_targets_file:write('return ' .. T(mob_targets):tovstring())
end
mob_targets = require('mob_targets')


selfSC_WS_file = files.new('self_skillchains.lua')
if selfSC_WS_file:exists() then

else
	selfSC_WS = {}
	selfSC_WS_file:write('return ' .. T(selfSC_WS):tovstring())
end
selfSC_WS = require('self_skillchains')



function showBox()
	local list = 'Party Size: '..party_size..'\n'
	if party_size > 1 then
		list = list..'Party Member: '..party_member..'\nOther Party Member: '..p2_name..'\n'
	end
	
	list = list..'Job: '..job..'\n'
	
	if pull == 'on' then
		list = list..'\\cs(0,255,0)Auto Pulling: '..pull..'\\cr\n'
	else
		list = list..'\\cs(255,0,0)Auto Pulling: '..pull..'\\cr\n'
	end
	
	if runtomob == 'on' then
		list = list..'\\cs(0,255,0)Run to Mob: '..runtomob..'\\cr\n'
	else
		list = list..'\\cs(255,0,0)Run to Mob: '..runtomob..'\\cr\n'
	end
	
	if voke == 'on' then
		list = list..'\\cs(0,255,0)Provoke: '..voke..'\\cr\n'
	else
		list = list..'\\cs(255,0,0)Provoke: '..voke..'\\cr\n'
	end
	
	if assistEnabled and assistTarget then
		list = list..'Assist: \\cs(0,255,0)'..assistTarget..'\\cr\n'
	elseif not assistEnabled then
		list = list..'Assist: \\cs(255,0,0)'..(assistTarget or 'off')..'\\cr\n'
	end	
	
	if use_ws == 'on' then
		list = list..'\\cs(0,255,0)Weaponskilling: '..job_ws_list[job].ws_a..'\\cr\n'
	else
		list = list..'\\cs(255,0,0)Weaponskilling: '..use_ws..'\\cr\n'
	end
	
	if self_SC == 'on' then
		list = list..'\\cs(0,255,0)Self SC: '..self_SC..'\\cr\n'
	else
		list = list..'\\cs(255,0,0)Self SC: '..self_SC..'\\cr\n'
	end
	
	
	
	if self_SC == 'on' then
		local exists = false
		local maxsteps = 1
		for i, v in pairs(selfSC_WS) do
			if v.job and v.job == job and v.step and tonumber(v.step) >= maxsteps then
				maxsteps = tonumber(v.step)
				exists = true
			end
		end
		if exists then
			for i = 1, maxsteps do
				if i == ws_turn then
					list = list..'\\cs(0,255,0)Step '..i..': '..self_sc(job, i)..'\\cr\n'
				else
					list = list..'Step '..i..': '..self_sc(job, i)..'\n'
				end
			end
		else
			list = list..'No self skillchain information found.\n'
		end
	end
	
	if pause == 'on' then
		list = list..'\\cs(255,0,0)Skillchainer Paused.'
	else
		list = list..'\\cs(0,255,0)Skillchainer Active.'
	end
	
	
	sc_info.value = list
	sc_info:show()
end


function Print_Settings()
    print('Party Size = '..party_size..'\nParty Member = '..party_member..'\nJob = '..job..'\nOther Party Member = '..p2_name..'\nAuto Pulling = '..pull..'\nRun to mob = '..runtomob..'\nProvoke = '..voke..'\nWeaponskilling = '..use_ws..'\nSelf SC = '..self_SC)
	showBox()
end

jobs = {
	'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'
}

--ws_b needs to chain together with your party member's ws_b, and ws_a needs to close whatever the two other weaponskills make

job_ws_list = {
	['WAR'] = {ws_a='Ukko\'s Fury', ws_b='Upheaval'},
	['MNK'] = {ws_a='Victory Smite', ws_b='Shijin Spiral'},
	['WHM'] = {ws_a='Hexa Strike', ws_b='Black Halo'},
	['BLM'] = {ws_a='Shattersoul', ws_b='Shattersoul'},
	['RDM'] = {ws_a='Chant du Cygne', ws_b='Savage Blade'},
	['THF'] = {ws_a='Rudra\'s Storm', ws_b='Evisceration'},
	['PLD'] = {ws_a='Chant du Cygne', ws_b='Savage Blade'},
	['DRK'] = {ws_a='Cross Reaper', ws_b='Entropy'},
	['BST'] = {ws_a='Ruinator', ws_b='Decimation'},
	['BRD'] = {ws_a='Rudra\'s Storm', ws_b='Evisceration'},
	['RNG'] = {ws_a='Last Stand', ws_b='Trueflight'},
	['SAM'] = {ws_a='Tachi: Fudo', ws_b='Tachi: Shoha'},
	['NIN'] = {ws_a='Blade: Hi', ws_b='Blade: Shun'},
	['DRG'] = {ws_a='Stardiver', ws_b='Camlann\'s Torment'},
	['SMN'] = {ws_a='Garland of Bliss', ws_b='Shattersoul'},
	['BLU'] = {ws_a='Chant du Cygne', ws_b='Savage Blade'},
	['COR'] = {ws_a='Leaden Salute', ws_b='Last Stand'},
	['PUP'] = {ws_a='Victory Smite', ws_b='Stringing Pummel'},
	['DNC'] = {ws_a='Rudra\'s Storm', ws_b='Evisceration'},
	['SCH'] = {ws_a='Shattersoul', ws_b='Shattersoul'},
	['GEO'] = {ws_a='Hexa Strike', ws_b='Black Halo'},
	['RUN'] = {ws_a='Resolution', ws_b='Dimidiation'},
}


skillchains = {
    [288] = 'Light',
    [289] = 'Darkness',
    [290] = 'Gravitation',
    [291] = 'Fragmentation',
    [292] = 'Distortion',
    [293] = 'Fusion',
    [294] = 'Compression',
    [295] = 'Liquefaction',
    [296] = 'Induration',
    [297] = 'Reverberation',
    [298] = 'Transfixion',
    [299] = 'Scission',
    [300] = 'Detonation',
    [301] = 'Impaction',
    [385] = 'Light',
    [386] = 'Darkness',
    [387] = 'Gravitation',
    [388] = 'Fragmentation',
    [389] = 'Distortion',
    [390] = 'Fusion',
    [391] = 'Compression',
    [392] = 'Liquefaction',
    [393] = 'Induration',
    [394] = 'Reverberation',
    [395] = 'Transfixion',
    [396] = 'Scission',
    [397] = 'Detonation',
    [398] = 'Impaction',
	[767] = 'Radiance',
    [768] = 'Umbra',
    [769] = 'Radiance',
    [770] = 'Umbra',
}





--Target the mob and engage it
windower.register_event('prerender', function()
	local curtime = os.clock()
	if nexttime + delay <= curtime then
		nexttime = curtime
		delay = 0.2
		
		if os.clock() > (now + 180) then	--AM time is 3 mins, reset it after it expires
			her_fucking_AM = 0
		end
		if pause == 'on' then return end					--If pause then exit
		local recasts = windower.ffxi.get_ability_recasts()
		local player = windower.ffxi.get_player()
		local subjob = player.sub_job
		local info = windower.ffxi.get_info()
		local zone = res.zones[info.zone].name				--Get the zone name
		if areas_Cities:contains(zone) then return end		--If we're in a town, exit
		if player and player.hpp == 0 then					--If we're dead, pause the skillchainer then exit
			pause = 'on'
			windower.add_to_chat(7, 'Skillchainer paused.')
			return
		end
		
		target = windower.ffxi.get_mob_by_index(player.target_index or 0)
		local self_vector = windower.ffxi.get_mob_by_index(player.index or 0)
		
		--Pull a mob if auto pull is on
		if player.in_combat == false and player.status == 0 and party_member == 1 and pull == 'on' then
			getNewMob(getAggroMob())
		end
		
		--Handle engaging in combat with target
		if assistEnabled then
			local assist = windower.ffxi.get_mob_by_name(assistTarget)
			local player_target = assist.target_index		--Get the assist target's target
			local mob_target = false
			if player_target then
				mob_target = windower.ffxi.get_mob_by_index(player_target)
			end
			if assist and assist.status ~= 0 and mob_target and mob_target.is_npc then
				if player.status ~= 1 then
					engagetarget = packets.new('outgoing', 0x01A, {
						['Target'] = mob_target.id,
						['Target Index'] = mob_target.index,
						['Category'] = 0x02,
					})
					packets.inject(engagetarget)
					delay = 1
					in_combat = true
					showBox()
				elseif player.status == 1 and (not windower.ffxi.get_mob_by_target('t') or mob_target.id ~= windower.ffxi.get_mob_by_target('t').id) then
					switchtarget = packets.new('outgoing', 0x01A, {
						['Target'] = mob_target.id,
						['Target Index'] = mob_target.index,
						['Category'] = 0x0F,
					})
					packets.inject(switchtarget)
					delay = 1
					in_combat = true
					showBox()
				end
			elseif assist and assist.status == 0 and player.status ~= 0 then
				disengagetarget = packets.new('outgoing', 0x01A, {
					--['Target'] = mob_target.id,
					--['Target Index'] = mob_target.index,
					['Category'] = 0x04,
				})
				packets.inject(disengagetarget)
				in_combat = false
				ws_turn = 1
				showBox()
				delay = 1
			end
		elseif not assistEnabled then
			if player.in_combat == true and player.status ~= 1 then		--If there's a party claimed mob
				windower.send_command('input /ta <bt>')
				if windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').claim_id ~= 0 then
					engagetarget = packets.new('outgoing', 0x01A, {
						['Target'] = windower.ffxi.get_mob_by_target('t').id,
						['Target Index'] = windower.ffxi.get_mob_by_target('t').index,
						['Category'] = 0x02,
					})
					packets.inject(engagetarget)
				end
				if player.status == 1 then
					in_combat = true
				end
				ws_turn = 1
				if windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').claim_id ~= 0 then
					current_mob = windower.ffxi.get_mob_by_target('t').id
				end
				delay = 1
				showBox()
			elseif mob_id and mob_id ~= 0 and windower.ffxi.get_mob_by_id(mob_id) and windower.ffxi.get_mob_by_id(mob_id).hpp >= 1 and player.status ~= 1 and not in_combat then	--If there's a mob that is hitting a party member
				engagetarget = packets.new('outgoing', 0x01A, {
					['Target'] = windower.ffxi.get_mob_by_id(mob_id).id,
					['Target Index'] = windower.ffxi.get_mob_by_id(mob_id).index,
					['Category'] = 0x02,
				})	
				packets.inject(engagetarget)
				if player.status == 1 then
					in_combat = true
				end
				ws_turn = 1
				current_mob = mob_id
				delay = 1
				showBox()
			elseif player.status == 1 and checkActor(windower.ffxi.get_mob_by_target('t')) then
				disengagetarget = packets.new('outgoing', 0x01A, {
					['Target'] = windower.ffxi.get_mob_by_target('t').id,
					['Target Index'] = windower.ffxi.get_mob_by_target('t').index,
					['Category'] = 0x04,
				})	
				packets.inject(disengagetarget)
			elseif player.status == 1 and player.target_index and windower.ffxi.get_mob_by_index(player.target_index) and windower.ffxi.get_mob_by_index(player.target_index).hpp >= 1 then		--If we're engaged in combat
				if windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').id ~= current_mob then
					ws_turn = 1
					current_mob = windower.ffxi.get_mob_by_target('t').id
				end
				in_combat = true
				showBox()
			elseif player.status == 1 and not player.in_combat and windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').claim_id ~= 0 then
				disengagetarget = packets.new('outgoing', 0x01A, {
					['Target'] = windower.ffxi.get_mob_by_target('t').id,
					['Target Index'] = windower.ffxi.get_mob_by_target('t').index,
					['Category'] = 0x04,
				})	
				packets.inject(disengagetarget)
			else					--Reset flags when out of combat
				in_combat = false
				mob_id = 0
				ws_turn = 1
				showBox()
			end
		end
		
	
	
		if in_combat == true and target and target ~= 0 then 							--Things to do when engaged: JA, WS, etc
				local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
				windower.ffxi.turn((angle):radian())			--Face the mob
			if party_size == 1 then		--If soloing
				if party_member == 1 and recasts[5] and recasts[5] == 0 and windower.ffxi.get_mob_by_target('t').hpp >= 90  and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 13  and voke == 'on' then	--Voke
					useJA('Provoke', '<t>')
				end
				if runtomob == 'on' then
					if math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 20 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) >= 3 and player.status == 1 then
						windower.ffxi.run(true)
					else
						windower.ffxi.run(false)
					end
				end
				if autoRA and (player.vitals.tp <= 1000 or not autoStopRA) then
					useRA()
				end
				if AM_flag_self == 1 and not isBuffActive(272) then		--Put up AM if you have it
					if player.vitals.tp == 3000 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 7 then
						useWS(AM_WS_self, '<t>')
					end
				elseif player.vitals.tp >= 1000 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 7 and self_SC == 'off' and use_ws == 'on' then	--WS all the things
					useWS(job_ws_list[job].ws_a, '<t>')
				elseif player.vitals.tp >= 1000 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 7 and self_SC == 'on' then	--Doing the multi step thang... or gonna try
					if self_sc(job, ws_turn) ~= 0 then
						useWS(ws_list[self_sc(job, ws_turn)].en, '<t>')
					end
				end
				
			elseif party_size == 2 then		--If in a party
				if party_member == 1 and recasts[5] and recasts[5] == 0 and windower.ffxi.get_mob_by_target('t').hpp >= 90 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 13 and voke == 'on' then	--Player 1 vokes
					useJA('Provoke', '<t>')
				end
				if runtomob == 'on' then
					if math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 20 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) >= 4 and player.status == 1 then
						windower.ffxi.run(true)
					else
						windower.ffxi.run(false)
					end
				end
			
				if AM_flag_self == 1 and not isBuffActive(272) then		--Put up AM if you have it, and reset the WS turn to 1
					if player.vitals.tp == 3000 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 7 then
						useWS(AM_WS_self, '<t>')
						ws_turn = 1
					end
				elseif player.vitals.tp >= 1000 and math.sqrt(windower.ffxi.get_mob_by_target('t').distance) <= 7 then
					if party_member == 1 then		--If you're party member 1
						if AM_flag_other == 1 and her_fucking_AM == 0 and AM_override == 0 then
							useWS(job_ws_list[job].ws_b, '<t>')
						elseif ws_turn == 1 and windower.ffxi.get_party().p1.tp >= 700 then
							useWS(job_ws_list[job].ws_b, '<t>')
						elseif ws_turn == 3 then
							useWS(job_ws_list[job].ws_a, '<t>')
						elseif ws_turn == 5 then
							useWS(job_ws_list[job].ws_b, '<t>')
						end
					elseif party_member == 2 then	--If you're party member 2
						if AM_flag_other == 1 and her_fucking_AM == 0 and AM_override == 0 then
							useWS(job_ws_list[job].ws_b, '<t>')
						elseif ws_turn == 2 then
							useWS(job_ws_list[job].ws_b, '<t>')
						elseif ws_turn == 4 and windower.ffxi.get_party().p1.tp >= 700 then
							useWS(job_ws_list[job].ws_b, '<t>')
						elseif ws_turn == 6 then
							useWS(job_ws_list[job].ws_a, '<t>')
						end
					end
				end
			end
		end
		recast_buffs(job)	--Handle job ability and spell buffs
	end
end)

--Used to check if a mob targets any party member with an attack
function checkTargets(check)
	local party = windower.ffxi.get_party()
	local player = windower.ffxi.get_player()
	for k,v in pairs(check) do
		if v.id == player.id then
			return true
		elseif party.p1 and party.p1.mob and v.id == party.p1.mob.id then
			return true
		elseif party.p2 and party.p2.mob and v.id == party.p2.mob.id then
			return true
		elseif party.p3 and party.p3.mob and v.id == party.p3.mob.id then
			return true
		elseif party.p4 and party.p4.mob and v.id == party.p4.mob.id then
			return true
		elseif party.p5 and party.p5.mob and v.id == party.p5.mob.id then
			return true
		end	
	end
	return false
end



--Check if whoever performed the action is in the party or their pet
function checkActor(check)
	local party = windower.ffxi.get_party()
	local player = windower.ffxi.get_player()
	--If the skillchain was created by a party member return true, else return false
	local petIndex = windower.ffxi.get_mob_by_id(player.id).pet_index
	if check == player.id or (petIndex and windower.ffxi.get_mob_by_index(petIndex) and windower.ffxi.get_mob_by_index(petIndex).id == check) then
		return true
	elseif (party.p1 and party.p1.mob and check == party.p1.mob.id) or (party.p1 and party.p1.mob and party.p1.mob.pet_index and windower.ffxi.get_mob_by_index(party.p1.mob.pet_index) and windower.ffxi.get_mob_by_index(party.p1.mob.pet_index).id == check) then
		return true
	elseif (party.p2 and party.p2.mob and check == party.p2.mob.id) or (party.p2 and party.p2.mob and party.p2.mob.pet_index and windower.ffxi.get_mob_by_index(party.p2.mob.pet_index) and windower.ffxi.get_mob_by_index(party.p2.mob.pet_index).id == check) then
		return true
	elseif (party.p3 and party.p3.mob and check == party.p3.mob.id) or (party.p3 and party.p3.mob and party.p3.mob.pet_index and windower.ffxi.get_mob_by_index(party.p3.mob.pet_index) and windower.ffxi.get_mob_by_index(party.p3.mob.pet_index).id == check) then
		return true
	elseif (party.p4 and party.p4.mob and check == party.p4.mob.id) or (party.p4 and party.p4.mob and party.p4.mob.pet_index and windower.ffxi.get_mob_by_index(party.p4.mob.pet_index) and windower.ffxi.get_mob_by_index(party.p4.mob.pet_index).id == check) then
		return true
	elseif (party.p5 and party.p5.mob and check == party.p5.mob.id) or (party.p5 and party.p5.mob and party.p5.mob.pet_index and windower.ffxi.get_mob_by_index(party.p5.mob.pet_index) and windower.ffxi.get_mob_by_index(party.p5.mob.pet_index).id == check) then
		return true
	end
	return false
end



windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
	local player = windower.ffxi.get_player()
	local target = windower.ffxi.get_mob_by_target('t')
	local info = windower.ffxi.get_info()
	local zone = res.zones[info.zone].name
	if id == 0x00E and (zone == 'Dho Gates' or zone == 'Woh Gates' or zone == 'Sih Gates' or zone == 'Moh Gates' or zone == 'Outer Ra\'Kaznar' or zone == 'Ra\'Kaznar Inner Court') then
		local parse = packets.parse('incoming', data)
		if player.status == 1 and target and parse['NPC'] == target.id then
			if parse['Claimer'] ~= 0 and not checkActor(parse['Claimer']) then
				mob_id = 0
				disengagetarget = packets.new('outgoing', 0x01A, {
					['Target'] = windower.ffxi.get_mob_by_target('t').id,
					['Target Index'] = windower.ffxi.get_mob_by_target('t').index,
					['Category'] = 0x04,
				})	
				packets.inject(disengagetarget)
			end
		end
	end
end)


windower.register_event('action', function(act)	--Grab the ID of the mob attacking us
	local player = windower.ffxi.get_player()
	local party = windower.ffxi.get_party()
	
	if checkTargets(act.targets) and windower.ffxi.get_mob_by_id(act.actor_id).is_npc == true and not checkActor(act.actor_id) then
		mob_id = act.actor_id
	--elseif mob_id == act.actor_id and not checkTargets(act.targets) and player.status == 1 and windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').id == mob_id then
		--mob_id = 0
		--windower.send_command('input /a off')
	end
	if party_size == 1 then
		if act.actor_id == player.id and act.category == 7 then
			ws_id = act.targets[1].actions[1].param
		elseif act.actor_id == player.id and act.category == 3 then
			message = act.targets[1].actions[1].message
		end
	elseif party_size == 2 then
		if (act.actor_id == player.id or (windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id)) and act.category == 7 then
			ws_id = act.targets[1].actions[1].param
		elseif (act.actor_id == player.id or (windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id)) and act.category == 3 then
			message = act.targets[1].actions[1].message
		end
	end
	
	if party_size == 2 then
		if AM_flag_other == 1 and her_fucking_AM == 0 and AM_override == 'off' then		--When party member uses their AM weaponskill, set flag, set the time and reset the WS turn to 1
			if party.party1_count > 1 and windower.ffxi.get_info().zone == party.p1.zone and act.actor_id == windower.ffxi.get_mob_by_name(party.p1.name).id and ws_id == ws_list[AM_WS_other].id and message == 185 then
				ws_turn = 1
				her_fucking_AM = 1
				now = os.clock()
				ws_id = 0
				message = 0
			end
		elseif AM_override == 'on' then
			if party.party1_count > 1 and windower.ffxi.get_info().zone == party.p1.zone and act.actor_id == windower.ffxi.get_mob_by_name(party.p1.name).id and ws_id == ws_list[AM_WS_other].id and message == 185 then
				ws_turn = 1
				ws_id = 0
				message = 0
			end
		end
		if ws_turn == 1 then	--Cycle through weaponskill turns
			if act.actor_id == player.id and ws_id == ws_list[job_ws_list[job].ws_b].id and party_member == 1 and message == 185 then
				ws_turn = 2
				delay = 3
				ws_id = 0
				message = 0
			elseif party.party1_count > 1 and windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id and party_member == 2 and message == 185 then
				ws_turn = 2
				delay = 3
				ws_id = 0
				message = 0
			end
		elseif ws_turn == 2 then
			if party.party1_count > 1 and windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id and party_member == 1 and message == 185 then
				ws_turn = 3
				delay = 3
				ws_id = 0
				message = 0
			elseif act.actor_id == player.id and ws_id == ws_list[job_ws_list[job].ws_b].id and party_member == 2 and message == 185 then
				ws_turn = 3
				delay = 3
				ws_id = 0
				message = 0
			end
		elseif ws_turn == 3 then
			if act.actor_id == player.id and ws_id == ws_list[job_ws_list[job].ws_a].id and party_size == 2 and party_member == 1 and message == 185 then
				ws_turn = 4
				delay = 3
				ws_id = 0
				message = 0
			elseif party.party1_count > 1 and windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id and party_member == 2 and message == 185 then
				ws_turn = 4
				delay = 3
				ws_id = 0
				message = 0
			end
		elseif ws_turn == 4 then
			if party.party1_count > 1 and windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id and party_member == 1 and message == 185 then
				ws_turn = 5
				delay = 3
				ws_id = 0
				message = 0
			elseif act.actor_id == player.id and ws_id == ws_list[job_ws_list[job].ws_b].id and party_size == 2 and party_member == 2 and message == 185 then
				ws_turn = 5
				delay = 3
				ws_id = 0
				message = 0
			end
		elseif ws_turn == 5 then
			if act.actor_id == player.id and ws_id == ws_list[job_ws_list[job].ws_b].id and party_size == 2 and party_member == 1 and message == 185 then
				ws_turn = 6
				delay = 3
				ws_id = 0
				message = 0
			elseif party.party1_count > 1 and windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id and party_member == 2 and message == 185 then
				ws_turn = 6
				delay = 3
				ws_id = 0
				message = 0
			end
		elseif ws_turn == 6 then
			if party.party1_count > 1 and windower.ffxi.get_mob_by_name(p2_name) and act.actor_id == windower.ffxi.get_mob_by_name(p2_name).id and party_member == 1 and message == 185 then
				ws_turn = 1
				delay = 3
				ws_id = 0
				message = 0
			elseif act.actor_id == player.id and ws_id == ws_list[job_ws_list[job].ws_a].id and party_size == 2 and party_member == 2 and message == 185 then
				ws_turn = 1
				delay = 3
				ws_id = 0
				message = 0
			end
			
		end
	elseif party_size == 1 and self_SC == 'on' then	--If self skillchaining, cycle through the list after a WS was performed
		if act.actor_id == player.id and self_sc(job, ws_turn) ~= 0 and ws_id == ws_list[self_sc(job, ws_turn)].id and message == 185 then
			ws_turn = ws_turn + 1
			ws_id = 0
			message = 0
			showBox()
		end
	end
end)


--Lists current self skillchain set if one exists
function listSelfSC()
	local exists = false
	if selfSC_WS then
		for i, v in pairs(selfSC_WS) do
			if v.job == job then
				windower.add_to_chat(7, 'Step '..v.step..': '..v.ws)
				exists = true
			end
		end
	end
	if not exists then
		windower.add_to_chat(7, 'No self skillchain info exists.')
	end
end




--Adds a self skillchain weaponskill/step combination
function addSelfSC(job, ws, step)
	if not ws_list[ws] then
		windower.add_to_chat(7, 'Weaponskill '..ws..' doesn\'t exist, check your spelling and use quotes')
		return
	end
	for i, v in pairs(selfSC_WS) do
		if v.job == job and v.step == step then
			windower.add_to_chat(7,'Failed to add weaponskill, job/step combination already exists.')
			return
		end
	end
	selfSC_WS[job..step] = {job=job, ws=ws, step=step}
	selfSC_WS_file:write('return ' .. T(selfSC_WS):tovstring())
	windower.add_to_chat(7,'Added '..job..' weaponskill '..ws..' as step '..step..'.')
end

--Removes a self skillchain step from the list
function removeSelfSC(job, step)
	for i, v in pairs(selfSC_WS) do
		if v.job == job and v.step == step then
			windower.add_to_chat(7,'Removed '..job..' weaponskill '..v.ws..' from step '..step..'.')
			selfSC_WS[job..step] = nil
			selfSC_WS_file:write('return ' .. T(selfSC_WS):tovstring())
			return
		end
	end
	windower.add_to_chat(7,'Failed to remove weaponskill, job/step combination doesn\'t exist.')
end


--Add a mob to the pull list
function add_mob_target(mob)
	if not mob_targets[mob] then
		mob_targets[mob] = {}
		mob_targets_file:write('return ' .. T(mob_targets):tovstring())
		windower.add_to_chat(7,'Added target: '..mob..' to target list.')
	end
end

--Remove a mob from the pull list
function remove_mob_target(mob)
	if mob_targets[mob] then
		mob_targets[mob] = nil
		windower.add_to_chat(7,'Removed target: '..mob..' from target list.')
	end
	mob_targets_file:write('return ' .. T(mob_targets):tovstring())
end

--Update job when you change jobs
windower.register_event('job change',function (main_job_id, main_job_level, sub_job_id, sub_job_level)
	job = job_list[main_job_id].ens
	Print_Settings()
end)

--Check if the name supplied is in the alliance/party
function checkName(cName)
	local party = windower.ffxi.get_party()
	local name = cName:ucfirst()
	if party.party1_count > 1 then
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
	end
	if party.party2_count > 0 then
		if party.a10 and party.a10.name == name then
			return true
		elseif party.a11 and party.a11.name == name then
			return true
		elseif party.a12 and party.a12.name == name then
			return true
		elseif party.a13 and party.a13.name == name then
			return true
		elseif party.a14 and party.a14.name == name then
			return true
		elseif party.a15 and party.a15.name == name then
			return true
		end
	end
	if party.party3_count > 0 then
		if party.a20 and party.a20.name == name then
			return true
		elseif party.a21 and party.a21.name == name then
			return true
		elseif party.a22 and party.a22.name == name then
			return true
		elseif party.a23 and party.a23.name == name then
			return true
		elseif party.a24 and party.a24.name == name then
			return true
		elseif party.a25 and party.a25.name == name then
			return true
		end
	end
	return false
end



--Check for any mobs that are aggro'd
function getAggroMob()
	local recasts = windower.ffxi.get_ability_recasts()
	local player = windower.ffxi.get_player()
	local spell_recasts = windower.ffxi.get_spell_recasts()
	local subjob = player.sub_job
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v.valid_target and v.id ~= player.id and v.claim_id == 0 and v.is_npc and not player.in_combat and v.status == 1 and v.spawn_type == 16 then	-- check for unclaimed mob in range
			if math.sqrt(v.distance) <= 10 then
				return v.id
			end
		end
	end
	return 0
end


--Pull a new mob
function getNewMob(aggro_mob_id)
	local recasts = windower.ffxi.get_ability_recasts()
	local player = windower.ffxi.get_player()
	local spell_recasts = windower.ffxi.get_spell_recasts()
	local subjob = player.sub_job
	local closestmob = nil
	local mobdistance = 25
	if aggro_mob_id ~= 0 then
		pullmob = packets.new('outgoing', 0x01A, {
			['Target'] = aggro_mob_id,
			['Target Index'] = windower.ffxi.get_mob_by_id(aggro_mob_id).index,
			['Category'] = 0x02,
		})
		packets.inject(pullmob)
		delay = 1.2
	elseif aggro_mob_id == 0 then
		for i,v in pairs(windower.ffxi.get_mob_array()) do
			if v.valid_target and v.id ~= player.id and v.claim_id == 0 and v.is_npc and not player.in_combat and v.status == 0 and mob_targets[v.name] then -- check for unclaimed mob in range
				if math.sqrt(v.distance) <= mobdistance then
					mobdistance = math.sqrt(v.distance)
					closestmob = v.id
				end
			end
		end
		if closestmob then
			if mobdistance <= 17.8 and recasts[5] and recasts[5] == 0 and (job == 'WAR' or subjob == 'WAR') then
				pullmob = packets.new('outgoing', 0x01A, {
					['Target'] = closestmob,
					['Target Index'] = windower.ffxi.get_mob_by_id(closestmob).index,
					['Category'] = 0x09,
					['Param'] = 35,		--Provoke
					['_unknown1'] = 0,
				})
				packets.inject(pullmob)
				delay = 1
				return
			elseif mobdistance <= 20 and spell_recasts[24] and spell_recasts[24] == 0 and (job == 'WHM' or job == 'SCH' or job == 'RDM' or subjob == 'WHM' or subjob == 'SCH' or subjob == 'RDM') then
				pullmob = packets.new('outgoing', 0x01A, {
					['Target'] = closestmob,
					['Target Index'] = windower.ffxi.get_mob_by_id(closestmob).index,
					['Category'] = 0x03,
					['Param'] = 24,		--Dia II
					['_unknown1'] = 0,
				})
				packets.inject(pullmob)
				delay = 1
				return
			elseif mobdistance <= 20 and spell_recasts[220] and spell_recasts[220] == 0 and job == 'RUN' then
				pullmob = packets.new('outgoing', 0x01A, {
					['Target'] = closestmob,
					['Target Index'] = windower.ffxi.get_mob_by_id(closestmob).index,
					['Category'] = 0x03,
					['Param'] = 220,		--Poison
					['_unknown1'] = 0,
				})
				packets.inject(pullmob)
				delay = 1
			end
		end
	end
end





--Set the delay to 20 when you zone so you don't immediately spam abilities and such
windower.register_event('zone change', function(new, old)
	delay = 20
end)

--Get currently equipped item ID in a slot
function getEquippedItemId(slot_name)
	inventory = windower.ffxi.get_items()
	local equipment = inventory['equipment'];
	return windower.ffxi.get_items(equipment[string.format('%s_bag', slot_name)], equipment[slot_name]).id
end


--Addon commands
windower.register_event('addon command', function(...)
	local command = {...}
    if command[1] == 'party' or command[1] == 'size' or command[1] == 'p' or command[1] == 's' or command[1] == 'partysize' or command[1] == 'psize' and command[2] then
        if tonumber(command[2]) ~= nil and tonumber(command[2]) > 0 and tonumber(command[2]) < 7 then
			party_size = tonumber(command[2])
			Print_Settings()
		end
	elseif command[1] == 'member' or command[1] == 'partymember' and command[2] then
		if tonumber(command[2]) ~= nil and tonumber(command[2]) == 1 or tonumber(command[2]) == 2 then
			party_member = tonumber(command[2])
		end
		Print_Settings()
	elseif command[1] == 'p2' or command[1] == 'pm' and command[2] then
		if isInParty(command[2]:ucfirst()) then
			p2_name = command[2]:ucfirst()
		end
		Print_Settings()
	elseif command[1] == 'selfsc' then
		if command[2] then
			if command[2] == 'on' then
				self_SC = 'on'
			elseif command[2] == 'off' then
				self_SC = 'off'
			end
		elseif not command[2] then
			if self_SC == 'on' then
				self_SC = 'off'
			elseif self_SC == 'off' then
				self_SC = 'on'
			end
		end
		showBox()
	elseif command[1] == 'amoverride' and command[2] then
		if command[2] == 'on' or command[2] == '1' or command[2] == 'yes' then
			AM_override = 'on'
		elseif command[2] == 'off' or command[2] == '0' or command[2] == 'no' then
			AM_override = 'off'
		end
		Print_Settings()
	elseif command[1] == 'pull' then
		if command[2] then
			if command[2] == 'on' or command[2] == '1' or command[2] == 'yes' then
				pull = 'on'
			elseif command[2] == 'off' or command[2] == '0' or command[2] == 'no' then
				pull = 'off'
			end
		elseif not command[2] then
			if pull == 'on' then
				pull = 'off'
			elseif pull == 'off' then
				pull = 'on'
			end
		end
		showBox()
	elseif command[1] == 'run' then
		if command[2] then
			if command[2] == 'on' then
				runtomob = 'on'
			elseif command[2] == 'off' then
				runtomob = 'off'
			end
		elseif not command[2] then
			if runtomob == 'on' then
				runtomob = 'off'
			elseif runtomob == 'off' then
				runtomob = 'on'
			end
		end
		showBox()
	elseif command[1] == 'provoke' then
		if command[2] then
			if command[2] == 'on' then
				voke = 'on'
			elseif command[2] == 'off' then
				voke = 'off'
			end
		elseif not command[2] then
			if voke == 'on' then
				voke = 'off'
			elseif voke == 'off' then
				voke = 'on'
			end
		end
		showBox()
	elseif command[1] == 'addmob' and command[2] then
		add_mob_target(command[2])
	elseif command[1] == 'removemob' and command[2] then
		remove_mob_target(command[2])
	elseif command[1]:lower() == 'addws' and command[2] and command[3] then
		addSelfSC(job, command[2]:ucfirst(), command[3])
		showBox()
	elseif command[1]:lower() == 'removews' and command[2] then
		removeSelfSC(job, command[2])
		showBox()
	elseif command[1]:lower() == 'listws' then
		listSelfSC()
	elseif command[1]:lower() == 'ws' then
		if command[2] then
			if command[2]:lower() == 'on' then
				use_ws = 'on'
			elseif command[2]:lower() == 'off' then
				use_ws = 'off'
			end
		elseif not command[2] then
			if use_ws == 'on' then
				use_ws = 'off'
			elseif use_ws == 'off' then
				use_ws = 'on'
			end
		end
		showBox()
	elseif command[1]:lower() == 'mainws' then
		if command[2] then
			local mainws = ws_list[command[2]]
			if mainws then
				job_ws_list[job].ws_a = command[2]:ucfirst()
				windower.add_to_chat(7, 'Main weaponskill changed to '..command[2]:ucfirst())
			else
				windower.add_to_chat(7, 'Unable to update main weaponskill to '..command[2]:ucfirst().. ' - please check spelling')
			end
		end
	elseif command[1]:lower() == 'subws' then
		if command[2] then
			local subws = ws_list[command[2]]
			if subws then
				job_ws_list[job].ws_b = command[2]:ucfirst()
				windower.add_to_chat(7, 'Sub weaponskill changed to '..command[2]:ucfirst())
			else
				windower.add_to_chat(7, 'Unable to update sub weaponskill to '..command[2]:ucfirst().. ' - please check spelling')
			end
		end
	elseif command[1] == 'autora' then
		if command[2] then
			if command[2] == 'on' then
				autoRA = true
				windower.add_to_chat(7, 'Auto Shooting Enabled.')
			elseif command[2] == 'off' then
				autoRA = false
				windower.add_to_chat(7, 'Auto Shooting Disabled.')
			end
		elseif not command[2] then
			if autoRA then
				autoRA = false
				windower.add_to_chat(7, 'Auto Shooting Disabled.')
			elseif not autoRA then
				autoRA = true
				windower.add_to_chat(7, 'Auto Shooting Enabled.')
			end
		end
		showBox()
	elseif command[1] == 'autostopra' then
		if command[2] then
			if command[2] == 'on' then
				autoStopRA = true
				windower.add_to_chat(7, 'Shooting will stop at '..autoRATP..' TP.')
			elseif command[2] == 'off' then
				autoStopRA = false
				windower.add_to_chat(7, 'Shooting will continue indefinitely.')
			else
				local raTP = tonumber(command[2])
				if raTP and raTP > 1000 and raTP <= 3000 then
					autoRATP = raTP
				end
			end
		elseif not command[2] then
			if autoStopRA then
				autoStopRA = false
				windower.add_to_chat(7, 'Shooting will continue indefinitely.')
			elseif not autoStopRA then
				autoStopRA = true
				windower.add_to_chat(7, 'Shooting will stop at '..autoRATP..' TP.')
			end
		end
		showBox()
	elseif command[1]:lower() == 'assist' then
		if command[2] then
			if command[2] == 'on' and assistTarget then
				assistEnabled = true
			elseif command[2] == 'off' and assistTarget then
				assistEnabled = false
			else
				if checkName(command[2]) then
					assistTarget = command[2]:ucfirst()
				end
			end
		elseif not command[2] and assistTarget then
			assistEnabled = not assistEnabled
		end
		showBox()
	elseif command[1] == 'pause' then
		if command[2] then
			if command[2] == 'on' then
				pause = 'on'
				windower.add_to_chat(7, 'Skillchainer paused.')
			elseif command[2] == 'off' then
				pause = 'off'
				windower.add_to_chat(7, 'Skillchainer resumed.')
			end
		elseif not command[2] then
			if pause == 'on' then
				pause = 'off'
				windower.add_to_chat(7, 'Skillchainer resumed.')
			elseif pause == 'off' then
				pause = 'on'
				windower.add_to_chat(7, 'Skillchainer paused.')
			end
		end
		showBox()
	elseif command[1] == 'help' then
		windower.add_to_chat(7, 'Commands:')
		windower.add_to_chat(7, 'sc help - displays this help')
		windower.add_to_chat(7, 'sc party #(1-2) - sets party size')
		windower.add_to_chat(7, 'sc p2 name - sets the other party member\'s name for SC purposes')
		windower.add_to_chat(7, 'sc member #(1-2) - sets user to member 1 or 2 for SC purposes')
		windower.add_to_chat(7, 'sc selfsc on|off - turn self skillchaining on or off')
		windower.add_to_chat(7, 'sc pull on|off - turns auto pulling on or off if user member is set to 1')
		windower.add_to_chat(7, 'sc run on|off - turns auto running to engaged mob on or off')
		windower.add_to_chat(7, 'sc provoke on|off - turns provoking on or off if warrior is main or sub')
		windower.add_to_chat(7, 'sc assist "name" - sets a person as the assist, no quotes required')
		windower.add_to_chat(7, 'sc pause on|off - pauses the skillchainer')
		windower.add_to_chat(7, 'sc addws "Weaponskill" Step | removews Step - adds or removes the self skillchain weaponskill')
		windower.add_to_chat(7, 'example: //sc addws "Tachi: Fudo" 1 and //sc removews 1')
		windower.add_to_chat(7, 'sc listws - lists all the self skillchain steps and weaponskills for current job')
		windower.add_to_chat(7, 'sc ws on|off - turns the use of weaponskills on or off')
		windower.add_to_chat(7, 'sc mainws|subws "Weaponskill" - changes the weaponskills used when either solo spamming or skillchaining with another player')
		windower.add_to_chat(7, 'sc addmob|removemob mob - adds or removes mob to the target auto pull list')
    end
end)


windower.register_event('mouse', function(type, x, y, delta, blocked)
	
	local mx, my = texts.extents(sc_info)
	local button_lines = sc_info:text():count('\n') + 1
	local hx = (x - settings.pos.x)
	local hy = (y - settings.pos.y)
	local location = {}
	location.offset = my / button_lines
	location[1] = {}
	location[1].ya = 1
	location[1].yb = location.offset
	local count = 2
	while count <= button_lines do
		 location[count] = {}
		 location[count].ya = location[count - 1].yb
		 location[count].yb = location[count - 1].yb + location.offset
		 count = count + 1
	end
	
	--[[local smx, smy = texts.extents(hl_sets)
	local setsbutton_lines = hl_sets:text():count('\n') + 1
	local shx = (x - spellsettings.pos.x)
	local shy = (y - spellsettings.pos.y)
	local setslocation = {}
	setslocation.offset = smy / setsbutton_lines
	setslocation[1] = {}
	setslocation[1].ya = 1
	setslocation[1].yb = setslocation.offset
	local setscount = 2
	while setscount <= setsbutton_lines do
		 setslocation[setscount] = {}
		 setslocation[setscount].ya = setslocation[setscount - 1].yb
		 setslocation[setscount].yb = setslocation[setscount - 1].yb + setslocation.offset
		 setscount = setscount + 1
	end]]
	
	
	if type == 2 then
		if sc_info:hover(x, y) and sc_info:visible() then
			for i, v in ipairs(location) do
				local switchb = {}
				switchb = {[1]="",[2]="",[3]="pull",[4]="run",[5]="provoke",[6]="assist",[7]="ws",[8]="selfsc"}
				switchb[table.getn(location)] = "pause"
				if hy > location[i].ya and hy < location[i].yb then
					if switchb[i] and switchb[i] ~= "" then
						windower.send_command("sc "..switchb[i])
					end
				end
			end
		end
		--[[if hl_sets:hover(x, y) and hl_sets:visible() then
			for i, v in ipairs(setslocation) do	
				if shy > setslocation[i].ya and shy < setslocation[i].yb then
					local num = i-1
					if num > 0 then
						windower.send_command("hl loadset "..num)
					end
				end
			end
		end]]
	end
end)





