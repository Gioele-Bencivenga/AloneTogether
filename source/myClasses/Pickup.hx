package myClasses;

import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import myClasses.Item.ItemType;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxSprite;

enum abstract PickupType(Int) to Int {
	var Coin = 0;
	var Paracetamol = 1;
}

class Pickup extends FlxSprite {
	public var emitter(default, null):FlxEmitter;

	public var type(default, null):PickupType;

	/// SOUNDS
	var getSound:FlxSound;
	var explosionSound:FlxSound;

	public function new() {
		super();

		emitter = new FlxEmitter();
	}

	public function initialize(_x:Float, _y:Float, _type:PickupType) {
		x = _x;
		y = _y;
		type = _type;

		angle = 0;
		drag.x = drag.y = 300;

		/// GRAPHIC
		switch type {
			case Coin:
				loadGraphic(AssetPaths.coin__png, false, 8, 8);

			case Paracetamol:
				loadGraphic(AssetPaths.paracetamol__png, false, 8, 8);
		}

		/// EMITTER
		emitter.makeParticles(2, 2, FlxColor.WHITE, 50);
		switch type {
			case Coin:
				emitter.color.set(FlxColor.YELLOW, FlxColor.ORANGE, FlxColor.WHITE, FlxColor.YELLOW);
			case Paracetamol:
				emitter.color.set(FlxColor.BLUE, FlxColor.CYAN, FlxColor.WHITE, FlxColor.BLUE);
		}
		emitter.alpha.set(1, 1, 0, 0.3);
		emitter.lifespan.set(0.1, 0.4);
		emitter.speed.set(50, 200);
		emitter.launchMode = FlxEmitterMode.CIRCLE;

		/// SOUNDS
		switch type {
			case Coin:
				//getSound = FlxG.sound.load("assets/sounds/PickupSounds/coinGet.wav");
				explosionSound = FlxG.sound.load("assets/sounds/PickupSounds/coinExplosion.wav");

			case Paracetamol:
				//getSound = FlxG.sound.load("assets/sounds/PickupSounds/pillGet.wav");
				explosionSound = FlxG.sound.load("assets/sounds/PickupSounds/pillExplosion.wav");
		}
		//getSound.volume = 0.5;
		//explosionSound.volume = 0.5;
	}

	override function kill() {
		alive = false;

		//getSound.proximity(x, y, PlayState.player, 50);
		//getSound.play().fadeIn(0.1);

		var randX = FlxG.random.int(-10, 10);
		var randY = FlxG.random.int(20, 45);
		var randAngle = FlxG.random.int(500, 1000);

		FlxTween.tween(this, {
			x: x + randX,
			y: y - randY,
			angle: angle - randAngle
		}, 0.50, {
			ease: FlxEase.expoOut,
			onComplete: function(_) {
				emitter.focusOn(this);
				emitter.start();
				//explosionSound.play().fadeIn(0.1);
				//explosionSound.proximity(x, y, PlayState.player, 50);
				exists = false;
			}
		});
	}
}
