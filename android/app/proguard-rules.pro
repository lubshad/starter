# Keep rules to silence optional OEM push SDK references from Hyphenate/Agora Chat
# These classes are referenced reflectively for optional integrations on China OEMs.
# We do not include those SDKs, so suppress missing class warnings.
-dontwarn com.heytap.msp.push.HeytapPushManager
-dontwarn com.heytap.msp.push.callback.ICallBackResultService
-dontwarn com.meizu.cloud.pushsdk.PushManager
-dontwarn com.meizu.cloud.pushsdk.util.MzSystemUtils
-dontwarn com.vivo.push.IPushActionListener
-dontwarn com.vivo.push.PushClient
-dontwarn com.vivo.push.PushConfig
-dontwarn com.vivo.push.PushConfig
-dontwarn com.vivo.push.util.VivoPushException
-dontwarn com.xiaomi.mipush.sdk.MiPushClient
# Keep Hyphenate push platform classes to avoid R8 analyzing optional OEM paths
-keep class com.hyphenate.push.** { *; }
-keep class com.hyphenate.chat.** { *; }

# Already suppress warnings for missing OEM SDKs; also suppress entire package just in case
-dontwarn com.vivo.push.**
-dontwarn com.xiaomi.mipush.**
-dontwarn com.heytap.msp.**
-dontwarn com.meizu.cloud.pushsdk.**
