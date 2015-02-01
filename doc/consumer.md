# SSDP::Consumer #
**SSDP client/consumer class.**
Source: [lib/ssdp/consumer.rb](https://github.com/daumiller/ssdp/blob/master/lib/ssdp/consumer.rb)

Make direct SSDP requests, listening for single or multiple responses.

Listen for SSDP notifications ('alive'/'byebye').

* [new](#ssdp-consumer-new)
* [search](#ssdp-consumer-search)
* [start_watching_type](#ssdp-consumer-start_watching_type)
* [stop_watching_type](#ssdp-consumer-stop_watching_type)
* [stop_watching_all](#ssdp-consumer-stop_watching_all)


<hr>
## <a name="ssdp-consumer-new"></a>Consumer.new(options = {}) ##
`SSDP::Consumer.new(options = {})`

If `options` are provided, they can override global defaults (in [SSDP::Defaults](ssdp.md)) for this instance (see individual calls for specific options).

<hr>
## <a name="ssdp-consumer-search"></a>Consumer.search(options, &block) ##
`consumer.search(options, &block)`

Perform an SSDP search request.

* When searching `:first_only`, block is called with a single response, or nil if request timed out.
* When searching without `:first_only`, block is called with array of all received responses after timeout (may be empty for no responses).

Options:

* `:service`
  * Service type string ('ST'/'NT' SSDP parameter) to search for.
  * **Should always be provided**.
  * If not provided, and `:no_warnings` is not set, call will display warning.
* `:synchronous`
  * If `true`, call will be blocking, and result will come through return value.
  * If `false`, call will be non-blocking, and result will be provided to the provided (`block`) callback.
* `:timeout`
  * Maximum time, in seconds, to wait for a search to complete.
  * If `0`, or `nil`, and `:no_warnings` is not set, call will display warning.
* `:first_only`
  * If `true`, will only read the first response, returning a single object as soon as possible.
  * If `false`, will read all responses until timing out, returning an array of objects when complete.
* `:no_warnings`
  * If set, inhibit any warnings this call may otherwise display.
* `:maxpack`
  * Maximum UDP packet size allowed to read (in bytes).

<hr>
## <a name="ssdp-consumer-start_watching_type"></a>Consumer.start_watching_type(type, &block) ##
`consumer.start_watching_type(type, &block)`

Register a service type ('ST'/'NT' SSDP parameter) to watch for, providing a callback block to be called each time a notification for the specified service type is encountered.

If the watcher thread is not running, adding a type to watch for will start it.

<hr>
## <a name="ssdp-consumer-stop_watching_type"></a>Consumer.stop_watching_type(type) ##
`consumer.stop_watching_type(type)`

Unregister a service type that was being watched for notifications.

If the watcher thread is running, removing the last watched type will stop it.

<hr>
## <a name="ssdp-consumer-stop_watching_all"></a>Consumer.stop_watching_all ##
`consumer.stop_watching_all`

Convenience method to stop watching all previously registered service types.

Will stop the watcher thread, if it is currently running.


