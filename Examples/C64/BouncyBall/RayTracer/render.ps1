
Import-Module ".\MathHelper.ps1"
Import-Module ".\Point.ps1"
Import-Module ".\Vector.ps1"

# & "$PSScriptRoot\MathHelper.ps1"
# & "$PSScriptRoot\Point.ps1"
# & "$PSScriptRoot\Vector.ps1"

# $filename = "$home\foo.png" 
# $bmp = new-object System.Drawing.Bitmap 128, 128

# $bmp.SetPixel(10, 10, [System.Drawing.Color]::FromArgb(0, 0, 0))

# $bmp.Save($filename)

# Invoke-Item $filename

# class Math {

#     static [double] Clamp([double] $value, [double] $min, [double] $max) {
#         if ($value -le $min) { return $min; }
#         if ($value -ge $max) { return $max; }
#         return $value;
#     }
#     static [double] ScaleAndClamp([double] $value, [double] $scale, [double] $min, [double] $max) {
#         return [Math]::Clamp($value * $scale, $min, $max);
#     }
# }

# class Point {
#     [double]$X
#     [double]$Y
#     [double]$Z

#     Point() { $this.X = 0.0; $this.Y = 0.0; $this.Z = 0.0; }
#     Point([double] $x, [double] $y, [double] $z) { $this.X = $x; $this.Y = $y; $this.Z = $z; }

#     [Point] Plus([Vector] $vector) {
#         return [Point]::new($this.X + $vector.X, $this.Y + $vector.Y, $this.Z + $vector.Z);
#     }

#     [string] ToString() {
#         return "$($this.X),$($this.Y),$($this.Z)"
#     }
# }
# class Vector {
#     [double]$X
#     [double]$Y
#     [double]$Z

#     Vector() { $this.X = 0.0; $this.Y = 0.0; $this.Z = 0.0; }
#     Vector([double] $x, [double] $y, [double] $z) { $this.X = $x; $this.Y = $y; $this.Z = $z; }

#     [Vector] Plus([Vector] $vector) {
#         return [Vector]::new($this.X + $vector.X, $this.Y + $vector.Y, $this.Z + $vector.Z);
#     }
#     [Vector] Scale([double] $scale) {
#         return [Vector]::new($this.X * $scale, $this.Y * $scale, $this.Z * $scale);
#     }
#     static [Vector] OriginFromPoint([Point] $point) {
#         return [Vector]::new($point.X, $point.Y, $point.Z);
#     }

#     [double] DotProduct([Vector] $vector) {
#         return ($this.X * $vector.X) + ($this.Y * $vector.Y) + ($this.Z * $vector.Z);
#     }
# }
class Sphere {
    [Point] $Origin = [Point]::new();
    $Radius = 1.0;

    [string] ToString() {
        return "Sphere(Origin=$($this.Origin.ToString()),Radius=$($this.Radius))"
    }
}

class Intersection {
    $Object
    [double] $Distance

    Intersection($object, [double] $distance) {
        $this.Object = $object; $this.Distance = $distance;
    }
    [string] ToString() {
        return "Intersection(Object=$($this.Object.ToString()), Distance=$($this.Distance))"
    }
}


class Ray {
    [Point]$Origin
    [Vector]$Direction

    Ray() { $this.Origin = [Point]::new(); $this.Direction = [Vector]::new(); }
    Ray([Point] $origin, [Vector] $direction) { $this.Origin = $origin; $this.Direction = $direction; }

    [Point] Position([double] $distance) {
        return $this.Origin.Plus($this.Direction.Scale($distance));
    }


    [Array] Intersects([Sphere] $sphere) {
        $sphereDirection = [Vector]::OriginFromPoint($this.Origin);
        $a = $this.Direction.DotProduct($this.Direction);
        $b = 2.0 * $this.Direction.DotProduct($sphereDirection);
        $c = $sphereDirection.DotProduct($sphereDirection) - 1.0;

        $discriminant = ($b * $b) - ( 4.0 * $a * $c);
        if ($discriminant -lt 0.0) { return @(); }

        return @(
            [Intersection]::new($sphere, (-$b - [System.Math]::Sqrt($discriminant)) / (2.0 * $a));
            [Intersection]::new($sphere, (-$b + [System.Math]::Sqrt($discriminant)) / (2.0 * $a));
        );
    }
}


class RGBColor {
    [double]$Red
    [double]$Green
    [double]$Blue

    RGBColor() { $this.Red = 0.0; $this.Green = 0.0; $this.Blue = 0.0; }
    RGBColor([double] $red, [double] $green, [double] $blue) { $this.Red = $red; $this.Green = $green; $this.Blue = $blue; }

    [System.Drawing.Color]ToColor() {
        return [System.Drawing.Color]::FromArgb([Math]::ScaleAndClamp($this.Red, 255, 0, 255),
                                                [Math]::ScaleAndClamp($this.Green, 255, 0, 255),
                                                [Math]::ScaleAndClamp($this.Blue, 255, 0, 255))
    }
    [RGBColor]Plus([RGBColor]$color) {
        return ]RGBColor]::new($this.Red + $color.Red, $this.Green + $color.Green, $this.Blue + $color.Blue);
    }
    [RGBColor]Times([RGBColor]$color) {
        return ]RGBColor]::new($this.Red * $color.Red, $this.Green * $color.Green, $this.Blue * $color.Blue);
    }
    [RGBColor]Scale([double]$scale) {
        return ]RGBColor]::new($this.Red * $scale, $this.Green * $scale, $this.Blue * $scale);
    }
}

class Canvas {
    $Bitmap

    Canvas($width, $height) {
        $this.Bitmap = New-Object System.Drawing.Bitmap $width, $height
    }

    [void]Save($filename) {
        $this.Bitmap.Save($filename);
    }

    [void]SetPixel($x, $y, [RGBColor]$color) {
        $this.Bitmap.SetPixel($x, $y, $color.ToColor())
    }
}


class RayTracer {
    $Canvas


    RayTracer($width, $height) {
        $this.Canvas = [Canvas]::new($width, $height);
    }
}

$ray = [Ray]::new([Point]::new(2,3,4), [Vector]::new(1,0,0));
$ray.Position(0.0);
$ray.Position(1.0);


$sphere = [Sphere]::new();

[Ray]::new([Point]::new(0,0,-5), [Vector]::new(0,0,1)).Intersects($sphere) | `
ForEach-Object {
    $_.ToString();
}

return;

[Ray]::new([Point]::new(0,1,-5), [Vector]::new(0,0,1)).Intersects($sphere);
[Ray]::new([Point]::new(0,2,-5), [Vector]::new(0,0,1)).Intersects($sphere);
[Ray]::new([Point]::new(0,0,0), [Vector]::new(0,0,1)).Intersects($sphere);
[Ray]::new([Point]::new(0,0,5), [Vector]::new(0,0,1)).Intersects($sphere);

return;

$raytracer = [RayTracer]::new(128, 128);

$raytracer.Canvas.SetPixel(10, 10, [RGBColor]::new(0, 0, 0));
$raytracer.Canvas.SetPixel(11, 10, [RGBColor]::new(1, 0, 0));
$raytracer.Canvas.SetPixel(12, 10, [RGBColor]::new(0, 1, 0));
$raytracer.Canvas.SetPixel(13, 10, [RGBColor]::new(0, 0, 1));
$raytracer.Canvas.SetPixel(14, 10, [RGBColor]::new(1, 1, 1));
$raytracer.Canvas.SetPixel(15, 10, [RGBColor]::new(0.5, 0.5, 0.5));


$filename = "$home\image.png"
$raytracer.Canvas.Save($filename);
Invoke-Item $filename