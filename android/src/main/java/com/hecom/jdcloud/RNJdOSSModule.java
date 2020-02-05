
package com.hecom.jdcloud;

import android.content.Context;

import com.amazonaws.services.s3.AmazonS3Client;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

public class RNJdOSSModule extends ReactContextBaseJavaModule {

    private AmazonS3Client mClient;
    private OssUploadManager mUploadManager;
    private OssAuthManager mAuth;

    /**
     * RNJdOSSModule constructor
     */
    public RNJdOSSModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        mAuth = new OssAuthManager(reactContext.getApplicationContext(), new OssAuthManager.AuthListener() {
            @Override
            public void onAuthFinished(AmazonS3Client obs) {
                init(reactContext.getApplicationContext(), obs);
            }
        });
    }

    @Override
    public String getName() {
        return "JDOSS";
    }


    /**
     * init oss ReactMethod
     */
    private void init(Context context, AmazonS3Client oss) {
        mClient = oss;
        mUploadManager = new OssUploadManager(context, mClient);
    }

    /**
     * initWithPlainTextAccessKey ReactMethod
     */
    @ReactMethod
    public void initWithPlainTextAccessKey(String accessKeyId, String accessKeySecret, String endPoint,
                                           ReadableMap configuration) {
        mAuth.initWithPlainTextAccessKey(accessKeyId, accessKeySecret, endPoint, configuration);
    }

    /**
     * initWithSecurityToken ReactMethod
     */
    @ReactMethod
    public void initWithSecurityToken(String securityToken, String accessKeyId, String accessKeySecret,
                                      String endPoint, ReadableMap configuration) {
        mAuth.initWithSecurityToken(securityToken, accessKeyId, accessKeySecret, endPoint, configuration);
    }

    /**
     * async Upload ReactMethod
     */
    @ReactMethod
    public void upload(String bucketName, String ossFile, String sourceFile, ReadableMap options,
                       final Promise promise) {
        mUploadManager.upload(getReactApplicationContext(), bucketName, ossFile, sourceFile, options, promise);
    }
}