$Global:variables = @{ "X" = 100; "Y" = 200; "xy" = 2; "yx" = 3; }

function EvaluateExpression {
    param ($Expression)

    "Original Statement : $($Expression)"

    $expressionVariables = @();
    $regex = [RegEx]'[a-zA-Z_]\w*';
    $regex.Matches($Expression) | ForEach-Object {
        if (-not $expressionVariables.Contains($_.Value)) { $expressionVariables += $_.Value; }
    }
    $expressionVariables | Sort-Object { $_.Length } -Descending | ForEach-Object {
        if ($variables.ContainsKey($_)) {
            $Expression = $Expression.Replace($_, $variables[$_]);
        };
    }
    $Expression = $Expression.Replace('$', '0x');

    "Modified Statement : $($Expression)"
    "Result : $(Invoke-Expression $Expression)"
}

Evaluate-Expression 'x + (y * yx) + xy + x'

Evaluate-Expression '$0801'