package;

import flixel.util.FlxTimer;
import openfl.ui.GameInputControl;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.FlxState;
import myClasses.*;

class PlayState extends FlxState {
	var player:Player;
	var coins:FlxTypedGroup<Coin>; // group of coins
	var npcs:FlxTypedGroup<NPC>; // group of npcs
	var actors:FlxTypedGroup<Human>; // group of npcs + player

	var emitters:FlxTypedGroup<FlxEmitter>; // group of emitters

	var map:FlxOgmo3Loader;
	var collisionsLayer:FlxTilemap;
	var groundLayer:FlxTilemap;
	var buildingsLayer:FlxTilemap;
	var rooftopsLayer:FlxTilemap;

	var hud:HUD;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;

	var npcDetectionTimer:FlxTimer;

	override public function create():Void {
		/// TILEMAP STUFF
		map = new FlxOgmo3Loader(AssetPaths.cityTilemap__ogmo, AssetPaths.city1__json);
		collisionsLayer = map.loadTilemap(AssetPaths.tiles__png, "collisions");
		collisionsLayer.setTileProperties(1, FlxObject.NONE);
		collisionsLayer.setTileProperties(2, FlxObject.ANY);
		collisionsLayer.immovable = true;
		add(collisionsLayer);
		groundLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "ground");
		add(groundLayer);
		buildingsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "buildings");
		add(buildingsLayer);

		/// COIN STUFF
		coins = new FlxTypedGroup<Coin>();
		add(coins);

		/// VIRUS STUFF
		emitters = new FlxTypedGroup<FlxEmitter>();
		add(emitters);

		/// NPC STUFF
		npcs = new FlxTypedGroup<NPC>();
		add(npcs);

		/// PLAYER STUFF
		player = new Player();
		add(player);
		add(player.emitter);
		emitters.add(player.emitter);

		/// ACTOR STUFF
		actors = new FlxTypedGroup<Human>();
		actors.add(player);

		/// ENTITIES STUFF
		map.loadEntities(placeEntities, "entities");

		npcs.getRandom().infect();

		// we put the rooftops after the player so they get rendered in front of it
		rooftopsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "rooftops");
		add(rooftopsLayer);

		/// CAMERA STUFF
		gameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		gameCamera.bgColor = FlxColor.TRANSPARENT;
		collisionsLayer.follow(gameCamera); // lock the camera to the wall map edges
		gameCamera.follow(player, FlxCameraFollowStyle.LOCKON);
		gameCamera.zoom = 2.4;
		FlxG.cameras.add(gameCamera);
		// hud camera
		hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera);

		FlxCamera.defaultCameras = [gameCamera];

		/// HUD STUFF
		hud = new HUD(player, actors);
		hud.forEach(function(element) {
			element.cameras = [hudCamera];
		});
		add(hud);

		/// TIMER STUFF
		npcDetectionTimer = new FlxTimer();
		npcDetectionTimer.start(1, callNpcDetectMethod, 0);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// collisions between actors
		FlxG.collide(actors, actors);
		// collisions between actors and tilemap
		FlxG.collide(actors, collisionsLayer);
		// collisions between germs and tilemap
		FlxG.collide(emitters, collisionsLayer);

		// overlap between actors and coins
		FlxG.overlap(actors, coins, humanTouchesCoin);
		// overlap between actors and virus
		FlxG.overlap(actors, emitters, humanTouchesVirus);

		// pressing period/comma zooms in/out
		if (FlxG.keys.justPressed.PERIOD) {
			SetZoom(FlxG.camera.zoom += 0.2);
		}
		if (FlxG.keys.justPressed.COMMA) {
			SetZoom(FlxG.camera.zoom -= 0.2);
		}
	}

	function placeEntities(entity:EntityData) {
		switch (entity.name) {
			case "player":
				player.setPosition(entity.x, entity.y);

			case "coin": // we add the coin in the ogmo project to our coins group, the +4 is to center the coin in the middle of the tile
				coins.add(new Coin(entity.x + 4, entity.y + 4));

			case "denizen":
				var npcSprite = FlxG.random.getObject([
					AssetPaths.bob__png,
					AssetPaths.boba__png,
					AssetPaths.bobby__png,
					AssetPaths.bobert__png,
					AssetPaths.bobesha__png,
					AssetPaths.bobunter__png
				]);
				var newNpc = new NPC(entity.x + 4, entity.y + 4, npcSprite);
				emitters.add(newNpc.emitter);
				npcs.add(newNpc);
				actors.add(newNpc);
		}
	}

	function humanTouchesCoin(_actor:Human, _coin:Coin) {
		if (_actor.alive && _actor.exists && _coin.alive && _coin.exists) {
			_coin.kill();
		}
	}

	function humanTouchesVirus(_actor:Human, _emitter:FlxEmitter) {
		if (_actor.alive && _actor.exists && _emitter.alive && _emitter.exists) {
			if (!_actor.isInfected && !_actor.isImmune) {
				_actor.infect();
			}
		}
	}

	function callNpcDetectMethod(_) { // called each second by the timer so that NPCs run less into walls
		for (npc in npcs) {
			npc.detectSurroundings(collisionsLayer);
		}
	}

	private function SetZoom(_zoom:Float) {
		gameCamera.zoom = FlxMath.bound(_zoom, 2, 4);
	}
}
