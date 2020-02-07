package com.hecom.jdcloud;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.hecom.jdcloud.utils.FileUtils;

import java.io.File;

public class OssUploadManager {

    private AmazonS3Client mClient;
    private TransferUtility mTransferUtility;

    /**
     * OssUploadManager contructor
     */
    public OssUploadManager(Context context, AmazonS3Client obs) {
        mClient = obs;
        mTransferUtility = TransferUtility.builder()
                .context(context.getApplicationContext())
                .s3Client(mClient)
                .build();
    }

    /**
     * upload
     */
    public void upload(final ReactContext context, String bucketName, final String ossFile, String sourceFile,
                       ReadableMap options, final Promise promise) {
        // Content to file:// start
        Uri selectedVideoUri = Uri.parse(sourceFile);

        // 1. content uri -> file path
        // 2. inputstream -> temp file path
        Cursor cursor = null;
        try {
            String[] proj = {MediaStore.Images.Media.DATA};
            cursor = context.getContentResolver().query(selectedVideoUri, proj, null, null, null);
            if (cursor == null) {
                sourceFile = selectedVideoUri.getPath();
            } else {
                int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                cursor.moveToFirst();
                sourceFile = cursor.getString(column_index);
            }
        } catch (Exception e) {
            sourceFile = FileUtils.getFilePathFromURI(context.getApplicationContext(), selectedVideoUri);
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        // init upload request
        final File source = new File(sourceFile);
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentType("application/octet-stream");
        mTransferUtility.upload(bucketName, ossFile, source, metadata,
                CannedAccessControlList.PublicRead, new TransferListener() {

                    @Override
                    public void onStateChanged(int id, TransferState state) {
                        if (state == TransferState.COMPLETED) {
                            Log.d("PutObject", "UploadSuccess");
                            promise.resolve("UploadSuccess");
                        }
                    }

                    @Override
                    public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                        Log.d("PutObject", "currentSize: " + bytesCurrent + " totalSize: " + bytesTotal);
                        String str_currentSize = Long.toString(bytesCurrent);
                        String str_totalSize = Long.toString(bytesTotal);
                        WritableMap onProgressValueData = Arguments.createMap();
                        onProgressValueData.putString("path", ossFile);
                        onProgressValueData.putString("currentSize", str_currentSize);
                        onProgressValueData.putString("totalSize", str_totalSize);
                        context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                .emit("uploadProgress", onProgressValueData);
                    }

                    @Override
                    public void onError(int id, Exception ex) {
                        ex.printStackTrace();
                        promise.reject(ex);
                    }
                });
    }
}
