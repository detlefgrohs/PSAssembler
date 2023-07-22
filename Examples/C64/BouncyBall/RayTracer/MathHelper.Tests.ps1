
Describe 'MathHelper::Clamp' {
    BeforeAll {
        . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    }

    It 'Clamp Passes Through' {
        [MathHelper]::Clamp(100, 0, 255) | Should Be 100
    }
    It 'Clamp To Min' {
        [MathHelper]::Clamp(-100, 0, 255) | Should Be 0
    }
    It 'Clamp To Max' {
        [MathHelper]::Clamp(300, 0, 255) | Should Be 255
    }
}

Describe 'MathHelper::ScaleAndClamp' {
    BeforeAll {
        . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    }

    It 'ScaleAndClamp 0.0' {
        [MathHelper]::ScaleAndClamp(0.0, 255, 0, 255) | Should Be 0.0
    }
    It 'ScaleAndClamp 0.5' {
        [MathHelper]::ScaleAndClamp(0.5, 255, 0, 255) | Should Be 127.5
    }
    It 'ScaleAndClamp 1.0' {
        [MathHelper]::ScaleAndClamp(1.0, 255, 0, 255) | Should Be 255.0
    }
}