#define complex_add(a, b) (float2) { (a).x + (b).x, (a).y + (b).y }
#define complex_square(a) (float2) { (a).x * (a).x - (a).y * (a).y, (a).y * (a).x + (a).x * (a).y }

kernel void mandelbrot (write_only image2d_t output) {
	int2 coord = (int2) (get_global_id(0), get_global_id(1));
	
	int depth = -1;
	const float2 c = (float2) { coord.x / 1365.0f - 2.0f, coord.y / 1365.0f - 1.5f };
	float2 z = c;
	
	for (int i = 0; i < 20; i++) {
		z = complex_add(complex_square(z), c);
		
		if (dot(z, z) > 4) {
			depth = i;
			break;
		}
	}
	
	if (depth < 0) {
		write_imagef(output, coord, (float4) (0.0f, 0.0f, 0.0f, 1.0f));
	}
	else {
		write_imagef(output, coord, (float4) (0.0f, 1.0f / (20-depth) * 4, 1.0f / (20-depth) * 8, 1.0f));
	}
}
