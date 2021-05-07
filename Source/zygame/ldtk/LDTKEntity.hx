package zygame.ldtk;

import zygame.components.ZQuad;
import zygame.components.ZBox;
import zygame.ldtk.LDTKProject.LDTKEventEntity;
import zygame.components.ZImage;

/**
 * 事件实例对象
 */
class LDTKEntity extends ZBox {
	public var display:ZImage;

	public function new(project:LDTKProject, event:LDTKEventEntity) {
		super();
		if (event.__tile != null) {
			var tilesetId = project.tilesetPathByUid.get(event.__tile.tilesetUid);
			display = new ZImage();
			this.addChild(display);
			display.dataProvider = project.assets.getBitmapData(tilesetId + ":" + event.__tile.srcRect[0] + "x" + event.__tile.srcRect[1]);
			switch (event.__pivot[0]) {
				case 0.5:
					display.hAlign = "center";
				case 1:
					display.hAlign = "right";
				case 0:
					display.hAlign = "left";
			}
			switch (event.__pivot[1]) {
				case 0.5:
					display.vAlign = "center";
				case 1:
					display.vAlign = "bottom";
				case 0:
					display.vAlign = "top";
			}
			display.width = event.width;
			display.height = event.height;
			display.smoothing = false;
		}
		this.width = event.width;
		this.height = event.height;
	}
}
