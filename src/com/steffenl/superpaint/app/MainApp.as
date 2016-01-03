package com.steffenl.superpaint.app {
import com.steffenl.superpaint.app.screens.*;
import com.steffenl.superpaint.app.themes.AppTheme;
import com.steffenl.superpaint.app.views.*;

import feathers.controls.*;
import feathers.core.Application;

import starling.events.Event;

/*import robotlegs.bender.extensions.contextView.ContextView;
import robotlegs.bender.extensions.contextView.ContextViewExtension;

import robotlegs.bender.framework.impl.Context;
*/

public class MainApp extends Application {
    private var _navigator:StackScreenNavigator;

    //private var _context:Context;

    public function MainApp() {
        // Apply our custom theme
        new AppTheme();
        super();
        //_context = new Context();
        //_context.configure(AppConfig);
    }

    protected override function initialize():void {
        _navigator = new StackScreenNavigator();
        addChild(_navigator);
        addScreens();
    }

    private function addScreens():void {
        var homeNavItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HomeScreenView);
        homeNavItem.setScreenIDForPushEvent(ScreenPushEvent.WORKSPACE, WorkspaceScreen.ID);
        homeNavItem.setScreenIDForPushEvent(ScreenPushEvent.LOCAL_DOCUMENT_STORE, LocalDocumentStoreScreen.ID);
        homeNavItem.setScreenIDForPushEvent(ScreenPushEvent.REMOTE_DOCUMENT_STORE, RemoteDocumentStoreScreen.ID);
        _navigator.addScreen(HomeScreen.ID, homeNavItem);

        var workspaceNavItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(WorkspaceScreenView);
        workspaceNavItem.addPopEvent(Event.CANCEL);
        _navigator.addScreen(WorkspaceScreen.ID, workspaceNavItem);

        var localDocumentStoreNavItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(LocalDocumentStoreScreenView);
        localDocumentStoreNavItem.setFunctionForPushEvent(Event.COMPLETE, localDocumentStore_complete);
        localDocumentStoreNavItem.addPopEvent(Event.CANCEL);
        _navigator.addScreen(LocalDocumentStoreScreen.ID, localDocumentStoreNavItem);

        var remoteDocumentStoreNavItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(RemoteDocumentStoreScreenView);
        remoteDocumentStoreNavItem.setFunctionForPushEvent(Event.COMPLETE, remoteDocumentStore_complete);
        remoteDocumentStoreNavItem.addPopEvent(Event.CANCEL);
        _navigator.addScreen(RemoteDocumentStoreScreen.ID, remoteDocumentStoreNavItem);

        _navigator.rootScreenID = HomeScreen.ID;
    }

    private function localDocumentStore_complete(event:Event):void {
        const documentStoreScreen:LocalDocumentStoreScreen = LocalDocumentStoreScreen(event.currentTarget);
        const workspaceScreen:WorkspaceScreen = WorkspaceScreen(_navigator.replaceScreen(ScreenPushEvent.WORKSPACE));
        workspaceScreen.loadDocument(documentStoreScreen.selectedImageUri);
    }

    private function remoteDocumentStore_complete(event:Event):void {
        const documentStoreScreen:RemoteDocumentStoreScreen = RemoteDocumentStoreScreen(event.currentTarget);
        const workspaceScreen:WorkspaceScreen = WorkspaceScreen(_navigator.replaceScreen(ScreenPushEvent.WORKSPACE));
        workspaceScreen.loadDocument(documentStoreScreen.selectedImageUri);
    }
}
}
