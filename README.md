# 京东云对象存储 SDK for React Native

## 简介

本文档主要介绍京东云OSS React Native SDK的安装和使用。本文档假设您已经开通了京东云OSS服务，并创建了Access Key ID 和Access Key Secret。文中的ID 指的是Access Key ID，KEY 指的是Access Key Secret。如果您还没有开通或者还不了解OSS，请登录[OSS产品主页](https://www.jdcloud.com/cn/products/object-storage-service)获取更多的帮助。

## 安装

* yarn

```script
yarn install https://github.com/hecom-rn/react-native-jdcloud-oss.git
```

### 手动安装

#### iOS

- **CocoaPods**
```
pod 'react-native-jdcloud-oss', :path => '../node_modules/react-native-jdcloud-oss'
````

#### Android
1. `settings.gradle`
    ```gradle
    include ':react-native-jdcloud-oss'
    project(':react-native-jdcloud-osss').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-jdcloud-oss/android')
    ```
2. `build.gradle`
    ```gradle
    dependencies {
        implementation project(':react-native-jdcloud-oss')
    }
    ```

3. `MainApplication.java`
    ```java
   import com.hecom.jdcloud.RNOssPackage;

    public class MainApplication extends Application implements ReactApplication {
     @Override
       protected List<ReactPackage> getPackages() {
         return Arrays.<ReactPackage>asList(
             new MainReactPackage(),
             new RNOssPackage()
         );
       }
    }
    ```

## License

* MIT