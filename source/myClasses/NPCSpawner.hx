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
	var closeDoorSound:FlxSound;
	var openDoorSound:FlxSound;

	public function new(_x:Float, _y:Float, _player:Player) {
		super(_x, _y);

		player = _player;

		textDissolver = new FlxTimer();

		/// SOUNDS
		closeDoorSound = FlxG.sound.load("assets/sounds/BuildingSounds/doorClose.wav");
		openDoorSound = FlxG.sound.load("assets/sounds/BuildingSounds/doorOpen.wav");
		closeDoorSound.volume = 0.5;
		openDoorSound.volume = 0.5;

		proximityText = new FlxText(x, y, 0, "Placeholder text");
		proximityText.setPosition(getGraphicMidpoint().x - (proximityText.width / 2), y - FlxG.random.int(10, 50));
		proximityText.setBorderStyle(SHADOW, FlxColor.ORANGE, 1);
		proximityText.shadowOffset.set(-1, 1);
		hideProximityText();

		spawnRate = 25;
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
			closeDoorSound.proximity(x, y, PlayState.player, 150);
			closeDoorSound.play();
		} else {
			activate();
			openDoorSound.proximity(x, y, PlayState.player, 150);
			openDoorSound.play();
		}
	}

	function activate() {
		loadGraphic(AssetPaths.openDoor__png, false, 16, 16);
		setSize(40, 40);
		spawnTimer.start(spawnRate, spawnNPC, 0);
		isActive = true;
		proximityText.text = "Press E to close the building";
	}

	function deactivate() {
		loadGraphic(AssetPaths.closedDoor__png, false, 16, 16);
		setSize(40, 40);
		spawnTimer.cancel();
		isActive = false;
		proximityText.text = "Press E to open the building";
	}

	function spawnNPC(_) {
		if (PlayState.actors.countLiving() < 70) {
			if (FlxG.random.bool(60)) {
				var newNpc = PlayState.npcs.recycle(NPC.new);
				newNpc.initialize(x, y + 10);
				PlayState.npcs.add(newNpc);
				PlayState.actors.add(newNpc);
				PlayState.emitters.add(newNpc.emitter);
			}
		}
	}
}
