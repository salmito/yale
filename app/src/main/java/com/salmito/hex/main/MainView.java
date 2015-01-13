package com.salmito.hex.main;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.MotionEvent;

import com.salmito.hex.entities.HexColor;
import com.salmito.hex.entities.HexMap.Coordinates;
import com.salmito.hex.entities.Hexagon;

import java.util.Timer;
import java.util.TimerTask;

import static com.salmito.hex.game.GameState.getCamera;
import static com.salmito.hex.game.GameState.getMap;


public class MainView extends GLSurfaceView {

    public float previousX, previousY;
    int i = 0;
    private ViewState state = ViewState.IDLE;

    public MainView(Context context) {
        super(context);
    }

    final static int[][] evenNeighbors = {{1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}, {0, 1}};
    final static int[][] oddNeighbors = {{1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}, {1, 1}};


    private void touch(final Coordinates t, final int ttl) {
        if (t.getR() >= 0 && t.getQ() >= 0) {

            for (final int[] n : t.getR() % 2 == 0 ? evenNeighbors : oddNeighbors) {
                System.out.println("Getting hex: " + (t.getQ() + n[0]) + " " + (t.getR() + n[1]) + " " + getMap().hasHexagon(t.getQ() + n[0], t.getR() + n[1]));
                getMap().getHexagon(t.getQ() + n[0], t.getR() + n[1]);
                if (getMap().hasHexagon(t.getQ() + n[0], t.getR() + n[1])) {
                    Hexagon h = getMap().getHexagon(t.getQ() + n[0], t.getR() + n[1]);
                    h.flip((h.getColor() + 1) % HexColor.mColorNumber, i);
                    Timer t1 = new Timer("t");
                    if(ttl>0) {
                        t1.schedule(new TimerTask() {
                            @Override
                            public void run() {
                                System.out.println("timer");
                                touch(new Coordinates(t.getQ() + n[0], t.getR() + n[1]), ttl - 1);
                            }
                        }, 500);
                    }
                }
            }



            Hexagon hexagon = getMap().getHexagon(t);
            hexagon.flip((hexagon.getColor() + 1) % (HexColor.mColorNumber-1), i);
        }
    }

    private void touch(final Coordinates t) {
        touch(t,1);
    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {
        float x = e.getX();
        float y = e.getY();

        switch (e.getAction()) {
            case MotionEvent.ACTION_UP:
                if (state == ViewState.IDLE) {
                    float[] coordinates = getCamera().unproject(x, y);
                    Coordinates t = Coordinates.geo(coordinates[0], coordinates[1]);
                    if (t.getR() >= 0 && t.getQ() >= 0) {
                        Hexagon h = getMap().getHexagon(t);
                        h.flip((h.getColor() + 1) % HexColor.mColorNumber, 0);
                    }
                }
                state = ViewState.IDLE;
                break;
            case MotionEvent.ACTION_MOVE:
                state = ViewState.MOVING;
                float dx = x - previousX;
                float dy = y - previousY;
                if (e.getPointerCount() == 1) {
                    getCamera().move(dx / 100.0f, dy / 100.0f);
                    //renderer.onTouch(x, y);
                    //System.out.println("Moved "+dx+" "+dy);
                    //MainRenderer.angle+=dx;
                    //MainRenderer.mainCamera.zoom(dy/1000.0f);

                } else {
                    if (e.getPointerCount() == 2) {
                        getCamera().zoom(dy / 100.0f);
                    }
                }
                break;
            case MotionEvent.ACTION_DOWN:
                state = ViewState.SELECTING;
                float[] coordinates = getCamera().unproject(x, y);
                Coordinates t = Coordinates.geo(coordinates[0], coordinates[1]);
                System.out.println("tap on: " + (t.getQ()) + " " + (t.getR()) + " " + getMap().hasHexagon(t));

                touch(t);
                break;
        }
        previousX = x;
        previousY = y;
        return true;
    }

    enum ViewState {
        SELECTING,
        MOVING,
        IDLE,
    }
}
