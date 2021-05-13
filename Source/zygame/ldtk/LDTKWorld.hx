package zygame.ldtk;

import zygame.ldtk.LDTKProject.LDTKMap;
import zygame.components.ZBox;

class LDTKWorld extends ZBox {
	public var tileSize:Int = 0;

	public var maps:Array<LDTKMap> = [];

	public function new() {
		super();
	}

	public function addMap(map:LDTKMap):Void {
		this.addChild(map);
		maps.push(map);
	}

	public function getGrid(x:Int, y:Int):Int {
		trace(x, y);
		for (map in maps) {
			if (map.offestWorldX <= x
				&& map.tileWidth + map.offestWorldX >= x
				&& map.offestWorldY <= y
				&& map.tileHeight + map.offestWorldY >= y) {
				return map.getGrid(x - map.offestWorldX, y - map.offestWorldY);
			}
		}
		return 0;
	}
}
