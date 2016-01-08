package com.steffenl.superpaint.app.screens {
import com.steffenl.superpaint.core.document.detail.RemoteDocumentStore;
import com.steffenl.superpaint.server.documentstore.DocumentStoreApi;

public class RemoteDocumentStoreScreen extends DocumentStoreScreenBase {
    public static const ID:String = "remoteDocumentStore";

    public function RemoteDocumentStoreScreen() {
        super(new RemoteDocumentStore(new DocumentStoreApi()));
    }

    protected override function initialize():void {
        super.initialize();

        title = "Online gallery";
    }
}
}
