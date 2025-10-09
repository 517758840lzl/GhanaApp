package com.juliusgithaiga.flutter_sms_inbox;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.List;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;

public class SmsQuery implements MethodChannel.MethodCallHandler {

    private final Context applicationContext;

    SmsQuery(Context applicationContext) {
        this.applicationContext = applicationContext;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        int start = 0;
        int count = -1;
        int threadId = -1;
        String address = null;
        List<String> sendList = null;
        List<String> contentList = null;
        SmsQueryRequest request;
        switch (call.method) {
            case "getInbox":
                request = SmsQueryRequest.Inbox;
                break;
            case "getSent":
                request = SmsQueryRequest.Sent;
                break;
            case "getDraft":
                request = SmsQueryRequest.Draft;
                break;
            default:
                result.notImplemented();
                return;
        }

        if (call.hasArgument("start")) {
            start = call.argument("start");
        }
        if (call.hasArgument("count")) {
            count = call.argument("count");
        }
        if (call.hasArgument("thread_id")) {
            threadId = call.argument("thread_id");
        }
        if (call.hasArgument("address")) {
            address = call.argument("address");
        }
        if (call.hasArgument("sendList")) {
            sendList = convertJsonArrayToList(call.argument("sendList"));
        }
        if (call.hasArgument("contentList")) {
            contentList = convertJsonArrayToList(call.argument("contentList"));
        }

        SmsQueryHandler smsQueryHandler = new SmsQueryHandler(
                this.applicationContext, result, request, start, count, threadId, address, sendList, contentList);
        smsQueryHandler.handle();
    }

    // 将JSONArray转换为List<String>
    private List<String> convertJsonArrayToList(Object jsonArray) {
        List<String> list = new ArrayList<>();
        if (jsonArray instanceof JSONArray) {
            JSONArray array = (JSONArray) jsonArray;
            try {
                for (int i = 0; i < array.length(); i++) {
                    String item = array.getString(i);
                    if (item != null && !item.isEmpty()) {
                        list.add(item);
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return list;
    }
}
