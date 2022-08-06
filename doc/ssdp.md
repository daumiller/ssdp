# SSDP #
Source: [lib/ssdp.rb](https://github.com/daumiller/ssdp/blob/master/lib/ssdp.rb)

SSDP module details shouldn't be needed by most programs; but are available for special use. The full list of default options used by various producer and consumer methods can also be found here.

* [DEFAULTS](#ssdp-defaults)
* [parse_ssdp](#ssdp-parse_ssdp)
* [create_listener](#ssdp-create_listener)
* [create_broadcaster](#ssdp-create_broadcaster)

<hr>

## <a name="ssdp-defaults"></a>DEFAULTS ##
`SSDP::DEFAULTS`

Default option-value hash used by producer and consumer classes.

#### Shared ####
* `:broadcast`
  * **default value**: `'239.255.255.250'`
  * SSDP broadcast address.
  * *Should not be overrode*.
* `:port`
  * **defualt value**: `1900`
  * SSDP port number.
  * *Should not be overrode*.
* `:bind`
  * **default value**: `'0.0.0.0'`
  * IP address to bind to. Set this to bind to a specific address/interface.
* `:maxpack`
  * **default value**: `65_507`
  * Maximum UDP packet size to to read.
  
#### Producer ####
* `:interval`
  * **default value**: `30`
  * Interval, in seconds, between sending 'alive' notifications.
* `:notifier`
  * **default value**: `true`
  * Whether to send 'alive' notifications.
* `:respond_to_all`:
  * **default value**: `true`
  * Whether to respond to searches for 'ssdp:all'.

#### Consumer ####
* `:timeout`
  * **default value**: `30`
  * Timeout, in seconds, to wait for search responses.
* `:first_only`
  * **default value**: `false`
  * `if :first_only` return only the first search response.
  * `else` gather all responses until timeout has expired.
* `:synchronous`
  * **default value**: `true`
  * `if :synchronous` make requests synchronously/blocking
  * `else` make requests asynchronously/with-a-callback
* `:no_warnings`
  * **default value**: `false`
  * Consumer has a couple of `warn` calls for conditions that should be avoided.
  * Turning this on will disable those warnings.

<hr>

## <a name="ssdp-parse_ssdp"></a>parse_ssdp(message) ##
`SSDP.parse_ssdp(message)`

Parse a raw SSDP packet, returning `{:status, :params, :body}`, where

* `:status` => HTTP status line
* `:params` => HTTP header key/value paris
* `:body` => HTTP content body

<hr>

## <a name="ssdp-create_listener"></a>create_listener(options) ##
`SSDP.create_listener(options)`

Return a UDP socket suitable for listening for SSDP broadcast messages.

Options used: [`:broadcast`, `:port`, `:bind`]

<hr>

## <a name="ssdp-create_broadcaster"></a>create_broadcaster ##
`SSDP.create_broadcaster(options)`

Return a UDP socket suitable for broadcasting SSDP messages. 

Options used: [`:bind`]
