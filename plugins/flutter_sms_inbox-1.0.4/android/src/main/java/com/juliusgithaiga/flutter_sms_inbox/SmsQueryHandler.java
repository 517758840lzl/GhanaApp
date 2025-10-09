package com.juliusgithaiga.flutter_sms_inbox;

import android.content.Context;
import android.database.Cursor;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;
import io.flutter.plugin.common.MethodChannel;
import android.os.Handler;
import android.os.Looper;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import android.os.Process;
import android.util.Log;

public class SmsQueryHandler {

    private final Context applicationContext;
    private final MethodChannel.Result result;
    private final SmsQueryRequest request;
    private final String address;
    private final int threadId;
    private final List<String> sendList;
    private final List<String> contentList;
    private int start;
    private int count;

    private static final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    SmsQueryHandler(Context applicationContext, MethodChannel.Result result, SmsQueryRequest request,
                    int start, int count, int threadId, String address, List<String> sendList, List<String> contentList) {
        this.applicationContext = applicationContext;
        this.result = result;
        this.request = request;
        this.threadId = threadId;
        this.address = address;
        this.sendList = sendList;
        this.contentList = contentList;
        this.start = start;
        this.count = count;
    }

    // 转义SQL LIKE特殊字符，防止SQL注入
    private String escapeSqlLike(String input) {
        return input.replace("%", "\\%")
                    .replace("_", "\\_")
                    .replace("[", "\\[")
                    .replace("]", "\\]");
    }

    void handle() {
        executor.execute(new Runnable() {
            @Override
            public void run() {
                // 降低线程优先级
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                long startTime = System.currentTimeMillis();
                ArrayList<JSONObject> list = new ArrayList<>();
                
                // 180天时间范围过滤
                long now = System.currentTimeMillis();
                long oneHundredEightyDaysAgo = now - 180L * 24 * 60 * 60 * 1000;

                // 构建WHERE条件
                StringBuilder whereClause = new StringBuilder();
                ArrayList<String> whereArgs = new ArrayList<>();
                
                // 添加发送者过滤条件（如果有）
                boolean hasSenderCondition = false;
                if (sendList != null && !sendList.isEmpty()) {
                    StringBuilder addressCondition = new StringBuilder("(");
                    for (String sender : sendList) {
                        if (sender != null && !sender.isEmpty()) {
                            if (addressCondition.length() > 1) addressCondition.append(" OR ");
                            addressCondition.append("address LIKE ?");
                            whereArgs.add("%" + escapeSqlLike(sender) + "%");
                            hasSenderCondition = true;
                        }
                    }
                    if (hasSenderCondition) {
                        addressCondition.append(")");
                        whereClause.append(addressCondition);
                    }
                }
                
                // 添加内容过滤条件（如果有）
                boolean hasContentCondition = false;
                if (contentList != null && !contentList.isEmpty()) {
                    StringBuilder bodyCondition = new StringBuilder("(");
                    for (String content : contentList) {
                        if (content != null && !content.isEmpty()) {
                            if (bodyCondition.length() > 1) bodyCondition.append(" OR ");
                            bodyCondition.append("body LIKE ?");
                            whereArgs.add("%" + escapeSqlLike(content) + "%");
                            hasContentCondition = true;
                        }
                    }
                    if (hasContentCondition) {
                        bodyCondition.append(")");
                        if (hasSenderCondition) {
                            whereClause.append(" OR ");
                        }
                        whereClause.append(bodyCondition);
                    }
                }

                // 时间范围过滤（AND连接，优先过滤）
                if (whereClause.length() > 0) {
                    whereClause.insert(0, "(");
                    whereClause.append(")");
                    whereClause.append(" AND ");
                }
                whereClause.append("date > ?");
                whereArgs.add(String.valueOf(oneHundredEightyDaysAgo));

                // 只查需要的字段
                String[] projection = new String[] {"address", "body", "date", "date_sent"};
                // 排序+限制条数
                String sortOrder = "date DESC LIMIT 200";

                Cursor cursor = applicationContext.getContentResolver().query(
                    request.toUri(), 
                    projection, 
                    whereClause.toString(), 
                    whereArgs.toArray(new String[0]), 
                    sortOrder
                );

                if (cursor == null) {
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            result.error("no_cursor", "flutter_sms_inbox plugin requires cursor to resolve content", null);
                        }
                    });
                    return;
                }

                if (!cursor.moveToFirst()) {
                    cursor.close();
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(list);
                        }
                    });
                    return;
                }

                int localStart = start;
                int localCount = count;
                do {
                    JSONObject obj = readSms(cursor);
                    try {
                        if (threadId >= 0 && obj.getInt("thread_id") != threadId) {
                            continue;
                        }
                        if (address != null && !obj.getString("address").equals(address)) {
                            continue;
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    if (localStart > 0) {
                        localStart--;
                        continue;
                    }
                    list.add(obj);
                    if (localCount > 0) {
                        localCount--;
                    }
                } while (cursor.moveToNext() && localCount != 0);
                cursor.close();
                // 执行耗时操作
                Log.d("SMSQuery", "SMSQuery: " + (System.currentTimeMillis() - startTime) + "ms");
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(list);
                    }
                });
            }
        });
    }

    private JSONObject readSms(Cursor cursor) {
        JSONObject res = new JSONObject();
        for (int i = 0; i < cursor.getColumnCount(); i++) {
            try {
                if (cursor.getColumnName(i).equals("address") || cursor.getColumnName(i).equals("body")) {
                    res.put(cursor.getColumnName(i), cursor.getString(i));
                } else if (cursor.getColumnName(i).equals("date") || cursor.getColumnName(i).equals("date_sent")) {
                    res.put(cursor.getColumnName(i), cursor.getLong(i));
                } else {
                    res.put(cursor.getColumnName(i), cursor.getInt(i));
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return res;
    }

}
