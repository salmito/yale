package com.salmito.engine.main;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.view.MotionEvent;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.lib.ResourceFinder;
import org.luaj.vm2.lib.jse.CoerceJavaToLua;
import org.luaj.vm2.lib.jse.JsePlatform;

import java.io.InputStream;


public class MainView extends GLSurfaceView implements ResourceFinder {
    private final Globals globals;
    private boolean initiated=false;

    public MainView(Context context) {
        super(context);
        globals = JsePlatform.standardGlobals();
        globals.finder=this;
    }

    public void init() {
        if(initiated) return;
        initiated=true;
        LuaValue chunk = globals.loadfile("main.lua");
        chunk.call(CoerceJavaToLua.coerce(this));
    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {
        float x = e.getX();
        float y = e.getY();

        return true;
    }
    @Override
    public InputStream findResource(String name) {
        try {
            System.out.println("Opening file "+name);
            return getContext().getAssets().open(name);
        } catch (java.io.IOException ioe) {
            return null;
        }
    }
}
