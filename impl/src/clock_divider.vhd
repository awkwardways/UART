library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clock_divider is
  generic(
    input_clock_frequency : positive := 27e6;
    output_clock_frequency : positive := 9600
  );
  port(
    clock_in  : in std_logic;
    clock_out : out std_logic
  );
end entity clock_divider;

architecture rtl of clock_divider is
  constant count_limit : integer := integer(floor(real(input_clock_frequency) / (2.0 * real(output_clock_frequency))));
  signal count : natural := 1;
  signal clk_out : std_logic := '0';
begin 
  DivideClock : process(clock_in, clk_out)
  begin
    if rising_edge(clock_in) then
      if count = count_limit then
        count <= 1;
        clk_out <= not clk_out;
      else
        count <= count + 1;
      end if;
    end if;
    clock_out <= clk_out;
  end process DivideClock;
end architecture rtl;