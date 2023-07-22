class MathHelper {
    static [double] Clamp([double] $value, [double] $min, [double] $max) {
        if ($value -le $min) { return $min; }
        if ($value -ge $max) { return $max; }
        return $value;
    }
    static [double] ScaleAndClamp([double] $value, [double] $scale, [double] $min, [double] $max) {
        return [Math]::Clamp($value * $scale, $min, $max);
    }
}