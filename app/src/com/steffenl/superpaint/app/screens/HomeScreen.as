package com.steffenl.superpaint.app.screens {

import com.steffenl.superpaint.app.ScreenPushEvent;

import feathers.controls.*;
import feathers.controls.StackScreenNavigator;

import starling.events.Event;

public class HomeScreen extends Screen {
    public static const ID:String = "home";

    public var newDrawingButton:Button;
    public var storedDrawingsButton:Button;
    public var onlineGalleryButton:Button;

    protected override function initialize():void {
        super.initialize();

        newDrawingButton.addEventListener(Event.TRIGGERED, newDrawingButton_triggeredHandler);
        storedDrawingsButton.addEventListener(Event.TRIGGERED, storedDrawingsButton_triggeredHandler);
        onlineGalleryButton.addEventListener(Event.TRIGGERED, onlineGalleryButton_triggeredHandler);
    }

    private function newDrawingButton_triggeredHandler(event:Event):void {
        var navigator:StackScreenNavigator = StackScreenNavigator(owner);
        var screen:WorkspaceScreen = WorkspaceScreen(navigator.pushScreen(ScreenPushEvent.WORKSPACE));
        screen.createNewDocument();
    }

    private function storedDrawingsButton_triggeredHandler(event:Event):void {
        dispatchEventWith(ScreenPushEvent.LOCAL_DOCUMENT_STORE);
    }

    private function onlineGalleryButton_triggeredHandler(event:Event):void {
        dispatchEventWith(ScreenPushEvent.REMOTE_DOCUMENT_STORE);

    }
}
}
