$nbs = Get-ChildItem notebooks -Recurse | where-object {$_.name -like '*.ipynb'}

$elements = @()

$elements = "`r"
$elements += "|Subject|Title|Description|Link|`r"
$elements += "| ------- | ------- | ------- | ------- |`r"

foreach($nb in $nbs)
{
    if($nb.FullName -like '*.ipynb_checkpoints*')
    {
        continue
    }

    $subject = $path.split("/")[1]

    $json = ((get-content $nb.FullName) | ConvertFrom-json)
    $cell = $json.cells[0].source
    $cell_elements = $cell.Split([Environment]::NewLine)
    $cell_elements = $cell_elements | Where-Object({($_ -ne '')})


    $title = $cell_elements[0].replace("# ","")
    
    $desc = $cell_elements[1]
    if($desc.Length -gt 99)
    {
        $desc = $desc.Substring(0, 100)
    }

    $path = ($nb | Resolve-Path -Relative).replace(".\","").replace("\","/")

    $new = "|<sub><sup>" + $subject +"</sup></sub>|<sub><sup>" + $title + "</sup></sub>|<sub><sup>" + $desc + "...</sup></sub>|<sub><sup>[" + $path + "](" + $path + ")</sup></sub>|`r"

    $elements += $new
}


$pattern_end = "## Table of contents:"
$readme = (get-content README.md)
$end_pos = $readme.IndexOf($pattern_end)
$readme = $readme[0..$end_pos] -join "`r"

$new_readme = "$readme

$elements"

$new_readme | Out-File README.md -Force