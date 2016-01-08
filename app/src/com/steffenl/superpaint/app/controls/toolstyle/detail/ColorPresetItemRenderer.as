package com.steffenl.superpaint.app.controls.toolstyle.detail {
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.core.FeathersControl;

import flash.geom.Point;

import starling.display.Quad;

import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * Item rendered for the color preset list.
 * This class has mostly been modified from the gallery example from Feathers.
 */
public class ColorPresetItemRenderer extends FeathersControl implements IListItemRenderer {
    public var fillQuad:Quad;

    private static const HELPER_POINT:Point = new Point();
    private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
    private static const FILL_QUAD_DIMENSIONS:Point = new Point(48, 48);
    private var _data:ColorPresetItem;
    private var _isSelected:Boolean;
    protected var _owner:List;
    private var _factoryID:String;
    private var _index:int = -1;
    protected var touchPointID:int = -1;

    public function ColorPresetItemRenderer() {
        this.isQuickHitAreaEnabled = true;
        this.addEventListener(TouchEvent.TOUCH, touchHandler);
        this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler)
    }

    private function removedFromStageHandler(event:Event):void {
        this.touchPointID = -1;
    }

    private function touchHandler(event:TouchEvent):void {
        var touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
        if (touches.length == 0) {
            return;
        }
        if (this.touchPointID >= 0) {
            var touch:Touch;
            for each(var currentTouch:Touch in touches) {
                if (currentTouch.id == this.touchPointID) {
                    touch = currentTouch;
                    break;
                }
            }
            if (!touch) {
                HELPER_TOUCHES_VECTOR.length = 0;
                return;
            }
            if (touch.phase == TouchPhase.ENDED) {
                this.touchPointID = -1;

                touch.getLocation(this, HELPER_POINT);
                if (this.hitTest(HELPER_POINT, true) != null && !this._isSelected) {
                    this.isSelected = true;
                }
            }
        }
        else {
            for each(touch in touches) {
                if (touch.phase == TouchPhase.BEGAN) {
                    this.touchPointID = touch.id;
                    break;
                }
            }
        }
        HELPER_TOUCHES_VECTOR.length = 0;
    }

    public function get isSelected():Boolean {
        return this._isSelected;
    }

    public function set isSelected(value:Boolean):void {
        if (this._isSelected == value) {
            return;
        }

        this._isSelected = value;
        this.dispatchEventWith(Event.CHANGE);
    }

    public function get data():Object {
        return this._data;
    }

    public function set data(value:Object):void {
        if (this._data == value) {
            return;
        }

        this._data = ColorPresetItem(value);
        this.invalidate(INVALIDATION_FLAG_DATA);
    }

    public function get index():int {
        return this._index;
    }

    public function set index(value:int):void {
        if (this._index == value) {
            return;
        }

        this._index = value;
        this.invalidate(INVALIDATION_FLAG_DATA);
    }

    public function get owner():List {
        return List(this._owner);
    }

    public function set owner(value:List):void {
        if (this._owner == value) {
            return;
        }

        this._owner = value;
        this.invalidate(INVALIDATION_FLAG_DATA);
    }

    public function get factoryID():String {
        return this._factoryID;
    }

    public function set factoryID(value:String):void {
        this._factoryID = value;
    }

    override protected function initialize():void {
        this.fillQuad = new Quad(FILL_QUAD_DIMENSIONS.x, FILL_QUAD_DIMENSIONS.y, 0);
        this.addChild(this.fillQuad);
    }

    override protected function draw():void {
        var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
        var selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
        var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);

        if (dataInvalid) {
            if (this._data) {
                this.fillQuad.color = this._data.color;
            }
        }

        sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
    }

    protected function autoSizeIfNeeded():Boolean {
        var needsWidth:Boolean = isNaN(this.explicitWidth);
        var needsHeight:Boolean = isNaN(this.explicitHeight);
        if (!needsWidth && !needsHeight) {
            return false;
        }

        var newWidth:Number = this.explicitWidth;
        if (needsWidth) {
            newWidth = FILL_QUAD_DIMENSIONS.x;
        }

        var newHeight:Number = this.explicitHeight;
        if (needsHeight) {
            newHeight = FILL_QUAD_DIMENSIONS.y;
        }

        return this.setSizeInternal(newWidth, newHeight, false);
    }
}
}
