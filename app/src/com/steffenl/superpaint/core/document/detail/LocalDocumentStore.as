package com.steffenl.superpaint.core.document.detail {
import com.steffenl.superpaint.core.document.*;

import flash.events.FileListEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.filesystem.File;

public class LocalDocumentStore implements IDocumentStore {
    private const _signals:DocumentStoreSignals = new DocumentStoreSignals();
    private var _storePath:String;

    public function LocalDocumentStore(path:String) {
        _storePath = path;
    }

    public function signals():DocumentStoreSignals {
        return _signals;
    }

    public function getListing():void {
        const storeUri:String = getDocumentStoreUri();
        const dir:File = new File(storeUri);
        if (!dir.exists) {
            //throw new Error("Document store does not exist: " + storeUri);
            return;
        }

        dir.addEventListener(FileListEvent.DIRECTORY_LISTING, function(event:FileListEvent):void {
            var entries:Vector.<IDocumentStoreEntry> = new <IDocumentStoreEntry>[];

            for each (var f:File in event.files) {
                entries.push(new LocalDocumentStoreEntry(f.url));
            }

            _signals.onListingReady.dispatch(entries);
        });

        dir.getDirectoryListingAsync();
    }

    private function getDocumentStoreUri():String {
        return File.applicationStorageDirectory.resolvePath(_storePath).url;
    }
}
}
