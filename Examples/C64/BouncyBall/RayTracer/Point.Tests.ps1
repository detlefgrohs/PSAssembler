Describe 'Point' {
    BeforeAll {
        . $PSCommandPath.Replace('.Tests.ps1','.ps1')
        . $PSScriptRoot/Vector.ps1
    }

    It 'Default Constructor' {
        $point = [Point]::new();
        $point.X | Should Be 0.0
        $point.Y | Should Be 0.0
        $point.Z | Should Be 0.0
    }
    It 'Constructor' {
        $point = [Point]::new(1.0,2.0,3.0);
        $point.X | Should Be 1.0
        $point.Y | Should Be 2.0
        $point.Z | Should Be 3.0
    }
    It 'Plus Vector' {
        $point = [Point]::new(1.0,2.0,3.0);
        $newPoint = $point.Plus([Vector]::new(4.0, 5.0, 6.0));
        $newPoint.X | Should Be 5.0
        $newPoint.Y | Should Be 7.0
        $newPoint.Z | Should Be 9.0
    }
}