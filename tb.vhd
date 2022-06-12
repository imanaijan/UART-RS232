library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb is
end tb;

architecture tb_arch of tb is
	component tester
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
	end component;
	
	component top
		port(
			clk_i_near: in std_logic;
			clk_i_far: in std_logic;
			reset_near_i: in std_logic;
			reset_far_i: in std_logic;
			
			duration_i: in std_logic_vector(15 downto 0); --длительность
			load_duration_i: in std_logic;                --сигнал загрузки в ближний трансмиттер и ресивер
			
			data_byte_near_i: in std_logic_vector(7 downto 0); --данные, которые будем передавать
			load_data_near_i: in std_logic;
		
			data_byte_far_i: in std_logic_vector(7 downto 0); --данные, которые будем передавать
			load_data_far_i: in std_logic;
			
			data_byte_near_o: out std_logic_vector(7 downto 0); --данные, которые получили обратно через цикл
			data_ready_near_o: out std_logic; --признак получения данных

			data_byte_far_o: out std_logic_vector(7 downto 0); --данные, которые получили обратно через цикл
			data_ready_far_o: out std_logic; --признак получения данных

			duration_particullary_calculated_far_o: out std_logic; --признак того, что прошел один цикл рассчета длительности
			duration_calculated_far_o: out std_logic;              --признак того, что длительность рассчитана 

			duration_particullary_calculated_near_o: out std_logic; --признак того, что прошел один цикл рассчета длительности
			duration_calculated_near_o: out std_logic               --признак того, что длительность рассчитана 
		);
	end component;
	
	signal clk_1: std_logic;
	signal clk_2: std_logic;
	signal reset: std_logic;
	signal duration: std_logic_vector(15 downto 0);
	signal load_duration: std_logic;
	signal send_data_near: std_logic_vector(7 downto 0);
	signal load_send_data_near: std_logic;
	signal send_data_far: std_logic_vector(7 downto 0);
	signal load_send_data_far: std_logic;
	signal get_data_near: std_logic_vector(7 downto 0);
	signal ready_get_data_near: std_logic;
	signal get_data_far: std_logic_vector(7 downto 0);
	signal ready_get_data_far: std_logic;
	signal duration_particullary_calculated_far: std_logic;
	signal duration_calculated_far: std_logic;
	signal duration_particullary_calculated_near: std_logic;
	signal duration_calculated_near: std_logic;
	signal test_index: integer;
begin
	
	test: tester
	port map(
		clk_o_1 => clk_1,
		clk_o_2 => clk_2,
		reset_o => reset,

		duration_o => duration,
		load_duration_o => load_duration,

		data_byte_near_o => send_data_near,
		load_data_near_o => load_send_data_near,

		data_byte_far_o => send_data_far,
		load_data_far_o => load_send_data_far,

		data_byte_near_i => get_data_near,
		data_ready_near_i => ready_get_data_near,

		data_byte_far_i => get_data_far,
		data_ready_far_i => ready_get_data_far,

		duration_particullary_calculated_far_i => duration_particullary_calculated_far,
		duration_calculated_far_i => duration_calculated_far,
		
		duration_particullary_calculated_near_i => duration_particullary_calculated_near,
		duration_calculated_near_i => duration_calculated_near,
		
		test_index_o => test_index
	);
	
	uut: top
	port map(
		clk_i_near => clk_1,
		clk_i_far => clk_2,
		reset_near_i => reset,
		reset_far_i => reset,
		
		duration_i => duration,
		load_duration_i => load_duration,
		
		data_byte_near_i => send_data_near,
		load_data_near_i => load_send_data_near,

		data_byte_far_i => send_data_far,
		load_data_far_i => load_send_data_far,
		
		data_byte_near_o => get_data_near,
		data_ready_near_o => ready_get_data_near,
		
		data_byte_far_o => get_data_far,
		data_ready_far_o => ready_get_data_far,

		duration_particullary_calculated_far_o => duration_particullary_calculated_far,
		duration_calculated_far_o => duration_calculated_far,

		duration_particullary_calculated_near_o => duration_particullary_calculated_near,
		duration_calculated_near_o => duration_calculated_near
	);

end tb_arch;