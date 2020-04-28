package myClasses;

import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
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

	var dissolveTween:FlxTween;

	/// SOUNDS
	var getSound:String;
	var explosionSound:String;

	public function new() {
		super();

		emitter = new FlxEmitter();
	}

	public function initialize(_x:Float, _y:Float, _type:PickupType) {
		x = _x;
		y = _y;
		type = _type;

		angle = 0;
		alpha = 1;
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
				getSound = AssetPaths.coinGet__wav;
				explosionSound = AssetPaths.coinExplosion__wav;

			case Paracetamol:
				getSound = AssetPaths.pillGet__wav;
				explosionSound = AssetPaths.pillExplosion__wav;
		}

		if (type == PickupType.Coin) {
			dissolveTween = FlxTween.tween(this, {alpha: 0}, 120, {onComplete: function(_) kill()});
			dissolveTween.start();
		}
	}

	public function myKill() {
		alive = false;

		DeanSound.playSound(getSound, 0.3, this, PlayState.player, 200);

		var randX = FlxG.random.int(-10, 10);
		var randY = FlxG.random.int(20, 45);
		var randAngle = FlxG.random.int(500, 1000);

		if (dissolveTween != null)
			dissolveTween.cancel();

		FlxTween.tween(this, {
			x: x + randX,
			y: y - randY,
			angle: angle - randAngle
		}, 0.50, {
			ease: FlxEase.expoOut,
			onComplete: function(_) {
				emitter.focusOn(this);
				emitter.start();
				DeanSound.playSound(explosionSound, 0.3, this, PlayState.player, 200);
				kill();
			}
		});
	}
}
