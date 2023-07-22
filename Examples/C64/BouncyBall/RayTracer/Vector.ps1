#class Point {}

class Vector {
    [double]$X
    [double]$Y
    [double]$Z

    Vector() { $this.X = 0.0; $this.Y = 0.0; $this.Z = 0.0; }
    Vector([double] $x, [double] $y, [double] $z) { $this.X = $x; $this.Y = $y; $this.Z = $z; }

    [Vector] Plus([Vector] $vector) {
        return [Vector]::new($this.X + $vector.X, $this.Y + $vector.Y, $this.Z + $vector.Z);
    }
    [Vector] Scale([double] $scale) {
        return [Vector]::new($this.X * $scale, $this.Y * $scale, $this.Z * $scale);
    }
    static [Vector] OriginFromPoint($point) {
        return [Vector]::new($point.X, $point.Y, $point.Z);
    }

    [double] DotProduct([Vector] $vector) {
        return ($this.X * $vector.X) + ($this.Y * $vector.Y) + ($this.Z * $vector.Z);
    }
}