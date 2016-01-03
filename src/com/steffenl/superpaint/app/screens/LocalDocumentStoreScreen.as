package com.steffenl.superpaint.app.screens {

import com.steffenl.superpaint.core.document.detail.LocalDocumentStore;

public class LocalDocumentStoreScreen extends DocumentStoreScreenBase {
    public static const ID:String = "localDocumentStore";

    private static const RELATIVE_DOCUMENT_STORE_DIR:String = "documents";

    public function LocalDocumentStoreScreen() {
        super(new LocalDocumentStore(RELATIVE_DOCUMENT_STORE_DIR));
    }

    protected override function initialize():void {
        super.initialize();

        title = "Local drawings";
    }
}
}
