tweens = {
	--[[
	--EXAMPLES
	--i: the current notes index for their strum group
	--isPlayer: uhhh idk
	--strum: name of the strum group (opponentStrums and playerStrums)
	--set: a function that can be used to set a property in the current note
	--get: a function that can be used to get a property from the current note
	--tween: a function that tweens the current note
	--tween function stuff
	--vars: just like in haxeflixel, this should be a table of variables and what to tween them to
	--duration: NO CLUE!!!!!!
	--options: options for the flxtween, supports onComplete and onStart!! cool!!
	dad = function(i, isPlayer, strum, set, get, tween)
		--this function is called 4 times for each strum (should work with multi key things too)
		local d = downscroll and -1 or 1 --value that multiplies the y based off if downscroll is enabled or not
		set('y', get 'y' + 900*d) --puts the strum up by 900 (sets y to its y + 900)
		--tweens like flxtween
		tween({y = get 'y' - 920*d}, 0.5, {startDelay = 0.5 + (0.2 * i), ease = 'cubeOut', onComplete = function()
			--this function is called when the tween ends, after that do another tween
			tween({y = get 'y' + 30*d}, 0.25, {ease = 'cubeIn', onComplete = function()
			tween({y = get 'y' - 10*d}, 0.25/2, {ease = 'backOut'})
			end})
		end})
	end,
	bf = function(i, isPlayer, strum, set, get, tween)
		set('x', get 'x' + 550)
		set('angle', 180)
		tween({angle = 0, x = get 'x' - 550}, 1, {startDelay = 0.5 + (0.2 * i), ease = 'cubeOut'})
	end
	]]
}
tweenNum = 0
function onStartCountdown()
	setProperty('skipArrowStartTween', true)
	luaDebugMode = true
end
tweenStarts = {}
tweenEnds = {}
tweenUpdates = {}
function onCountdownStarted()
	local stuff = function(func, char)
		local isPlayer = char == boyfriendName
		local strum = isPlayer and 'playerStrums' or 'opponentStrums'
		for i=0,3 do 
			local set = function(variable, value) setPropertyFromGroup(strum, i, variable, value) end
			local get = function(variable) return getPropertyFromGroup(strum, i, variable) end
			local tween = function(vars, duration, options)
				local curTweenNum = tweenNum
				local tag = options.tag or 'CUSTOM_INTRO_TWEEN_'..tostring(curTweenNum)
				runHaxeCode('setVar("CUSTOM_INTRO_tweenstuff", null);')
				setProperty('CUSTOM_INTRO_tweenstuff', {vars = vars, duration = duration, options = options, i = i})
				tweenEnds[tag] = options.onComplete
				tweenStarts[tag] = options.onStart
				tweenUpdates[tag] = options.onUpdate
				local idiotTag = '"'..tag:gsub('"', '\\"')..'"'
				runHaxeCode([[
					var stuff = getVar('CUSTOM_INTRO_tweenstuff');
					if(stuff.options != null && stuff.options.ease != null)
					stuff.options.ease = FlxEase.]]..(options.ease or '')..[[;
					var strum = game.]]..strum..[[.members[stuff.i];
					if(stuff.options == null)
					stuff.options = {onComplete: _ -> {}, onStart: _ -> {}, onUpdate: _ -> {}};
					stuff.options.onComplete = _ -> game.callOnLuas('_customIntroTweens', []]..idiotTag..[[]);
					stuff.options.onStart = _ -> game.callOnLuas('_tweenStart', []]..idiotTag..[[]);
					stuff.options.onUpdate = t -> game.callOnLuas('_tweenUpdate', []]..idiotTag..[[, t.percent]);
					game.modchartTweens.set(]]..idiotTag..[[, FlxTween.tween(strum, stuff.vars, stuff.duration, stuff.options));
					setVar('CUSTOM_INTRO_tweenstuff', null);
				]])
				tweenNum = tweenNum + 1
			end
			func(i, isPlayer, strum, set, get, tween) 
		end
	end
	for i,char in pairs{dadName, boyfriendName} do
		if tweens[char] then
			stuff(tweens[char], char)
		else
			stuff(function(i, isPlayer, strum, set, get, tween) --just does the normal shit
			set('alpha', 0)
			tween({alpha = 1}, 1, {startDelay = 0.5 + (0.2 * i), ease = 'circOut'})
			end, char)
		end
	end
end
--hahahahhahahahhahahahhahahahahahahahahahahahahhah :3
function _tweenStart(t) if tweenStarts[t] then tweenStarts[t]() end; tweenStarts[t] = nil end
function _customIntroTweens(t) if tweenEnds[t] then tweenEnds[t]() end; tweenEnds[t] = nil; tweenUpdates[t] = nil end
function _tweenUpdate(t, p) if tweenUpdates[t] then tweenUpdates[t](p) end end