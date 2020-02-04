import { DeviceEventEmitter, NativeEventEmitter, NativeModules, Platform } from "react-native";

const {JDOSS} = NativeModules;

let subscription;

//default configuration for OSS Client
const conf = {
    maxRetryCount: 3,
    timeoutIntervalForRequest: 30,
    timeoutIntervalForResource: 24 * 60 * 60
};

export default JdOss = {

    //Enable dev mode
    enableDevMode() {
        JDOSS.enableDevMode();
    },

    /**
     * Initialize the OSS Client
     * Mode: PlainTextAKSK
     */
    initWithPlainTextAccessKey(accessKey, secretKey, endPoint, configuration = conf) {
        JDOSS.initWithPlainTextAccessKey(accessKey, secretKey, endPoint, configuration);
    },

    /**
     * Initialize the OSS Client
     * Mode: SecurityToken (STS)
     */
    initWithSecurityToken(securityToken, accessKey, secretKey, endPoint, configuration = conf) {
        JDOSS.initWithSecurityToken(securityToken, accessKey, secretKey, endPoint, configuration);
    },

    /**
     * Asynchronously uploading
     */
    upload(bucketName, objectKey, filepath, options) {
        return JDOSS.upload(bucketName, objectKey, filepath, options);
    },

    /**
     * event listener for native upload/download event
     * @param event one of 'uploadProgress' or 'downloadProgress'
     * @param callback a callback function accepts one params: event
     */
    addEventListener(event, callback) {
        const RNAliyunEmitter = Platform.OS === 'ios' ? new NativeEventEmitter(JDOSS) : DeviceEventEmitter;
        switch (event) {
            case 'uploadProgress':
                subscription = RNAliyunEmitter.addListener(
                    'uploadProgress',
                    e => callback(e)
                );
                break;
            case 'downloadProgress':
                subscription = RNAliyunEmitter.addListener(
                    'downloadProgress',
                    e => callback(e)
                );
                break;
            default:
                break;
        }
    },

    /**
     * remove event listener for native upload/download event
     * @param event one of 'uploadProgress' or 'downloadProgress'
     */
    removeEventListener(event) {
        switch (event) {
            case 'uploadProgress':
                subscription.remove();
                break;
            case 'downloadProgress':
                subscription.remove();
                break;
            default:
                break;
        }
    }
};