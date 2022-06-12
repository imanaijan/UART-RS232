library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity transmitter is
	port(
		clk_i: in std_logic;   --синхросигнал
		reset_i: in std_logic; --асинхронный сброс
		duration_i: in std_logic_vector(15 downto 0); --длительность такта работы уарт
		load_duration_i: in std_logic;                --сигнал загрузки длительности

		data_byte_i: in std_logic_vector(7 downto 0); --байт данных, который будем передавать
		load_data_i: in std_logic;                    --сигнал загрузки данных
		
		data_o: out std_logic                        --передача бита через уарт
    );
end transmitter;

architecture transmitter_arch of transmitter is
	type transmitter_state is (s_wait_duration, s_idle, s_start_bit, s_data_bit, s_end_bit);
	
	signal state_r: transmitter_state;

	signal duration_r: std_logic_vector(15 downto 0);
	
	signal bit_current_duration_r: std_logic_vector(15 downto 0);
	signal bit_read_number: std_logic_vector(2 downto 0);
	
	signal data_r: std_logic_vector(7 downto 0);

begin

	--процесс, отвечающий за переключение состояний
	process (clk_i, reset_i) begin
		if reset_i = '1' then
			state_r <= s_wait_duration;
		else
			if clk_i = '1' and clk_i'event then
				case state_r is
					when s_wait_duration =>
						if load_duration_i = '1' then
							state_r <= s_idle;
						end if;
					when s_idle =>
						if load_data_i = '1' then
							state_r <= s_start_bit;
						end if;
					when s_start_bit =>
						if bit_current_duration_r = x"0000" then
							state_r <= s_data_bit;
						end if;
					when s_data_bit =>
						if bit_current_duration_r = x"0000" then
							if bit_read_number = "000" then
								state_r <= s_end_bit;
							end if;
						end if;
					when s_end_bit =>
						if bit_current_duration_r = x"0000" then
							state_r <= s_idle;
						end if;
				end case;
			end if;
		end if;
	end process;

	--процесс со счетчиками
	process (clk_i, reset_i) begin
		if reset_i = '1' then
			data_o <= '1';
			duration_r <= x"0000";
			bit_current_duration_r <= x"0000";
			bit_read_number <= "000";
			data_r <= x"00";
		else
			if clk_i = '1' and clk_i'event then
				case state_r is
					when s_wait_duration =>
						if load_duration_i = '1' then
							duration_r <= duration_i;
						end if;
						data_o <= '1';
					when s_idle =>
						if load_data_i = '1' then
							data_r <= data_byte_i;
							bit_current_duration_r <= duration_r - 1;
						end if;
						data_o <= '1';
					when s_start_bit =>
						if bit_current_duration_r /= x"0000" then
							bit_current_duration_r <= bit_current_duration_r - 1;
						else
							bit_current_duration_r <= duration_r - 1;
							bit_read_number <= "111";
						end if;
						data_o <= '0';
					when s_data_bit =>
						if bit_current_duration_r = duration_r - 1 then
							data_o <= data_r(conv_integer(bit_read_number));
						end if;
						if bit_current_duration_r = x"0000" then
							bit_read_number <= bit_read_number - 1;
							bit_current_duration_r <= duration_r - 1;
						else
							bit_current_duration_r <= bit_current_duration_r - 1;
						end if;
					when s_end_bit =>
						if bit_current_duration_r /= x"0000" then
							bit_current_duration_r <= bit_current_duration_r - 1;
						end if;
						data_o <= '1';
				end case;
			end if;
		end if;
	end process;

end architecture;
