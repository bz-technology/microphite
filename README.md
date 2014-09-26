Microphite
==========
[![Gem Version](https://badge.fury.io/rb/microphite.png)](http://rubygems.org/gems/microphite)
[![Build Status](https://travis-ci.org/bz-technology/microphite.png?branch=master)](https://travis-ci.org/bz-technology/microphite)
[![Code Climate](https://codeclimate.com/github/bz-technology/microphite.png)](https://codeclimate.com/github/bz-technology/microphite)
[![Coverage Status](https://coveralls.io/repos/bz-technology/microphite/badge.png)](https://coveralls.io/r/bz-technology/microphite)


Overview
--------

Microphite is a tiny and fast, asynchronous [Graphite](http://graphite.wikidot.com/) client.  It can be called
many times per second with minimal overhead.  It is synchronized internally and
can be shared across threads.  Both tcp and udp connections are supported.

Microphite has been in use in production by a BZ technology client for quite some time without issue.


Usage
-----

Construct a standard socket client.  See the 'Client Options' section below
for initializer options.

    client = Microphite.client(
        host: 'graphite.host',
        port: 2003,
        transport: :udp,
        prefix: 'app.prefix.')

Construct a client with an error_handler.  The client is fault tolerant, but
an error_handler is useful for logging connection failures.

    handler = Proc.new { |error| Rails.logger.error "Microphite error: #{error.message}" }
    client = Microphite.client(host: '...', error_handler: handler)

Construct a no-op/dummy client.  This is useful in development.  You can leave client API
calls in-place and the dummy client will behave appropriately.

    # Initializer options are accepted, but no data is written
    client = Microphite.noop(host: 'host', ...)

Send data points

    client.write('some.key': 300, 'another.key': 25)

Accumulate counters (flushed every :flush_interval seconds)

    client.gather('some.counter': 22, 'another.counter': 10)

Time a code block, gathering to timing.task

    client.time('timing.task') do
      task
    end

Execute-around for writes and gathers -- Send data unless a block throws.  The block's return value is preserved.

    client.write(accurate_data: 42) do
      something_that_may_throw()
    end
    client.gather(accurate_data: 42) do
      something_else_that_throws()
    end

Easy prefixing

    client.prefix('p1.') do |p1|
      # Write to p1.key
      app.write(key: 42)

      p1.prefix('p2.') do |p2|
        # Write to p1.p2.key
        p2.write(key: 5)
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
    <td>Graphite server host (REQUIRED)</td>
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
    <td>How often to flush gathered data (in seconds)</td>
    <td><tt>1.0</tt></td>
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
    <td>Initial delay between retry attempts after failure (in seconds)</td>
    <td><tt>2</tt></td>
  </tr>
  <tr>
    <td><tt>:max_delay</tt></td>
    <td>Numeric</td>
    <td>Maximum delay between retry attempts after failure (in seconds)</td>
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
