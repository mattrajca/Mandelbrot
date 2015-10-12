//
//  TextureShaders.metal
//  Mandelbrot
//
//  Created by Matt on 10/11/15.
//  Copyright © 2015 Matt Rajca. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

typedef struct {
	packed_float2 position;
	packed_float2 texcoord;
} Vertex;

typedef struct {
	float4 position [[position]];
	float2 texcoord;
} Varyings;

vertex Varyings vertexPassthrough(device Vertex *vertices [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
	Varyings out;

	device Vertex &v = vertices[vid];
	out.position = float4(float2(v.position), 0.0, 1.0);
	out.texcoord = v.texcoord;

	return out;
}

fragment half4 fragmentSampler(Varyings in [[ stage_in ]], texture2d<float, access::sample> texture [[ texture(0) ]]) {
	constexpr sampler s(address::clamp_to_edge, filter::linear);
	const float3 rgb = float3(texture.sample(s, in.texcoord).rgb);

	return half4(half3(rgb), 1.0);
}
