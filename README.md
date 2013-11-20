Microphite
==========


Overview
--------

Microphite is a tiny and fast, asynchronous graphite client.  It can be called
many times per second with minimal overhead (approx 6-8 microseconds per
write/gather call on commodity hardware).  It is synchronized internally and
client instances can safely be shared across threads.


Usage
-----

Construct a standard socket client.  See the 'Client Options' section below
for initializer options.

    client = Microphite::Client::Socket.new(
        host: 'graphite.blah',
        port: 2003,
        transport: :udp,
        prefix: 'some.prefix')

Construct a client with an error_handler.  The client is fault tolerant, but
an error_handler is useful for logging failure events.

    handler = Proc.new { |error| Rails.logger.error "Microphite error: #{error.message}" }
    client = Microphite::Client::Socket.net(host: '...', error_handler: handler)

Construct a no-op/dummy client.  This is useful in development.  You can leave client API
calls in-place and the dummy client will behave appropriately.

    # Initializer options are still accepted for the dummy client, but no data
    # is ever written by it
    client = Microphite::Client::Dummy.new(host: 'blah', ...)

Send complete data points

    client.write('some.key': 300, 'another.key': 25)

Accumulate counters (flushed every options[:flush_interval] seconds)

    client.gather('some.counter': 22, 'another.counter': 10)

Time a code block (results are gather()'d to the specified key)

    client.time('app.timings.important_stuff') do
      important_stuff()
    end

Prefixing helper

    client.prefix('app.') do |app_ns|
      # Key is prefixed with 'app.' automatically
      app.write(key: 42)

      # Nest as much as you'd like
      app_ns.prefix('sub.') do |sub_ns|
        # Keys prefixed by 'app.sub.'
        sub_ns.gather(something: 5)
      end
    end

Close the client, waiting for data to flush

    client.close

Alternatively, wait at most 1 second to flush

    flushed = client.close(1)


Client Options
--------------

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>:host</tt></td>
    <td>String</td>
    <td>Graphite server -- REQUIRED</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>:port</tt></td>
    <td>Integer</td>
    <td>Graphite port</td>
    <td><tt>2003</tt></td>
  </tr>
  <tr>
    <td><tt>:transport</tt></td>
    <td>Symbol</td>
    <td>Graphite transport to use (:tcp or :udp)</td>
    <td><tt>:udp</tt></td>
  </tr>
  <tr>
    <td><tt>:prefix</tt></td>
    <td>String/Symbol</td>
    <td>Global prefix for all keys</td>
    <td><tt>''</tt></td>
  </tr>
  <tr>
    <td><tt>:flush_interval</tt></td>
    <td>Numeric</td>
    <td>How often to flush gather()'d data (in seconds)</td>
    <td><tt>10.0</tt></td>
  </tr>
  <tr>
    <td><tt>:limit</tt></td>
    <td>Integer</td>
    <td>Limit the write and gather stacks to this size</td>
    <td><tt>1000000</tt></td>
  </tr>
  <tr>
    <td><tt>:min_delay</tt></td>
    <td>Numeric</td>
    <td>Initial delay between retry attempts for write failures (in seconds)</td>
    <td><tt>2</tt></td>
  </tr>
  <tr>
    <td><tt>:max_delay</tt></td>
    <td>Numeric</td>
    <td>Maximum delay between retry attempts for write failures (in seconds)</td>
    <td><tt>60</tt></td>
  </tr>
  <tr>
    <td><tt>:error_handler</tt></td>
    <td>Proc</td>
    <td>Code block called on exception (takes a single exception param)</td>
    <td><tt>nil</tt></td>
  </tr>
</table>


License
-------

The MIT License (MIT)

Copyright (c) 2013 BZ Technology Services, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
