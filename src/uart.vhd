library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
  generic(
    system_clock_freq : natural := 27e6;
    uart_baud : integer := 9600
  );
  port(
    data_in         : in std_logic_vector(7 downto 0);
    data_out        : out std_logic_vector(7 downto 0);
    tx              : out std_logic := '1';
    rx              : in std_logic;
    wrn             : in std_logic; --Write to register. Active low
    rdn             : in std_logic; --Read received data. Active low
    ctsn            : in std_logic; --Clear to send. Active low
    system_clock_in : in std_logic
  );
end entity uart;

architecture rtl of uart is
  type rx_state_t is (r_idle, r_data, r_stop_bit);
  type tx_state_t is (t_idle, t_data, t_stop_bit);
  signal bauds : std_logic;
  signal rx_state : rx_state_t := r_idle;
  signal tx_state : tx_state_t := t_idle;
  signal rx_register : std_logic_vector(7 downto 0) := x"00";
  signal tx_register : std_logic_vector(7 downto 0) := x"00";
begin

  baud_generator: entity work.clock_divider(rtl)
  generic map(
    input_clock_frequency => system_clock_freq,
    output_clock_frequency => uart_baud
  )
  port map(
    clock_in => system_clock_in,
    clock_out => bauds
  );

  --Receiver process
  receive : process(bauds)
    variable bits_received : natural := 0;
  begin
    if rising_edge(bauds) then

      if rdn = '0' then
        data_out <= rx_register;
      end if;

      case rx_state is

        --Check if rx line was pulled low to begin transmission
        when r_idle =>
          if rx = '0' then
            rx_state <= r_data;
          end if;
        
        --Read order: LSB first
        when r_data =>
          rx_register(bits_received) <= rx;
          bits_received := bits_received + 1;
          if bits_received = 8 then
            rx_state <= r_stop_bit;
            bits_received := 0;
          end if;

        when r_stop_bit =>
          if rx = '1' then
            rx_state <= r_idle;
          else
            rx_state <= r_data;
          end if;
          
      end case;
    end if;
  end process receive;

  --Transmitter process
  transmit : process(bauds)
    variable sent_bits : natural := 0;
  begin
    if rising_edge(bauds) then
      if wrn = '0' then
        tx_register <= data_in;
      end if;

      if ctsn = '0' then
        case tx_state is

          --Send starting bit
          when t_idle =>
            tx <= '0';
            tx_state <= t_data;

          --Send data LSB first
          when t_data =>
            tx <= tx_register(sent_bits);
            sent_bits := sent_bits + 1;
            if sent_bits = 8 then
              tx_state <= t_stop_bit;
              sent_bits := 0;
            end if;
          
          when t_stop_bit =>
            tx <= '1';
            tx_state <= t_idle;  

        end case;        
      end if;
    end if;
  end process transmit;

end architecture rtl;