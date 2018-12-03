<# Get cards from google sheet "Mike Hex_game_cards"

    gets the list with column headers from a published google sheet
    getting the list gets full rows with headers
    getting the cells gets individual cells
    http://damolab.blogspot.ca/2011/03/od6-and-finding-other-worksheet-ids.html

    get the key from the published sheet and include here in the url .../list/<key>/od6/...

    http://blog.haake.nu/2015/02/use-google-sheets-cell-content-in-script.html
    https://developers.google.com/gdata/samples/spreadsheet_sample
    https://developers.google.com/google-apps/spreadsheets/data

    to determine the sheet id: https://spreadsheets.google.com/feeds/worksheets/<KEY>/private/full, then find worksheet code (default/first sheet is 'od6')
    ie ...//spreadsheets.google.com/feeds/cells/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/od6/private/full...
    look for ...//spreadsheets.google.com/feeds/cells/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/<worksheet code>/private/full
#>

#https://spreadsheets.google.com/feeds/list/1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc/od6/public/values #/R1C1


#example: Get-GoogleSheet "https://spreadsheets.google.com/feeds/list/1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc/od6/public/values"

function Get-GoogleSheet 
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $uri
    )

$sheet = Invoke-WebRequest -UseBasicParsing -Uri $uri
$content = $sheet.content
[xml]$xml = [xml]$content
[System.Xml.XmlElement] $root = $xml.get_DocumentElement()
#[System.Xml.XmlElement] $categories = $root.entry
[System.Xml.XmlElement] $category = $null
return $root

}
