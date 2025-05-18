library ieee;
use ieee.std_logic_1164.all;

entity uart_rx_TB is
end entity uart_rx_TB;

architecture sim of uart_rx_TB is
  signal tb_data_in : std_logic_vector(7 downto 0);
  signal tb_data_out : std_logic_vector(7 downto 0);
  signal tb_tx : std_logic;
  signal tb_rx : std_logic := '1';
  signal tb_wrn : std_logic;
  signal tb_rdn : std_logic := '1';
  signal tb_ctsn : std_logic;
  signal tb_system_clock : std_logic := '0';
  constant tb_system_clock_freq : natural := 50e6;
  constant tb_uart_baud : natural := 9600;
  constant tb_system_clock_period : time := (1000 ms / tb_system_clock_freq);
  constant tb_baud_period : time := (1000 ms / tb_uart_baud);
begin
  UUT: entity work.uart(rtl)
  generic map(
    system_clock_freq => tb_system_clock_freq,
    uart_baud => tb_uart_baud
  )
  port map(
    data_in => tb_data_in,
    data_out => tb_data_out,
    tx => tb_tx,
    rx => tb_rx,
    wrn => tb_wrn,
    rdn => tb_rdn,
    ctsn => tb_ctsn,
    system_clock_in => tb_system_clock
  );

  --Generate system clock
  tb_system_clock <= not tb_system_clock after (tb_system_clock_period) / 2; 

  --Stimuli
  process
    variable message1 : std_logic_vector(7 downto 0) := x"AA";
    variable message2 : std_logic_vector(7 downto 0) := x"7A";
    variable message3 : std_logic_vector(7 downto 0) := x"B3";
  begin
    wait for tb_baud_period;
    tb_rx <= '0';

    wait for tb_baud_period;
    for i in 0 to 7 loop
      tb_rx <= message1(i);
      wait for tb_baud_period;
    end loop;
    tb_rx <= '1';
    tb_rdn <= '0';

    wait for tb_baud_period;
    assert tb_data_out = x"AA" report "data_out bus has value " & to_hstring(tb_data_out) & " instead of 'AA'" severity error;
    tb_rdn <= '1';
    tb_rx <= '0';
    wait for tb_baud_period;
    for i in 0 to 7 loop
      tb_rx <= message2(i);
      wait for tb_baud_period;
    end loop;
    tb_rx <= '1';
    tb_rdn <= '0';

    wait for tb_baud_period;
    assert tb_data_out = x"7A" report "data_out bus has value " & to_hstring(tb_data_out) & " instead of '7A'" severity error;
    tb_rdn <= '1';
    tb_rx <= '0';
    wait for tb_baud_period;
    for i in 0 to 7 loop
      tb_rx <= message3(i);
      wait for tb_baud_period;
    end loop;
    tb_rx <= '1';
    tb_rdn <= '0';

    wait for tb_baud_period;
    assert tb_data_out = x"B3" report "data_out bus has value " & to_hstring(tb_data_out) & " instead of 'B3'" severity error;
    wait;
  end process;
end architecture sim;