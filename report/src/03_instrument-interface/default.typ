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
values, typed per command from thirteen data types listed in
@apx:reference. These comprise integers, floating-point numbers, strings, and
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

A second port serves continuous data logging, with records instead of messages
and no request-response structure. Each record is a short header (channel
count, sample counter, logger state) followed by one value per channel, at a
base rate of $2$ kHz divided by an integer. The protocol specification omits
this format; only a vendor-supplied LabVIEW example documents it.
Both ports are TCP; only one of them is a conversation.

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
settings take a builder in which an unset field means "no change". Of the 661
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

Argument order, magic numbers, and channel and step-count ranges moved from
run time to compile time. Signal indices did not. They are newtypes but built
without a range check, and conversion from a machine-sized integer truncates
instead of failing.

Variation across installations remains uncatchable. The scan-properties response
has grown across Nanonis versions by fields appended at its end. The client
therefore reads the full layout and falls back to the core when an older
Nanonis controller sends less. The specification is also self-inconsistent in
places. It gives two unused header bytes for a request and four for a
same-size response. It describes the error status as unsigned where other
parts of the protocol use signed integers. Its encoding of a feedback
controller's slope differs from module to module. Each case is handled in the
function for that command, where a caller would otherwise have had to know
about it.

Without an instrument, the client's tests cover encoding and decoding of every
data type and the typed parameter sets of its larger subsystems. The commands
themselves were exercised against the vendor's simulator and on the
instrument.

== Connection management and tip safety <sec:connection>

A connection that has failed once is not trusted again. Any I/O error, and
any response under a name other than the one requested, marks it poisoned. Its
socket may then hold half a message, and the next response read would belong to the
wrong command. Every later command is refused until the caller explicitly
reconnects, as the session of @sec:harness does.

When dropped, the client can withdraw the tip and back off the coarse motor,
but only on request and only while the connection is healthy. The routines of
@sec:framework do not rely on this. Their tip safety sits one layer up, in the
harness. It applies a routine's exit policy however the run ends, including a
panic (@sec:harness, @sec:outcomes). The client's own withdrawal is a last
resort for programs written directly against it.
