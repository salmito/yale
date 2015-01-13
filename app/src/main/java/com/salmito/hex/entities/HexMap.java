package com.salmito.hex.entities;

import android.os.SystemClock;

import java.util.HashMap;
import java.util.Map;

public class HexMap {

    private final int size;
    private Map<Coordinates, Hexagon> map;

    public HexMap(int size) {
        this.size = size;
        map = new HashMap<Coordinates, Hexagon>();
    }

    public int getSize() {
        return size;
    }

    public boolean hasHexagon(int x, int y) {
        return hasHexagon(new Coordinates(x, y));
    }

    public boolean hasHexagon(Coordinates p) {
        return map.containsKey(p);
    }

    public int getColor(int i, int j) {
        long time = (SystemClock.uptimeMillis() / 250) % 4L;
        return (Math.abs(i) + Math.abs(j) + (int) time) % 5;
    }

    public Hexagon getHexagon(int i, int j) {
        final Coordinates p = new Coordinates(i, j);
        Hexagon hex = map.get(p);
        if (hex == null) {
            hex = new Hexagon(p.getQ(),p.getR());
            map.put(p, hex);
        }
        return hex;
    }

    public Hexagon getHexagon(Coordinates p) {
        Hexagon hex = map.get(p);
        if (hex == null) {
            hex = new Hexagon(p.getQ(),p.getR());
            map.put(p, hex);
        }
        return hex;
    }

    public void draw() {
        for (int i = 0; i < size; i++)
            for (int j = 0; j < size; j++)
                if(hasHexagon(i,j)) getHexagon(i,j).draw();


    }

    public static class Coordinates {
        private static float sq = (float) Math.sqrt(3.0);
        private static float H = Hexagon.radius * (float) Math.sin(Math.PI / 6);
        private static float height = Hexagon.radius + 2.0f * H;
        private static float R = Hexagon.radius * (float) Math.cos(Math.PI / 6);
        private static float M = H / R;
        private static float width = 2.0f * R;
        private final int hash;
        private int q;
        private int r;

        public Coordinates(int q, int r) {
            this.q = q;
            this.r = r;

            int sum = q + r;
            hash = sum * (sum + 1) / 2 + r;
        }

        public Coordinates(int x, int y, int z) {
            this.q = x;
            this.r = z;
            int sum = q + r;
            hash = sum * (sum + 1) / 2 + r;
        }

        public static Coordinates get(int x, int y, int z) {//throws Exception {
            //if(x+y+z!=0) throw(new Exception("Invalid cube coordinates"));
            return new Coordinates(x + (z - (z & 1)) / 2, z);
        }

        public static Coordinates geo(float x, float y) {
            x += R;
            //else x-=R;
            y += Hexagon.radius;
            //else y-=Hexagon.radius;

            int Xs = (int) (x / width); //hex coord
            int Ys = (int) (y / (H + Hexagon.radius));

            float Xi = Math.abs(x - ((float) Xs) * width); //position inside hex
            float Yi = y - Math.abs(((float) Ys) * (H + Hexagon.radius));

            if (Ys % 2 == 1) { //even line B
                if (Xi >= R) {
                    if (Yi < (2 * H - Xi * M)) Ys--;
                } else {
                    if (Yi < (Xi * M)) Ys--;
                    else Xs--;
                }
            } else { //odd line A
                if (Yi < H - Xi * M) {
                    Ys--;
                    Xs--;
                } else if (Yi < (-H + Xi * M)) Ys--;
            }
            //if(Ys<0) Ys=0;
            //if(Xs<0) Xs=0;
            return new Coordinates(Xs, Ys);
        }

        public int getQ() {
            return q;
        }

        public int getR() {
            return r;
        }

        public int getX() {
            return q - (r - (r & 1)) / 2;
        }

        public int getY() {
            return -this.getX() - this.getZ();
        }

        public int getZ() {
            return r;
        }

        @Override
        public boolean equals(Object o) {
            Coordinates t = (Coordinates) o;
            return this.q == t.q && this.r == t.r;
        }


        //private static float H=Hexagon.radius/2.0f;

        @Override
        public int hashCode() {
            return hash;
        }
    }
}
