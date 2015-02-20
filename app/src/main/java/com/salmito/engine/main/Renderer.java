package com.salmito.engine.main;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.lib.ResourceFinder;
import org.luaj.vm2.lib.jse.CoerceLuaToJava;
import org.luaj.vm2.lib.jse.JsePlatform;

import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;
import java.util.HashMap;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class Renderer implements GLSurfaceView.Renderer {
    private final MainView view;

    public Renderer(MainView view) {
        super();
        this.view = view;
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        view.draw();
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        view.init();
    }

    @Override
    public void onSurfaceChanged(GL10 gl10, int i, int i2) {
    }


}
