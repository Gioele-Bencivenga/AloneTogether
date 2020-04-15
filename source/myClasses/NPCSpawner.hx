package myClasses;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class NPCSpawner extends FlxSprite {
	var spawnRate:Float;

	var spawnTimer:FlxTimer;

	public function new(_x:Float, _y:Float) {
		super(_x, _y);

		spawnRate = 10;
		spawnTimer = new FlxTimer();
		spawnTimer.start(spawnRate, spawnNPC, 0);
	}

	function spawnNPC(_) {
		if(FlxG.random.bool(50)){
			var newNpc = PlayState.npcs.recycle(NPC.new);
			newNpc.initialize(x, y);
			PlayState.npcs.add(newNpc);
			PlayState.actors.add(newNpc);
			PlayState.emitters.add(newNpc.emitter);
		}
	}
}
