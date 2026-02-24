
--[[
Copyright Â© 2019, Xathe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Debuffed nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Xathe BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Debuffed'
_addon.author = 'Xathe (Asura),Aragan modi. add miss debuffed'
_addon.version = '1.0.0.4'
_addon.commands = {'dbf','debuffed'}

config = require('config')
packets = require('packets')
res = require('resources')
texts = require('texts')
require('logger')

defaults = {}
defaults.interval = .1
defaults.mode = 'blacklist'
defaults.timers = true
defaults.hide_below_zero = false
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.colors = {}
defaults.colors.player = {}
defaults.colors.player.red = 255
defaults.colors.player.green = 255
defaults.colors.player.blue = 255
defaults.colors.others = {}
defaults.colors.others.red = 255
defaults.colors.others.green = 255
defaults.colors.others.blue = 0

settings = config.load(defaults)
box = texts.new('${current_string}', settings)
box:show()

list_commands = T{
    w = 'whitelist',
    wlist = 'whitelist',
    white = 'whitelist',
    whitelist = 'whitelist',
    b = 'blacklist',
    blist = 'blacklist',
    black = 'blacklist',
    blacklist = 'blacklist'
}

sort_commands = T{
    a = 'add',
    add = 'add',
    ['+'] = 'add',
    r = 'remove',
    remove = 'remove',
    ['-'] = 'remove'
}

player_id = 0
frame_time = 0
debuffed_mobs = {}
step_duration = {}

debuffs_map = {
    [112] = {effect = 156, duration = 12},
    [242] = {effect = 242, duration = 215}, -- Absorb ACC
    [252] = {effect = 10, duration = 12},
    [266] = {effect = 266, duration = 215}, -- Absorb STR
    [267] = {effect = 267, duration = 215}, -- Absorb DEX
    [268] = {effect = 268, duration = 215}, -- Absorb VIT
    [269] = {effect = 269, duration = 215}, -- Absorb AGI
    [270] = {effect = 270, duration = 215}, -- Absorb INT
    [271] = {effect = 271, duration = 215}, -- Absorb MND
    [272] = {effect = 272, duration = 215}, -- Absorb CHR
    [319] = {effect = 147, duration = 120},
    [341] = {effect = 4, duration = 120},
    [344] = {effect = 13, duration = 120},
    [345] = {effect = 13, duration = 300},
    [347] = {effect = 5, duration = 180},
    [348] = {effect = 5, duration = 180},
    [350] = {effect = 3, duration = 60},
    [351] = {effect = 3, duration = 120},
    [365] = {effect = 7, duration = 30},
    [376] = {effect = 193, duration = 45},
    [377] = {effect = 193, duration = 90},
    [463] = {effect = 193, duration = 45},
    [471] = {effect = 193, duration = 90},
    [508] = {effect = 168, duration = 180},
    [524] = {effect = 146, duration = 180},
    [531] = {effect = 11, duration = 60},
    [535] = {effect = 129, duration = 90},
    [572] = {effect = 140, duration = 30},
    [575] = {effect = 28, duration = 2},
    [598] = {effect = 2, duration = 90},
    [610] = {effect = 148, duration = 60},
    [644] = {effect = 4, duration = 90},
    [651] = {effect = {147, 149}, duration = 90},
    [656] = {effect = 167, duration = 120},
    [659] = {effect = 147, duration = 30},
    [682] = {effect = 31, duration = 60},
    [687] = {effect = 6, duration = 90},
    [699] = {effect = 146, duration = 120},
    [703] = {effect = 13, duration = 180},
    [704] = {effect = 4, duration = 60},
    [705] = {effect = 133, duration = 180},
    [707] = {effect = 156, duration = 15},
    [708] = {effect = 12, duration = 120},
    [716] = {effect = 3, duration = 30},
    [719] = {effect = 128, duration = 90},
    [720] = {effect = 28, duration = 30},
    [725] = {effect = 156, duration = 60},
    [726] = {effect = 147, duration = 180},
    [738] = {effect = 28, duration = 30},
    [746] = {effect = 28, duration = 30},
}

BloodPact_map = {
    [580] = {duration = 90},
    [585] = {duration = 90},
    [611] = {duration = 90},
    [617] = {duration = 180},
    [633] = {duration = 15},
    [657] = {duration = 60},
    [963] = {duration = 90},
    [966] = {duration = 180},
}

function update_box()
    local lines = L{}
    local target = windower.ffxi.get_mob_by_target('t')
    
    if target and target.valid_target and (target.claim_id ~= 0 or target.spawn_type == 16) then
        local data = debuffed_mobs[target.id]
        
        if data then
            for effect, spell in pairs(data) do
                local name = spell.name or (res.spells[spell.id] and res.spells[spell.id].name) or (res.job_abilities[spell.id] and res.job_abilities[spell.id].name) or tostring(spell.id)
                local remains = math.max(0, spell.timer - os.clock())
                
                if settings.mode == 'whitelist' and settings.whitelist:contains(name) or settings.mode == 'blacklist' and not settings.blacklist:contains(name) then
                    if settings.timers and remains > 0 then
                        lines:append('\\cs(%s)%s: %.0f\\cr':format(get_color(spell.actor), name, remains))
                    elseif remains < 0 and settings.hide_below_zero then
                        debuffed_mobs[target.id][effect] = nil
                    else
                        lines:append('\\cs(%s)%s\\cr':format(get_color(spell.actor), name))
                    end
                end
            end
        end
    end
    
    if lines:length() == 0 then
        box.current_string = ''
    else
        box.current_string = 'Debuffed [' .. target.name .. ']\n\n' .. lines:concat('\n')
    end
end

function get_color(actor)
    if actor == player_id then
        return '%s,%s,%s':format(settings.colors.player.red, settings.colors.player.green, settings.colors.player.blue)
    else
        return '%s,%s,%s':format(settings.colors.others.red, settings.colors.others.green, settings.colors.others.blue)
    end
end

function handle_overwrites(target, new, t)
    if not debuffed_mobs[target] then
        return true
    end
    
    for effect, spell in pairs(debuffed_mobs[target]) do
        local old = res.spells[spell.id].overwrites or {}
        
        -- Check if there isn't a higher priority debuff active
        if table.length(old) > 0 then
            for _,v in ipairs(old) do
                if new == v then
                    return false
                end
            end
        end
        
        -- Check if a lower priority debuff is being overwritten
        if table.length(t) > 0 then
            for _,v in ipairs(t) do
                if spell.id == v then
                    debuffed_mobs[target][effect] = nil
                end
            end
        end
    end
    return true
end

function apply_debuff(target, effect, spell, actor)
    if not debuffed_mobs[target] then
        debuffed_mobs[target] = {}
    end
    
    -- Check overwrite conditions
    local overwrites = res.spells[spell].overwrites or {}
    if not handle_overwrites(target, spell, overwrites) then
        return
    end
    
    -- Create timer
    debuffed_mobs[target][effect] = {id=spell, timer=(os.clock() + (res.spells[spell].duration or 0)), actor=actor}
end

function handle_shot(target)
    if not debuffed_mobs[target] or not debuffed_mobs[target][134] then
        return true
    end
    
    local current = debuffed_mobs[target][134].id
    if current < 26 then
        debuffed_mobs[target][134].id = current + 1
    end
end

local function get_pet_owner(id)
    local pet = windower.ffxi.get_mob_by_id(id)
    for i,v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' and v.mob and v.mob.pet_index and pet and v.mob.pet_index == pet.index then
            return v.mob.id
        end
    end
    return id
end

function inc_action(act)
    if act.category == 4 then
        for _, t in pairs(act.targets) do
            local msg = t.actions[1].message
            local target = t.id
            local spell = act.param
            local actor = act.actor_id
            local duration = (res.spells[spell] and res.spells[spell].duration) or (debuffs_map[spell] and debuffs_map[spell].duration) or 0

            if S{2,252,264,265}:contains(msg) then
                local effect = res.spells[spell] and res.spells[spell].status or nil
                if effect then
                    apply_debuff(target, effect, spell, actor)
                elseif debuffs_map[spell] then
                    if type(debuffs_map[spell].effect) == 'table' then
                        for _, eff in pairs(debuffs_map[spell].effect) do
                            local buff_name = res.buffs[eff] and (res.buffs[eff].name or res.buffs[eff].en) or tostring(eff)
                            local name = (res.spells[spell] and res.spells[spell].name or tostring(spell)) .. ' (' .. buff_name .. ')'
                            debuffed_mobs[target] = debuffed_mobs[target] or {}
                            debuffed_mobs[target][eff] = {id = spell, timer = os.clock() + duration, actor = actor, name = name}
                        end
                    else
                        debuffed_mobs[target] = debuffed_mobs[target] or {}
                        debuffed_mobs[target][debuffs_map[spell].effect] = {id = spell, timer = os.clock() + duration, actor = actor}
                    end
                end
            elseif S{236,237,266,267,268,269,270,271,272,277,278,279,280}:contains(msg) then
                local effect = t.actions[1].param
                if spell == 719 and debuffed_mobs[target] and debuffed_mobs[target][133] then
                    return
                elseif spell == 535 and debuffed_mobs[target] and debuffed_mobs[target][128] then
                    return
                elseif spell == 705 and debuffed_mobs[target] and debuffed_mobs[target][132] then
                    return
                end

                if res.spells[spell] and res.spells[spell].status == effect then
                    apply_debuff(target, effect, spell, actor)
                elseif debuffs_map[spell] and type(debuffs_map[spell].effect) == 'table' then
                    for _, eff in pairs(debuffs_map[spell].effect) do
                        local buff_name = res.buffs[eff] and (res.buffs[eff].name or res.buffs[eff].en) or tostring(eff)
                        local name = (res.spells[spell] and res.spells[spell].name or tostring(spell)) .. ' (' .. buff_name .. ')'
                        debuffed_mobs[target] = debuffed_mobs[target] or {}
                        debuffed_mobs[target][eff] = {id = spell, timer = os.clock() + duration, actor = actor, name = name}
                    end
                elseif debuffs_map[spell] and debuffs_map[spell].effect == effect then
                    debuffed_mobs[target] = debuffed_mobs[target] or {}
                    debuffed_mobs[target][effect] = {id = spell, timer = os.clock() + duration, actor = actor}
                elseif debuffs_map[spell] then
                    debuffed_mobs[target] = debuffed_mobs[target] or {}
                    debuffed_mobs[target][debuffs_map[spell].effect] = {id = spell, timer = os.clock() + duration, actor = actor}
                end
            elseif S{329,330,331,332,333,334,335,533}:contains(msg) then
                local effect = debuffs_map[spell] and debuffs_map[spell].effect or nil
                if effect then
                    debuffed_mobs[target] = debuffed_mobs[target] or {}
                    debuffed_mobs[target][effect] = {id = spell, timer = os.clock() + duration, actor = actor}
                end
            end
        end
        return
    end

    if act.category == 6 and act.param == 131 then
        handle_shot(act.targets[1].id)
    elseif act.category == 13 and BloodPact_map[act.param] then
        for _, t in pairs(act.targets) do
            if S{320,267}:contains(t.actions[1].message) then
                local effect = t.actions[1].param
                local target = t.id
                local spell = act.param
                local actor = get_pet_owner(act.actor_id)
                local duration = BloodPact_map[spell].duration or 0
                local name = res.job_abilities[spell] and res.job_abilities[spell].name or tostring(spell)
                local buff_name = res.buffs[effect] and (res.buffs[effect].name or res.buffs[effect].en) or tostring(effect)
                debuffed_mobs[target] = debuffed_mobs[target] or {}
                debuffed_mobs[target][effect] = {id = spell, timer = os.clock() + duration, actor = actor, name = name .. ' (' .. buff_name .. ')'}
            end
        end
    elseif act.category == 14 then
        for _, t in pairs(act.targets) do
            if S{519,520,521,591}:contains(t.actions[1].message) then
                local effect = act.param
                local target = t.id
                local tier = t.actions[1].param

                if not step_duration[target] then step_duration[target] = {} end
                if tier == 1 or not step_duration[target][effect] then
                    step_duration[target][effect] = os.clock() + 60
                elseif step_duration[target][effect] - os.clock() >= 90 then
                    step_duration[target][effect] = os.clock() + 120
                else
                    step_duration[target][effect] = step_duration[target][effect] + 30
                end

                local name = res.job_abilities[effect] and res.job_abilities[effect].name or tostring(effect)
                debuffed_mobs[target] = debuffed_mobs[target] or {}
                debuffed_mobs[target][effect] = {id = effect, timer = step_duration[target][effect], actor = act.actor_id, name = name .. ' lv.' .. tier}
            end
        end
    end
end

function inc_action_message(arr)

    -- Unit died
    if S{6,20,113,406,605,646}:contains(arr.message_id) then
        debuffed_mobs[arr.target_id] = nil
        
    -- Debuff expired
    elseif S{64,204,206,350,531}:contains(arr.message_id) then
        if debuffed_mobs[arr.target_id] then
            debuffed_mobs[arr.target_id][arr.param_1] = nil
        end
    end
end

windower.register_event('login','load', function()
    player_id = (windower.ffxi.get_player() or {}).id
end)

windower.register_event('logout','zone change', function()
    debuffed_mobs = {}
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        inc_action(windower.packets.parse_action(data))
    elseif id == 0x029 then
        local arr = {}
        arr.target_id = data:unpack('I',0x09)
        arr.param_1 = data:unpack('I',0x0D)
        arr.message_id = data:unpack('H',0x19)%32768
        
        inc_action_message(arr)
    end
end)

local _prerender_delay = 0.25
local _prerender_last = 0
windower.register_event('prerender', function()
    local now = os.clock()
    if (now - _prerender_last) < _prerender_delay then
        return
    end
    _prerender_last = now
    local curr = os.clock()
    if curr > frame_time + settings.interval then
        frame_time = curr
        update_box()
    end
end)

windower.register_event('addon command', function(command1, command2, ...)
    local args = L{...}
    command1 = command1 and command1:lower() or nil
    command2 = command2 and command2:lower() or nil
    
    local name = args:concat(' ')
    if command1 == 'm' or command1 == 'mode' then
        if settings.mode == 'blacklist' then
            settings.mode = 'whitelist'
        else
            settings.mode = 'blacklist'
        end
        log('Changed to %s mode.':format(settings.mode))
        settings:save()
    elseif command1 == 't' or command1 == 'timers' then
        settings.timers = not settings.timers
        log('Timer display %s.':format(settings.timers and 'enabled' or 'disabled'))
        settings:save()
    elseif command1 == 'i' or command1 == 'interval' then
        settings.interval = tonumber(command2) or .1
        log('Refresh interval set to %s seconds.':format(settings.interval))
        settings:save()
    elseif command1 == 'h' or command1 == 'hide' then
        settings.hide_below_zero = not settings.hide_below_zero
        log('Timers that reach 0 will be %s.':format(settings.hide_below_zero and 'hidden' or 'shown'))
        settings:save()
    elseif list_commands:containskey(command1) then
        if sort_commands:containskey(command2) then
            local spell = res.spells:with('name', windower.wc_match-{name})
            command1 = list_commands[command1]
            command2 = sort_commands[command2]
            
            if spell == nil then
                error('No spells found that match: %s':format(name))
            elseif command2 == 'add' then
                settings[command1]:add(spell.name)
                log('Added spell to %s: %s':format(command1, spell.name))
            else
                settings[command1]:remove(spell.name)
                log('Removed spell from %s: %s':format(command1, spell.name))
            end
            settings:save()
        end
    else
        print('%s (v%s)':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)mode\\cr - Switches between blacklist and whitelist mode (default: blacklist)')
        print('    \\cs(255,255,255)timers\\cr - Toggles display of debuff timers (default: true)')
        print('    \\cs(255,255,255)interval <value>\\cr - Allows you to change the refresh interval (default: 0.1)')
        print('    \\cs(255,255,255)blacklist|whitelist add|remove <name>\\cr - Adds or removes the spell <name> to the specified list')
    end
end)
