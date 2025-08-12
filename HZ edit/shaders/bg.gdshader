shader_type canvas_item;

uniform float checker_size : hint_range(1.0, 400.0) = 40.0; // Size of each square
uniform vec2 scroll_speed = vec2(1.0, 0.0); // Scrolling direction & speed (UV units per second)
uniform vec4 base_color : source_color = vec4(1.0, 0.2, 0.2, 1.0); // Starting color
uniform float hue_shift : hint_range(0.0, 1.0) = 0.0; // Hue shift (0-1)
uniform float brightness : hint_range(0.0, 2.0) = 1.0; // Brightness
uniform float contrast : hint_range(0.0, 2.0) = 1.0; // Contrast

// RGB -> HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y)/(6.0*d + e)), d/(q.x + e), q.x);
}

// HSV -> RGB
vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
    // scale UVs to control square size and add scrolling
    vec2 uv = UV * checker_size + TIME * scroll_speed;

    // rotate UVs 45 degrees (manual rotation to avoid mat2 constructor issues)
    float angle = radians(45.0);
    float ca = cos(angle);
    float sa = sin(angle);
    uv = vec2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca);

    // integer grid -> checker
    float checker = mod(floor(uv.x) + floor(uv.y), 2.0);

    // hue-shift the base color
    vec3 hsv = rgb2hsv(base_color.rgb);
    hsv.x = mod(hsv.x + hue_shift, 1.0);
    vec3 shifted = hsv2rgb(hsv);

    // alternate between black and the shifted color (use base_color.alpha for final alpha)
    vec3 col = mix(vec3(0.0), shifted, checker);

    // brightness & contrast
    col = (col - 0.5) * contrast + 0.5;
    col *= brightness;

    COLOR = vec4(col, base_color.a);
}
