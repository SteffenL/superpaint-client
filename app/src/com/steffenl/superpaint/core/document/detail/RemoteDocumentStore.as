package com.steffenl.superpaint.core.document.detail {
import com.steffenl.superpaint.core.document.*;
import com.steffenl.superpaint.server.documentstore.DocumentStoreApiEntry;
import com.steffenl.superpaint.server.documentstore.IDocumentStoreApi;


public class RemoteDocumentStore implements IDocumentStore {
    private const _signals:DocumentStoreSignals = new DocumentStoreSignals();
    private var _documentStoreApi:IDocumentStoreApi;

    public function RemoteDocumentStore(api:IDocumentStoreApi) {
        _documentStoreApi = api;
        _documentStoreApi.signals().onListingReady.add(listingReadyHandler);
        _documentStoreApi.signals().onListingError.add(listingErrorHandler);
    }

    public function signals():DocumentStoreSignals {
        return _signals;
    }

    public function getListing():void {
        _documentStoreApi.getListing();
    }

    private function listingReadyHandler(entries:Vector.<DocumentStoreApiEntry>):void {
        var newEntries:Vector.<IDocumentStoreEntry> = new <IDocumentStoreEntry>[];
        for each (var f:Object in entries) {
            newEntries.push(new RemoteDocumentStoreEntry(f.path));
        }

        _signals.onListingReady.dispatch(newEntries);
    }

    private function listingErrorHandler(errorText:String):void {
        _signals.onListingError.dispatch(errorText);
    }
}
}
