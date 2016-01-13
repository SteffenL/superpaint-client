// TODO: If needed, fix issue with tool selection list where clicking on an item (without dragging/scrolling)
// prevents the UI from updating the selection. This can be seen in the emulator, at least.
// The issue may be that the list is closed before the animation finishes.

package com.steffenl.superpaint.app.screens {

import com.steffenl.superpaint.app.controls.drawingboard.DrawingBoard;
import com.steffenl.superpaint.app.controls.toolstyle.PopupPaintStylePicker;
import com.steffenl.superpaint.app.controls.SpButton;
import com.steffenl.superpaint.core.document.DocumentState;
import com.steffenl.superpaint.core.document.DocumentStateManager;
import com.steffenl.superpaint.core.painting.algorithm.LinearLineAlgorithms;
import com.steffenl.superpaint.core.painting.detail.PaintStyles;
import com.steffenl.superpaint.core.painting.IToolManager;
import com.steffenl.superpaint.core.painting.detail.ToolManager;
import com.steffenl.superpaint.core.painting.tools.ITool;
import com.steffenl.superpaint.core.painting.tools.detail.PencilTool;
import com.steffenl.superpaint.core.painting.tools.detail.ToolFactory;

import feathers.controls.*;
import feathers.controls.popups.DropDownPopUpContentManager;
import feathers.core.IFeathersControl;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.Loader;
import flash.events.Event;

import flash.geom.*;
import flash.net.URLRequest;

import starling.display.DisplayObject;
import starling.display.Quad;

import starling.events.Event;

public class WorkspaceScreen extends PanelScreen {
    public static const ID:String = "workspace";

    public var drawingBoardContainerLayoutGroup:LayoutGroup;
    public var statusBarLayoutGroup:LayoutGroup;
    public var pointerHoverPositionLabel:Label;
    public var pointerTouchPositionLabel:Label;

    private static const INITIAL_TOOL_ID:String = PencilTool.ID;

    private var _drawingBoard:DrawingBoard;
    private var _activeToolPickerList:PickerList;

    private var _toolManager:IToolManager = new ToolManager();
    private var _availableToolsList:ListCollection = new ListCollection();
    private var _availableToolsListIndices:Object = new Object();
    private var _availableToolsListIndicesToId:Object = new Object();
    private var _documentStateManager:DocumentStateManager = new DocumentStateManager();

    private static const INITIAL_STROKE_WIDTH:Number = 1.0;
    private static const INITIAL_STROKE_COLOR:Number = 0;
    private static const INITIAL_STROKE_ALPHA:Number = 0xff;
    private var _paintStyles:PaintStyles = new PaintStyles();
    private var _lastPosition:Point;

    public function WorkspaceScreen() {
        _paintStyles.strokeWidth = INITIAL_STROKE_WIDTH;
        _paintStyles.strokeColor = INITIAL_STROKE_COLOR;
        _paintStyles.strokeAlpha = INITIAL_STROKE_ALPHA;

        // The document state manager provides the state we are going to load
        _documentStateManager.onStateChanged.add(function(state:DocumentState):void {
            _loadDocumentState(state);
        });
    }

    /**
     * Loads a remote or local document.
     * @param uri
     */
    public function loadDocument(uri:String):void {
        destroyDrawingBoard();

        // TODO: Decouple this
        const loader:flash.display.Loader = new flash.display.Loader();
        loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, function(event:flash.events.Event):void {
            const bitmap:Bitmap = Bitmap(loader.content);
            createAndSetupDrawingBoard(bitmap.bitmapData);
        });
        loader.load(new URLRequest(uri));
    }

    /**
     * Creates a new (blank) document and loads it.
     */
    public function createNewDocument():void {
        destroyDrawingBoard();
        const bitmapData:BitmapData = DrawingBoard.createBlankBitmapData();
        createAndSetupDrawingBoard(bitmapData);
    }

    /**
     * Creates a new drawing board and sets it up.
     * @param bitmapData
     */
    private function createAndSetupDrawingBoard(bitmapData:BitmapData):void {
        var drawingBoard:DrawingBoard = createDrawingBoard();
        drawingBoard.width = drawingBoardContainerLayoutGroup.width;
        drawingBoard.height = drawingBoardContainerLayoutGroup.height;
        drawingBoardContainerLayoutGroup.addChild(drawingBoard);

        // Load the specified bitmap data when the drawing board is ready for it
        if (bitmapData) {
            const listener:Function = function():void {
                drawingBoard.onReady.remove(listener);
                drawingBoard.loadBitmapData(bitmapData);
                // Make sure to dispose the temporary bitmap data
                bitmapData.dispose();
                _recordDocumentState(drawingBoard.capture());
            };

            drawingBoard.onReady.add(listener);
        }

        _drawingBoard = drawingBoard;
    }

    /**
     * Destroys the current instance of the drawing board.
     */
    private function destroyDrawingBoard():void {
        if (_drawingBoard) {
            drawingBoardContainerLayoutGroup.removeChild(_drawingBoard, true);
            _drawingBoard = null;
        }
    }

    protected override function initialize():void {
        super.initialize();

        title = "Workspace";

        backButtonHandler = function():void {
            dispatchEventWith(starling.events.Event.CANCEL);
        };

        menuButtonHandler = function():void {
        };


        setupLayout();
        setupSignalHandlers();

        // Do tool registration
        _toolManager.registerTools(new ToolFactory());

        addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
    }

    /**
     * Setup the UI layout, create controls and such.
     */
    private function setupLayout():void {
        var drawingBoardLayoutData:AnchorLayoutData = new AnchorLayoutData(0, 0, 0, 0);
        drawingBoardLayoutData.bottomAnchorDisplayObject = statusBarLayoutGroup;
        drawingBoardContainerLayoutGroup.layoutData = drawingBoardLayoutData;
        addChild(drawingBoardContainerLayoutGroup);

        var statusBarLayoutData:AnchorLayoutData = new AnchorLayoutData(NaN, 0, 0, 0);
        statusBarLayoutGroup.layoutData = statusBarLayoutData;



        headerFactory = function():IFeathersControl {
            var header:Header = new Header();
            header.leftItems = new <DisplayObject>[];
            header.centerItems = new <DisplayObject>[];
            header.rightItems = new <DisplayObject>[];
            header.styleNameList.add(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR);


            var closeButton:Button = new Button();
            closeButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON);
            closeButton.label = "Close";
            closeButton.addEventListener(starling.events.Event.TRIGGERED, function(event:starling.events.Event):void {
                backButtonHandler();
            });
            header.leftItems.push(closeButton);


            var undoButton:Button = new Button();
            undoButton.addEventListener(starling.events.Event.TRIGGERED, undoButton_triggeredHandler);
            undoButton.label = "Undo";
            undoButton.isEnabled = false;
            header.centerItems.push(undoButton);
            _documentStateManager.onStateChanged.add(function(state:DocumentState):void {
                undoButton.isEnabled = _documentStateManager.hasPast();
            });

            var redoButton:Button = new Button();
            redoButton.addEventListener(starling.events.Event.TRIGGERED, redoButton_triggeredHandler);
            redoButton.label = "Redo";
            redoButton.isEnabled = false;
            header.centerItems.push(redoButton);
            _documentStateManager.onStateChanged.add(function(state:DocumentState):void {
                redoButton.isEnabled = _documentStateManager.hasFuture();
            });


            var saveButton:Button = new Button();
            saveButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON);
            saveButton.label = "Save";
            saveButton.isEnabled = false;
            header.rightItems.push(saveButton);


            return header;
        };

        footerFactory = function():LayoutGroup {
            var footer:LayoutGroup = new LayoutGroup();
            footer.styleNameList.add(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR);

            setupToolbar(footer);

            return footer;
        };
    }

    /**
     * Create and setup the toolbar.
     * @param container Parent of the toolbar.
     */
    private function setupToolbar(container:LayoutGroup):void {
        // TODO: Fix broken selection in the tool list
        const popupContentManager:DropDownPopUpContentManager = new DropDownPopUpContentManager();
        _activeToolPickerList = new PickerList();
        _activeToolPickerList.popUpContentManager = popupContentManager;
        _activeToolPickerList.dataProvider = _availableToolsList;
        _activeToolPickerList.listProperties.@itemRendererProperties.labelField = "text";
        _activeToolPickerList.labelField = "text";
        _activeToolPickerList.addEventListener(starling.events.Event.CHANGE, activeToolPickerList_changeHandler);
        container.addChild(_activeToolPickerList);

        const toolStyleButton:Button = new Button();
        toolStyleButton.label = "Style";
        toolStyleButton.addEventListener(starling.events.Event.TRIGGERED, toolStyleButton_triggeredHandler);
        container.addChild(toolStyleButton);
    }

    /**
     * Sets up signals handlers for various things.
     */
    private function setupSignalHandlers():void {
        _toolManager.signals().toolAdded.add(toolAddedHandler);
        _toolManager.signals().activeToolChanged.add(activeToolChangedHandler);
    }

    /**
     * A tool has been added, and should be reflected in the UI.
     * @param tool
     */
    private function toolAddedHandler(tool:ITool):void {
        const index:int = _availableToolsList.length;
        _availableToolsList.push({ id: tool.getId(), text: tool.getDisplayName() });
        _availableToolsListIndices[tool.getId()] = index;
        _availableToolsListIndicesToId[index] = tool.getId();
    }

    /**
     * The active tool changed, and should be reflected in the UI.
     * @param tool
     * @param oldTool
     */
    private function activeToolChangedHandler(tool:ITool, oldTool:ITool):void {
        // TODO: Check whether this can happen, and whether there is a better method to change the selection without
        // dispatching a new selection event.
        //var currentIndex:int = activeToolPickerList.selectedIndex;
        var newIndex:int = _availableToolsListIndices[tool.getId()];
        /*if (newIndex === currentIndex) {
            return;
        }*/

        _activeToolPickerList.selectedIndex = newIndex;
    }

    private function drawingBoardTouchBeganHandler(position:Point, pressure:Number):void {
        var tool:ITool = _toolManager.getActiveTool();
        if (!tool) {
            return;
        }

        _lastPosition = position;
        tool.beginAction(position, _drawingBoard.nativeCanvas, _paintStyles);
    }

    private function drawingBoardTouchMovedHandler(position:Point, pressure:Number):void {
        var tool:ITool = _toolManager.getActiveTool();
        if (!tool) {
            return;
        }

        pointerTouchPositionLabel.text = format2dPoint(position);

        var batchPositions:Vector.<Point> = new <Point>[];
        LinearLineAlgorithms.line1(_lastPosition.x, _lastPosition.y, position.x, position.y, function(x:int, y:int):void {
            batchPositions.push(new Point(x, y));
        });

        // TODO: Optimize that we don't do too much work here causing bad performance while drawing
        for each (var position:Point in batchPositions) {
            tool.updateAction(position, _drawingBoard.nativeCanvas, _paintStyles);
        }

        _lastPosition = position;
    }

    private function drawingBoardTouchEndedHandler(position:Point, pressure:Number):void {
        var tool:ITool = _toolManager.getActiveTool();
        if (!tool) {
            return;
        }

        pointerTouchPositionLabel.text = "";
        pointerHoverPositionLabel.text = format2dPoint(position);
        tool.endAction(position, _drawingBoard.nativeCanvas, _paintStyles);

        _recordCurrentDocumentState();
    }

    private function drawingBoardTouchHoverHandler(position:Point):void {
        pointerHoverPositionLabel.text = format2dPoint(position);
    }

    private function toolStyleButton_triggeredHandler(event:starling.events.Event):void {
        var picker:PopupPaintStylePicker = new PopupPaintStylePicker(_paintStyles);
        picker.show(Button(event.currentTarget));
    }

    private function format2dPoint(pt:Point):String {
        return pt.x + "x" + pt.y;
    }

    private function activeToolPickerList_changeHandler(event:starling.events.Event):void {
        var pickerList:PickerList = PickerList(event.currentTarget);
        if (pickerList.selectedIndex === -1) {
            return;
        }

        var id:String = _availableToolsListIndicesToId[pickerList.selectedIndex];
        _toolManager.setActiveTool(id);
    }

    /**
     * Creates a new drawing board.
     * @return The new drawing board.
     */
    private function createDrawingBoard():DrawingBoard {
        var drawingBoard:DrawingBoard = new DrawingBoard();
        drawingBoard.onTouchBegan.add(drawingBoardTouchBeganHandler);
        drawingBoard.onTouchMoved.add(drawingBoardTouchMovedHandler);
        drawingBoard.onTouchEnded.add(drawingBoardTouchEndedHandler);
        drawingBoard.onTouchHover.add(drawingBoardTouchHoverHandler);

        return drawingBoard;
    }

    private function creationCompleteHandler(event:starling.events.Event):void {
        _toolManager.setActiveTool(INITIAL_TOOL_ID);
    }

    private function undoButton_triggeredHandler(event:starling.events.Event):void {
        _documentStateManager.stepBackward();
    }

    private function redoButton_triggeredHandler(event:starling.events.Event):void {
        _documentStateManager.stepForward();
    }

    /**
     * Records the current document state into the state manager.
     */
    private function _recordCurrentDocumentState():void {
        // TODO: Decouple stuff
        const bitmapData:BitmapData = _drawingBoard.capture();
        _recordDocumentState(bitmapData);
    }

    /**
     * Records the specified document state into the state manager.
     * @param bitmapData
     */
    private function _recordDocumentState(bitmapData:BitmapData):void {
        // TODO: Decouple stuff
        if (bitmapData) {
            var state:DocumentState = new DocumentState();
            state.bitmapData = bitmapData;
            _documentStateManager.push(state);
        }
    }

    /**
     * Load the specified document state.
     * @param state
     */
    private function _loadDocumentState(state:DocumentState):void {
        _drawingBoard.loadBitmapData(state.bitmapData);
    }
}
}
