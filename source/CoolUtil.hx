package;

import flixel.util.FlxSave;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.system.FlxSound;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static var defaultDifficulty:String = 'Normal'; // The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	public static function formatString(string:String):String
	{
		var split:Array<String> = string.split('-');
		var formattedString:String = '';
		for (i in 0...split.length)
		{
			var piece:String = split[i];
			var allSplit = piece.split('');
			var firstLetterUpperCased = allSplit[0].toUpperCase();
			var substring = piece.substr(1, piece.length - 1);
			var newPiece = firstLetterUpperCased + substring;
			if (i != split.length - 1)
			{
				newPiece += " ";
			}
			formattedString += newPiece;
		}
		return formattedString;
	}

	public static function getIntArray(max:Int):Array<Int>
	{
		var arr:Array<Int> = [];
		for (i in 0...max)
		{
			arr.push(i);
		}
		return arr;
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	inline public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	inline public static function clamp(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if (FileSystem.exists(path))
			daList = File.getContent(path).trim().split('\n');
		#else
		if (Assets.exists(path))
			daList = Assets.getText(path).trim().split('\n');
		#end

		return [for (i in 0...daList.length) daList[i].trim()];
	}

	public static function listFromString(string:String):Array<String>
	{
		final daList = string.trim().split('\n');
		return [for (i in 0...daList.length) daList[i].trim()];
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	/**
		Funny handler for `Application.current.window.alert` that *doesn't* crash on Linux and shit.

		@param message Message of the error.
		@param title Title of the error.

		@author Leather128
	**/
	public static function coolError(message:Null<String> = null, title:Null<String> = null):Void
	{
		#if !linux
		lime.app.Application.current.window.alert(message, title);
		#else
		trace(title + " - " + message, ERROR);

		var text:FlxText = new FlxText(8, 0, 1280, title + " - " + message, 24);
		text.color = FlxColor.RED;
		text.borderSize = 1.5;
		text.borderStyle = OUTLINE;
		text.borderColor = FlxColor.BLACK;
		text.scrollFactor.set();
		text.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		FlxG.state.add(text);

		FlxTween.tween(text, {alpha: 0, y: 8}, 5, {
			onComplete: function(_)
			{
				FlxG.state.remove(text);
				text.destroy();
			}
		});
		#end
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'ShadowMario'):String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
}
