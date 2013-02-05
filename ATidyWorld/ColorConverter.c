//
//  ColorConverter.c
//  TidyTime
//
//  Created by Rudi Strahl on 2012-10-08.
//
//

#include <stdio.h>
#include <math.h>
#include "ColorConverter.h"

/// Converts a uint color value to RGB color values
void int_to_rgb(int value, int *r, int *g, int *b)
{
    *r = (value >> 16) & 0xff;
    *g = (value >> 8) & 0xff;
    *b = (value & 0xff);
}

/// Converts RGB color values to a uint color value
int rgb_to_int(int r, int g, int b)
{
    int value = 0;
    value += r << 16;
    value += g << 8;
    value += b;
    return value;
    
}

/// Converts RGB [0..255] color values to HSV, where Hue ranges from [0..360], Sat and Val ranges from [0..1]
void rgb_to_hsv(int r, int g, int b, float *h, float *s, float *v)
{
    float min, max, delta, rc, gc, bc;
    
    rc = (float)r / 255.0;
    gc = (float)g / 255.0;
    bc = (float)b / 255.0;
    max = fmaxf(rc, fmaxf(gc, bc));
    min = fminf(rc, fminf(gc, bc));
    delta = max - min;
    *v = max;
    
    if (max != 0.0)
        *s = delta / max;
    else
        *s = 0.0;
    
    if (*s == 0.0) {
        *h = 0.0;
    }
    else {
        if (rc == max)
            *h = (gc - bc) / delta;
        else if (gc == max)
            *h = 2 + (bc - rc) / delta;
        else if (bc == max)
            *h = 4 + (rc - gc) / delta;
        
        *h *= 60.0;
        if (*h < 0)
            *h += 360.0;
    }
}

/**Converts HSV color values to RGB [0..255) color values, where Hue ranges from 0..360, Sat and Val ranges from 0..1
 */
void hsv_to_rgb(float h, float s, float v, int *r, int *g, int *b)
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v * 255;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v * 255;
			*g = t * 255;
			*b = p;
			break;
		case 1:
			*r = q * 255;
			*g = v * 255;
			*b = p * 255;
			break;
		case 2:
			*r = p * 255;
			*g = v * 255;
			*b = t * 255;
			break;
		case 3:
			*r = p * 255;
			*g = q * 255;
			*b = v * 255;
			break;
		case 4:
			*r = t * 255;
			*g = p * 255;
			*b = v * 255;
			break;
		default:		// case 5:
			*r = v * 255;
			*g = p * 255;
			*b = q * 255;
			break;
	}
}

// =================================================================
void HSLtoRGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
    temp2;
	float			temp[3];
	int				i;
	
	// Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
	// Test for luminance and compute temporary values based on luminance and saturation
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
	
	// Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) {
		
		// Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
		
		
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
	
	// Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}


void RGBtoHSL(float r, float g, float b, float* outH, float* outS, float* outL)
{
    r = r/255.0f;
    g = g/255.0f;
    b = b/255.0f;
    
    
    float h,s, l, v, m, vm, r2, g2, b2;
    
    h = 0;
    s = 0;
    l = 0;
    
    v = fmaxf(r, g);
    v = fmaxf(v, b);
    m = fminf(r, g);
    m = fminf(m, b);
    
    l = (m+v)/2.0f;
    
    if (l <= 0.0){
        if(outH)
			*outH = h;
		if(outS)
			*outS = s;
		if(outL)
			*outL = l;
        return;
    }
    
    vm = v - m;
    s = vm;
    
    if (s > 0.0f){
        s/= (l <= 0.5f) ? (v + m) : (2.0 - v - m);
    }else{
        if(outH)
			*outH = h;
		if(outS)
			*outS = s;
		if(outL)
			*outL = l;
        return;
    }
    
    r2 = (v - r)/vm;
    g2 = (v - g)/vm;
    b2 = (v - b)/vm;
    
    if (r == v){
        h = (g == m ? 5.0f + b2 : 1.0f - g2);
    }else if (g == v){
        h = (b == m ? 1.0f + r2 : 3.0 - b2);
    }else{
        h = (r == m ? 3.0f + g2 : 5.0f - r2);
    }
    
    h/=6.0f;
    
    if(outH)
        *outH = h;
    if(outS)
        *outS = s;
    if(outL)
        *outL = l;
    
}