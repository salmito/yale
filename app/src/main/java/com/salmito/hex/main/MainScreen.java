package com.salmito.hex.main;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.os.Bundle;
import android.view.Window;

import com.salmito.hex.game.GameState.State;

import static com.salmito.hex.game.GameState.getState;

public class MainScreen extends Activity {

    private MainView mGLSurfaceView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        mGLSurfaceView = new MainView(this);

        final ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        final ConfigurationInfo configurationInfo = activityManager.getDeviceConfigurationInfo();
        final boolean supportsEs2 = configurationInfo.reqGlEsVersion >= 0x20000;
        if (supportsEs2) {
            mGLSurfaceView.setEGLContextClientVersion(2);
            mGLSurfaceView.setRenderer(getState().getRenderer());
        } else {
            return;
        }
        //mGLSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        setContentView(mGLSurfaceView);

		/*mGLSurfaceView.setOnTouchListener(new View.OnTouchListener() {
            @Override
			public boolean onTouch(View v, MotionEvent event) {
				System.out.println("Touched "+event.getAxisValue(MotionEvent.AXIS_X)+" "+event.getAxisValue(MotionEvent.AXIS_Y));
				return false;
			}
		});*/
    }

    @Override
    protected void onResume() {
        super.onResume();
        getState().setCurrentState(State.RESUMED);
        mGLSurfaceView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        getState().setCurrentState(State.PAUSED);
        mGLSurfaceView.onPause();
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
    }

}
