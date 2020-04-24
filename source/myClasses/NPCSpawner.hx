package myClasses;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class NPCSpawner extends FlxSprite {
	var spawnRate:Float;

	var spawnTimer:FlxTimer;

	var player:Player;

	public var proximityText(default, null):FlxText; // text displayed when player is nearby
	public var isTextVisible(default, default):Bool; // flag that gets changed in playstate when displaying the text

	var isActive(default, null):Bool;

	public function new(_x:Float, _y:Float, _player:Player) {
		super(_x, _y);

		player = _player;

		proximityText = new FlxText(x, y, 70, "Press E to close the building", 8);
		proximityText.setBorderStyle(OUTLINE, FlxColor.BLACK, 0.5);
		isTextVisible = false;

		spawnRate = 10;
		spawnTimer = new FlxTimer();
		activate();
		centerOffsets(true);
	}

	public function toggleOnOff() {
		if (isActive) {
			deactivate();
		} else {
			activate();
		}
	}

	function spawnNPC(_) {
		if (PlayState.actors.countLiving() < 40) {
			if (FlxG.random.bool(15)) {
				var newNpc = PlayState.npcs.recycle(NPC.new);
				newNpc.initialize(x, y + 10);
				PlayState.npcs.add(newNpc);
				PlayState.actors.add(newNpc);
				PlayState.emitters.add(newNpc.emitter);
			}
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
}
