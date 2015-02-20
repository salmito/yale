package com.salmito.engine.main;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLU;
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
    private LuaTable window;
    public MainView(Context context) {
        super(context);
        globals = JsePlatform.standardGlobals();
        globals.finder=this;
    }

    public void draw() {
        System.out.println("ERROR "+GLU.gluErrorString(1282));
        if(window!=null) {
            window.get("draw").call(window);
        }

    }

    public void init() {
        if(initiated) return;
        initiated=true;
        LuaValue chunk = globals.loadfile("main.lua");
        chunk.call(CoerceJavaToLua.coerce(this));
    }

    public void setWindowObject(LuaTable v) {
        window=v;
    }

    @Override
    public void onSizeChanged(int w, int h, int oldw, int oldh) {
        if(window!=null) {
            LuaTable t=new LuaTable();
            LuaTable resize=new LuaTable();
            t.set("type","VIDEORESIZE");
            resize.set("w", w);
            resize.set("h",h);
            t.set("resize",resize);
            window.get("fire").call(window,t);
        }
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
