library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity midi_byte_rx is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        rx         : in  std_logic;          -- synchronized line (idles '1')
        start_edge : in  std_logic;          -- from sync_start
        tick_half  : in  std_logic;          -- from midi_baud
        tick_bit   : in  std_logic;          -- from midi_baud
        baud_en    : out std_logic;          -- to enable midi_baud during a frame
        data       : out std_logic_vector(7 downto 0);
        data_valid : out std_logic
    );
end entity;

architecture rtl of midi_byte_rx is
    type state_t is (IDLE, START_CENTER, DATA_BITS, STOP_BIT, DONE);
    signal s          : state_t := IDLE;
    signal bit_idx    : integer range 0 to 7 := 0;
    signal shifter    : std_logic_vector(7 downto 0) := (others=>'0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                s         <= IDLE;
                bit_idx   <= 0;
                shifter   <= (others=>'0');
                data      <= (others=>'0');
                data_valid<= '0';
                baud_en   <= '0';
            else
                data_valid <= '0';
                case s is
                    when IDLE =>
                        baud_en <= '0';
                        if start_edge='1' then
                            baud_en <= '1';
                            s <= START_CENTER;  -- wait to center of start bit
                        end if;

                    when START_CENTER =>
                        if tick_half='1' then
                            -- optionally verify rx='0' here
                            bit_idx <= 0;
                            s <= DATA_BITS;
                        end if;

                    when DATA_BITS =>
                        if tick_bit='1' then
                            -- LSB first
                            shifter(bit_idx) <= rx;
                            if bit_idx=7 then
                                s <= STOP_BIT;
                            else
                                bit_idx <= bit_idx + 1;
                            end if;
                        end if;

                    when STOP_BIT =>
                        if tick_bit='1' then
                            -- optionally check rx='1'
                            data      <= shifter;
                            data_valid<= '1';
                            s         <= DONE;
                        end if;

                    when DONE =>
                        baud_en <= '0';
                        s <= IDLE;
                end case;
            end if;
        end if;
    end process;
end architecture;
