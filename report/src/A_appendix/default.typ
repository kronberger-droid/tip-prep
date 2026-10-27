#import "/report.typ": flex-caption

= Reference tables <apx:reference>

The data types of the message format of @sec:interface in full, and every
field of the routine's configuration file with its default, so that a run in
@sec:validation can be reproduced from the configuration its log records. Both
are here because nobody reads them in sequence.

#figure(
  table(
    columns: 3,
    align: (left, left, left),
    table.header[Type][Encoding][Length],
    [string], [one byte per character], [prefixed as a 32-bit integer; fixed 32 bytes for a command name],
    [int], [32-bit signed, big-endian], [4 bytes],
    [unsigned int16], [16-bit unsigned, big-endian], [2 bytes],
    [unsigned int32], [32-bit unsigned, big-endian], [4 bytes],
    [float32], [single precision, big-endian], [4 bytes],
    [float64], [double precision, big-endian], [8 bytes],
    [1D array string], [strings, each length-prefixed], [element count and byte size sent before it],
    [1D array int], [32-bit signed integers], [element count usually sent before it],
    [1D array unsigned int8], [8-bit unsigned integers], [element count usually sent before it],
    [1D array unsigned int32], [32-bit unsigned integers], [element count usually sent before it],
    [1D array float32], [single-precision floats], [element count usually sent before it],
    [1D array float64], [double-precision floats], [element count usually sent before it],
    [2D array float32], [single-precision floats, by row], [rows and columns usually sent before it],
    [2D array string], [strings, each length-prefixed], [rows and columns usually sent before it],
  ),
  caption: flex-caption([
    The data types of the Nanonis TCP protocol (specification revision
    R14718), which announces thirteen and lists these fourteen. "Usually" is the specification's own word: the
    signature of each command says which argument carries the length.
  ], [Data types of the Nanonis TCP protocol]),
) <tab:data-types>
