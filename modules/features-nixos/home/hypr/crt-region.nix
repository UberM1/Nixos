{
  config,
  pkgs,
  ...
}: let
  # Paints a CRT tube (barrel curvature, scanlines, aperture grille, chromatic
  # aberration, vignette) over a region picked with slurp. Hyprland only has one
  # global `decoration:screen_shader`, so the region is baked into a generated
  # shader: everything outside the rect — and every other monitor, via the
  # `wl_output` uniform — is passed through untouched.
  crt-region = pkgs.writeShellApplication {
    name = "crt-region";
    runtimeInputs = [
      pkgs.slurp
      pkgs.jq
      pkgs.gawk
      config.wayland.windowManager.hyprland.package
    ];
    text = ''
      shader="''${XDG_RUNTIME_DIR:-/tmp}/crt-region.frag"
      damage_state="''${XDG_RUNTIME_DIR:-/tmp}/crt-region.damage"

      disable() {
        hyprctl keyword decoration:screen_shader "[[EMPTY]]" >/dev/null
        # restore damage tracking (see below)
        hyprctl keyword debug:damage_tracking "$(cat "$damage_state" 2>/dev/null || echo 2)" >/dev/null
        rm -f "$damage_state"
        hyprctl dispatch submap reset >/dev/null
      }

      if [ "''${1:-}" = "off" ]; then
        disable
        exit 0
      fi

      # second press toggles it back off
      if [ "$(hyprctl getoption decoration:screen_shader -j | jq -r .str)" = "$shader" ]; then
        disable
        exit 0
      fi

      # ESC or right click aborts slurp -> nothing to do
      geom=$(slurp -b 00000040 -c c0c0c0ff -w 2) || exit 0

      pos=''${geom%% *}
      dim=''${geom##* }
      x=''${pos%,*}
      y=''${pos#*,}
      w=''${dim%%x*}
      h=''${dim##*x}

      # monitor holding the centre of the selection: id, logical origin/size, physical size
      read -r mon mx my mlw mlh mpw mph < <(
        hyprctl monitors -j |
          jq -r --argjson cx "$((x + w / 2))" --argjson cy "$((y + h / 2))" '
            .[]
            | (.width / .scale) as $lw
            | (.height / .scale) as $lh
            | select($cx >= .x and $cx < .x + $lw and $cy >= .y and $cy < .y + $lh)
            | "\(.id) \(.x) \(.y) \($lw) \($lh) \(.width) \(.height)"' |
          head -n1
      ) || true
      [ -n "''${mon:-}" ] || exit 1

      # selection -> monitor-local 0..1 texture coords
      read -r u0 v0 u1 v1 < <(
        awk -v x="$x" -v y="$y" -v w="$w" -v h="$h" -v mx="$mx" -v my="$my" -v lw="$mlw" -v lh="$mlh" '
          BEGIN {
            u0 = (x - mx) / lw; v0 = (y - my) / lh
            u1 = (x + w - mx) / lw; v1 = (y + h - my) / lh
            if (u0 < 0) u0 = 0; if (v0 < 0) v0 = 0
            if (u1 > 1) u1 = 1; if (v1 > 1) v1 = 1
            printf "%.6f %.6f %.6f %.6f\n", u0, v0, u1, v1
          }'
      )

      cat > "$shader" <<EOF
      precision highp float;
      varying vec2 v_texcoord;
      uniform sampler2D tex;
      uniform int wl_output;

      const int  MON = $mon;
      const vec2 R0  = vec2($u0, $v0);
      const vec2 R1  = vec2($u1, $v1);
      const vec2 RES = vec2($mpw.0, $mph.0);

      const float CURVE  = 0.10;
      const float SCAN   = 0.22;
      const float MASK   = 0.26;
      const float CHROMA = 1.3;
      const float VIGN   = 0.45;
      const float GAIN   = 1.45;

      void main() {
          vec2 uv = v_texcoord;
          vec4 base = texture2D(tex, uv);

          if (wl_output != MON || uv.x < R0.x || uv.x > R1.x || uv.y < R0.y || uv.y > R1.y) {
              gl_FragColor = base;
              return;
          }

          vec2 size = R1 - R0;
          vec2 px   = size * RES;       // region size in physical pixels
          vec2 p    = (uv - R0) / size; // 0..1 inside the region

          // barrel distortion
          vec2 c = p * 2.0 - 1.0;
          c *= 1.0 + CURVE * vec2(c.y * c.y, c.x * c.x);
          vec2 q = c * 0.5 + 0.5;

          // outside the curved tube: bezel
          if (q.x < 0.0 || q.x > 1.0 || q.y < 0.0 || q.y > 1.0) {
              gl_FragColor = vec4(0.0, 0.0, 0.0, base.a);
              return;
          }

          // sample with chromatic aberration
          vec2 off = vec2(CHROMA / RES.x, 0.0);
          vec2 s   = R0 + q * size;
          vec3 col;
          col.r = texture2D(tex, s + off).r;
          col.g = texture2D(tex, s).g;
          col.b = texture2D(tex, s - off).b;

          // scanlines
          col *= 1.0 - SCAN * (0.5 + 0.5 * cos(q.y * px.y * 3.14159265));

          // aperture grille
          float m = mod(floor(q.x * px.x), 3.0);
          vec3 mask = vec3(1.0 - MASK);
          if (m < 1.0)      mask.r = 1.0 + MASK;
          else if (m < 2.0) mask.g = 1.0 + MASK;
          else              mask.b = 1.0 + MASK;
          col *= mask;

          // vignette + soft tube edge
          col *= 1.0 - VIGN * dot(c, c) * 0.25;
          vec2 e = min(q, 1.0 - q) * px;
          col *= smoothstep(0.0, 2.0, min(e.x, e.y));

          gl_FragColor = vec4(clamp(col * GAIN, 0.0, 1.0), base.a);
      }
      EOF

      # The shader displaces pixels (curvature + chromatic aberration), so a fragment
      # shows a texel from somewhere else. Hyprland only re-renders damaged regions,
      # which are computed at the source texel, not at the fragment that displays it —
      # hence smearing/trails around the cursor. Full damage while the tube is up.
      hyprctl getoption debug:damage_tracking -j | jq -r .int > "$damage_state"
      hyprctl keyword debug:damage_tracking 0 >/dev/null

      hyprctl keyword decoration:screen_shader "$shader" >/dev/null
      hyprctl dispatch submap crt >/dev/null
    '';
  };
in {
  home.packages = [crt-region pkgs.slurp];

  wayland.windowManager.hyprland.extraConfig = ''
    bind = SUPER SHIFT,C,exec,crt-region #"CRT Region"

    # while the effect is up, ESC (or the same bind) removes it.
    # ends with `submap = reset` so following binds stay global.
    submap = crt
    bind = ,ESCAPE,exec,crt-region off
    bind = SUPER SHIFT,C,exec,crt-region off
    submap = reset
  '';
}
