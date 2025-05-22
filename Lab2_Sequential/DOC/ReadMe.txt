proc1 – Fast Counter Process
This process implements a fast counter that increments until it matches the value of the slow counter. Once both counters are equal, it resets to zero, unless the system is in non-repeating mode and the slow counter has already reached the upper bound—in which case the fast counter holds its value. The purpose is to generate rapid ticks that follow the pace set by the slow counter.

proc2 – Slow Counter Process
This process controls a slower counter that advances only when it is equal to the fast counter and still below the upper bound. In repeat mode, it resets to zero once both counters reach the upper bound, allowing the counting cycle to restart. It essentially regulates how far the fast counter is allowed to progress.

Combinational Part
The combinational logic determines the module outputs: it assigns the fast counter's value to the output count_o and activates the busy_o signal when counting has completed (both counters are equal and at the upper bound, and repeat is disabled). This part reflects the system status and current counter value to the outside world.