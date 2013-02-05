
#ifndef H_COLOR_CONVERTER
#define H_COLOR_CONVERTER

/// Converts a uint color value to RGB color values
void int_to_rgb(int value, int *r, int *g, int *b);

/// Converts RGB color values to a uint color value
int rgb_to_int(int r, int g, int b);

/// Converts RGB [0..255] color values to HSV, where Hue ranges from [0..360], Sat and Val ranges from [0..1]
void rgb_to_hsv(int r, int g, int b, float *h, float *s, float *v);

/**Converts HSV color values to RGB [0..255) color values, where Hue ranges from 0..360, Sat and Val ranges from 0..1
 */
void hsv_to_rgb(float h, float s, float v, int *r, int *g, int *b);

// =================================================================
void HSLtoRGB(float h, float s, float l, float* outR, float* outG, float* outB);

void RGBtoHSL(float r, float g, float b, float* outH, float* outS, float* outL);

#endif