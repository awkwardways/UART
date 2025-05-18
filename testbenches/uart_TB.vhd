library ieee;
use ieee.std_logic_1164.all;

entity uart_TB is
end entity uart_TB;

architecture sim of uart_TB is
  signal tb_data_in_0 : std_logic_vector(7 downto 0);
  signal tb_data_out_0 : std_logic_vector(7 downto 0);
  signal tb_data_in_1 : std_logic_vector(7 downto 0);
  signal tb_data_out_1 : std_logic_vector(7 downto 0);
  signal tb_tx_0 : std_logic;
  signal tb_rx_0 : std_logic := '1';
  signal tb_wrn_0 : std_logic;
  signal tb_rdn_0 : std_logic := '1';
  signal tb_ctsn_0 : std_logic;
  signal tb_tx_1 : std_logic;
  signal tb_rx_1 : std_logic := '1';
  signal tb_wrn_1 : std_logic;
  signal tb_rdn_1 : std_logic := '1';
  signal tb_ctsn_1 : std_logic;
  signal tb_system_clock : std_logic := '0';
  constant tb_system_clock_freq : natural := 50e6;
  constant tb_uart_baud : natural := 9600;
  constant tb_system_clock_period : time := (1000 ms / tb_system_clock_freq);
  constant tb_baud_period : time := (1000 ms / tb_uart_baud);
begin
  UART0: entity work.uart(rtl)
  generic map(
    system_clock_freq => tb_system_clock_freq,
    uart_baud => tb_uart_baud
  )
  port map(
    data_in => tb_data_in_0,
    data_out => tb_data_out_0,
    tx => tb_rx_1,
    rx => tb_rx_0,
    wrn => tb_wrn_0,
    rdn => tb_rdn_0,
    ctsn => tb_ctsn_0,
    system_clock_in => tb_system_clock
  );

  UART1: entity work.uart(rtl)
  generic map(
    system_clock_freq => tb_system_clock_freq,
    uart_baud => tb_uart_baud
  )
  port map(
    data_in => tb_data_in_1,
    data_out => tb_data_out_1,
    tx => tb_rx_0,
    rx => tb_rx_1,
    wrn => tb_wrn_1,
    rdn => tb_rdn_1,
    ctsn => tb_ctsn_1,
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
    tb_data_in_0 <= message1;
    tb_wrn_0 <= '0';
    wait for tb_baud_period;
    tb_ctsn_0 <= '0';
    wait for 10 * tb_baud_period;
    tb_rdn_1 <= '0';
    wait;
  end process;

end architecture sim;