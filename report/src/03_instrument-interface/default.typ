= The instrument interface <sec:interface>

Every layer above this one talks to the microscope through a single library, a
typed Rust client for the Nanonis TCP protocol. This chapter works upwards from
the transport to that client.

== The TCP transport <sec:tcp>

What TCP provides and, more importantly, what it does not: an ordered,
reliable stream of bytes with no notion of where one message ends and the next
begins. Every application protocol on top of it has to supply that boundary
itself, which is the reason @sec:message-format exists at all.

// One diagram: bytes in, framed messages out.

== The Nanonis message format <sec:message-format>

The frame the controller expects: command name, body size, response flag, and a
big-endian payload described by a table of type codes. How arrays and strings
are laid out inside a body, and how a reply is matched to the call that
provoked it.

The instrument exposes a second channel on its own port for continuous data
logging, with a different frame layout and no request-response structure at
all. Both are TCP; only one of them is a conversation.

== Type safety at the protocol boundary <sec:typed-api>

What the specification leaves to the caller is the harder part. Value arrays
arrive untyped, arguments are positional, signals are bare integers, and a
number of per-command conventions exist only in the manual. An unattended
routine needs predictable failure and a call that either did the thing or said
why it did not.

The client answers with one function per command, so that argument order lives
in a signature rather than in the caller's memory, with newtypes where the
protocol uses bare integers and enumerations where it uses magic numbers.
Errors form a taxonomy rather than a string: a timeout, a protocol violation
and an error the instrument itself reported are three different situations, and
the caller needs the distinction to decide what to do next.

== Connection management and tip safety <sec:connection>

Multiple control ports, connection poisoning and reconnection, and tip
withdrawal when the client is dropped, so that the tip is protected by
ownership rather than by remembering to call a cleanup function.

== Coverage and limitations <sec:type-safety-eval>

Which classes of error moved from run time to compile time, what the effort
cost in command coverage and maintenance, and what remains uncatchable, notably
firmware variation across installations.
