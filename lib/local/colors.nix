{lib, ...}: let
  abs = x:
    if x < 0.0
    then -x
    else x;
  mod = dividend: divisor: let
    quotient = dividend / divisor;
    quotient_floor = builtins.floor quotient;
    remainder = dividend - quotient_floor * divisor;
  in
    if divisor == 0
    then builtins.NaN
    else if remainder == divisor
    then 0.0
    else remainder;
in rec {
  rgbString2Rgb = string: let
    values =
      builtins.split ","
      (builtins.replaceStrings ["rgb(" ")"] ["" ""] string);
    get = n: builtins.fromJSON (builtins.elemAt values n);
  in
    lib.mapAttrs (_: builtins.floor  )
    {
    r = get 0;
    g = get 2;
    b = get 4;
  };
  splitHex = hex: {
    r = builtins.substring 0 2 hex;
    g = builtins.substring 2 2 hex;
    b = builtins.substring 4 2 hex;
  };
  dec2Hex = dec:
    (lib.strings.fixedWidthString 2 "0") (
      lib.toHexString dec
    );
  hex2Rgb = hex: lib.mapAttrs (_: lib.fromHexString) (splitHex hex);

  rgb2Hex = rgb: "${dec2Hex rgb.r}${dec2Hex rgb.g}${dec2Hex rgb.b}";

  rgb2Hsl = rgb: let
    r = rgb.r / 255.0;
    g = rgb.g / 255.0;
    b = rgb.b / 255.0;
    max = lib.max r (lib.max g b);
    min = lib.min r (lib.min g b);
    delta = max - min;
    l = (max + min) / 2.0;
    s =
      if delta == 0.0
      then 0.0
      else delta / (1.0 - abs (2.0 * l - 1.0));
    h =
      if delta == 0.0
      then 0.0
      else if max == r
      then 60.0 * (mod ((g - b) / delta) 6.0)
      else if max == g
      then 60.0 * (((b - r) / delta) + 2.0)
      else 60.0 * (((r - g) / delta) + 4.0);
  in {
    h =
      if h < 0.0
      then h + 360.0
      else h;
    inherit s l;
  };

  hsl2Rgb = hsl: let
    h = hsl.h;
    s = hsl.s;
    l = hsl.l;

    a = s * (lib.min l (1 - l));
    f = n: let
      k = mod (n + h / 30.0) 12;
    in
      builtins.floor (255 * (l - a * (lib.max (-1) (lib.min (k - 3) (lib.min 1 (9 - k))))));
  in {
    r = f 0;
    g = f 8;
    b = f 4;
  };
  mix = hex1: hex2: percent: let
    hsl = rgb2Hsl (hex2Rgb hex1);
    hsl2 = rgb2Hsl (hex2Rgb hex2);
    h = hsl.h + ((hsl2.h - hsl.h) * percent / 100.0);
    s = hsl.s + ((hsl2.s - hsl.s) * percent / 100.0);
    l =   hsl.l + ((hsl2.l - hsl.l) * percent / 100.0);
  in
    rgb2Hex (
      hsl2Rgb {
        h =
          if h < 0.0
          then h + 360.0
          else if h > 360.0
          then h - 360.0
          else h;
        s =
          if s > 1.0
          then 1.0
          else if s < 0.0
          then 0.0
          else s;
        l =
          if l > 1.0
          then 1.0
          else if l < 0.0
          then 0.0
          else l;
      }
    );
  lighten = hex: percent: let
    hsl = rgb2Hsl (hex2Rgb hex);
    l = hsl.l + (percent / 100.0);
  in
    rgb2Hex
    (hsl2Rgb {
      inherit (hsl) h s;
      l =
        if l > 1.0
        then 1.0
        else if l < 0.0
        then 0.0
        else l;
    });
}
