package com.hecom.jdcloud.utils;

import com.amazonaws.ClientConfiguration;
import com.facebook.react.bridge.ReadableMap;

public class ConfigUtils {

    /**
     * Auth initAuthConfig
     */
    public static ClientConfiguration initAuthConfig(ReadableMap configuration) {
        ClientConfiguration conf = new ClientConfiguration();
        conf.setConnectionTimeout(configuration.getInt("timeoutIntervalForRequest") * 1000);
        conf.setSocketTimeout(configuration.getInt("timeoutIntervalForRequest") * 1000);
        conf.setMaxErrorRetry(configuration.getInt("maxRetryCount"));
        return conf;
    }
}
