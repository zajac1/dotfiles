// Vellum, dark - a blind deboss in black card.
//
// ONE IDEA, unchanged: the mark belongs IN the material, not on it, and the
// theme therefore spends zero rows on a logo.
//
// WHAT CHANGED BEYOND THE VALUES: light vellum shows its watermark by
// TRANSMISSION - you hold the sheet up and the pressed area is thinner, so it
// passes more light and carries a faint body tint. Black card transmits
// nothing. The only thing left is surface relief read by raking light, so the
// body tint is gone entirely (BODY = 0) and the mark is defined by its two
// edges alone. The operator changed with it: the light version MULTIPLIES,
// because paper scatters in proportion to what is already there; this one ADDS,
// because multiplying a near-black ground by anything is still near-black.
//
// COST: one iChannel0 fetch, three markMask() calls (~10 ALU each), one hash,
// ~70 ALU total. No loops, no dynamic branches, nothing resolution-scaled.
//
// ALPHA: carried from the terminal on the last line, never a constant.
//
// MEASURED, not assumed: fragCoord.y increases DOWNWARD in a Ghostty shader.
// Everything geometric here works in `pu`, which is fragCoord with y flipped.

const float EMBOSS = 0.000;   // mark off, amplitude 0 folds the term away
const float OFFSET = 0.026;   // width of that edge, in mark radii
const float FIBRE  = 0.010;   // the card's own tooth

// Mark height as a fraction of the launcher WINDOW, not of the fzf box: with
// OMNI_FRAME="boxed" the shader cannot see where the box is. The box IS
// centred in the window (bin/omni: --margin="$top,$side"), so the POSITION is
// exact; only this one number is coupled to OMNI_TERM_SIZE and the font size.
// Tuned for OMNI_TERM_SIZE="46%,96%" at font-size 19.
const float MARK_H = 0.25;

// The NordPass mark, traced from the brand SVG
// (sb.nordcdn.com/asset/9c2a3627-.../nordpass.svg, the #00CFB6 path): a disc
// whose lower edge is a two-slope lambda rising to an apex 0.464 above centre.
// Ink is the part of the disc ABOVE that boundary. p in unit-circle space,
// y up. Bounding box is x in [-1,1], y in [-0.59,1], hence the 1.59 below.
float markMask(vec2 p) {
    float a  = abs(p.x);
    float yb = min(0.464 - 0.818 * a, 0.194 - 1.631 * (a - 0.330));
    float disc  = 1.0 - smoothstep(0.93, 1.03, length(p));
    float above = smoothstep(-0.06, 0.06, p.y - yb);
    return disc * above;
}

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
float hash(vec2 p) { return fract(sin(dot(p, vec2(23.7, 91.4))) * 24634.6345); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv   = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    float card = 1.0 - smoothstep(0.25, 0.50, luma(term.rgb));

    vec2 pu = vec2(fragCoord.x, iResolution.y - fragCoord.y);   // y up
    float R = MARK_H * iResolution.y / 1.59;
    vec2  C = vec2(0.5 * iResolution.x, 0.5 * iResolution.y - 0.205 * R);
    vec2  mp = (pu - C) / R;

    float up = markMask(mp + vec2(0.0, OFFSET));
    float dn = markMask(mp - vec2(0.0, OFFSET));

    // no body term: a deboss in an opaque material has edges and nothing else
    float press = (up - dn) * EMBOSS;

    float f = (hash(vec2(floor(fragCoord.x / 3.0), floor(fragCoord.y))) - 0.5) * FIBRE;

    vec3 col = term.rgb + (press + f) * card;
    fragColor = vec4(col, term.a);
}
