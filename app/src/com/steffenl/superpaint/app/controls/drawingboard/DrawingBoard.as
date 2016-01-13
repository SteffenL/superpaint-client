package com.steffenl.superpaint.app.controls.drawingboard {

import feathers.controls.LayoutGroup;
import feathers.core.FeathersControl;
import feathers.events.FeathersEventType;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.TimerEvent;


import flash.geom.*;
import flash.utils.Timer;

import org.osflash.signals.Signal;

import starling.display.Image;
import starling.display.Quad;

import starling.events.*;
import starling.textures.Texture;

/**
 * The drawing board wraps the components and behaviors needed by the canvas.
 */
public class DrawingBoard extends FeathersControl {
    // Dispatched when the canvas has been touched.
    public const onTouchBegan:Signal = new Signal(Point, Number);
    // Dispatched when the canvas is being touched and the "cursor" is moving.
    public const onTouchMoved:Signal = new Signal(Point, Number);
    // Dispatched when the canvas is no longer being touched.
    public const onTouchEnded:Signal = new Signal(Point, Number);
    // Dispatched when the "cursor" is hovering/moving on (not touching) the canvas.
    public const onTouchHover:Signal = new Signal(Point);
    // Dispatched when the UI has been created.
    public const onReady:Signal = new Signal();

    // Easy access to the canvas (shape) for tools and such to manipulate the canvas.
    public function get nativeCanvas():Shape {
        return _nativeCanvas;
    }

    public static const DEFAULT_CANVAS_REAL_SIZE:Point = new Point(1280, 720);
    private static const CANVAS_BACKGROUND_COLOR:uint = 0xffffff;

    // The rasterized graphics of the canvas; should be updated when the canvas changes.
    private var _bitmapData:BitmapData;
    // The internal canvas itself, where vector graphics added; should be rasterized when changed.
    private var _nativeCanvas:Shape;
    // The current panning offset.
    private var _canvasPosition:Point = new Point(0, 0);
    // The real/full size of the canvas even when scaled.
    private var _canvasRealSize:Point = DEFAULT_CANVAS_REAL_SIZE;
    // Indicates whether we are currently handling panning.
    private var _pan:Boolean = false;
    // The current touch position relative to the canvas' position (possibly out of bounds).
    private var _touchPosition:Point;
    // The last touch position relative to the canvas' position (possibly out of bounds).
    private var _lastTouchPosition:Point;
    // Persistent texture for rendering the rasterized canvas.
    private var _texture:Texture;
    // Visible canvas presented to the user.
    private var _canvasDisplayImage:Image;
    // Indicates whether the render texture is invalid and must be updated. It is invalid after the canvas has been changed and rasterized.
    private var _textureIsInvalid:Boolean = false;
    // Timer to update the render texture when needed.
    private const _textureUpdaterTimer:Timer = new Timer(10, 0);
    // A container for the canvas and other things that should be positioned relative to the canvas.
    private var _canvasContainer:LayoutGroup = new LayoutGroup();
    private var _hasLoadedBitmapDataOnce:Boolean = false;


    /**
     * Loads bitmap data to be used for with the canvas. The bitmap data will be cloned and managed internally.
     * @param bitmapData
     */
    public function loadBitmapData(bitmapData:BitmapData):void {
        if (_bitmapData) {
            _bitmapData.dispose();
        }

        _bitmapData = bitmapData.clone();

        const texture:Texture = Texture.fromBitmapData(_bitmapData, false);
        if (_texture) {
            _texture.dispose();
        }

        _texture = texture;
        _canvasRealSize = new Point(_bitmapData.width, _bitmapData.height);

        _nativeCanvas = new Shape();
        _nativeCanvas.width = _canvasRealSize.x;
        _nativeCanvas.height = _canvasRealSize.y;

        _canvasContainer.removeChildren(0, _canvasContainer.numChildren -1, true);
        _canvasContainer.width = _canvasRealSize.x;
        _canvasContainer.height = _canvasRealSize.y;

        if (_canvasDisplayImage) {
            _canvasDisplayImage.dispose();
        }

        _canvasDisplayImage = new Image(_texture);
        _canvasDisplayImage.width = _canvasRealSize.x;
        _canvasDisplayImage.height = _canvasRealSize.y;
        _canvasContainer.addChild(_canvasDisplayImage);

        rasterizeCanvasShape();

        // Position the canvas depending on whether the bitmap data is being loaded for the first time or simply replacing the current one
        if (_hasLoadedBitmapDataOnce) {
            setCanvasPosition(_canvasPosition);
        }
        else {
            centerCanvas();
        }

        _hasLoadedBitmapDataOnce = true;
    }

    /**
     * Creates new, blank bitmap data, which can be loaded and used as the initial bitmap data.
     * @return
     */
    public static function createBlankBitmapData():BitmapData {
        return new BitmapData(DEFAULT_CANVAS_REAL_SIZE.x, DEFAULT_CANVAS_REAL_SIZE.y, true, 0x00ffffff);
    }

    protected override function initialize():void {
        super.initialize();

        addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);

        // Add an invisible background for catching touch events
        const backgroundQuad:Quad = new Quad(stage.stageWidth, stage.stageHeight);
        backgroundQuad.alpha = 0;
        backgroundQuad.addEventListener(TouchEvent.TOUCH, touchHandler);
        addChild(backgroundQuad);

        _canvasContainer.backgroundSkin = new Quad(1, 1, CANVAS_BACKGROUND_COLOR);
        _canvasContainer.addEventListener(TouchEvent.TOUCH, touchHandler);
        addChild(_canvasContainer);
    }

    /**
     * Handles touch-events for the canvas.
     * @param event
     */
    private function touchHandler(event:TouchEvent):void {
        var touches:Vector.<Touch> = new <Touch>[];
        event.getTouches(this, null, touches);

        if (touches.length === 0) {
            return;
        }

        const touch:Touch = touches[0];
        var endPan:Boolean = false;

        // TODO: This does not work for mobile devices since there is usually no CTRL key conveniently available.
        if (event.ctrlKey || touches.length > 1) {
            if (touch.phase === TouchPhase.BEGAN) {
                _pan = true;
            }
            else if (event.ctrlKey && touch.phase === TouchPhase.ENDED) {
                endPan = true;
            }
        }

        // Check whether we should capture input in order to handle panning for the canvas.
        var position:Point;
        if (_pan) {
            if (endPan) {
                _pan = false;
                return;
            }

            position = touch.getLocation(this);

            _lastTouchPosition = _touchPosition;
            _touchPosition = position;

            if (touch.phase === TouchPhase.MOVED) {
                // We are currently panning.

                var offset:Point = new Point(
                        _touchPosition.x - _lastTouchPosition.x,
                        _touchPosition.y - _lastTouchPosition.y
                );

                moveCanvas(offset);
            }
        }
        else {
            // We should handle the user's actions for tools

            position = touch.getLocation(_canvasDisplayImage);

            _lastTouchPosition = _touchPosition;
            _touchPosition = position;

            switch (touch.phase) {
                case TouchPhase.BEGAN:
                    onTouchBegan.dispatch(position, touch.pressure);
                    rasterizeCanvasShape();
                    break;

                case TouchPhase.MOVED:
                    onTouchMoved.dispatch(position, touch.pressure);
                    rasterizeCanvasShape();
                    break;

                case TouchPhase.ENDED:
                    onTouchEnded.dispatch(position, touch.pressure);
                    rasterizeCanvasShape();
                    break;

                case TouchPhase.HOVER:
                    onTouchHover.dispatch(position);
                    break;
            }
        }
    }

    /**
     * Rasterize the vector graphics in our canvas into bitmap data.
     */
    private function rasterizeCanvasShape():void {
        _bitmapData.draw(_nativeCanvas);
        _nativeCanvas.graphics.clear();
        // We should recreate the rendering texture
        _textureIsInvalid = true;
    }

    /**
     * Centers the canvas.
     */
    private function centerCanvas():void {
        const newOffset:Point = new Point((actualWidth - _canvasRealSize.x) / 2, (actualHeight - _canvasRealSize.y) / 2);
        setCanvasPosition(newOffset);
    }

    /**
     * Sets the position of the canvas (relative to its current position).
     * @param offset
     */
    private function moveCanvas(offset:Point):void {
        setCanvasPosition(new Point(_canvasPosition.x + offset.x, _canvasPosition.y + offset.y));
    }

    /**
     * Sets the position of the canvas (relative to 0x0).
     * @param position
     */
    private function setCanvasPosition(position:Point):void {
        _canvasPosition = sanitizeCanvasPosition(position);
        _canvasContainer.x = _canvasPosition.x;
        _canvasContainer.y = _canvasPosition.y;
    }

    /**
     * Makes sure the specified position is valid within the canvas' bounds; otherwise, clip the value.
     * @param position
     * @return The clipped/sanitized position within the canvas' bounds.
     */
    private function sanitizeCanvasPosition(position:Point):Point {
        const center:Point = new Point(actualWidth >> 1, actualHeight >> 1);
        position.x = Math.min(center.x, Math.max(center.x - _canvasRealSize.x, position.x));
        position.y = Math.min(center.y, Math.max(center.y - _canvasRealSize.y, position.y));
        position.x = Math.floor(position.x);
        position.y = Math.floor(position.y);
        return position;
    }

    /**
     * Captures (clones) the current rasterization (bitmap data) of what is currently in the canvas.
     * @return A clone of the current bitmap data.
     */
    public function capture():BitmapData {
        if (!_bitmapData) {
            throw new Error("No bitmap data is loaded");
        }

        return _bitmapData.clone();
    }

    /**
     * Updates the render texture when the canvas has been rasterized.
     * @param event
     */
    private function textureUpdaterTimer_timerHandler(event:TimerEvent):void {
        if (!_textureIsInvalid) {
            return;
        }

        if (_texture) {
            _texture.dispose();
            _texture = null;
        }

        _texture = Texture.fromBitmapData(_bitmapData, false);
        if (_canvasDisplayImage.texture) {
            _canvasDisplayImage.texture.dispose();
        }

        _canvasDisplayImage.texture = _texture;
        _textureIsInvalid = false;
    }

    private function removedFromStageHandler(event:Event):void {
        // If we don't stop the timer when we have been removed from the stage, the timer will keep running.
        if (_textureUpdaterTimer.running) {
            _textureUpdaterTimer.stop();
        }

        stage.removeEventListener(TouchEvent.TOUCH, touchHandler);
    }

    private function creationCompleteHandler(event:Event):void {
        _textureUpdaterTimer.addEventListener(TimerEvent.TIMER, textureUpdaterTimer_timerHandler);
        _textureUpdaterTimer.start();
        onReady.dispatch();
    }
}
}
