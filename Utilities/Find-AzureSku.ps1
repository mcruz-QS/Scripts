function Find-AzureSKU  {

    Param (
    [parameter(HelpMessage="provide partial name of sku")]
    [String] $sku,
    [parameter(HelpMessage="'get-azurermlocation | select location' for list of locations")]
    [String] $location='Central US',
    [String] $publisherName = "Microsoft"
      )

    if ($publisher){
            $publishers = Get-AzureRmVMImagePublisher -location $location | where-object PublisherName -Match $publisherName
        }else{
            $publishers = Get-AzureRmVMImagePublisher -location $location
        }
    foreach ($publisher in $publishers) {
       $offers=Get-AzureRmVMImageOffer -location $location `
                                       -PublisherName $publisher.PublisherName

      foreach ($offer in $offers) {
         if ($offer.offer -LIKE "*$sku*") {
           Get-AzureRmVMImageSku -Location $location `
                                 -PublisherName $publisher.PublisherName `
                                 -Offer $offer.offer
        }
     }
    }
   }