package com.steffenl.superpaint.app.screens {
import com.steffenl.superpaint.core.document.detail.RemoteDocumentStore;

public class RemoteDocumentStoreScreen extends DocumentStoreScreenBase {
    public static const ID:String = "remoteDocumentStore";

    public function RemoteDocumentStoreScreen() {
        super(new RemoteDocumentStore(RemoteDocumentStore.API_URL));
    }

    protected override function initialize():void {
        super.initialize();

        title = "Online gallery";
    }
}
}
