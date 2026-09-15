// Halftone, dark - screen printed on black stock.
//
// ONE IDEA, unchanged: this is a printed page, so its ground is a real rotated
// dot screen and the selected row is the one thing printed solid.
//
// WHAT CHANGED BEYOND THE VALUES: the screen is now ADDITIVE. On paper the ink
// is absorbed and the dot is darker than the ground; on black stock the ink is
// opaque and lighter than the ground, which is a different press entirely. Two
// consequences that are not colour choices: the field density had to come down
// from 0.075 to 0.042, because light dots on dark read heavier than dark dots
// on light at the same coverage; and the selected row is deliberately NOT
// screened, because a screen print lays its solids flat.
//
// COST: one iChannel0 fetch, ~25 ALU, no loops, no dynamic branches, nothing
// that scales with resolution. Same as the light version.
//
// ALPHA: the last line carries texture(iChannel0).a. With
// background-opacity = 0 (OMNI_FRAME="boxed") every cell fzf does not paint
// keeps alpha 0, so the launcher window stays invisible. Never a constant.
//
// The screen is rotated 22.5 degrees. That is what a real halftone does, and
// it is also the fix for moire against the glyph grid.

const vec3  INK    = vec3(0.0000, 0.6784, 0.6000);  // #00ad99  teal-700
const float PITCH  = 6.0;      // dot pitch, device pixels
const float ANGLE  = 0.3927;   // 22.5 deg
const float FIELD  = 0.042;    // ink density of the field
const float RADIUS = 0.38;     // dot radius within its cell

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv   = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // Inverted against the light version: print on the STOCK, never on the
    // type and never on the solid. A wide ramp so antialiased glyph edges fade
    // out of the screen instead of ringing it.
    float stock = 1.0 - smoothstep(0.22, 0.45, luma(term.rgb));

    vec2 r = vec2(cos(ANGLE), sin(ANGLE));
    vec2 q = vec2(dot(fragCoord, r), dot(fragCoord, vec2(-r.y, r.x))) / PITCH;
    float d = length(fract(q) - 0.5);
    float dot_ = 1.0 - smoothstep(RADIUS - 0.14, RADIUS + 0.14, d);

    // additive, because opaque ink SITS ON dark stock rather than soaking in
    vec3 col = term.rgb + INK * (FIELD * dot_ * stock);
    fragColor = vec4(col, term.a);
}
