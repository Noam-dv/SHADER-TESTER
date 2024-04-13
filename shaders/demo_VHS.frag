#pragma header
				uniform float intensity;
				vec2 uv = openfl_TextureCoordv.xy;
				vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
				vec2 iResolution = openfl_TextureSize;
				uniform float iTime;
				#define iChannel0 bitmap
				#define texture flixel_texture2D
				#define fragColor gl_FragColor
				#define mainImage main
				
				float noise(vec2 p) {
					return fract(sin(dot(p, vec2(12.9898, 4.1414))) * 4.5453);
				}

				void mainImage() {
					vec2
					uv = fragCoord / iResolution.xy;
					vec2
					uvn = uv;
					float
					time = iTime;

					// tape wave + wave distortion
					uvn.x += (noise(vec2(uvn.y, time)) - 0.5) * noise(vec2(0.005)) * 0.015 * intensity;
					uvn.x += (noise(vec2(uvn.y * 100.0, time * 10.0)) - 0.5) * 0.01 * intensity;
					float
					tcPhase = clamp((sin(uvn.y * 8.0 - time * 3.14159265 * 1.2) - 0.92) * noise(vec2(time)), 0.0, 0.01) * 10.0;
					float
					tcNoise = max(noise(vec2(uvn.y * 100.0, time * 10.0)) - 0.5, 0.0);
					uvn.x = uvn.x - tcNoise * tcPhase * intensity;

					// rand scanlines
					float
					scanlines = sin(uv.y * noise(vec2(800.0))) * 0.1 * intensity;

					// color distortion (chromatic abberation)
					vec2
					distortion = vec2(sin(time * 2.0 + uvn.y * 10.0) * 0.005, cos(time * 1.5 + uvn.y * 15.0) * 0.005) * intensity;
					vec3
					color = texture(iChannel0, uvn + distortion).rgb;

					float
					noiseVal = (fract(sin(dot(uv + time, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.2 * intensity;
					color += noiseVal;

					// apply effects
					color -= scanlines;
					color *= 1.0 - tcPhase;

					// Final color output
					fragColor = vec4(color, 1.0);
				}
