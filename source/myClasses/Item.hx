package myClasses;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxVector;
import flixel.FlxSprite;

enum abstract ItemType(Int) to Int {
	var Mask = 0;
	var Gloves = 1;
	var Sanitizer = 2;
}

class Item extends FlxSprite {
	public var type(default, null):ItemType;

	public var slot(default, null):Int; // array slot where the item is kept in the human class (0 = Mask, 1 = Gloves, 2 = Sanitizer)

	var owner:Human;

	var maxDistFromOwner:Int; // distance after which the item starts following the player
	var velocityMultiplier:Float; // how fast the item follows

	var direction:FlxVector;

	public var infectionChanceReduction(default, null):Int;
	public var germSpeedReduction(default, null):Int;

	public var isEquipped(default, null):Bool;

	var uprightTimer:FlxTimer; // timer that once in a while checks the angle and brings it upright if it's not

	// for things that are only set once
	public function new() {
		super();

		drag.x = drag.y = 600;
	}

	// for things that need to be set each time we recycle
	public function initialize(_x:Float, _y:Float, _type:ItemType) {
		x = _x;
		y = _y;
		type = _type;
		isEquipped = false;

		if (owner != null) {
			owner = null;
		}

		switch type {
			case Mask:
				loadGraphic(AssetPaths.surgicalMask__png, false, 16, 16);
				maxDistFromOwner = 5;
				velocityMultiplier = 5;
				infectionChanceReduction = 25;
				germSpeedReduction = 7;
				slot = 0;

			case Gloves:
				loadGraphic(AssetPaths.latticeGlove__png, false, 16, 16);
				maxDistFromOwner = 10;
				velocityMultiplier = 3.5;
				infectionChanceReduction = 15;
				germSpeedReduction = 3;
				slot = 1;

			case Sanitizer:
				loadGraphic(AssetPaths.handSanitizer__png, false, 16, 16);
				maxDistFromOwner = 15;
				velocityMultiplier = 2.5;
				infectionChanceReduction = 20;
				germSpeedReduction = 5;
				slot = 2;
		}

		scale.set(0.7, 0.7);
		updateHitbox();

		uprightTimer = new FlxTimer().start(1.5, function(_) {
			if (angle != 0) {
				FlxTween.tween(this, {angle: 0}, 0.5);
			}
		}, 0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		followOwner();
	}

	public function equipTo(_owner:Human) {
		if (!isEquipped) {
			solid = false;
			owner = _owner;
			isEquipped = true;
			setColorTransform(1, 1, 1, 1, 50, 100, 50);

			FlxTween.tween(this.scale, {
				x: 1.5,
				y: 1,
			}, 0.15, {
				ease: FlxEase.expoOut,
			}).then(FlxTween.tween(this, {
				angle: angle + 360,
			}, 0.20).then(FlxTween.tween(this.scale, {
					x: 0.7,
					y: 0.7
				}, 0.15, {
					ease: FlxEase.expoOut,
				})));
		}
	}

	public function unEquip() {
		owner = null;
		isEquipped = false;
		setColorTransform();
		solid = true;
	}

	function followOwner() {
		if (owner != null) {
			var distFromOwner = getPosition().distanceTo(owner.getPosition());

			direction = FlxVector.weak(owner.x - x, owner.y - y);
			direction.length = distFromOwner * velocityMultiplier;

			if (distFromOwner > maxDistFromOwner) {
				velocity.set(direction.x, direction.y);
			}
		}
	}
}
