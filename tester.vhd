library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tester is
	port(
		clk_o_1: out std_logic;
		clk_o_2: out std_logic;
		reset_o: out std_logic;

		duration_o: out std_logic_vector(15 downto 0);
		load_duration_o: out std_logic;

		data_byte_near_o: out std_logic_vector(7 downto 0);
		load_data_near_o: out std_logic;

		data_byte_far_o: out std_logic_vector(7 downto 0);
		load_data_far_o: out std_logic;

		data_byte_near_i: in std_logic_vector(7 downto 0);
		data_ready_near_i: in std_logic;

		data_byte_far_i: in std_logic_vector(7 downto 0);
		data_ready_far_i: in std_logic;
		
		duration_particullary_calculated_far_i: in std_logic; --признак того, что прошел один цикл рассчета длительности
		duration_calculated_far_i: in std_logic;

		duration_particullary_calculated_near_i: in std_logic; --признак того, что прошел один цикл рассчета длительности
		duration_calculated_near_i: in std_logic;
		
		test_index_o: out integer
	);
end tester;

architecture tester_arch of tester is
	
	procedure make_test(
		constant test_index: in integer;
		constant clk_p: in time;
		constant send_data: in std_logic_vector(7 downto 0);
		constant is_calculating_phase: in boolean;
		signal current_duration: in std_logic_vector(15 downto 0);
		signal data_ready_i: in std_logic;
		signal duration_particullary_calculated_i: in std_logic; --признак того, что прошел один цикл рассчета длительности
		signal duration_calculated_i: in std_logic;
		signal data_byte_o: out std_logic_vector(7 downto 0);
		signal load_data_o: out std_logic;
		signal test_index_o: out integer
	)
		is 
	begin
		wait for clk_p;
		data_byte_o <= send_data;
		load_data_o <= '1';
		wait for clk_p;
		load_data_o <= '0';
		if is_calculating_phase then
			wait until duration_particullary_calculated_i'event or duration_calculated_i'event;
			wait for clk_p * 9 * conv_integer(current_duration);
		else
			wait until data_ready_i'event;
		end if;
		
		test_index_o <= test_index;
		
		wait for clk_p;
	end make_test;
	
	signal clk_r_1: std_logic := '0';
	signal clk_r_2: std_logic := '0';
	constant clk_p_1: time := 10 ns;
	constant clk_p_2: time := 35 ns;
	
	signal reset_r: std_logic := '0';
	signal current_duration: std_logic_vector(15 downto 0);
	signal far_duration: std_logic_vector(15 downto 0);

begin

	clk_r_1 <= not clk_r_1 after clk_p_1 / 2;
	clk_o_1 <= clk_r_1;
	
	clk_r_2 <= not clk_r_2 after clk_p_2 / 2;
	clk_o_2 <= clk_r_2;

	reset_o <= reset_r;
	duration_o <= current_duration;
	far_duration <= x"0006";

	process begin
		test_index_o <= 0;
		reset_r <= '1';
		load_duration_o <= '0';
		load_data_near_o <= '0';
		data_byte_near_o <= x"00";
		load_data_far_o <= '0';
		data_byte_far_o <= x"00";
		current_duration <= x"0000";
		wait for (clk_p_1 + clk_p_2) * 4;
		reset_r <= '0';		
		wait for clk_p_1;
		load_duration_o <= '1';
		current_duration <= x"0015";
		wait for clk_p_1;
		load_duration_o <= '0';
		
		make_test(1, clk_p_1, x"FF", true, current_duration,
			data_ready_far_i, duration_particullary_calculated_far_i, duration_calculated_far_i, 
			data_byte_near_o, load_data_near_o, test_index_o);

		make_test(2, clk_p_1, x"FF", true, current_duration,
			data_ready_far_i, duration_particullary_calculated_far_i, duration_calculated_far_i,
			data_byte_near_o, load_data_near_o, test_index_o);

		make_test(3, clk_p_1, x"FF", true, current_duration,
			data_ready_far_i, duration_particullary_calculated_far_i, duration_calculated_far_i,
			data_byte_near_o, load_data_near_o, test_index_o);

		make_test(4, clk_p_1, x"FF", true, current_duration,
			data_ready_far_i, duration_particullary_calculated_far_i, duration_calculated_far_i,
			data_byte_near_o, load_data_near_o, test_index_o);

		make_test(5, clk_p_2, x"FF", true, far_duration,
			data_ready_far_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_far_o, load_data_far_o, test_index_o);
			
		make_test(6, clk_p_2, x"FF", true, far_duration,
			data_ready_far_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_far_o, load_data_far_o, test_index_o);

		make_test(7, clk_p_2, x"FF", true, far_duration,
			data_ready_far_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_far_o, load_data_far_o, test_index_o);

		make_test(8, clk_p_2, x"FF", true, far_duration,
			data_ready_far_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_far_o, load_data_far_o, test_index_o);

		make_test(9, clk_p_1, x"6C", false, current_duration,
			data_ready_far_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_near_o, load_data_near_o, test_index_o);

		make_test(10, clk_p_1, x"5A", false, current_duration,
			data_ready_far_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_near_o, load_data_near_o, test_index_o);

		make_test(9, clk_p_2, x"7B", false, current_duration,
			data_ready_near_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_far_o, load_data_far_o, test_index_o);

		make_test(10, clk_p_2, x"36", false, current_duration,
			data_ready_near_i, duration_particullary_calculated_near_i, duration_calculated_near_i,
			data_byte_far_o, load_data_far_o, test_index_o);

		wait;
	end process;

end architecture tester_arch;