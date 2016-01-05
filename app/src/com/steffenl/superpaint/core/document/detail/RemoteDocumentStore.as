package com.steffenl.superpaint.core.document.detail {
import com.steffenl.superpaint.core.document.*;

import flash.events.Event;

import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;

// TODO: Decouple stuff
public class RemoteDocumentStore implements IDocumentStore {
    private const _signals:DocumentStoreSignals = new DocumentStoreSignals();
    private var _storePath:String;
    private var _documentUrlLoader:URLLoader = new URLLoader();

    public static const API_URL:String = "http://192.168.0.173/";

    public function RemoteDocumentStore(apiUrl:String) {
        _storePath = apiUrl + "documents/";
        _documentUrlLoader.addEventListener(Event.COMPLETE, documentUrlLoader_completeHandler);
        _documentUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, documentUrlLoader_ioErrorHandler);
        _documentUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, documentUrlLoader_securityErrorHandler);
    }

    public function signals():DocumentStoreSignals {
        return _signals;
    }

    public function getListing():void {
        _documentUrlLoader.load(new URLRequest(_storePath));
    }

    private function documentUrlLoader_completeHandler(event:Event):void {
        const responseItems:Array = JSON.parse(_documentUrlLoader.data) as Array;

        var entries:Vector.<IDocumentStoreEntry> = new <IDocumentStoreEntry>[];
        for each (var f:Object in responseItems) {
            entries.push(new LocalDocumentStoreEntry(f.fullUrl));
        }

        _signals.listingReady.dispatch(entries);
    }

    private function documentUrlLoader_ioErrorHandler(event:IOErrorEvent):void {
        _signals.listingError.dispatch(event.text);
    }

    private function documentUrlLoader_securityErrorHandler(event:SecurityErrorEvent):void {
        _signals.listingError.dispatch(event.text);
    }
}
}
