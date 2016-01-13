package com.steffenl.superpaint.app.screens {

import com.steffenl.superpaint.app.controls.gallery.GalleryItem;
import com.steffenl.superpaint.app.controls.gallery.GalleryList;
import com.steffenl.superpaint.core.document.IDocumentStoreEntry;
import com.steffenl.superpaint.core.document.IDocumentStore;

import feathers.controls.*;
import feathers.core.IFeathersControl;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;

import starling.display.DisplayObject;

import starling.events.Event;

public class DocumentStoreScreenBase extends PanelScreen {
    public var previewImage:ImageLoader;
    public var galleryList:GalleryList;

    private var _documentStore:IDocumentStore;
    public var selectedImageUri:String;

    public function DocumentStoreScreenBase(documentStore:IDocumentStore) {
        super();

        _documentStore = documentStore;
        _documentStore.signals().onListingReady.add(listingReadyHandler);
        _documentStore.signals().onListingError.add(listingErrorHandler);
    }

    protected override function initialize():void {
        super.initialize();

        backButtonHandler = function():void {
            dispatchEventWith(Event.CANCEL);
        };

        setupLayout();
        updateListing();
    }

    private function setupLayout():void {
        headerFactory = function():IFeathersControl {
            var header:Header = new Header();
            header.leftItems = new <DisplayObject>[];
            header.rightItems = new <DisplayObject>[];
            header.styleNameList.add(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR);


            var backButton:Button = new Button();
            backButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON);
            backButton.label = "Back";
            backButton.addEventListener(Event.TRIGGERED, function(event:Event):void {
                backButtonHandler();
            });
            header.leftItems.push(backButton);


            var editButton:Button = new Button();
            editButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON);
            editButton.label = "Edit";
            editButton.isEnabled = false;
            editButton.addEventListener(Event.TRIGGERED, editButton_triggeredHandler);
            galleryList.addEventListener(Event.CHANGE, function(event:Event):void {
                var list:GalleryList = GalleryList(event.currentTarget);
                var item:GalleryItem = GalleryItem(list.selectedItem);
                editButton.isEnabled = !!item;
            });
            header.rightItems.push(editButton);


            return header;
        };

        var previewImageLayoutData:AnchorLayoutData = new AnchorLayoutData(0, 0, 0, 0);
        previewImageLayoutData.bottomAnchorDisplayObject = galleryList;
        previewImage.layoutData = previewImageLayoutData;

        var listLayoutData:AnchorLayoutData = new AnchorLayoutData(NaN, 0, 0, 0);
        galleryList.layoutData = listLayoutData;
        galleryList.height = 150;
        galleryList.addEventListener(Event.CHANGE, galleryList_changeHandler);
    }

    private function updateListing():void {
        _documentStore.getListing();
    }

    private function galleryList_changeHandler(event:Event):void {
        var list:GalleryList = GalleryList(event.currentTarget);
        var item:GalleryItem = GalleryItem(list.selectedItem);
        if (!item) {
            return;
        }

        selectedImageUri = item.url;
        previewImage.source = item.url;
    }

    private function editButton_triggeredHandler(event:Event):void {
        dispatchEventWith(Event.COMPLETE);
    }

    private function listingReadyHandler(entries:Vector.<IDocumentStoreEntry>):void {
        var items:Vector.<GalleryItem> = new <GalleryItem>[];
        for each (var entry:IDocumentStoreEntry in entries) {
            items.push(new GalleryItem(null, entry.getPath(), entry.getPath()));
        }

        galleryList.dataProvider = new ListCollection(items);
        galleryList.selectedIndex = 0;
    }

    private function listingErrorHandler(text:String):void {
        Alert.show(text, "Error", new ListCollection([
            { label: "OK", triggered: errorAlertOkButton_triggeredHandler }
        ]));
    }

    private function errorAlertOkButton_triggeredHandler():void {
        backButtonHandler();
    }
}
}
