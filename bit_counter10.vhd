library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bit_counter10 is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    clr   : in  std_logic;           -- sync clear
    inc   : in  std_logic;           -- pulse per bit center
    tc10  : out std_logic            -- '1' after 10 increments (0..9)
  );
end entity;

architecture rtl of bit_counter10 is
  signal c : unsigned(3 downto 0) := (others=>'0');  -- 0..15
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' or clr='1' then
        c <= (others=>'0');
      elsif inc='1' then
        c <= c + 1;
      end if;
    end if;
  end process;
  tc10 <= '1' when c = to_unsigned(10, c'length) else '0';
end architecture;
