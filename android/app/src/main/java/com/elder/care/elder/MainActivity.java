package com.elder.care.elder;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;


import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        System.out.println("Hey");

        createNotificationChannel("NOTIFICATION_CHANNEL", "alert notification",
                "", this, NotificationManager.IMPORTANCE_HIGH);

        SharedPreferences preferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);


        long period = 6000;

        new Thread(new Runnable() {
            @Override
            public void run() {

                while (true){
                    runOnUiThread((Runnable) () -> {
                        Date now = new Date();

                        String date = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(now);
                        if (preferences.contains("flutter." + date + ".elder")) {

                            String elder = preferences.getString("flutter." + date + ".elder", null);
                            String times = preferences.getString("flutter." + date + ".times", null);
                            String care = preferences.getString("flutter." + date + ".care", null);

                            for (String s : times.split(",")) {
                                if (s.trim().length() > 0){

                                    try {
                                        Date t = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.US).parse(date + " " + s.trim());
                                        if (t != null) {

                                            long dif = (now.getTime()) - t.getTime();
                                            System.out.println(dif);

                                            if (Math.abs(dif ) < period * 1.1){

                                                if (elder != null && times != null && care != null){
                                                    show_notification(care, elder + " needs " + care + " around " + s);
                                                }

                                            }
                                        }


                                    }catch (Exception e){}

                                }
                            }

                        }
                    });
                    try {
                        Thread.sleep(period);
                    }catch (Exception e){}

                }

            }
        }).start();

    }


    public static void createNotificationChannel(
            String CHANNEL_ID, String name, String description, Activity activity, int importance) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            NotificationManager notificationManager = activity.getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }


    public static int ALERT = 1;
    private void show_notification (String title, String text){
        NotificationCompat.Builder builder = new NotificationCompat.Builder(
                this,
                "NOTIFICATION_CHANNEL")
                .setOngoing(false)
                .setContentTitle(title)
                .setSmallIcon(R.drawable.notification)
                .setContentText(text);


        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        notificationManager.notify(ALERT++, builder.build());

    }

}
