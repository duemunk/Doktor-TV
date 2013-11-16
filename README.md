# Doktor-TV
Vi vil lave en App til streaming af DR's video materiale via deres [API](http://www.dr.dk/mu/).
Vi ønsker ikke at duplikere funktionalitet af DR's services, såsom live stream data på andre servere.

Det er vigtigt for os at vi kun i minimal grad laver redundant funktionalitet, således at data forbliver mellem DR og slutbrugeren.
Med andre ord, ønsker vi at holde os ude af denne kommunikation så meget som muligt. Dog ønsker vi også at give brugeren en god oplevelse.

## Funktionalitet i version 1
Det skal være muligt at ...

* Søge i udsendelser og serier.
* Hente en komplet liste over alle udsendelser og serier.
* Lagring af information omkring valgte udsendelser på en service (til brug ved PUSH).
* Få PUSH beskeder omkring opdateringer af serier.

### Søgning på udsendelser og serier / Hentning af komplet liste
Følgende informationer skal benyttes til visning i Appen:

* Overskrift/Navn på udsendelsen
* Beskrivende tekst omkring udsendelsen.
* Billede af serien.
* Liste af de seneste 10 episoder (se Liste af episoder)

### Liste af episoder.
Vi starter med blot at vise de første 10 episoder. Senere kan vi udvide dette til søgning.    
Følgende informationer skal benyttes til visning i Appen:

* Overskrift/Navn på episoden.
* Beskrivende tekst omkring episoden.
* Billede af episoden.

### PUSH-service
Det er muligt at få besked omkring opdateringer til information i appen ved brug af en PUSH-service.
Dette ønskes blot at være en ekstra service, som giver ekstra funktionalitet, men som i reglen ikke er nødendig for at Appen virker.

### Servicen skal virke således:
Det skal være muligt at registerer udsendelser i en service og få besked om opdateringer, når disse sker.
I den forbindelse skal følgende information sendes med:

* Et unikt ID der følger telefonen.
* Et unikt ID (Slug) på serien.
* En måde hvorpå telefonen kan kaldes igennem Apples/Googles PUSH netværk.


## DR API
http://www.dr.dk/mu

### Eksempel på data fra en episode
http://www.dr.dk/mu/manifest/urn:dr:mu:manifest:5280b5ec6187a20b6c913965

```
Hvis du erstatter 'rtmp://vod.dr.dk/cms/mp4:CMS' med 'http://vodfiles.dr.dk/CMS' virker det på http.
```

### Eksempel på en mp4 fil
http://vodfiles.dr.dk/CMS/Resources/dr.dk/NETTV/DR3/2013/11/dd50a214-8aee-4c6a-8631-70a0c671a1b1/BoesseStudier---Stereotyper--2_9a4fb08b27d24c46992e81bd967a52b4_122.mp4?ID=1629336



## Projektnavne
* Doktor TV
* Doktor DR
* DR R.... (rekursiv akronym)
* DRown or DReam
* Dr. TV



## iOS

### Submodules
#### AFNetworking
https://github.com/AFNetworking/AFNetworking
#### KeepLayout
https://github.com/iMartinKiss/KeepLayout


