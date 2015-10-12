//
//  Shaders.metal
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

#define complex_square(a) (float2) { (a).x * (a).x - (a).y * (a).y, (a).y * (a).x + (a).x * (a).y }

kernel void mandelbrot(texture2d<float, access::write> outTexture [[texture(0)]], uint2 gid [[thread_position_in_grid]])
{
	int depth = -1;
	const float2 c = (float2) { gid[0] / 1365.0f - 2.0f, gid[1] / 1365.0f - 1.5f };
	float2 z = c;

	for (int i = 0; i < 20; i++) {
		z = complex_square(z) + c; // complex_add

		if (dot(z, z) > 4) {
			depth = i;
			break;
		}
	}

	if (depth < 0) {
		outTexture.write((float4) (0.0f, 0.0f, 0.0f, 1.0f), gid);
	}
	else {
		outTexture.write((float4) (0.0f, 1.0f / (20-depth) * 4, 1.0f / (20-depth) * 8, 1.0f), gid);
	}
}
