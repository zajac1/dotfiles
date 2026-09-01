// Theme-derived static background gradient.
// Colors are computed at runtime from the live theme: each corner is
// ANSI accent blended over the theme background, then dimmed — the same
// formula as the hand-tuned Mocha winner (30% accent, 75% brightness),
// but it now follows every tinty scheme switch automatically.
// Rotation scripts rewrite only the two ACCENT_* lines below.

const int ACCENT_A = 12;           // ANSI palette index, top-left (4 = blue)
const int ACCENT_B = 15;           // ANSI palette index, bottom-right (5 = magenta)
const float BLEND = 0.30;         // accent share over theme background
const float DIM = 0.75;          // overall brightness multiplier

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    vec3 cornerA = mix(iBackgroundColor, iPalette[ACCENT_A], BLEND) * DIM;
    vec3 cornerB = mix(iBackgroundColor, iPalette[ACCENT_B], BLEND) * DIM;

    float gradientFactor = smoothstep(0.0, 1.0, (uv.x + uv.y) / 2.0);
    vec3 gradientColor = mix(cornerA, cornerB, gradientFactor);

    float mask = 1.0 - step(0.5, dot(term.rgb, vec3(1.0)));
    vec3 blended = mix(term.rgb, gradientColor, mask);

    fragColor = vec4(blended, term.a);
}
