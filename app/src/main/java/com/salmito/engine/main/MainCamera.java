package com.salmito.engine.main;

public class MainCamera {

/*	private final float[] eye=new float[3];
	private final float[] look=new float[3];
	private final float[] up=new float[3];
	
	public MainCamera(){
		eye[0] = 0.0f;
		eye[1] = -5.0f;
		eye[2] = 10.0f;

		look[0] = 0.0f;
		look[1] = 0.0f;
		look[2] = 0.0f;

		up[0] = 0.0f;
		up[1] = 1.0f;
		up[2] = 0.0f;
	}
	
	public void lookAt() {
		//Matrix.setLookAtM(Renderer.mViewMatrix, 0, eye[0], eye[1], eye[2], look[0], look[1], look[2], up[0], up[1], up[2]);
	}
	
	public void zoom(float ammount) {
		eye[2]+=ammount;
		lookAt();
	}
	
	public float [] unproject(float x,float y) {
		float[] objCoordsnear = new float[4];
		float[] objCoordsfar = new float[4];
		GLU.gluUnProject(x, Renderer.mView[3]-y, 0.0f, Renderer.mViewMatrix,  0, Renderer.mProjectionMatrix, 0, Renderer.mView, 0, objCoordsnear, 0);
		GLU.gluUnProject(x, Renderer.mView[3]-y, 1.0f, Renderer.mViewMatrix,  0, Renderer.mProjectionMatrix, 0, Renderer.mView, 0, objCoordsfar, 0);
		
		//Noirmalizando
		
		objCoordsnear[0]=objCoordsnear[0]/objCoordsnear[3];
		objCoordsnear[1]=objCoordsnear[1]/objCoordsnear[3];
		objCoordsnear[2]=objCoordsnear[2]/objCoordsnear[3];
		
		objCoordsfar[0]=objCoordsfar[0]/objCoordsfar[3];
		objCoordsfar[1]=objCoordsfar[1]/objCoordsfar[3];
		objCoordsfar[2]=objCoordsfar[2]/objCoordsfar[3];
		
		float u=-objCoordsnear[2]/(objCoordsfar[2]-objCoordsnear[2]); //Equacao do plano z=0
		
		//Calcula ponto de interseção da reta near-far com o plano z=0 	
		float[] ret = new float[3];
		ret[0]=objCoordsnear[0]+u*(objCoordsfar[0]-objCoordsnear[0]);
		ret[1]=objCoordsnear[1]+u*(objCoordsfar[1]-objCoordsnear[1]);
		ret[2]=0.0f;
		
		return ret;
	}
	
	public void move(float x, float y) {
		eye[0]-=x;
		eye[1]+=y;
		look[0] -= x;
		look[1] += y;
		lookAt();
	}
*/
}
