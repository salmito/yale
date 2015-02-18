return {[[#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy ) + mouse / 4.0;

	float color = 0.0;
	color += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
	color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
	color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
	color *= sin( time / 10.0 ) * 0.5;

	gl_FragColor = vec4( vec3( color, color * 0.5, sin( color + time / 3.0 ) * 0.75 ), 1.0 );

}]],
[[
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;


void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;   //normalise coordinates (1,1)

	uv.x -= 0.5; //center coordinates
	uv.y -= 0.5; //center coordinates
	//uv.y *= resolution.y/resolution.x; //correct the aspect ratio
	uv *= 2.0; //scale  
	float po = 2.0; // amount to power the lengths by
	float px = pow(uv.x * uv.x, po); //squaring the values causes them to rise slower creating a square effect
	float py = pow(uv.y * uv.y, po);
	float a =   2.0* atan(uv.y , uv.x) + time/10.0 ; //this makes the checker board but I still don't get why it works with atan
	//float a = 2.0; // uncomment to remove the checker board
	float r = pow( px + py, 1.0/(2.0 * po) );  // convert the vector into a length (pythagoras duh)
	vec2 q = vec2( 1.0/r + time * 0.25 , a ); //flip it so that the bands get wider towards the edge
	
	vec2 l = floor(q*4.6); //scale the values higher to make them into cycling integers
	float c = mod(l.x+l.y, 2.0); // now get the modulo to return values between 0 and 1 (ish)
	c *= pow(r,2.0); // darken everything towards the center

	gl_FragColor = vec4( c,c,c, 1.0 ); // set the pixel colour


}
]],[[
//Galaxy Collision
//By nikoclass

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

const int iters = 300;

int fractal(vec2 p) {
  	vec2 m=mouse / resolution.xy;

	vec2 seed = vec2(sin(time),cos(time))+m;	
	
	
	for (int i = 0; i < iters; i++) {
		
		if (length(p) > 2.0) {
			return i;
		}
		p = vec2(p.x * p.x - p.y * p.y + seed.x, 2.0* p.x * p.y + seed.y);
		
	}
	
	return 0;	
}

vec3 color(int i) {
	float f = float(i)/float(iters) ;//* (time);
	f=f*f*2.;
	//return vec3(f,f,f);
	return vec3((sin(f*2.0)), (sin(f*3.0)), abs(sin(f*7.0)));
}

void main( void ) {

	vec2 position = 2.5 * (-0.5 + gl_FragCoord.xy / resolution.xy );// + mouse / 1.0;
	position.x *= resolution.x/resolution.y;
	vec3 c = color(fractal(position));
	
	gl_FragColor = vec4( c , 1.0 );

}]],[[
// "tunnel of whoa!"
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define PI 3.14159265359

vec3 texPoint(vec2 v) {
	return vec3(mod(floor((v.x+0.02*sin(v.y+time*2.0))*1.0) + floor((v.y+time)*2.0), 2.0),
		    mod(floor((v.x-0.02*sin(v.y+time*2.0))*10.0) + floor((v.y+time)*71.0), 2.0),
		    mod(floor((v.x+0.02*cos(v.y+time*2.0))*1.0) + floor((v.y+time)*71.0), 7.0));
}

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy ) - vec2(0.5, 0.5);
	position.x *= resolution.x / resolution.y;
	float dist = tan(mix(PI/2.2, PI/3.0, length(position)));
	vec2 tex = vec2(mod(atan(position.x, position.y), 2.0*PI)/(1.0*PI), dist);

	vec3 color = texPoint(tex) / pow(dist, 0.1);

	gl_FragColor = vec4( color, 7.0 );
}]],[[#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define PI 3.14159265359

void main( void ) {

	vec2 position = (( gl_FragCoord.xy / resolution.xy ) - vec2(0.5, 0.5)) * 2.0;

	position.x += 0.5 * sin(position.y * (3.0 + cos(time)));
	
	float xSize = abs(position.x / position.y);
	float tanAngle = tan(mix(PI/2.0, PI/4.0, abs(position.y)));
	
	float ground = step(0.0, -position.y);
	float road = step(xSize, 1.0) * ground;
	float side = step(0.8, xSize) * road;
	float center = step(xSize, 0.05);
	
	float brightness = step(0.5, road) * 0.5;
	
	float stripe = max(0.0, sign(mod(tanAngle*1.0 + time*4.0, 2.0) - 1.0) * road);
	
	brightness += 0.5 * (stripe * (side + 1.0 * center));
	
	// sides = red
	float red = side;
	brightness -= red*0.25; // reduce overall brightness just to make the sides more pleasing
	
	// ground = green
	float green = (1.0 - road) * ground * 0.75 + (1.0 - ground) * 0.5;
	
	// sky = blue
	float blue = (1.0 - ground);
	brightness += blue * (1.0 - position.y) * 0.5;

	gl_FragColor = vec4( brightness + red, brightness + green, brightness + blue, 1.0 );

}]],[[#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
varying vec3 positionSurface;
varying vec3 positionSize;

vec3   iResolution = vec3(resolution, 1.0);
float  iGlobalTime = time-60.;
vec4   iMouse = vec4(mouse, 0.0, 1.0);
uniform sampler2D iChannel0,iChannel1;

//Oblivion by nimitz (twitter: @stormoid)

/*
	Mostly showing off animated triangle noise, the idea is to just use	combinations
	of moving triangle waves to create animated noise. In practice, only very few
	layers of triangle wave basis are needed to produce animated noise that	is visually
	interesting (using 4 layers here), meaning that this runs considerably faster
	than equivalent animated perlin-style noise and without the need for value noise as input.
*/

#define ITR 50
#define FAR 25.
#define time iGlobalTime*2.

#define MSPEED 5.
#define ROTSPEED .3

#define VOLSTEPS 20

//#define PENTAGRAM_ONLY

float hash(in float n){ return fract(sin(n)*43758.5453); }
mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

float tri(in float x){return abs(fract(x)-.5);}
vec3 tri3(in vec3 p){return vec3( tri(p.z+tri(p.y*1.)), tri(p.z+tri(p.x*1.)), tri(p.y+tri(p.x*1.)));}                           

vec3 path(in float t){return vec3(sin(t*.3),sin(t*0.25),0.)*0.3;}

mat2 m2 = mat2( 0.970,  0.242, -0.242,  0.970 );
float triNoise3d(in vec3 p)
{
    float z=1.5;
	float rz = 0.;
    vec3 bp = p;
	for (float i=0.; i<=3.; i++ )
	{
        vec3 dg = tri3(bp*2.)*1.;
        p += (dg+time*0.25);

        bp *= 1.8;
		z *= 1.5;
		p *= 1.1;
        p.xz*= m2;
        
        rz+= (tri(p.z+tri(p.x+tri(p.y))))/z;
        bp += 0.14;
	}
	return rz;
}

float map(vec3 p)
{
    p -= path(p.z);
    float d = 1.-length(p.xy);
    return d;
}

float march(in vec3 ro, in vec3 rd)
{
	float precis = 0.001;
    float h=precis*2.0;
    float d = 0.;
    float id = 0.;;
    for( int i=0; i<ITR; i++ )
    {
        if( abs(h)<precis || d>FAR ) break;
        d += h;
	    float res = map(ro+rd*d);
        h = res;
    }
	return d;
}

float mapVol(vec3 p)
{
    p -= path(p.z);
    float d = 1.-length(p.xy);
    d -= triNoise3d(p*0.15)*1.2;
    return d*0.55;
}

vec4 marchVol( in vec3 ro, in vec3 rd )
{
	vec4 rz = vec4(0);

	float t = 0.3;
	for(int i=0; i<VOLSTEPS; i++)
	{
		if(rz.a > 0.99)break;

		vec3 pos = ro + t*rd;
        float r = mapVol( pos );
		
        float gr =  clamp((r - mapVol(pos+vec3(.0,.1,.5)))/.5, 0., 1. );
        vec3 lg = vec3(0.7,0.5,.1)*1.2 + 3.*vec3(1)*gr;
        vec4 col = vec4(lg,r+0.55);
		
		col.a *= .2;
		col.rgb *= col.a;
		rz = rz + col*(1. - rz.a);
		t += 0.05;
	}
	rz.b += rz.w*0.2;
    rz.rg *= mm2(-rd.z*0.09);
    rz.rb *= mm2(-rd.z*0.13);
	return clamp(rz, 0.0, 1.0);
}

vec2 tri2(in vec2 p)
{
    const float m = 1.5;
    return vec2(tri(p.x+tri(p.y*m)),tri(p.y+tri(p.x*m)));
}

float triNoise2d(in vec2 p)
{
    float z=2.;
    float z2=1.5;
	float rz = 0.;
    vec2 bp = p;
    rz+= (tri(-time*0.5+p.x*(sin(-time)*0.3+.9)+tri(p.y-time*0.2)))*.7/z;
	for (float i=0.; i<=2.; i++ )
	{
        vec2 dg = tri2(bp*2.)*.8;
        dg *= mm2(time*2.);
        p += dg/z2;

        bp *= 1.7;
        z2 *= .7;
		z *= 2.;
		p *= 1.5;
        p*= m2;
        
        rz+= (tri(p.x+tri(p.y)))/z;
	}
	return rz;
}


vec3 shadePenta(in vec2 p, in vec3 rd)
{   
    p*=2.5;    
	float rz= triNoise2d(p)*2.;
    
    vec2 q = abs(p);
    float pen1 = max(max(q.x*1.176+p.y*0.385, q.x*0.727-p.y), p.y*1.237);
    float pen2 = max(max(q.x*1.176-p.y*0.385, q.x*0.727+p.y), -p.y*1.237);
    float d = abs(min(pen1,pen1-pen2*0.619)*4.28-.95)*1.2;
    d = min(d,abs(length(p)-1.)*3.);
    d = min(d,abs(pen2-0.37)*4.);
    d = pow(d,.7+sin(sin(time*4.1)+time)*0.15);
    rz = max(rz,d/(rz));
    
    vec3 col1 = vec3(.3,0.5,0.45)/(rz*rz);
    vec3 col2 = vec3(1.,0.5,0.25)/(rz*rz);
    vec3 col = mix(col1,col2,clamp(rd.z,0.,1.));
    
    return col;
}

void main(void)
{	
	vec2 p = gl_FragCoord.xy/iResolution.xy-0.5;
	p.x*=iResolution.x/iResolution.y;
	p += vec2(hash(time),hash(time+1.))*0.008;
    float dz = sin(time*ROTSPEED)*8.+1.;
    vec3 ro = path(time*MSPEED+dz)*.7+vec3(0,0,time*MSPEED);
    ro.z += dz;
    ro.y += cos(time*ROTSPEED)*.4;
    ro.x += cos(time*ROTSPEED*2.)*.4;
    
    vec3 tgt = vec3(0,0,time*MSPEED+1.);
    vec3 eye = normalize( tgt - ro);
    vec3 rgt = normalize(cross( vec3(0.0,1.0,0.0), eye ));
    vec3 up = normalize(cross(eye,rgt));
    vec3 rd = normalize( p.x*rgt + p.y*up + .75*eye );
	
    #ifndef PENTAGRAM_ONLY
    
	float rz = march(ro,rd);
    
    vec3 pos = ro+rz*rd;
            
    vec4 col = marchVol(pos,rd);
    vec3 ligt = normalize( vec3(-.0, 0., -1.) );
    vec2 spi = vec2(sin(time),cos(time))*1.;
    float flick = clamp(1.-abs(((pos.z-time*MSPEED)*0.3+mod(time*5.,30.))-15.),0.,1.)*clamp(dot(pos.xy,spi),0.,1.)*1.7;
    flick += 	 clamp(1.-abs(((pos.z-time*MSPEED)*0.3+mod(time*5.+10.,30.))-15.),0.,1.)*clamp(dot(pos.xy,spi),0.,1.)*2.;
    flick += 	 clamp(1.-abs(((pos.z-time*MSPEED)*0.3+mod(time*5.+20.,30.))-15.),0.,1.)*clamp(dot(pos.xy,spi),0.,1.)*2.;
    col.rgb += flick*(step(mod(time,2.5),0.2))*.4;
    col.rgb += flick*(step(mod(time*1.5,3.2),0.2))*.4;
    
    col.rgb = mix(col.rgb*col.rgb,col.rgb*shadePenta(p,rd)*1.2,(1.-col.w)*step(tri(time*.25),0.1)*smoothstep(0.5,1.,2.*tri(time)));
    
    #else
    vec3  col = shadePenta(p,rd);
    col = pow(col,vec3(1.5))*0.4;
    #endif
    
	gl_FragColor = vec4( col.rgb, 1.0 );
}
]]}
