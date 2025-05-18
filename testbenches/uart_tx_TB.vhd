library ieee;
use ieee.std_logic_1164.all;

entity better_uart_tx_TB is
end entity better_uart_tx_TB;

architecture sim of better_uart_tx_TB is
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
  UUT: entity work.better_uart(rtl)
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
    tb_data_in <= message1;
    tb_wrn <= '0';
    wait for tb_baud_period;
    tb_ctsn <= '0';
    wait for tb_baud_period;

    wait for tb_baud_period;
    tb_data_in <= message2;
    wait for tb_baud_period;
    tb_ctsn <= '0';
    wait for tb_baud_period;    
  
    wait for tb_baud_period;
    tb_data_in <= message3;
    wait for tb_baud_period;
    tb_ctsn <= '0';
    wait for tb_baud_period;   
    wait;
  end process;
end architecture sim;