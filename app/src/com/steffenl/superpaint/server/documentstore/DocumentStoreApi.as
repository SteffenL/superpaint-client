package com.steffenl.superpaint.server.documentstore {
import flash.events.Event;

import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;

public class DocumentStoreApi implements IDocumentStoreApi {
    private const _signals:DocumentStoreApiSignals = new DocumentStoreApiSignals();
    private var _storePath:String;
    private var _documentUrlLoader:URLLoader = new URLLoader();

    // TODO: Decouple API URL
    public static const API_URL:String = "https://superpaint-server-staging.herokuapp.com/";

    public function DocumentStoreApi(apiUrl:String = API_URL) {
        _storePath = apiUrl + "documents/";
        _documentUrlLoader.addEventListener(Event.COMPLETE, documentUrlLoader_completeHandler);
        _documentUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, documentUrlLoader_ioErrorHandler);
        _documentUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, documentUrlLoader_securityErrorHandler);
    }

    public function signals():DocumentStoreApiSignals {
        return _signals;
    }

    public function getListing():void {
        _documentUrlLoader.load(new URLRequest(_storePath));
    }

    private function documentUrlLoader_completeHandler(event:Event):void {
        const responseItems:Array = JSON.parse(_documentUrlLoader.data) as Array;

        var entries:Vector.<DocumentStoreApiEntry> = new <DocumentStoreApiEntry>[];
        for each (var f:Object in responseItems) {
            entries.push(new DocumentStoreApiEntry(f.id, f.fullUrl));
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
