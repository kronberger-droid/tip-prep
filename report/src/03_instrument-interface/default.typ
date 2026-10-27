#import "/report.typ": flex-caption
#import "/lib.typ": todo
#import "fig_frame.typ": frame-diagram

// Describes nanonis-rs 0.5.0 with the protocol fixes of the branch
// fix/protocol-defects applied: a reply under the wrong name poisons the
// connection, a nonzero error status is an error even without a description,
// a stalled data stream surfaces as a timeout, and the Osci2T and ZSpectr
// command names match the specification. Sources: nanonis-rs src/protocol.rs,
// src/client/mod.rs, src/error.rs, src/tcplogger_stream.rs, and the
// specification docs/tcp-protocol.md (R14718). The data-logger frame layout
// comes from a LabVIEW VI the vendor supplies, not from the specification.
// The LabVIEW route is Martin's statement; the Python clients are
// nanonis_spm (SPECS GitHub) and nanonisTCP (Zenodo), used by Scanbot.

= The instrument interface <sec:interface>

Every higher layer talks to the instrument through one library, nanonis-rs,
a typed Rust client for the Nanonis TCP protocol. The Nanonis controller
@nanonis is programmable through LabVIEW, the vendor's Python package
@nanonisspm, or TCP. Community clients build on the TCP interface too, such as
the Python library @nanonistcp that Scanbot runs on @ceddia2024. What
nanonis-rs adds is the subject of @sec:typed-api and @sec:connection. This
chapter works up from the transport to the client.

== The Nanonis message format <sec:message-format>

The Nanonis controller is a TCP server accepting up to four client
connections. TCP provides an ordered, reliable byte stream with no notion of
where one message ends and the next begins. Every protocol on top must supply
that boundary itself, so the Nanonis protocol delimits every message.

The protocol adds an ordering guarantee per connection. Commands on one
connection execute one after another, in the order sent, while across
connections no order is guaranteed. The client therefore drives the
instrument through a single connection, and its synchronization is the
connection's.

Every message, in either direction, is a fixed-size header followed by a
body (@fig:frame). The header carries the command name zero-padded to 32
bytes, the body size, and in a request a flag asking for a response. All
numbers are big-endian. The body holds the command's arguments or return
values, typed per command from the data types listed in @apx:reference. These comprise integers, floating-point numbers, strings, and
one- and two-dimensional arrays of them. Strings are length-prefixed, and an
array usually takes its length from the argument just before it. A body is
therefore readable only with the command's signature at hand.

#figure(
  frame-diagram(),
  kind: image,
  caption: flex-caption([
    Request and response messages of the Nanonis TCP protocol. The header is
    40 bytes in both directions; the error section closes every response
    body. Widths are not to scale.
  ], [Request and response messages of the Nanonis TCP protocol]),
) <fig:frame>

A response ends in an error section: a status, a description length, and the
description. A response carries nothing identifying its request. It is matched by
position, as the next message on an in-order connection, and checked by its
command name.

A second port streams the data logger as records of one value per channel, at
a base rate of $2$ kHz divided by an integer, with no request-response
structure. The protocol specification omits this format; only a
vendor-supplied LabVIEW example documents it.

== Type safety at the protocol boundary <sec:typed-api>

The harder part is what the specification leaves to the caller. Value arrays
arrive untyped and arguments are positional. Signals are bare integers, and
several per-command conventions exist only in the manual. An unattended
routine needs predictable failure and a call that either did the thing or said
why it did not.

The client answers with one function per command, so argument order lives in
a signature, not the caller's memory. For bare integers it uses newtypes, such
as a channel index constructible only within the logger's 24 channels or a
motor step count checked to fit its field. For magic numbers it uses
enumerations, such as the six motor directions. Commands with many optional
settings take a builder in which an unset field means "no change". Argument
order, magic numbers, and channel and step-count ranges thus moved from run
time to compile time. Signal indices did not: they are newtypes built without a
range check, and conversion from a machine-sized integer truncates instead of
failing. Of the 661
commands in the targeted specification revision, the client wraps 576
($87 %$), including every scanning command.
// 576 of 661 `####` command headings in docs/tcp-protocol.md, counted on
// fix/protocol-defects (6f12b10); the client also sends BiasSwp.PropsGet and
// Signals.InSlotsGet, which the specification does not list.

Errors form a taxonomy, not a string. A connection failure, a timeout, a
protocol violation and an error reported by the instrument are four variants.
The last carries the instrument's code and description. The caller needs the
distinction to choose its next step. Any nonzero error status counts as an
error, even without a description.

Variation across installations remains uncatchable. Responses such as the scan
properties have grown across Nanonis versions, and the specification is
self-inconsistent in places, such as the unused header bytes of a request and
a response. Each case is handled in the function for that command, where a
caller would otherwise have had to know about it.
// The cases: scan-properties fields appended over versions (the client falls
// back to the core layout); 2 unused header bytes for a request, 4 for a
// response; error status unsigned where the rest is signed; feedback slope
// encoded differently per module; 13 data types announced, 14 listed.

== Connection management and tip safety <sec:connection>

A connection that has failed once is not trusted again. Any I/O error, and
any response under a name other than the one requested, marks it poisoned. Its
socket may then hold half a message, and the next response read would belong to the
wrong command. Every later command is refused until the caller explicitly
reconnects, as the session of @sec:harness does.

When dropped, the client can withdraw the tip and back off the coarse motor,
but only on request and only while the connection is healthy. The routines of
@sec:framework rely instead on the harness (@sec:harness), and the client's
own withdrawal is a last resort for programs written directly against it.
