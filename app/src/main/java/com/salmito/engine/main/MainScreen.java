package com.salmito.engine.main;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.os.Bundle;
import android.view.Window;

public class MainScreen extends Activity {

    private MainView mainView;
    private Renderer renderer;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        mainView = new MainView(this);

        final ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        final ConfigurationInfo configurationInfo = activityManager.getDeviceConfigurationInfo();
        final boolean supportsEs2 = configurationInfo.reqGlEsVersion >= 0x20000;
        if (supportsEs2) {
            mainView.setEGLContextClientVersion(2);
            renderer=new Renderer(mainView);
            mainView.setRenderer(renderer);
        } else {
            return; //todo fallback
        }
        //mainView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        setContentView(mainView);
    }

    @Override
    protected void onResume() {
        super.onResume();
        mainView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mainView.onPause();
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
    }

}
