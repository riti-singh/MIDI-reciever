-- entity midi_receiver is
--   generic (CLK_HZ: integer := 100_000_000);
--   port (
--     clk, rst       : in  std_logic;
--     serial_in      : in  std_logic;
--     event_channel  : out std_logic_vector(7 downto 0);
--     key            : out std_logic_vector(7 downto 0);
--     velocity       : out std_logic_vector(7 downto 0);
--     message_ready  : out std_logic;
--     note_on        : out std_logic;
--     note_off       : out std_logic
--   );

library ieee;
use ieee.std_logic_1164.all;

entity midi_hw_test is
  generic (
    CLK_HZ : integer := 100_000_000
  );
  port (
    clk100   : in  std_logic;   -- Basys3 100 MHz
    btnC     : in  std_logic;   -- use as reset (active-high)
    sw       : in  std_logic_vector(15 downto 0);  -- display select
    led      : out std_logic_vector(15 downto 0);  -- drive LEDs
    midi_rx  : in  std_logic    -- from PmodMIDI (JA1)
  );
end entity;

architecture rtl of midi_hw_test is
  -- raw receiver outputs
  signal status_b   : std_logic_vector(7 downto 0);
  signal key_b      : std_logic_vector(7 downto 0);
  signal vel_b      : std_logic_vector(7 downto 0);
  signal msg_rdy    : std_logic;
  signal note_on_p  : std_logic;
  signal note_off_p : std_logic;

  -- stretched for LEDs
  signal msg_led    : std_logic;
  signal on_led     : std_logic;
  signal off_led    : std_logic;

  -- heartbeat (slow blink to prove clock is alive)
  signal hb         : std_logic := '0';
  signal hb_cnt     : integer := 0;
begin
  --------------------------------------------------------------------------
  -- DUT
  --------------------------------------------------------------------------
  dut: entity work.midi_receiver
    generic map (CLK_HZ => CLK_HZ)
    port map (
      clk           => clk100,
      rst           => btnC,
      serial_in     => midi_rx,
      event_channel => status_b,
      key           => key_b,
      velocity      => vel_b,
      message_ready => msg_rdy,
      note_on       => note_on_p,
      note_off      => note_off_p
    );

  --------------------------------------------------------------------------
  -- Stretch the 1-clk pulses so you can see them on LEDs
  --------------------------------------------------------------------------
  u_st_msg : entity work.pulse_stretcher
    generic map (CLK_HZ => CLK_HZ, STRETCH_MS => 100)
    port map (clk=>clk100, rst=>btnC, din=>msg_rdy,    q=>msg_led);

  u_st_on  : entity work.pulse_stretcher
    generic map (CLK_HZ => CLK_HZ, STRETCH_MS => 150)
    port map (clk=>clk100, rst=>btnC, din=>note_on_p,  q=>on_led);

  u_st_off : entity work.pulse_stretcher
    generic map (CLK_HZ => CLK_HZ, STRETCH_MS => 150)
    port map (clk=>clk100, rst=>btnC, din=>note_off_p, q=>off_led);

  --------------------------------------------------------------------------
  -- Heartbeat ~1 Hz on LED15 (proves clock + design are alive)
  --------------------------------------------------------------------------
  process(clk100)
  begin
    if rising_edge(clk100) then
      if btnC='1' then
        hb_cnt <= 0; hb <= '0';
      else
        if hb_cnt = CLK_HZ/2-1 then  -- toggle every 0.5s
          hb_cnt <= 0; hb <= not hb;
        else
          hb_cnt <= hb_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Drive LEDs
  -- sw(0)=0 -> show KEY on led[7:0]
  -- sw(0)=1 -> show VELOCITY on led[7:0]
  -- led[11:8] shows status high nibble (1001=NOTE ON, 1000=NOTE OFF)
  -- led[12]   shows msg_ready (stretched)
  -- led[13]   shows note_off (stretched)
  -- led[14]   shows note_on  (stretched)
  -- led[15]   heartbeat
  --------------------------------------------------------------------------
  led(7 downto 0) <= key_b when sw(0)='0' else vel_b;
  led(11 downto 8) <= status_b(7 downto 4);
  led(12) <= msg_led;
  led(13) <= off_led;
  led(14) <= on_led;
  led(15) <= hb;
end architecture;
