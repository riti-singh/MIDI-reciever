# MIDI-reciever
Receiver module for a MIDI piano - UART &amp; SPI integrations (for entire project, reach out to me)


The goal of this project is to generate music from a keyboard using the Musi-
cal Instrument Digital Interface (MIDI) protocol. MIDI is a serial communi-
cation protocol developed specifically for interfacing with digital instruments.
It operates very similar to the Serial Communication Interface (SCI).
In MIDI, information is sent serially one byte at a time at a bit rate of
31.25 kbit/s. Like SCI, each byte is framed by a start bit (‘0’) and stop bit
(‘1’). Each MIDI message consists of 3 bytes sent in succession. MIDI bytes
are sent LSB first. See the timing diagram below.


<img width="624" height="141" alt="image" src="https://github.com/user-attachments/assets/4fd309ec-6ea7-485a-9c22-4b64f8074265" />


