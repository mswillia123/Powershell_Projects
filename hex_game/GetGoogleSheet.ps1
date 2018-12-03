# GET LIST FROM GOOGLE SPREADSHEET
#gets the list with column headers from a published google sheet
#getting the list gets full rows with headers
#getting the cells gets individual cells
#http://damolab.blogspot.ca/2011/03/od6-and-finding-other-worksheet-ids.html

#get the key from the published sheet and include here in the url .../list/<key>/od6/...

#http://blog.haake.nu/2015/02/use-google-sheets-cell-content-in-script.html
#https://developers.google.com/gdata/samples/spreadsheet_sample
#https://developers.google.com/google-apps/spreadsheets/data

#to determine the sheet id: https://spreadsheets.google.com/feeds/worksheets/<KEY>/private/full, then find worksheet code (default/first sheet is 'od6')
#ie ...//spreadsheets.google.com/feeds/cells/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/od6/private/full...
#look for ...//spreadsheets.google.com/feeds/cells/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/<worksheet code>/private/full


#$CellA1 = Invoke-WebRequest -UseBasicParsing -Uri https://spreadsheets.google.com/feeds/cells/18qdDkCbzLdogdTvjw-lRRTD5ifkRvZ4bOwgPaigbdyo/od6/public/basic?range=A1:A5 #/R1C1
#$CellA1 = Invoke-WebRequest -UseBasicParsing -Uri https://spreadsheets.google.com/feeds/cells/18qdDkCbzLdogdTvjw-lRRTD5ifkRvZ4bOwgPaigbdyo/od6/public/values #/R1C1
#$CellA1 = Invoke-WebRequest -UseBasicParsing -Uri https://spreadsheets.google.com/feeds/list/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/od6/public/values #/R1C1
$CellA1 = Invoke-WebRequest -UseBasicParsing -Uri https://spreadsheets.google.com/feeds/list/1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc/od6/public/values #/R1C1
#1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc

#https://docs.google.com/spreadsheets/d/1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc/edit?usp=sharing
#$CellA1 = Invoke-WebRequest -UseBasicParsing -Uri https://spreadsheets.google.com/feeds/list/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/or5qzhc/public/values #/R1C1
#$CellA1 = Invoke-WebRequest -UseBasicParsing -Uri http://spreadsheets.google.com/feeds/cells/o13394135408524254648.240766968415752635/od6/public/values #/R1C1
#http://spreadsheets.google.com/feeds/cells/o13394135408524254648.240766968415752635/od6/public/values
#https://docs.google.com/spreadsheets/d/1lo8W6CpjrI3f3JKERHuuK0jx-VYY8F44zBW7FegewF0/pubhtml
$Value = (($CellA1 -split "<content type=.text.>") -split "</content")#[1]


$content = $CellA1.content
[xml]$xml = [xml]$content
[System.Xml.XmlElement] $root = $xml.get_DocumentElement()

[System.Xml.XmlElement] $categories = $root.entry

[System.Xml.XmlElement] $category = $null
$list = @()
foreach($category in $root.entry) #.ChildNodes)

{

#$list += $category | select Sort,NAME,AC,HD,MV,THAC0,ATK,DMG,SV,ML,TT,AL,LV,XP,PAGE,TERRAIN,Description
#$list += $category | select 
$list += $category | select * -ExcludeProperty id,updated,category,title,content,link,LocalName,NamespaceURI,Prefix,NodeType,ParentNode,OwnerDocument,IsEmpty,Attributes,HasAttributes,SchemaInfo,InnerXml, InnerText,NextSibling,PreviousSibling,Value,ChildNodes,FirstChild,LastChild,HasChildNodes,IsReadOnly,OuterXml,BaseURI,PreviousText
#[string] $title = $category.'#text'

#[string] $description = $category.Description

#Write-Host (“Title={0},Description={1}” -f $title,$description)

}

$list | FT
<#

$list = @()

foreach($branch in $tree.ChildNodes)
{
    if(!([string]::isnullorempty($branch.content.'#text'))){
    $list += $branch.content.'#text'
    }

    echo "branch: $($branch.content | gm)"

}

#$list

#>



$skillcards = $list | ? {$_.Type -eq "Skill"} 

$skillcards | ft

$skillcards[(get-random -minimum 0 -maximum $skillcards.count)]
