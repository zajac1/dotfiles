// Tessera - mnoise.glsl with a NordPass mark in the corner.
//
// ONE IDEA: the ground stays exactly the mosaic the user already runs, and the
// only two chromatic things in the frame are both NordPass - the selected row
// and the mark, in the same teal.
//
// PROVENANCE: a COPY of ~/.config/ghostty/shaders/mnoise.glsl, which is tracked
// and was not touched. The four colour stops col1..col4 are the ORIGINAL greys,
// restored: an earlier revision recoloured them green and that is exactly what
// was asked to come back. The noise, the 60-column quantisation that makes the
// blocks blocky, the two rounded-rect SDFs that cut them into tiles, and the
// scroll are all untouched. Diff the two files and there are three additions
// and no edits:
//   1. PANEL_MASK and an early-out, so the shader only touches the fzf panel.
//   2. a luminance mask, so the mosaic sits BEHIND the type instead of adding
//      over it. The original adds to every pixel including glyphs, which on a
//      moving frame softens them. This is a legibility change, not a taste one.
//   3. the corner mark.
//
// THE CORNER. My first attempt at a corner mark in this set was placed against
// iResolution and came out invisible, because with OMNI_FRAME="boxed" the
// shader sees the whole launcher WINDOW and the fzf box is a sub-rectangle
// somewhere inside it. The technique below is from np-kerf.glsl in the
// structure agent's set, which solved it: at background-opacity = 0 every cell
// fzf painted is opaque and the margin around it is transparent, so the
// terminal texture's ALPHA IS the panel silhouette. Walk it and you have the
// real box corner rather than a guess.
//
// Two things here are not a copy of that. The mark is the exact brand
// silhouette, traced from the SVG path - a disc cut from below by a two-slope
// lambda - rather than a ring-and-triangle approximation of an arch. And it is
// gated by the ground mask as well as the panel mask, so it can never sit on
// top of a glyph.
//
// COST, stated precisely. The mosaic is mnoise's own: three snoise() calls per
// pixel at roughly 120 ALU each, plus noise2D, two SDFs and an fwidth - on the
// order of 400 ALU per pixel, every frame, because it animates. This is by far
// the most expensive shader in the set, and it is NOT free relative to what the
// user runs today: the masks gate what gets ADDED, not what gets COMPUTED. On
// top of mnoise this copy costs one dot product, one smoothstep, and two
// texture samples per fragment for the corner test. Only fragments within
// CORNER_R of BOTH the right and bottom edges pay for the walk itself, which is
// a few thousand pixels out of 2.4 million.
//
// ALPHA: the last line carries ghosttyCol.a, as the original does. Fragments
// outside the panel are returned completely untouched.

// MOCKSWAP: the render harness replaces this line to key on its sentinel
// background instead of alpha, because the mock runs opaque.
#define PANEL_MASK(c) step(0.5, (c).a)

const vec3  MARK_INK = vec3(0.000, 0.812, 0.714);  // #00cfb6  teal-600, the
                                                   // exact colour of the mark
const float MARK_A   = 0.00;   // mark off, amplitude 0 folds the term away
const float MARK_R   = 19.0;   // mark radius, device px
// The walk finds the OUTER edge of the panel, which is the outside of fzf's
// own border cell. The inset has to clear that cell plus the one column of
// --padding, and a cell is not square: at font-size 18 with OMNI_ROW_PAD 32%
// it is about 22 device px wide and 59 tall. A single pad put the mark half
// inside the rounded corner.
const float MARK_PAD_X = 44.0;
const float MARK_PAD_Y = 52.0;
const float CORNER_R = 96.0;   // how far the corner search may walk

// The NordPass mark, traced from the brand SVG
// (sb.nordcdn.com/asset/9c2a3627-.../nordpass.svg, the #00CFB6 path): a disc
// whose lower edge is a two-slope lambda rising to an apex 0.464 above centre.
// Ink is the part ABOVE that boundary - the dome, the deep centre notch and the
// two feet. p in unit-circle space, y up. Bounding box x in [-1,1],
// y in [-0.59, 1].
float npMark(vec2 p) {
    float a  = abs(p.x);
    float yb = min(0.464 - 0.818 * a, 0.194 - 1.631 * (a - 0.330));
    float disc  = 1.0 - smoothstep(0.90, 1.04, length(p));
    float above = smoothstep(-0.07, 0.07, p.y - yb);
    return disc * above;
}

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 10.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
float snoise(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

  // First corner
  vec3 i = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);

  // Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

  // Permutations
  i = mod289(i);
  vec4 p = permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0)) + i.y +
                           vec4(0.0, i1.y, i2.y, 1.0)) +
                   i.x + vec4(0.0, i1.x, i2.x, 1.0));

  // Gradients: 7x7 points over a square, mapped onto an octahedron.
  // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z); //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_); // mod(j,N)

  vec4 x = x_ * ns.x + ns.yyyy;
  vec4 y = y_ * ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  // vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  // vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

  // Normalise gradients
  vec4 norm =
      taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  // Mix final noise value
  vec4 m =
      max(0.5 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 105.0 *
         dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

float noise2D(vec2 uv) {
  uvec2 pos = uvec2(floor(uv * 1000.));
  return float((pos.x * 68657387u ^ pos.y * 361524851u + pos.x) % 890129u) *
         (1.0 / 890128.0);
}

float roundRectSDF(vec2 center, vec2 size, float radius) {
  return length(max(abs(center) - size + radius, 0.)) - radius;
}

float panelAt(vec2 q) {
    if (q.x < 0.5 || q.y < 0.5 || q.x > iResolution.x - 0.5 || q.y > iResolution.y - 0.5)
        return 0.0;
    return PANEL_MASK(texture(iChannel0, q / iResolution.xy));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy, sd = vec2(2.), sdh = vec2(1.);
  vec4 ghosttyCol = texture(iChannel0, uv);
  if (PANEL_MASK(ghosttyCol) < 0.5) { fragColor = ghosttyCol; return; }
  float ratio = iResolution.y / iResolution.x,
        fw = max(fwidth(uv.x), fwidth(uv.y));

  vec2 puv = floor(uv * vec2(60., 60. * ratio)) / 60.;
  puv +=
      (smoothstep(0., 0.7, noise2D(puv)) - 0.5) * 0.05 - vec2(0., iTime * 0.08);

  uv = fract(vec2(uv.x, uv.y * ratio) * 10.);
  float d = roundRectSDF((sd + 0.01) * (uv - .5), sdh, 0.075),
        d2 = roundRectSDF((sd + 0.065) * (fract(uv * 6.) - .5), sdh, 0.2),
        noiseTime = iTime * 0.03, noise = snoise(vec3(puv, noiseTime));

  noise += snoise(vec3(puv * 1.1, noiseTime + 0.5)) + .1;
  noise += snoise(vec3(puv * 2., noiseTime + 0.8));
  noise = pow(noise, 2.);

  vec3 col1 = vec3(0.), col2 = vec3(0.), col3 = vec3(0.07898),
       col4 = vec3(0.089184),
       fcol = mix(mix(mix(col1, col3, smoothstep(0.0, 0.3, noise)), col2,
                      smoothstep(0.0, 0.5, noise)),
                  col4, smoothstep(0.0, 1.0, noise));

  // Mosaic on the ground, never on the type: without this the tiles add over
  // the glyphs too, and a moving background eats the text it is behind.
  float ground = 1.0 - smoothstep(0.28, 0.52,
      dot(ghosttyCol.rgb, vec3(0.2126, 0.7152, 0.0722)));

  vec3 out_ = ghosttyCol.rgb + ground *
      mix(col4, fcol, smoothstep(fw, -fw, d) * smoothstep(fw, -fw, d2));

  // The mark, in the BOTTOM RIGHT of the fzf panel - the real corner, walked
  // out of the alpha silhouette, not guessed from iResolution. fragCoord.y
  // grows DOWNWARD here (measured twice in this set), so +y is toward the
  // bottom edge. A fragment only pays for the walk when it is within CORNER_R
  // of both edges; everything else pays two texture samples.
  if (panelAt(fragCoord + vec2(CORNER_R, 0.0)) < 0.5
      && panelAt(fragCoord + vec2(0.0, CORNER_R)) < 0.5) {
    float rx = fragCoord.x;
    for (int i = 0; i < 100; i++) {
      if (panelAt(vec2(rx + 1.0, fragCoord.y)) < 0.5) break;
      rx += 1.0;
    }
    float by = fragCoord.y;
    for (int i = 0; i < 100; i++) {
      if (panelAt(vec2(fragCoord.x, by + 1.0)) < 0.5) break;
      by += 1.0;
    }
    // the mark's bounding box is 2R wide and 1.59R tall; sit its bottom right
    // MARK_PAD in from the walked corner
    vec2 c = vec2(rx - MARK_PAD_X - MARK_R, by - MARK_PAD_Y - 0.59 * MARK_R);
    vec2 q = vec2(fragCoord.x - c.x, c.y - fragCoord.y) / MARK_R;  // y up
    out_ = mix(out_, MARK_INK, MARK_A * npMark(q) * ground);
  }

  fragColor = vec4(out_, ghosttyCol.a);
}
