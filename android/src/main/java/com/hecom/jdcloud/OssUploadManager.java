package com.hecom.jdcloud;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import com.amazonaws.event.ProgressEvent;
import com.amazonaws.event.ProgressListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
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
                .context(context)
                .s3Client(obs)
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
        PutObjectRequest put = new PutObjectRequest(bucketName, ossFile, source);
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentType("application/octet-stream");
        put.setMetadata(metadata);

        // set callback
        put.setGeneralProgressListener(new ProgressListener() {
            @Override
            public void progressChanged(ProgressEvent progressEvent) {
                long currentSize = progressEvent.getBytesTransferred();
                long totalSize = source.length();
                Log.d("PutObject", "currentSize: " + currentSize + " totalSize: " + totalSize);
                String str_currentSize = Long.toString(currentSize);
                String str_totalSize = Long.toString(totalSize);
                WritableMap onProgressValueData = Arguments.createMap();
                onProgressValueData.putString("path", ossFile);
                onProgressValueData.putString("currentSize", str_currentSize);
                onProgressValueData.putString("totalSize", str_totalSize);
                context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("uploadProgress", onProgressValueData);
            }
        });
        try {
            PutObjectResult result = mClient.putObject(put);
            Log.d("PutObject", "UploadSuccess");
            Log.d("ETag", result.getETag());
            promise.resolve("UploadSuccess");
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject(e);
        }
        Log.d("AliyunOSS", "OSS uploadObjectAsync ok!");
    }
}
