package;

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
	var actors:FlxGroup; // group of npcs + player

	public static var emitters:FlxGroup; // group of emitters

	var map:FlxOgmo3Loader;
	var collisionsLayer:FlxTilemap;
	var groundLayer:FlxTilemap;
	var buildingsLayer:FlxTilemap;
	var rooftopsLayer:FlxTilemap;

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
		emitters = new FlxGroup();
		add(emitters);

		/// NPC STUFF
		npcs = new FlxTypedGroup<NPC>();
		add(npcs);

		/// PLAYER STUFF
		player = new Player();
		add(player);
		add(player.emitter);
		player.infect();
		
		/// ACTOR STUFF
		actors = new FlxGroup();
		actors.add(player);
		actors.add(npcs);
		
		/// ENTITIES STUFF
		map.loadEntities(placeEntities, "entities");

		// we put the rooftops after the player so they get rendered in front of it
		rooftopsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "rooftops");
		add(rooftopsLayer);

		/// CAMERA STUFF
		collisionsLayer.follow(); // lock the camera to the wall map edges
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON);
		FlxG.camera.zoom = 2.5;

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// collisions between actors
		FlxG.collide(actors, actors);
		// collisions between actors and tilemap
		FlxG.collide(actors, collisionsLayer);

		// overlap between actors and coins
		FlxG.overlap(actors, coins, actorTouchesCoin);
		// overlap between actors and virus
		FlxG.overlap(actors, emitters, callback);

		// pressing period/comma zooms in/out
		if (FlxG.keys.justPressed.PERIOD) {
			SetZoom(FlxG.camera.zoom += 0.5);
		}
		if (FlxG.keys.justPressed.COMMA) {
			SetZoom(FlxG.camera.zoom -= 0.5);
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
				add(newNpc.emitter);
				emitters.add(newNpc.emitter);
				npcs.add(newNpc);
		}
	}

	function actorTouchesCoin(_actor:Human, _coin:Coin) {
		if (_actor.alive && _actor.exists && _coin.alive && _coin.exists) {
			_coin.kill();
		}
	}

	function callback(_actor:Human, _particle:FlxParticle) {
		trace("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		if (_actor.alive && _actor.exists && _particle.alive && _particle.exists) {
			if (!_actor.isInfected) {
				_actor.infect();
			}
		}
	}

	private function SetZoom(_zoom:Float) {
		FlxG.camera.zoom = FlxMath.bound(_zoom, 1.5, 6);
	}
}
