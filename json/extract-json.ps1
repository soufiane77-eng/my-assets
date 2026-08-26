param(
    [Parameter(Mandatory=$true)]
    [string]$JsonFile,
    
    [string[]]$ExtraAttributes = @()
)

$json = Get-Content $JsonFile -Raw | ConvertFrom-Json

Write-Host "=== SOURCE URL ===" -ForegroundColor Cyan
Write-Host $json.data.sourceUrl
Write-Host ""
Write-Host "=== VIEWPORT ===" -ForegroundColor Cyan
Write-Host ($json.data.viewport | ConvertTo-Json -Compress)
Write-Host ""

$baseAttrs = @('href', 'src', 'alt', 'aria-label', 'data-testid', 'role', 'placeholder')
$allAttrs = $baseAttrs + $ExtraAttributes

function Get-ContentNodes($node, $depth=0) {
    $indent = "  " * $depth
    
    if ($node.text -and $node.text.Trim().Length -gt 0) {
        Write-Host "$indent[TEXT]: $($node.text.Trim())"
    }
    
    if ($node.attributes) {
        foreach ($attr in $allAttrs) {
            $val = $node.attributes.$attr
            if ($val -and $val.Length -gt 0) {
                Write-Host "$indent[$($attr.ToUpper())]: $val"
            }
        }
    }
    
    if ($node.children) {
        foreach ($child in $node.children) {
            Get-ContentNodes $child ($depth + 1)
        }
    }
}

Write-Host "=== CONTENT TREE ===" -ForegroundColor Cyan
Get-ContentNodes $json.data.root
