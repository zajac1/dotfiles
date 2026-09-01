// Bespoke: focus dimmer.
// Unfocused panes desaturate and darken (like macOS inactive windows),
// so the active split is instantly obvious. Un-dims with a short fade
// when focus returns. Affects the whole pane by design, text included.

const float DESATURATE = 0.65;   // 0.0 = keep colors, 1.0 = grayscale when unfocused
const float DARKEN = 0.72;       // brightness multiplier when unfocused
const float FADE_IN = 0.25;      // seconds to restore when refocused

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    float focused = 0.0;
    if (iFocus > 0) {
        focused = smoothstep(0.0, FADE_IN, iTime - iTimeFocus);
    }

    float lum = dot(term.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 dimmed = mix(term.rgb, vec3(lum), DESATURATE) * DARKEN;
    vec3 col = mix(dimmed, term.rgb, focused);

    fragColor = vec4(col, term.a);
}
