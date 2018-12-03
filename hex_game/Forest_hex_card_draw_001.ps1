<#Using my google sheet https://spreadsheets.google.com/feeds/list/1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc/od6/public/values
Creates a 'master deck' of cards using the rows with 'inuse' = 'y'
Creates separate decks for landscape, location, common, etc

Creates the terrain and foliage labels/icons based upon the number of symbols (indicating rarity), eg fff is forest with common rarity - creates [Green][Forest] labels

Can select from various decks, draw a card, change the current terrain, shuffle the decks

#>

Import-Module $PSScriptRoot\Get-GoogleSheet.psm1 #$GetGoogleSheet_path

#select cards matching deck and foliage or terrain or wildness
function get_card_selection($all_cards, $deck_type, $foliage, $terrain, $wildness){ #select cards that have not been discarded
    $selection = $all_cards | ?{($_.sourcedeck -eq "$deck_type" -and $_.deck -ne "discard" -and $_.additionalcards -ne "Drawn")} # -and $_.type -eq "Location")} 
    #TODO: this looks for foliage OR terrain to match (what if they both need to match?)
    
    #comment out next line to just draw card after card from the selected deck (ie like real life)
    #$selection = $selection | ?{$_.foliageicons -like "*$foliage*" -or $_.terrainicons -like "*$terrain*" -or ($_.foliageicons -eq "" -and $_.terrainicons -eq "")}
    return $selection
}

if($("No", "Yes" | ogv -PassThru -Title "Reload google sheet?") -eq "Yes"){

<# Get cards _____________________________________________________________________________________________________________________#>
    $root = Get-GoogleSheet "https://spreadsheets.google.com/feeds/list/1MabkaqSrzaTlcWAde5Or6l7rKXa54J3NxaaW60olkVc/od6/public/values"
    $raw_cards = @()
    foreach($category in $root.entry) #.ChildNodes)
    {
        $raw_cards += $category | select * -ExcludeProperty id,updated,category,title,content,link,LocalName,NamespaceURI,Prefix,NodeType,ParentNode,OwnerDocument,IsEmpty,Attributes,HasAttributes,SchemaInfo,InnerXml, InnerText,NextSibling,PreviousSibling,Value,ChildNodes,FirstChild,LastChild,HasChildNodes,IsReadOnly,OuterXml,BaseURI,PreviousText
    }

    $raw_cards | %{$_.deck = $_.sourcedeck; if($_.count -eq ""){$_.count = 1}}

    #only include cards that are "in use" = 'y' on the spreadsheet
    $raw_cards = $raw_cards | ?{($_.inuse -eq "y")}

    $cards = @()
    foreach($card in $raw_cards){
        $count = 0      
        $card_count = $card.count
        if($card.count -eq ""){$card_count = 1}
        for($i=0; $i -lt $card_count; $i++){
            $temp_card = $card.psobject.copy()
            
            ### determine foliage icons (ie rarity) based on number of symbols in web sheet - eg mmmhhp means mountain green/common, hills yellow/fairly common, plains red/rare
            ### eg symbols fffs	creates: [Forest_Green][Scrub_Red]            
            foreach($letter in ($temp_card.foliage.tochararray() | sort | get-unique)){ 
                $count = ([regex]::matches($temp_card.foliage, $letter)).count
                #if( (1/(([regex]::matches($temp_card.foliage, $letter)).count))*$i -ge 1) {$foliageicons += $letter}  
                #"$($card.name) $($card.foliage), count $i, % $((1/(([regex]::matches($temp_card.foliage, $letter)).count))*$i), icons $foliageicons"
                switch($count){
                    1 {$color = "Red"}
                    2 {$color = "Yellow"}
                    3 {$color = "Green"}
                }
                switch($letter){
                    "f" {$foliage = "Forest"}
                    "s" {$foliage = "Scrub"}
                    "g" {$foliage = "Grass"}
                    "b" {$foliage = "Barren"}

                }
                #"$foliage`_$color"
                $temp_card.foliageicons+="[$foliage`_$color]"                     
            }

            #determine terrain icons (ie rarity) based on number of symbols in web sheet - eg mmmhhp means mountain green/common, hills yellow/fairly common, plains red/rare
            #eg symbols mmmhh creates: [Mountain_Green][Hill_Yellow]
            
            foreach($letter in ($temp_card.terrain.tochararray() | sort | get-unique)){
                $count = ([regex]::matches($temp_card.terrain, $letter)).count
                #if( (1/(([regex]::matches($temp_card.foliage, $letter)).count))*$i -ge 1) {$foliageicons += $letter}  
                #"$($card.name) $($card.foliage), count $i, % $((1/(([regex]::matches($temp_card.foliage, $letter)).count))*$i), icons $foliageicons"
                switch($count){
                    1 {$color = "Red"}
                    2 {$color = "Yellow"}
                    3 {$color = "Green"}
                }
                switch($letter){

                    "m" {$terrain = "Mountain"}
                    "h" {$terrain = "Hill"}
                    "p" {$terrain = "Plain"}
                }
                #"$terrain`_$color"
                $temp_card.terrainicons+="[$terrain`_$color]"                     
            }

            #determine wildness icons (ie rarity) based on number of symbols in web sheet - eg mmmhhp means mountain green/common, hills yellow/fairly common, plains red/rare
            #eg symbols bbbw creates [Border_Green][Wild_Red]
            
            foreach($letter in ($temp_card.wildness.tochararray() | sort | get-unique)){
                $count = ([regex]::matches($temp_card.wildness, $letter)).count
                #if( (1/(([regex]::matches($temp_card.foliage, $letter)).count))*$i -ge 1) {$foliageicons += $letter}  
                #"$($card.name) $($card.foliage), count $i, % $((1/(([regex]::matches($temp_card.foliage, $letter)).count))*$i), icons $foliageicons"
                switch($count){
                    1 {$color = "Red"}
                    2 {$color = "Yellow"}
                    3 {$color = "Green"}
                }
                switch($letter){

                    "w" {$wildness = "Wild"}
                    "b" {$wildness = "Border"}
                    "p" {$wildness = "Settled"}
                }
                #"$terrain`_$color"
                $temp_card.wildnessicons+="[$wildness `_$color]"                     
            }
            $cards += $temp_card
        }        
        
    }

    #$cards = $cards | ? {![string]::IsNullOrEmpty($_.tokencard)}

    "Cards loaded"
}

#$cards_untouched = $cards.psobject.copy()

$foliage = "Forest"
$terrain = "Mountain"
$wildness = "Wild"
$deck = "Location"

    while(1){
        
        switch($("Draw card","Exit", "Change terrain", "Change foliage", "Change wildness", "Select deck", "Shuffle deck",  "View all cards", `
        "*** Currently: $foliage $terrain $wildness, deck $deck ($(($cards | ?{($_.sourcedeck -eq "$deck" -and $_.deck -ne "discard" -and $_.additionalcards -ne "Drawn")}).count)) ***" `
         | ogv -PassThru -Title "Select Command"))
        {
            "Draw card" {
                $selection = get_card_selection $cards $deck $foliage $terrain $wildness; 
                $selected_card = $selection[(get-random -min 0 -max ($selection.count - 1))];
                $selected_card.additionalcards = "Drawn"
                $selected_card | select name, description, type, sourcedeck, count | ogv -PassThru -title "Card draw: $deck $foliage $terrain $wildness"}
            "Exit" {exit}
            "Select deck" {$deck = @("Landscape","Location","Common", "Uncommon", "Rare") | ogv -PassThru -title "Select deck"}
            "Shuffle deck" {$cards | % {if($_.additionalcards -eq "Drawn" -and $_.sourcedeck -eq $deck) {$_.additionalcards = ""}}} #THIS IS NOT WORKING YET
            "Change terrain" {$terrain = @("Mountain", "Hill", "Plain") | ogv -PassThru -title "Select new terrain"}
            "Change foliage" {$foliage = @("Forest","Scrub","Grass","Barren") | ogv -PassThru -title "Select new foliage"}
            "Change wildness" {$wildness = @("Wild", "Border", "Settled") | ogv -PassThru -title "Select new wildness"}
            "View all cards" {$cards | ogv -PassThru -Title "Viewing all cards"}

            default {}
        }

        
        #$selection = get_card_selection $cards $deck "forest" "mountain" "test"

    }