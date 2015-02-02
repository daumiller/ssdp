SSDP
====

### Simple SSDP Ruby Gem. ###

* Doesn't require a full UPnP library.
* Supports both client and server functionality.
  * producer [**respond-to-search**, **notify**, **bye**]
  * consumer [**search**, **monitor**]

### SSDP Protocol ###
* [Overview](http://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol)
* [Draft Spec.](https://tools.ietf.org/html/draft-cai-ssdp-v1-03)

### Documentation ###
* [SSDP](doc/ssdp.md)
* [SSDP::Producer](doc/producer.md) *(server)*
* [SSDP::Consumer](doc/consumer.md) *(client)*

### Examples ###
* [Roku device pause/play](example/roku_play_pause.rb)

### Installation ###
`gem install ssdp`

### License ###
[BSD 2-Clause](LICENSE)
