package com.salmito.hex.game;

import com.salmito.hex.entities.HexMap;
import com.salmito.hex.main.MainCamera;
import com.salmito.hex.main.MainRenderer;

/**
 * Global gamestate
 * <p/>
 * Created by tiago on 09/01/2015.
 */
public class GameState {
    private static GameState state;
    private static MainRenderer renderer;
    private static MainCamera camera;
    private static HexMap map;
    private State currentState;

    private GameState() {
        this.currentState = State.RESUMED;
    }

    public static GameState getState() {
        if (state == null) {
            state = new GameState();
            map = new HexMap(10);
            camera = new MainCamera();
            renderer = new MainRenderer();
        }
        return state;
    }

    public static MainCamera getCamera() {
        return camera;
    }

    public static MainRenderer getRenderer() {
        return renderer;
    }

    public static HexMap getMap() {
        return map;
    }

    public static void setMap(HexMap currentMap) {
        map = currentMap;
    }

    public State getCurrentState() {
        return currentState;
    }

    public void setCurrentState(State currentState) {
        this.currentState = currentState;
    }

    public enum State {
        RESUMED,
        PAUSED,
        SELECTING,
    }
}
