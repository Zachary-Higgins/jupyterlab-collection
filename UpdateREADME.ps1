$nbs = Get-ChildItem notebooks -Recurse | where-object {$_.name -like '*.ipynb'} | Sort-Object {$_.FullName} | foreach-object {$_.FullName}

$elements = @()

$elements = "`r"
$elements += "|Subject|Title|Description|Link|`r"
$elements += "| ------- | ------- | ------- | ------- |`r"

foreach($nb in $nbs)
{
    if($nb -like '*.ipynb_checkpoints*')
    {
        continue
    }

    $json = ((get-content $nb) | ConvertFrom-json)
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
    $subject = $path.split("/")[1]

    $new = "|<sub>" + $subject +"</sub>|<sub>" + $title + "</sub>|<sub>" + $desc + "...</sub>|<sub>[" + $path + "](" + $path + ")</sub>|`r"

    $elements += $new
}


$pattern_end = "## Table of contents:"
$readme = (get-content README.md)
$end_pos = $readme.IndexOf($pattern_end)
$readme = $readme[0..$end_pos] -join "`r"

$new_readme = "$readme

$elements"

$new_readme | Out-File README.md -Force