#class Vector {}
Write-Host "Including Point"

class Point {
    [double]$X
    [double]$Y
    [double]$Z

    Point() { $this.X = 0.0; $this.Y = 0.0; $this.Z = 0.0; }
    Point([double] $x, [double] $y, [double] $z) { $this.X = $x; $this.Y = $y; $this.Z = $z; }

    [Point] Plus($vector) {
        return [Point]::new($this.X + $vector.X, $this.Y + $vector.Y, $this.Z + $vector.Z);
    }

    [string] ToString() {
        return "$($this.X),$($this.Y),$($this.Z)"
    }
}