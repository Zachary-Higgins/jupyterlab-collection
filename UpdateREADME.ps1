$nbs = Get-ChildItem notebooks -Recurse | where-object {$_.name -like '*.ipynb'}

$elements = @()

$elements = "<font size = `"2`">"
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

    $new = "|" + $subject +"|" + $title + "|" + $desc + "...|[" + $path + "](" + $path + ")|`r"

    $elements += $new
}


$pattern = "## Table of contents:"
$readme = (get-content README.md)

$start_pos = $readme.IndexOf($pattern)
$new_readme = $readme[0..$start_pos]
$new_readme += $elements
$new_readme += "</font>"

$new_readme | Out-File README.md -Force