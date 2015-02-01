# SSDP::Producer #
**SSDP server/producer class.**
Source: [lib/ssdp/producer.rb](https://github.com/daumiller/ssdp/blob/master/lib/ssdp/producer.rb)

For registered service types, provide alive and byebye SSDP notifications.

Respond to SSDP search requests for registered types.


* [new](#ssdp-producer-new)
* [services](#ssdp-producer-services)
* [uuid](#ssdp-producer-uuid)
* [running?](#ssdp-producer-running)
* [start](#ssdp-producer-start)
* [stop](#ssdp-producer-stop)
* [add_service](#ssdp-producer-add_service)
* [remove_service](#ssdp-producer-remove_service)

<hr>
## <a name="ssdp-producer-new"></a>Producer.new(options = {}) ##
`SSDP::Producer.new(options = {})`

If `options` are provided, they can override global defaults (in [SSDP::Defaults](ssdp.md)) for this instance (see individual calls for specific options).

<hr>
## <a name="ssdp-producer-services"></a> Producer.services ##
`producer.services`

Attribute accessor for registered services hash. Adding new service types should only be done through [`add_service`](#ssdp-producer-add_service), but removing services directly via `services.delete` is permitted.

Each key-value-pair in services has the service type string as the key, and a parameter hash as the value (used as HTTP headers in search responses).

<hr>
## <a name="ssdp-producer-uuid"></a> Producer.uuid ##
`producer.uuid`

The UUID assigned to this producer instance during initialization. This variable can be modified, but should not be done after any other methods have been called.

<hr>
## <a name="ssdp-producer-running"></a> Producer.running?() ##
`producer.running?`

Check if the producer's search-response listener is currently running.

<hr>
## <a name="ssdp-producer-start"></a> Producer.start() ##
`producer.start`

Start the search-response listener, and if enabled, the periodic notifications thread.

Options (set in [`new`](#ssdp-producer-new)):

* `:notifier`
  * Whether or not to send notifications (/start a notifier thread).
* `:interval`
  * If `:notifier` is `true`, interval, in seconds, between sending 'alive' notifications for each registered service type.
* `:maxpack`
  * Maximum UDP packet size allowed to read (in bytes).

<hr>
## <a name="ssdp-producer-stop"></a> Producer.stop(bye_bye = true) ##
`producer.stop(bye_bye = true)`

Stop the search-response listener, and if currently running, the periodic notifications thread.

* `bye_bye`
  * If `true`, send a 'byebye' SSDP notification for each registered type, to indicate that the service is no longer available.

<hr>
## <a name="ssdp-producer-add_service"></a> Producer.add_service(type, location_or_param_hash) ##
`producer.add_service(type, location_or_param_hash)`

Add a registered service type, specifying a location or set of parameters (HTTP headers).

* `type`
  * The service type string ('NT'/'ST' SSDP parameter) to register.
* `location_or_param_hash`
  * If this parameter is a string, the HTTP response will receive 'AL' and 'LOCATION' headers set to this value.
  * If this parameter is a hash, all key-value-pairs will be added as HTTP response headers (*don't forget to set an 'AL' and/or 'LOCATION' value!*)

Options (set in [`new`](#ssdp-producer-new)):

* `:notifier`
  * If `:notifier` is set, an immediate notification will be sent when adding a type, as well as future notifications sent every `:interval` seconds.

<hr>
## <a name="ssdp-producer-remove_service"></a> Producer.remove_service(type) ##
`producer.remove_service(type)`

Convenience method to remove registered types.

(*`Producer.`[`services`](#ssdp-producer-services)`.delete` works just as well.*)


