library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_stretcher is
  generic (
    CLK_HZ     : integer := 100_000_000;
    STRETCH_MS : integer := 100          -- show pulse ~100 ms on LED
  );
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    din   : in  std_logic;               -- 1-clk input pulse
    q     : out std_logic                -- stretched level
  );
end entity;

architecture rtl of pulse_stretcher is
  constant MAX : unsigned(31 downto 0) :=
    to_unsigned((CLK_HZ / 1000) * STRETCH_MS, 32);

  signal cnt : unsigned(31 downto 0) := (others=>'0');
  signal y   : std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        y   <= '0';
        cnt <= (others=>'0');
      else
        if din='1' then
          y   <= '1';
          cnt <= MAX;
        elsif y='1' then
          if cnt = 0 then
            y <= '0';
          else
            cnt <= cnt - 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  q <= y;
end architecture;
