// android/app/src/main/java/com/example/clarity_break/BootReceiver.java
package com.chagall04.claritybreak.clarity_break;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;

public class BootReceiver extends BroadcastReceiver {
    private static final String CHANNEL = "clarity_break/boot";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Log.d("BootReceiver", "Boot completed, scheduling reminders");
            FlutterEngine engine = new FlutterEngine(context);
            engine.getDartExecutor().executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
            );
            new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                    .invokeMethod("onBootCompleted", null);
        }
    }
}
