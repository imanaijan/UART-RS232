library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity reciver is
	port(
		clk_i: in std_logic;   --синхросигнал
		reset_i: in std_logic; --асинхронный сброс

		duration_o: out std_logic_vector(15 downto 0);     --рассчитанная длительность
		duration_particullary_calculated_o: out std_logic; --признак того, что прошел один цикл рассчета длительности
		duration_calculated_o: out std_logic;              --признак того, что длительность рассчитана 

		data_i: in std_logic;                          --данные, передающиеся по разряду
		data_byte_o: out std_logic_vector(7 downto 0); --результирующие данные
		data_ready_o: out std_logic                    --флаг готовности данных
    );
end reciver;

architecture reciver_arch of reciver is

	type reciver_state is (s_before_counting, s_counting, s_idle, s_start_bit, s_data_bit, s_end_bit);
	
	signal state_r: reciver_state;
	signal bit_counter_number_r: std_logic_vector(1 downto 0);
	
	signal counter_r: std_logic_vector(17 downto 0);
	signal duration_r: std_logic_vector(15 downto 0);
	signal duration_half_r: std_logic_vector(15 downto 0);
	
	signal bit_current_duration_r: std_logic_vector(15 downto 0);
	signal bit_read_number: std_logic_vector(2 downto 0);
	
	signal data_r: std_logic_vector(7 downto 0);
	
begin

	duration_r <= counter_r(17 downto 2);
	duration_half_r <= '0' & duration_r(15 downto 1);

	--процесс, отвечающий за переход из одного состояния в другое
	process (clk_i, reset_i) begin
		if reset_i = '1' then
			state_r <= s_before_counting;
		else
			if clk_i = '1' and clk_i'event then
				case state_r is
					when s_before_counting =>
						if data_i = '0' then
							state_r <= s_counting;
						end if;
					when s_counting =>
						if data_i = '1' then
							if bit_counter_number_r = "11" then
								state_r <= s_idle;
							else
								state_r <= s_before_counting;
							end if;
						end if;
					when s_idle =>
						if data_i = '0' then
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

	--процесс, отвечающий за счетчики и расчет различных значений
	process (clk_i, reset_i) begin
		if reset_i = '1' then
			counter_r <= "00" & x"0000";
			duration_calculated_o <= '0';
			duration_particullary_calculated_o <= '0';
			duration_o <= x"0000";
			data_byte_o <= x"00";
			data_ready_o <= '0';
			bit_counter_number_r <= "00";
			bit_current_duration_r <= x"0000";
			bit_read_number <= "000";
			data_r <= x"00";
		else
			if clk_i = '1' and clk_i'event then
				case state_r is
					when s_before_counting =>
						duration_particullary_calculated_o <= '0';
						if data_i = '0' then
							counter_r <= counter_r + 1;
						end if;
					when s_counting =>
						if data_i = '0' then
							counter_r <= counter_r + 1;
						else
							if bit_counter_number_r = "11" then
								duration_o <= duration_r;
								duration_calculated_o <= '1';
							else
								duration_particullary_calculated_o <= '1';
								bit_counter_number_r <= bit_counter_number_r + 1;
							end if;
						end if;
					when s_idle =>
						duration_calculated_o <='0';
						data_ready_o <= '0';
						if data_i = '0' then
							bit_current_duration_r <= duration_r - 1;
						end if;
					when s_start_bit =>
						if bit_current_duration_r /= x"0000" then
							bit_current_duration_r <= bit_current_duration_r - 1;
						else
							bit_current_duration_r <= duration_r - 1;
							bit_read_number <= "111";
						end if;
					when s_data_bit =>
						if bit_current_duration_r = duration_half_r then
							data_r(conv_integer(bit_read_number)) <= data_i;
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
						else
							data_byte_o <= data_r;
							data_ready_o <= '1';
						end if;
				end case;
			end if;
		end if;
	end process;

end architecture reciver_arch;