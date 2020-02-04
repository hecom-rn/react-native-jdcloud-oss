package com.hecom.jdcloud;

import android.content.Context;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.SDKGlobalConfiguration;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.SignerFactory;
import com.amazonaws.internal.StaticCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.S3ClientOptions;
import com.facebook.react.bridge.ReadableMap;
import com.hecom.jdcloud.utils.ConfigUtils;
import com.hecom.jdcloud.utils.JdAWSS3V4Signer;

public class OssAuthManager {
    private AmazonS3Client mClient;
    private Context mContext;
    private AuthListener mAuthListener;

    /**
     * OssAuthManager constructor
     * @param context
     * @param listener
     */
    public OssAuthManager(Context context, AuthListener listener) {
        mContext = context;
        mAuthListener = listener;
    }

    /**
     * inteface AuthListener
     */
    public interface AuthListener {
        void onAuthFinished(AmazonS3Client oss);
    }

    /**
     * initWithPlainTextAccessKey
     * @param accessKeyId
     * @param accessKeySecret
     * @param endPoint
     * @param configuration
     */
    public void initWithPlainTextAccessKey(String accessKeyId,
                                           String accessKeySecret,
                                           String endPoint,
                                           ReadableMap configuration) {
        SignerFactory.registerSigner("JdAWSS3V4Signer", JdAWSS3V4Signer.class);
        System.setProperty(SDKGlobalConfiguration.ENABLE_S3_SIGV4_SYSTEM_PROPERTY, "true");
        ClientConfiguration config = ConfigUtils.initAuthConfig(configuration);
        config.setSignerOverride("JdAWSS3V4Signer");
        BasicAWSCredentials credentials = new BasicAWSCredentials(accessKeyId, accessKeySecret);
        StaticCredentialsProvider credProvider = new StaticCredentialsProvider(credentials);

        mClient = new AmazonS3Client(credProvider, config);
        mClient.setEndpoint(endPoint);
        S3ClientOptions options = S3ClientOptions.builder()
                .disableChunkedEncoding()
                .setPayloadSigningEnabled(true)
                .build();
        mClient.setS3ClientOptions(options);

        // init conf
        mAuthListener.onAuthFinished(mClient);
    }

    /**
     * initWithPlainTextAccessKey
     * @param securityToken
     * @param accessKeyId
     * @param accessKeySecret
     * @param endPoint
     * @param configuration
     */
    public void initWithSecurityToken(String securityToken,
                                      String accessKeyId,
                                      String accessKeySecret,
                                      String endPoint,
                                      ReadableMap configuration) {
        initWithPlainTextAccessKey(accessKeyId, accessKeySecret, endPoint, configuration);
    }
}
