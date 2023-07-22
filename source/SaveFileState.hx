/* package;

// taken from vs marcello lol
import Controls;
import openfl.Lib;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.util.FlxSave;
import flixel.effects.FlxFlicker;

class SaveFileState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	public static var saveFile:FlxSave;

	var bgBackdrop:FlxBackdrop;

	var timeElapsed:Float = 0;

	var emptySave:Array<Bool> = [true, true, true];

	var controlsStrings:Array<String> = [];
	var savesCanDelete:Array<Int> = [];

	var deleteMode:Bool = false;

	var selectedSomething:Bool = false;

	private var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

		bgBackdrop = new FlxBackdrop(Paths.image('checkeredBG', 'preload'), #if (flixel_addons < "3.0.0") 1, 1, true, true, #else XY, #end 1, 1);
		bgBackdrop.alpha = 0;
		bgBackdrop.antialiasing = true;
		bgBackdrop.scrollFactor.set();
		add(bgBackdrop);

		for (i in 0...3)
		{
			var save:FlxSave = new FlxSave();
			save.bind("FoxaSaveFile" + Std.string(i), "saves");
			trace("Save File " + Std.string(i + 1));
			emptySave[i] = (!save.data.init || save.data.init == null);
			save.flush();
			controlsStrings.push("Save File " + Std.string(i + 1) + (!emptySave[i] ? "" : " Empty"));
		}

		controlsStrings.push("Erase Save");

		trace(controlsStrings);

		menuBG.color = 0xFFA04646;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, 0, controlsStrings[i], true);
			controlLabel.screenCenter();
			controlLabel.y += (100 * (i - (controlsStrings.length / 2))) + 50;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		var scrollSpeed:Float = 50;
		bgBackdrop.x -= scrollSpeed * elapsed;
		bgBackdrop.y -= scrollSpeed * elapsed;

		timeElapsed += elapsed;

		super.update(elapsed);

		if (!selectedSomething)
		{
			if (controls.UI_UP_P)
				changeSelection(-1);
			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.ACCEPT)
			{
				if (curSelected != (grpControls.length - 1))
				{
					if (!deleteMode)
					{
						selectedSomething = true;

						FlxG.sound.play(Paths.sound('confirmMenu'));

						for (i in 0...grpControls.length)
						{
							var fuk:Alphabet = grpControls.members[i];
							if (curSelected != i)
							{
								fuk.alpha = 0;
							}
							else
							{
								FlxFlicker.flicker(fuk, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									saveFile = new FlxSave();
									saveFile.bind("FoxaSaveFile" + Std.string(curSelected), "saves");
									saveFile.data.init = true;
									saveFile.flush();
									Highscore.load();
									FlxG.switchState(new MainMenuState());
								});
							}
						}
					}
					else
					{
						eraseSave(savesCanDelete[curSelected]);
					}
				}
				else
				{
					deleteMode = !deleteMode;
					if (deleteMode)
					{
						idkLol();
					}
					else
					{
						grpControls.clear();

						for (i in 0...controlsStrings.length)
						{
							var controlLabel:Alphabet = new Alphabet(0, 0, controlsStrings[i], true);
							controlLabel.screenCenter();
							controlLabel.y += (100 * (i - (controlsStrings.length / 2))) + 50;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}

						curSelected = 0;
						changeSelection(curSelected);
					}
				}
			}
		}
	}

	function eraseSave(id:Int)
	{
		// erase save file
		var save:FlxSave = new FlxSave();
		save.bind("FoxaSaveFile" + Std.string(id), "saves");
		save.erase();

		// rebind to avoid issues
		trace("Erased Save File " + (id + 1));
		save.bind("FoxaSaveFile" + Std.string(id), "saves");
		save.flush();

		emptySave[id] = true;
		controlsStrings[id] = "Save File " + Std.string(id + 1) + " Empty";
		idkLol();
	}

	function idkLol()
	{
		savesCanDelete = [];

		for (i in 0...grpControls.length)
		{
			if (i != 3)
			{
				if (!emptySave[i])
				{
					savesCanDelete.push(i);
				}
			}
		}

		grpControls.clear();

		var savesAvailable:Array<String> = [];

		for (i in 0...savesCanDelete.length)
		{
			savesAvailable.push("Save File " + Std.string(i + 1));
		}

		savesAvailable.push("Cancel");

		for (i in 0...savesAvailable.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, 0, savesAvailable[i], true);
			controlLabel.screenCenter();
			controlLabel.y += (100 * (i - (savesAvailable.length / 2))) + 50;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		changeSelection();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}*/
// todo: fix this shit shsdgrrtgjftgyj