library ieee;
use ieee.std_logic_1164.all;

entity midi_receiver is
  generic (
    CLK_HZ : integer := 100_000_000
  );
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    serial_in      : in  std_logic;  -- from Pmod MIDI adapter

    -- To your DDS block
    event_channel  : out std_logic_vector(7 downto 0); -- status byte
    key            : out std_logic_vector(7 downto 0);
    velocity       : out std_logic_vector(7 downto 0);
    message_ready  : out std_logic;
    note_on        : out std_logic;
    note_off       : out std_logic
  );
end entity;

architecture rtl of midi_receiver is
  signal byte_d : std_logic_vector(7 downto 0);
  signal byte_v : std_logic;
begin
  u_rx: entity work.midi_uart_rx
    generic map (CLK_HZ=>CLK_HZ, BAUD=>31_250)
    port map (
      clk=>clk, rst=>rst, rx_in=>serial_in,
      byte_data=>byte_d, byte_valid=>byte_v
    );

  u_parse: entity work.midi_parser
    port map (
      clk=>clk, rst=>rst, byte_in=>byte_d, byte_valid=>byte_v,
      status_byte=>event_channel, key=>key, velocity=>velocity,
      message_ready=>message_ready, note_on=>note_on, note_off=>note_off
    );
end architecture;
