param (
    [string]$InputFile,
    [string]$SharedDataSource
)

# Define the service account variable
$ServiceAccount = "HKG\app_hk_pbiprd_adm"

# Help message if required parameters are missing
if ([string]::IsNullOrWhiteSpace($InputFile) -or [string]::IsNullOrWhiteSpace($SharedDataSource)) {
    Write-Host "`nUsage: .\UpdateXML.ps1 -InputFile <XML_File_Path> -SharedDataSource <New_Reference_Value>" -ForegroundColor Cyan
    Write-Host "`nDescription:"
    Write-Host "  This script updates the following fields in the XML file:"
    Write-Host "   - 'ModifiedBy' and 'Owner' → Replaced with '$ServiceAccount'"
    Write-Host "   - 'Reference' → Replaced with the specified '-SharedDataSource' argument"
    Write-Host "`nExample:"
    Write-Host "  .\UpdateXML.ps1 -InputFile `"C:\Temp\FO_CounterPartyAmendment.xml`" -SharedDataSource `"/hksynp01sql`"" -ForegroundColor Green
    exit 1
}

# Check if file exists
if (-Not (Test-Path $InputFile)) {
    Write-Host "Error: File not found - $InputFile" -ForegroundColor Red
    exit 1
}

# Load XML
[xml]$xml = Get-Content -Path $InputFile

# Define Namespace Manager
$namespaceMgr = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$namespaceMgr.AddNamespace("ps", "http://schemas.microsoft.com/powershell/2004/04")

# Modify 'ModifiedBy' and 'Owner' values using the ServiceAccount variable
$nodesToModify = $xml.SelectNodes("//ps:S[@N='ModifiedBy'] | //ps:S[@N='Owner']", $namespaceMgr)
foreach ($node in $nodesToModify) {
    $originalValue = $node.InnerText
    $node.InnerText = $ServiceAccount
    Write-Host "Updated '$($node.Attributes['N'].Value)' from '$originalValue' to '$ServiceAccount'" -ForegroundColor Yellow
}

# Modify 'Reference' values
$referenceNodes = $xml.SelectNodes("//ps:S[@N='Reference']", $namespaceMgr)
foreach ($node in $referenceNodes) {
    $originalValue = $node.InnerText
    $node.InnerText = $SharedDataSource
    Write-Host "Updated 'Data Source Reference' from '$originalValue' to '$SharedDataSource'" -ForegroundColor Yellow
}

# Save the updated XML back to the file
$xml.Save($InputFile)

Write-Host "Successfully updated 'ModifiedBy', 'Owner', and 'Data Source Reference' fields in $InputFile" -ForegroundColor Green
