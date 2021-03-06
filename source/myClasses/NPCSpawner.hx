package myClasses;

import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import openfl.display.InteractiveObject;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class NPCSpawner extends FlxSprite {
	/// SPAWNER STUFF
	var spawnRate:Float;
	var spawnTimer:FlxTimer;
	var isActive(default, null):Bool;

	/// TEXT INTERACT STUFF
	var player:Player;

	public var proximityText(default, null):FlxText; // text displayed when player is nearby
	public var isTextVisible(default, null):Bool;

	var textDissolver:FlxTimer; // after switching isTextVisible on the timer switches it off

	/// SOUNDS
	var closeDoorSound:String;
	var openDoorSound:String;
	var spawnSound:String;

	public function new(_x:Float, _y:Float, _player:Player) {
		super(_x, _y);

		player = _player;

		textDissolver = new FlxTimer();

		/// SOUNDS
		closeDoorSound = AssetPaths.doorClose__wav;
		openDoorSound = AssetPaths.doorOpen__wav;
		spawnSound = AssetPaths.spawn__wav;

		proximityText = new FlxText(x, y, 0, "Placeholder text");
		proximityText.setPosition(getGraphicMidpoint().x - (proximityText.width / 2), y - FlxG.random.int(10, 50));
		proximityText.setBorderStyle(SHADOW, FlxColor.ORANGE, 1);
		proximityText.shadowOffset.set(-1, 1);
		hideProximityText();

		spawnRate = FlxG.random.int(5, 20);
		spawnTimer = new FlxTimer();
		activate();
		centerOffsets(true);
	}

	public function showProximityText() {
		FlxTween.tween(proximityText, {alpha: 1}, 0.6, {
			onComplete: function(_) {
				isTextVisible = true;
				textDissolver.start(0.5, function(_) hideProximityText());
			}
		});
	}

	public function hideProximityText() {
		FlxTween.tween(proximityText, {alpha: 0}, 0.6, {onComplete: function(_) isTextVisible = false});
	}

	public function interact() {
		if (isActive) {
			deactivate();
			DeanSound.playSound(closeDoorSound, 1, this, PlayState.player, 40);
		} else {
			activate();
			DeanSound.playSound(openDoorSound, 1, this, PlayState.player, 40);
		}
	}

	function activate() {
		loadGraphic(AssetPaths.openDoor__png, false, 16, 16);
		setSize(40, 40);
		spawnTimer.start(spawnRate, spawnNPC, 0);
		isActive = true;
		proximityText.text = "[E] to close the building";
	}

	function deactivate() {
		loadGraphic(AssetPaths.closedDoor__png, false, 16, 16);
		setSize(40, 40);
		spawnTimer.cancel();
		isActive = false;
		proximityText.text = "[E] to open the building";
	}

	function spawnNPC(_) {
		var spawnProbability:Int = 0;

		if (PlayState.actors.countLiving() <= 10) {
			spawnProbability = 100;
		} else if (PlayState.actors.countLiving() <= 20) {
			spawnProbability = 90;
		} else if (PlayState.actors.countLiving() <= 30) {
			spawnProbability = 85;
		} else if (PlayState.actors.countLiving() <= 40) {
			spawnProbability = 75;
		} else if (PlayState.actors.countLiving() <= 60) {
			spawnProbability = 60;
		} else if (PlayState.actors.countLiving() < 70) {
			spawnProbability = 30;
		} else if (PlayState.actors.countLiving() >= 70) {
			spawnProbability = 10;
		}

		if (FlxG.random.bool(spawnProbability)) {
			var newNpc = PlayState.npcs.recycle(NPC.new);
			newNpc.initialize(getMidpoint().x, getMidpoint().y + 12);
			PlayState.npcs.add(newNpc);
			PlayState.actors.add(newNpc);
			PlayState.emitters.add(newNpc.emitter);
			PlayState.npcTexts.add(newNpc.thanksText);

			DeanSound.playSound(spawnSound, 1, this, PlayState.player, 200);
		}
	}
}
